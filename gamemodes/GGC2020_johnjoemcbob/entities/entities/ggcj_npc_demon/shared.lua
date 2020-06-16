--
-- GGC2020_johnjoemcbob
-- 16/06/20
--
-- Shared NPC Entity - Demon
--

AddCSLuaFile()

ENT.Base 			= "ggcj_npc_base"
ENT.Spawnable		= true

list.Set( "NPC", "ggcj_npc_demon", {
	Name = "Demon",
	Class = "ggcj_npc_demon",
	Category = "GGCJ"
} )

ENEMY_DEMON_SIZE = 128

local INITIALIZED = false
MAT_ENEMY_DEMON = {}
	MAT_ENEMY_DEMON["idle"] = {
		Frames = 6,
		Between = 0.2,
		FrameActions = {
			[2] = function( self )
				if ( CLIENT ) then
					sound.Play( "ambient/fire/mtov_flame2.wav", self:GetPos(), 95, 100, 1 )
				end
			end,
		},
	}
	MAT_ENEMY_DEMON["attack"] = {
		Frames = 8,
		Between = 0.1,
	}
	MAT_ENEMY_DEMON["breath"] = {
		Frames = 5,
		Between = 0.1,
	}

local width = ENEMY_DEMON_SIZE / 2
local height = ENEMY_DEMON_SIZE
local offground = 0
ENEMY_DEMON_PHYS_MIN = Vector( -width / 2, -width / 2, offground )
ENEMY_DEMON_PHYS_MAX = Vector( width / 2, width / 2, offground + height )

function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube8x8x8.mdl" )

	-- Collision
	self:SetCollisionBounds( ENEMY_DEMON_PHYS_MIN, ENEMY_DEMON_PHYS_MAX )
	self:SetSolid( SOLID_BBOX )
	if ( CLIENT ) then
		self:SetRenderBounds( ENEMY_DEMON_PHYS_MIN, ENEMY_DEMON_PHYS_MAX )
	end
	self:DrawShadow( false )

	self.LoseTargetDist	= 2000	-- How far the enemy has to be before we lose them
	self.SearchRadius 	= 1000	-- How far to search for enemies

	self:SetHealth( 100 )
	self.BaseSpeed = 250
	self.Speed = self.BaseSpeed
	--								self.Speed = 0 -- TODO TEMP TESTING
	self.AttackRange = 200
	self.AttackBetween = 1
	self:SetNWString( "Animation", "idle" )
end

function ENT:OnNewEnemy()
	self:EmitSound( "npc/antlion_guard/angry1.wav", 130, math.random( 150, 200 ), 1 )
end

function ENT:OnNoEnemy()
end

function ENT:OnRemove()
	--self:EmitSound( "npc/antlion_grub/squashed.wav", 130, math.random( 90, 120 ), 1 )
end

function ENT:MoveCallback()
	if ( self.NextAttack and self.NextAttack > CurTime() ) then return end

	-- If near any enemy, attack
	for k, v in pairs( player.GetAll() ) do
		local dist = v:GetPos():Distance( self:GetPos() )
		if ( dist <= self.AttackRange ) then
			self:SetEnemy( v )
			self:Attack( v )
			self.NextAttack = CurTime() + self.AttackBetween
			return "ok"
		end
	end
end

function ENT:Attack( victim )
	-- Animate
	self:SetNWString( "Animation", "attack" )
	self.Speed = 0

	-- Damage
	local function attack()
		if ( self and self:IsValid() ) then
			if ( victim:GetPos():Distance( self:GetPos() ) <= self.AttackRange ) then
				victim:TakeDamage( 5, self, self )
			end
		end
	end
	timer.Simple( MAT_ENEMY_DEMON["attack"].Between * 3, attack )
	timer.Simple( MAT_ENEMY_DEMON["attack"].Between * 5, attack )
	timer.Simple( MAT_ENEMY_DEMON["attack"].Between * 7, attack )
	timer.Simple( MAT_ENEMY_DEMON["attack"].Between * 2, function()
		if ( self and self:IsValid() ) then
			sound.Play( "ambient/fire/gascan_ignite1.wav", self:GetPos(), 95, 100, 1 )
		end
	end )

	-- Stop
	timer.Simple( MAT_ENEMY_DEMON["attack"].Between * MAT_ENEMY_DEMON["attack"].Frames, function()
		if ( self and self:IsValid() ) then
			self:SetNWString( "Animation", "idle" )
			self.Speed = self.BaseSpeed
		end
	end )
end

if ( CLIENT ) then
	function ENT:Draw()
		--self:DrawModel()
		
		-- Initialize in Draw?? TODO MOVE
		if ( !INITIALIZED ) then
			for k, v in pairs( MAT_ENEMY_DEMON ) do
				v[1] = Material( "enemy/demon/" .. k .. ".png", "nocull 1 smooth 0" )
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
		local size = ENEMY_DEMON_SIZE
			local dmg = self:GetNWFloat( "LastDamage", 0 )
			if ( dmg + 0.2 >= CurTime() ) then
				local prog = math.sin( CurTime() * 100 )
				size = size + prog * 10
				col = LerpColour( prog, COLOUR_WHITE, Color( 0, 255, 255, 255 ) )
			end
		local offset = size * 0.5
		if ( self.NextFrameTime <= CurTime() ) then
			-- Increment and loop
			self.Frame = self.Frame + 1
			if ( self.Frame > MAT_ENEMY_DEMON[anim].Frames ) then
				self.Frame = 1
			end

			-- Frame specific action functions
			if ( MAT_ENEMY_DEMON[anim].FrameActions and MAT_ENEMY_DEMON[anim].FrameActions[self.Frame] ) then
				MAT_ENEMY_DEMON[anim].FrameActions[self.Frame]( self )
			end

			self.NextFrameTime = CurTime() + MAT_ENEMY_DEMON[anim].Between
		end
		local u1, v1, u2, v2 = GetDemonUVs( anim, self.Frame )
		local ang = GAMEMODE:GetBillboardAngle()
		render.PushColourModulation( col )
			GAMEMODE:DrawBillboardedUVs(
				self:GetPos() + ang:Up() * offset,
				0,
				Vector( 1, 1 ) * size,
				MAT_ENEMY_DEMON[anim][1],
				u1, v1, u2, v2,
				false
			)
			local start = 4
			if ( anim == "attack" and self.Frame > start ) then
				local u1, v1, u2, v2 = GetDemonUVs( "breath", self.Frame - start )
				GAMEMODE:DrawBillboardedUVs(
					self:GetPos() + ang:Up() * ( offset + size / 2.5 ) +
					ang:Forward() * size / 2.5 +
					ang:Right() * 1,
					0,
					Vector( 1, 1 ) * size,
					MAT_ENEMY_DEMON["breath"][1],
					u1, v1, u2, v2,
					false
				)
			end
		render.PopColourModulation()

		--render.DrawBox( self:GetPos(), Angle( 0, 0, 0 ), ENEMY_DEMON_PHYS_MIN, ENEMY_DEMON_PHYS_MAX, Color( 255, 0, 255, 100 ) )
	end
end

function GetDemonUVs( anim, frame )
	local full = MAT_ENEMY_DEMON[anim][1]:Width()
	local per = MAT_ENEMY_DEMON[anim].Frames
	local size = full / per

	local x = math.floor( frame % per )

	local u1 = x * size / full
	local v1 = 0
	local u2 = u1 + size / full
	local v2 = 1

	return u1, v1, u2, v2
end
