--
-- GGC2020_johnjoemcbob
-- 16/06/20
--
-- Shared NPC Entity - Shrieker
--

AddCSLuaFile()

ENT.Base 			= "ggcj_npc_base"
ENT.Spawnable		= true

list.Set( "NPC", "ggcj_npc_shrieker", {
	Name = "Shrieker",
	Class = "ggcj_npc_shrieker",
	Category = "GGCJ"
} )

ENEMY_SHRIEKER_SIZE = 128

local INITIALIZED = false
MAT_ENEMY_SHRIEKER = {}
	MAT_ENEMY_SHRIEKER["idle"] = {
		Frames = 7,
		Between = 0.2,
	}
	MAT_ENEMY_SHRIEKER["in"] = {
		Frames = 6,
		Between = 0.1,
	}
	MAT_ENEMY_SHRIEKER["out"] = {
		Frames = 7,
		Between = 0.1,
	}
	MAT_ENEMY_SHRIEKER["attack"] = {
		Frames = 4,
		Between = 0.1,
	}

local width = ENEMY_SHRIEKER_SIZE / 2
local height = ENEMY_SHRIEKER_SIZE * 0.7
local offground = 0
ENEMY_SHRIEKER_PHYS_MIN = Vector( -width / 2, -width / 2, offground )
ENEMY_SHRIEKER_PHYS_MAX = Vector( width / 2, width / 2, offground + height )

function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube8x8x8.mdl" )

	-- Collision
	self:SetCollisionBounds( ENEMY_SHRIEKER_PHYS_MIN, ENEMY_SHRIEKER_PHYS_MAX )
	self:SetSolid( SOLID_BBOX )
	if ( CLIENT ) then
		self:SetRenderBounds( ENEMY_SHRIEKER_PHYS_MIN, ENEMY_SHRIEKER_PHYS_MAX )
	end
	self:DrawShadow( false )

	self.LoseTargetDist	= 2000	-- How far the enemy has to be before we lose them
	self.SearchRadius 	= 1000	-- How far to search for enemies

	self:SetHealth( 100 )
	self.BaseSpeed = 100
	self.Speed = self.BaseSpeed
	--								self.Speed = 0 -- TODO TEMP TESTING
	self.Damage = 10
	self.ShriekRange = 200
	self.AttackRange = 500
	self.AttackBetween = 3
	self:SetNWString( "Animation", "idle" )
end

function ENT:OnNewEnemy()
	--self:EmitSound( "npc/antlion_guard/angry1.wav", 130, math.random( 150, 200 ), 1 )
end

function ENT:OnNoEnemy()
end

function ENT:OnRemove()
	self:EmitSound( "ambient/voices/f_scream1.wav", 130, math.random( 170, 200 ), 1 )
end

function ENT:MoveCallback()
	if ( self.NextAttack and self.NextAttack > CurTime() ) then return end

	-- If near any enemy, attack
	for k, v in pairs( player.GetAll() ) do
		local dist = v:GetPos():Distance( self:GetPos() )
		if ( dist <= self.AttackRange ) then
			self:SetEnemy( v )
			if ( self.ShriekerVisible ) then
				self:Attack( v )
				self.NextAttack = CurTime() + self.AttackBetween
			else
				self:ShowSelf()
			end
			return "ok"
		end
	end
end

function ENT:Attack( victim )
	-- Animate
	self:SetNWString( "Animation", "attack" )
	self.Speed = 0

	self:EmitSound( "ambient/voices/f_scream1.wav", 130, math.random( 30, 50 ), 1 )

	-- Attack all close by players
	for k, ent in pairs( ents.FindInSphere( self:GetPos(), self.ShriekRange ) ) do
		if ( ent:IsPlayer() ) then
			ent:TakeDamage( self.Damage, self, self )
			ent:SetVelocity( ( ent:GetPos() - self:GetPos() ):GetNormalized() * 1000 )
		end
	end

	self:HideSelf()
end

