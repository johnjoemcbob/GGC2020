--
-- GGC2020_johnjoemcbob
-- 01/06/20
--
-- Shared Ship Entity
--

AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "GGC2020_johnjoemcbob Ship"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "2DPos" )
	self:NetworkVar( "Vector", 1, "2DVelocity" )
	self:NetworkVar( "Float", 0, "2DRotation" )
	-- self:NetworkVar( "Float", 1, "2DSpeed" )
	self:NetworkVar( "Int", 0, "Index" )

	-- self:SetIndex( -1 )
	local range = 20
	self:Set2DPos( Vector( math.random( -range, range ), math.random( -range, range ) ) )
	self:Set2DVelocity( Vector( 0, 0 ) )
	self:Set2DRotation( 0 )
	-- self:Set2DSpeed( 0 )
end

function ENT:Initialize()
	if ( SERVER ) then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:SetNoDraw( true )
	end

	self.Parts = {}
	self.CurrentCollisions = {}
	self.LateInitialized = false
	self.Speed = 0
	self.RotateSpeed = 0
	self.RotateDirection = 0

	self.Multiplier = 4
	self.SideSpeedMult = 0.02
	self.Acceleration = 100 * self.Multiplier
	self.RotateAcceleration = 10 * self.Multiplier
	self.Decceleration = 100 * self.Multiplier
	self.MaxSpeed = 100 * self.Multiplier
	self.MaxRotateSpeed = 0.5 * self.Multiplier
	self.MaxVelocity = 1000 * self.Multiplier
end

DEBUG = true
function ENT:MoveInput( ply )
	if ( !DEBUG and tablelength( self.CurrentCollisions ) > 0 ) then return end

	-- TODO TEMP
	self.SideSpeedMult = 0.02
	self.MaxVelocity = 100 * self.Multiplier
	self.MaxRotateSpeed = 0.5 * self.Multiplier

	-- Drag/Dampen?
	self:Set2DVelocity( ApproachVector( FrameTime() * self.Decceleration, self:Get2DVelocity(), Vector( 0, 0, 0 ) ) )

	-- Input
	local moving = false
		if ( ply:KeyDown( IN_FORWARD ) ) then
			self:AddMove( self:Forward() * ( self.Speed + FrameTime() * self.Decceleration ) )
			moving = true
		end
		if ( ply:KeyDown( IN_BACK ) ) then
			self:AddMove( -self:Forward() * ( self.Speed + FrameTime() * self.Decceleration ) )
			moving = true
		end
		local right = self:Right() * ( self.Speed + FrameTime() * self.Decceleration ) * self.SideSpeedMult
		if ( ply:KeyDown( IN_MOVERIGHT ) ) then
			self:AddMove( right )
			self.RotateDirection = 1
			moving = true
		elseif ( ply:KeyDown( IN_MOVELEFT ) ) then
			self:AddMove( -right )
			self.RotateDirection = -1
			moving = true
		else
			self.RotateDirection = 0
		end

	-- Acceleration
	local target = self.MaxSpeed
		if ( !moving ) then
			target = 0
		end
	self.Speed = Lerp( FrameTime() * self.Acceleration, self.Speed, target )
	local target = self.MaxRotateSpeed * self.RotateDirection
		if ( !moving ) then
			target = 0
		end
	self.RotateSpeed = Lerp( FrameTime() * self.RotateAcceleration, self.RotateSpeed, target )
	self:Set2DRotation( self:Get2DRotation() + self.RotateSpeed )
end

function ENT:AddMove( add )
	self:Set2DVelocity(
		-- self:Get2DVelocity() + add
		Clamp2DVectorLength(
			self:Get2DVelocity() + add,
			-self.MaxVelocity,
			self.MaxVelocity
		)
	)
end

function ENT:Think()
	if ( self:GetIndex() == 3 ) then
		-- self:Set2DRotation( self:Get2DRotation() + 1 )
	end

	-- self:Set2DPos( Vector( 0, 0 ) )
	if ( self:GetIndex() != -1 and !self.LateInitialized ) then
		Ship.Ship[self:GetIndex()] = self
		if( SERVER ) then
			Ship:SendToClient( self )
		end

		self.LateInitialized = true
	end

	-- Calculate the max bounds of the ship to get center
	if ( !self.Size and self.Constructor ) then
		local min = Vector( 100, 100 )
		local max = Vector( 0, 0 )
			for k, part in pairs( self.Constructor ) do
				if ( part.Grid.x < min.x ) then
					min.x = part.Grid.x
				end
				if ( part.Grid.x > max.x ) then
					max.x = part.Grid.x
				end
				if ( part.Grid.y < min.y ) then
					min.y = part.Grid.y
				end
				if ( part.Grid.y > max.y ) then
					max.y = part.Grid.y
				end
			end
		self.Min = min
		self.Max = max
		self.Size = Vector( max.x - min.x, max.y - min.y )
	end

	-- Move & then collision detect
	if ( SERVER ) then
		self:Set2DPos( self:Get2DPos() + self:Get2DVelocity() * FrameTime() )

		local collisions = Ship:CheckCollision( self )
		for collide, bool in pairs( collisions ) do
			if ( self.CurrentCollisions[collide] ) then
				self:OnCollisionStay( collide )
			else
				self:OnCollisionStart( collide )

				self.CurrentCollisions[collide] = self:Get2DPos() - Ship.Ship[collide]:Get2DPos()
			end
		end
		local remove = {}
		for old, bool in pairs( self.CurrentCollisions ) do
			if ( !collisions[old] ) then
				self:OnCollisionFinish( old )

				remove[old] = true
			end
		end
		for rmv, bool in pairs( remove ) do
			self.CurrentCollisions[rmv] = nil
		end
	end
