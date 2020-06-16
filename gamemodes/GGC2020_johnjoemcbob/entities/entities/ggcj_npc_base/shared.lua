--
-- GGC2020_johnjoemcbob
-- 16/06/20
--
-- Shared Base NPC Entity
--

AddCSLuaFile()

ENT.Base = "base_nextbot"

function ENT:RunBehaviour()
	-- Start coroutine loop
	while ( true ) do
		-- Move towards the target enemy if one has been found
		if ( self:HaveEnemy() ) then
			-- Visuals
			self:StartActivity( ACT_RUN )

			-- Speed
			self.loco:SetDesiredSpeed( self.Speed )
			self.loco:SetAcceleration( self.Speed * 2 )

			-- Run in a straight line if there is a clear path to the target, otherwise pathfind
			-- local tr = self:GetTrace( self:GetEnemy() )
			-- if ( tr.Entity == self:GetEnemy() ) then
				-- self:SetEyeTarget( self:GetEnemy():GetPos() )
				-- self:MoveDirectlyToEnemy()
			-- else
				self.loco:FaceTowards( self:GetEnemy():GetPos() )
				self:ChaseEnemy()
			-- end

			-- Remove safely when flagged
			if ( self.ToRemove ) then
				self:Remove()
				return
			end
		end

		coroutine.wait( 0.1 )
	end
end

function ENT:OnStuck()
	self:SetPos( self:GetPos() + VectorRand() * 2 )
end

function ENT:IsNPC()
	return true
end

-- Move in a straight line towards the player until reached or path impeded
function ENT:MoveDirectlyToEnemy()
	while ( self:HaveEnemy() ) do
		local tr = self:GetTrace( self:GetEnemy() )
		local along_ground = tr.Normal * 5 * FrameTime() * self.Speed
			along_ground.z = 0
		self:SetPos( self:GetPos() + along_ground )

		if ( tr.Entity != self:GetEnemy() ) then
			return "ok"
		end

		local dist = self:GetPos():Distance( self:GetEnemy():GetPos() )
		if ( dist < 10 ) then
			return "ok"
		end

		self:MoveCallback()

		coroutine.yield()
	end
end

----------------------------------------------------
-- ENT:ChaseEnemy()
-- Works similarly to Garry's MoveToPos function
-- except it will constantly follow the
-- position of the enemy until there no longer
-- is one.
----------------------------------------------------
function ENT:ChaseEnemy( options )
	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		-- Compute the path towards the enemies position

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:HaveEnemy() ) do
		-- Speed
		self.loco:SetDesiredSpeed( self.Speed )
		self.loco:SetAcceleration( self.Speed * 2 )

		-- Since we are following the player we have to constantly remake the path
		if ( path:GetAge() > 0.1 ) then					
			path:Compute( self, self:GetEnemy():GetPos() )
		end
		if ( self.Speed != 0 ) then
			path:Update( self ) -- This function moves the bot along the path
		end

		if ( options.draw ) then path:Draw() end

		-- If we're stuck, then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		-- If there is a direct line of sight to the player, we don't need pathfinding
		-- local tr = self:GetTrace( self:GetEnemy() )
		-- if ( tr.Entity == self:GetEnemy() ) then
			-- return "ok"
		-- end

		self:MoveCallback()

		coroutine.yield()
	end

	return "ok"
end

function ENT:MoveCallback()
	-- Note: This should be a virtual function, this logic in specific npc class instead
end

----------------------------------------------------
-- ENT:FindEnemy()
-- Returns true and sets our enemy if we find one
----------------------------------------------------
function ENT:FindEnemy()
	-- print( "find" )
	local possibletargets = {}
	for k, v in pairs( player.GetAll() ) do
		-- Check if there is line of sight between the enemy and the player
		local tr = self:GetTrace( v )
		-- if ( v:GetPos():Distance( self:GetPos() ) < 100 ) then
			-- print( tr.Entity )
		-- end
		if ( tr.Entity == v ) then
			table.insert( possibletargets, v )
		end
	end
	if ( #possibletargets > 0 ) then
		-- We found one so lets set it as our enemy and return true
		self:SetEnemy( possibletargets[math.random( 1, #possibletargets ) ] )
		return true
	end
	-- We found nothing so we will set our enemy as nil ( nothing ) and return false
	self:SetEnemy( nil )
	return false
end

----------------------------------------------------
-- ENT:Get/SetEnemy()
-- Simple functions used in keeping our enemy saved
----------------------------------------------------
function ENT:SetEnemy( ent )
	local temp = self.Enemy
	self.Enemy = ent
	if ( ent and ent:IsValid() ) then
		self:OnNewEnemy()
	elseif ( temp and temp:IsValid() ) then
		self:OnNoEnemy()
	end
end
function ENT:GetEnemy()
	return self.Enemy
end

function ENT:OnNewEnemy()
end
function ENT:OnNoEnemy()
end

----------------------------------------------------
-- ENT:HaveEnemy()
-- Returns true if we have a enemy
----------------------------------------------------
function ENT:HaveEnemy()
	-- If our current enemy is valid
	if ( self:GetEnemy() and IsValid( self:GetEnemy() ) ) then
		-- If the enemy is too far
		-- if ( self:GetRangeTo( self:GetEnemy():GetPos() ) > self.LoseTargetDist ) then
			-- If the enemy is lost then call FindEnemy() to look for a new one
			-- FindEnemy() will return true if an enemy is found, making this function return true
			-- return self:FindEnemy()
		-- If the enemy is dead( we have to check if its a player before we use Alive() )
		if ( self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive() ) then
			self:SetEnemy( nil )
			return self:FindEnemy()		-- Return false if the search finds nothing
		end
		-- The enemy is neither too far nor too dead so we can return true
		return true
	else
		-- The enemy isn't valid so lets look for a new one
		return self:FindEnemy()
	end
end

function ENT:GetTraceData( target )
	local up = Vector( 0, 0, 20 )
	local postarget = target:GetPos()
	local dir = ( postarget - self:GetPos() ):GetNormalized()
	return {
		start = self:GetPos() + up + dir * 50,
		endpos = postarget + up + dir * 50,
	}
end

function ENT:GetTrace( target )
	local trdata = self:GetTraceData( target )
	-- debugoverlay.Line( trdata.start, trdata.endpos, 0.04, Color( 255, 255, 255, 255 ), true )
	return util.TraceLine( trdata )
end

function ENT:GetCollideTrace( target )
	local trdata = self:GetTraceData( target )
	return util.TraceEntity( trdata, self )
end

if ( SERVER ) then
	function ENT:OnInjured( dmg )
		self.LastDmgInfo = dmg
		self:SetNWFloat( "LastDamage", CurTime() )

		local min, max = self:GetCollisionBounds()
		GAMEMODE.AddWorldText(
			self:GetPos() +
				Vector( 0, 0, 1 ) * max.z * 1.2 +
				dmg:GetAttacker():EyeAngles():Right() * math.random( -20, 20 ) +
				dmg:GetAttacker():EyeAngles():Up() * math.random( -15, 15 ) +
				dmg:GetAttacker():EyeAngles():Forward() * -5,
			Vector( 0, 0, 1 ),
			Angle( 0, 0, 0 ),
			1,
			dmg:GetDamage(),
			Color( 255, 0, 0, 255 ),
			0.5,
			false
		)
	end

	function ENT:OnKilled( dmginfo )
		hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )

		self.Killer = dmginfo:GetAttacker()
		self:Remove()
	end
end
