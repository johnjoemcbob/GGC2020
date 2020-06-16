--
-- GGC2020_johnjoemcbob
-- 16/06/20
--
-- Shared NPC Entity - Skull
--

AddCSLuaFile()

ENT.Base 			= "ggcj_npc_base"
ENT.Spawnable		= true

list.Set( "NPC", "ggcj_npc_skull", {
	Name = "Skull",
	Class = "ggcj_npc_skull",
	Category = "GGCJ"
} )

ENEMY_SKULL_SIZE = 64

local INITIALIZED = false
MAT_ENEMY_SKULL = {}
	MAT_ENEMY_SKULL["idle"] = {
		Frames = 8,
		Between = 0.2,
		FrameActions = {
			[2] = function( self )
				if ( CLIENT ) then
					sound.Play( "ambient/fire/mtov_flame2.wav", self:GetPos(), 95, 100, 1 )
				end
			end,
		},
	}
	MAT_ENEMY_SKULL["die"] = {
		Frames = 4,
		Between = 0.1,
	}

local width = ENEMY_SKULL_SIZE / 2
local height = ENEMY_SKULL_SIZE * 2
local offground = 0
ENEMY_SKULL_PHYS_MIN = Vector( -width / 2, -width / 2, offground )
ENEMY_SKULL_PHYS_MAX = Vector( width / 2, width / 2, offground + height )

function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube8x8x8.mdl" )

	-- Collision
	self:SetCollisionBounds( ENEMY_SKULL_PHYS_MIN, ENEMY_SKULL_PHYS_MAX )
	self:SetSolid( SOLID_BBOX )
	if ( CLIENT ) then
		self:SetRenderBounds( ENEMY_SKULL_PHYS_MIN, ENEMY_SKULL_PHYS_MAX )
	end
	self:DrawShadow( false )

	self.LoseTargetDist	= 2000	-- How far the enemy has to be before we lose them
	self.SearchRadius 	= 1000	-- How far to search for enemies

	self:SetHealth( 30 )
	self.BaseSpeed = 100
	self.Speed = self.BaseSpeed
	--								self.Speed = 0 -- TODO TEMP TESTING
	self.AttackRange = 500
	self.AttackBetween = 3
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
	--self:SetNWString( "Animation", "attack" )
	self.Speed = 0

	-- Shoot projectile
	local proj = ents.Create( "ggcj_projectile" )
	proj:Spawn()
	proj:SetOwner( self )
	proj.Damage = 10
	proj.Range = 10

	local dir = ( victim:GetPos() + Vector( 0, 0, 24 ) - self:EyePos() ):GetNormalized()
	local goal = self:EyePos() + dir * 50
	local tr = util.TraceLine( {
		start = self:EyePos(),
		endpos = goal,
		filter = self
	} )
	if ( tr.Hit ) then
		proj:SetPos( tr.HitPos )
		proj:CollideWithEnt( tr.Entity )
	else
		proj:Launch(
			goal,
			dir * 300,
			false
		)
	end

	timer.Simple( 0.1, function()
		self.Speed = self.BaseSpeed
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
			for k, v in pairs( MAT_ENEMY_SKULL ) do
				v[1] = Material( "enemy/skull/" .. k .. ".png", "nocull 1 smooth 0" )
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
		local size = ENEMY_SKULL_SIZE
			local dmg = self:GetNWFloat( "LastDamage", 0 )
			if ( dmg + 0.2 >= CurTime() ) then
				local prog = math.sin( CurTime() * 100 )
				size = size + prog * 10
				col = LerpColour( prog, COLOUR_WHITE, Color( 0, 255, 255, 255 ) )
			end
		local offset = size * 0
		if ( self.NextFrameTime <= CurTime() ) then
			-- Increment and loop
			self.Frame = self.Frame + 1
			if ( self.Frame > MAT_ENEMY_SKULL[anim].Frames ) then
				self.Frame = 1
			end

			-- Frame specific action functions
			if ( MAT_ENEMY_SKULL[anim].FrameActions and MAT_ENEMY_SKULL[anim].FrameActions[self.Frame] ) then
				MAT_ENEMY_SKULL[anim].FrameActions[self.Frame]( self )
			end

			self.NextFrameTime = CurTime() + MAT_ENEMY_SKULL[anim].Between
		end
		local u1, v1, u2, v2 = GetSkullUVs( anim, self.Frame )
		local ang = GAMEMODE:GetBillboardAngle()
		render.PushColourModulation( col )
			GAMEMODE:DrawBillboardedUVs(
				self:GetPos() + ang:Up() * offset,
				0,
				Vector( 1, 1 ) * size,
				MAT_ENEMY_SKULL[anim][1],
				u1, v1, u2, v2,
				false
			)
		render.PopColourModulation()

		--render.DrawBox( self:GetPos(), Angle( 0, 0, 0 ), ENEMY_SKULL_PHYS_MIN, ENEMY_SKULL_PHYS_MAX, Color( 255, 0, 255, 100 ) )
	end
end

function GetSkullUVs( anim, frame )
	local full = MAT_ENEMY_SKULL[anim][1]:Width()
	local per = MAT_ENEMY_SKULL[anim].Frames
	local size = full / per

	local x = math.floor( frame % per )

	local u1 = x * size / full
	local v1 = 0
	local u2 = u1 + size / full
	local v2 = 1

	return u1, v1, u2, v2
end