end

function ENT:OnCollisionStart( other )
	-- Temp measure to only board in one direction
	-- if ( self:GetIndex() > other ) then
	if ( false ) then
		-- Board!!
		for k, ply in pairs( player.GetAll() ) do
			if ( ply:GetNWInt( "CurrentShip" ) == self:GetIndex() ) then
				if ( ply:InVehicle() ) then
					ply:ExitVehicle()
				end
				ply:SetPos( Ship.Ship[other].SpawnPoint )
				PrintMessage( HUD_PRINTCENTER, "NOW BOARDING" )
			end
		end

		-- Spawn enemies
		for _, pos in pairs( Ship.Ship[other].EnemySpawners ) do
			local npc = GAMEMODE.CreateEnt( "npc_combine_s", nil, pos, Angle( 0, 0, 0 ) )
				npc:Give( "weapon_ar2" )
				-- npc:Give( "ggcj_weapon_base" )
				npc:SetHealth( 20 )
			table.insert( Ship.Ship[other].Parts, npc )
		end

		-- Temp: Close doors
		for k, ent in pairs( ents.FindByClass( "ggcj_door" ) ) do
			ent:Toggle( false )
		end
	end

	-- Shake
	for k, v in pairs( player.GetAll() ) do
		if ( v:GetNWInt( "CurrentShip" ) == self:GetIndex() ) then
			util.ScreenShake( Vector( 0, 0, 0 ), 5, 5, 1, 5000 )
		end
	end

	-- Sound
	self:EmitSound( "physics/metal/metal_large_debris" .. math.random( 1, 2 ) .. ".wav" )

	-- Don't go inside
	if ( !DEBUG ) then
		self:Set2DVelocity( -self:Get2DVelocity() )
	end
end

function ENT:OnCollisionStay( other )
	-- Push back from other ship
	if ( !DEBUG ) then
		local othership = Ship.Ship[other]
		self:AddMove( self.CurrentCollisions[other] * 50 )
	end
end

function ENT:OnCollisionFinish( other )
	if ( !DEBUG ) then
		self:Set2DVelocity( Vector( 0, 0 ) )
	end
end

if ( CLIENT ) then
	function ENT:HUDPaint( x, y, scale, col )
		col = table.shallowcopy( col ) -- TODO TEMP REMOVE
		col.a = 100 -- TODO TEMP REMOVE

		local cellsize = SHIPPART_SIZE_2D
		if ( self.Constructor and self.Pos ) then
			local mat = Matrix()
				if ( self.Pos != Vector( 0, 0, 0 ) ) then
					-- Translate back onto vgui
					mat:Rotate( Angle( 0, 0, 90 ) )
					-- print( self.Pos.x )
					-- mat:Translate( Vector( self.Pos.x / 3.5, self.Pos.z + 60, -self.Pos.y ) )
					mat:Translate( Vector( -640, self.Pos.z + 60, -self.Pos.y ) )
					mat:Scale( Vector( 1, 1, 1 ) * 0.4 )

					-- Translate this ship
					mat:Translate( Vector( x, -y ) / 0.4 )
					mat:Rotate( Angle( 0, -self:Get2DRotation(), 0 ) )
					mat:Translate( Vector(
						-( ( self.Size.x / 2 + self.Min.x ) * cellsize ),
						-( ( self.Size.y / 2 + self.Min.y ) * cellsize )
					) / 0.4 )
				else
					-- Translate this ship
					mat:Translate( Vector( x, y ) )
					mat:Rotate( Angle( 0, self:Get2DRotation(), 0 ) )
					mat:Translate( Vector(
						-( ( self.Size.x / 2 + self.Min.x ) * cellsize ),
						-( ( self.Size.y / 2 + self.Min.y ) * cellsize )
					) )
				end
			cam.PushModelMatrix( mat )
				local index = 0
				for k, part in pairs( self.Constructor ) do
					local w = cellsize * SHIPPARTS[part.Name][2].x
					local h = cellsize * SHIPPARTS[part.Name][2].y

					surface.SetDrawColor( col )
					SHIPPARTS[part.Name][4](
						part,
						( part.Grid.x ) * cellsize,
						( part.Grid.y ) * cellsize,
						w, h
					)
				end
			cam.PopModelMatrix()
		end

		-- local x = gui.MouseX()
		-- local y = gui.MouseY()
		-- surface.DrawRect(
			-- x,
			-- y,
			-- 32, 32
		-- )
		-- local dir = ( Vector( 100, 100 ) - Vector( x, y ) ):GetNormalized()
		-- self:Set2DRotation( -math.atan2( dir.x, dir.y ) * 180 / math.pi )
		-- surface.DrawLine( x, y, x + dir.x * 32, y + dir.y * 32 )
		-- print( dir )
		-- draw.SimpleText( dir, "DermaDefault", x, y + 32 * self:GetIndex(), Color( 255, 255, 255, 10 ) )
		-- draw.SimpleText( self:Get2DVelocity(), "DermaDefault", x, y + 44, Color( 255, 255, 255, 10 ) )
	end
end

function ENT:GetPosFrom2D()
	local pos = self:Get2DPos()
		pos.x = -pos.x
		pos.z = self:GetMapPos().z
	return pos
end

function ENT:GetMapPos()
	return Vector( 100, 48, SHIPEDITOR_ORIGIN( self:GetIndex() ).z + 40 )
end

function ENT:Forward()
	return Angle( 0, self:Get2DRotation(), 0 ):Right()
	-- return Vector( 0, -1, 0 )
end
function ENT:Right()
	return Angle( 0, self:Get2DRotation(), 0 ):Forward()
	-- return Vector( 1, 0, 0 )
end