function ENT:HideSelf()
	if ( self.Animating ) then return end

	self.Animating = true
	timer.Simple( 0.5, function()
		if ( self and self:IsValid() ) then
			self:SetNWString( "Animation", "out" )
			timer.Simple( ( MAT_ENEMY_SHRIEKER["out"].Frames -1 ) * MAT_ENEMY_SHRIEKER["out"].Between, function()
				if ( self and self:IsValid() ) then
					self.ShriekerVisible = false
					self.Speed = self.BaseSpeed * 10
					--self:SetCollisionBounds( ENEMY_SHRIEKER_PHYS_MIN / 100, ENEMY_SHRIEKER_PHYS_MAX / 100 )
					self.Animating = false
					self:SetNoDraw( true )
				end
			end )
		end
	end )
end

function ENT:ShowSelf()
	if ( self.Animating ) then return end

	self.Animating = true
	self:SetNWString( "Animation", "in" )
	self:SetNoDraw( false )
	self.Speed = 0
	--self:SetCollisionBounds( ENEMY_SHRIEKER_PHYS_MIN, ENEMY_SHRIEKER_PHYS_MAX )
	timer.Simple( MAT_ENEMY_SHRIEKER["in"].Frames * MAT_ENEMY_SHRIEKER["in"].Between, function()
		if ( self and self:IsValid() ) then
			self.ShriekerVisible = true
			self.Animating = false
		end
	end )
end

function ENT:EyePos()
	return self:GetPos() + Vector( 0, 0, 1 ) * 100
end

if ( CLIENT ) then
	function ENT:Draw()
		--self:DrawModel()

		-- Initialize in Draw?? TODO MOVE
		if ( !INITIALIZED ) then
			for k, v in pairs( MAT_ENEMY_SHRIEKER ) do
				v[1] = Material( "enemy/shrieker/" .. k .. ".png", "nocull 1 smooth 0" )
			end
			INITIALIZED = true
		end

		local anim = self:GetNWString( "Animation", "idle" )
		if ( self.Animation != anim ) then
			self.Animation = anim
			self.Frame = 0
			self.NextFrameTime = 0
		end
		local col = COLOUR_WHITE
		local size = ENEMY_SHRIEKER_SIZE
			local dmg = self:GetNWFloat( "LastDamage", 0 )
			if ( dmg + 0.2 >= CurTime() ) then
				local prog = math.sin( CurTime() * 100 )
				size = size + prog * 10
				col = LerpColour( prog, COLOUR_WHITE, Color( 0, 255, 255, 255 ) )
			end
		local offset = size * 0.9
		if ( self.NextFrameTime <= CurTime() ) then
			-- Increment and loop
			self.Frame = self.Frame + 1
			if ( self.Frame > MAT_ENEMY_SHRIEKER[anim].Frames ) then
				self.Frame = 1
			end

			-- Frame specific action functions
			if ( MAT_ENEMY_SHRIEKER[anim].FrameActions and MAT_ENEMY_SHRIEKER[anim].FrameActions[self.Frame] ) then
				MAT_ENEMY_SHRIEKER[anim].FrameActions[self.Frame]( self )
			end

			self.NextFrameTime = CurTime() + MAT_ENEMY_SHRIEKER[anim].Between
		end
		local u1, v1, u2, v2 = GetShriekerUVs( anim, self.Frame )
		local ang = GAMEMODE:GetBillboardAngle()
		render.PushColourModulation( col )
			GAMEMODE:DrawBillboardedUVs(
				self:GetPos() + ang:Up() * offset,
				0,
				Vector( 1, 1 ) * size,
				MAT_ENEMY_SHRIEKER[anim][1],
				u1, v1, u2, v2,
				false
			)
		render.PopColourModulation()

		--render.DrawBox( self:GetPos(), Angle( 0, 0, 0 ), ENEMY_SHRIEKER_PHYS_MIN, ENEMY_SHRIEKER_PHYS_MAX, Color( 255, 0, 255, 100 ) )
	end
end

function GetShriekerUVs( anim, frame )
	local full = MAT_ENEMY_SHRIEKER[anim][1]:Width()
	local per = MAT_ENEMY_SHRIEKER[anim].Frames
	local size = full / per

	local x = math.floor( frame % per )

	local u1 = x * size / full
	local v1 = 0
	local u2 = u1 + size / full
	local v2 = 1

	return u1, v1, u2, v2
end
