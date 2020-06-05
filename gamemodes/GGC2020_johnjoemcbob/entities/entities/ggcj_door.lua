--
-- GGC2020_johnjoemcbob
-- 03/06/20
--
-- Shared Door Entity
--

AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Door"
ENT.RenderGroup = RENDERGROUP_BOTH

local size = SHIPPART_SIZE
local depth = 10
local mins = Vector( -depth, -size / 2, 0 )
local maxs = Vector( depth, size / 2, size )

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Open" )

	if ( SERVER ) then
		self:SetOpen( false )
	end
end

function ENT:Initialize()
	self:SetModel( "models/cerus/modbridge/misc/doors/door11a_anim.mdl" )
	-- self:PhysicsInit( SOLID_VPHYSICS )
	self:PhysicsInitBox( mins, maxs )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	if ( SERVER ) then
		self:SetUseType( ONOFF_USE )
		
		local ent = GAMEMODE.CreateProp( "models/cerus/modbridge/misc/doors/door11a.mdl", self:GetPos(), self:GetAngles(), false )
		ent:SetModelScale( 0.999 ) -- TODO try to avoid z fighting
		ent:SetColor( self:GetColor() )
		-- ent:SetParent( self )
		self.OuterFrame = ent
	end
end

function ENT:Think()
	if ( CLIENT ) then
		if ( self:GetOpen() ) then
			self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		else
			self:SetCollisionGroup( COLLISION_GROUP_NONE )
		end
	end
end

function ENT:Use( activator, caller, type, value )
	if ( !activator:IsPlayer() ) then return end

	if ( type == USE_ON ) then
		self:Toggle( !self:GetOpen(), activator )
	end
	return
end

function ENT:Toggle( bEnable, ply )
	if ( bEnable ) then
		-- Open
		self:SetSequence( 1 )
		self:EmitSound( "doors/garage_stop1.wav", SNDLVL_100dB, 120 + math.random( -20, 20 ) )
		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	else
		-- Close
		self:SetSequence( 2 )
		self:EmitSound( "doors/garage_stop1.wav", SNDLVL_100dB, 80 + math.random( -20, 20 ) )
		self:SetCollisionGroup( COLLISION_GROUP_NONE )
		-- self:EmitSound( "doors/drawbridge_stop1.wav" )
	end
	self:SetOpen( bEnable )
end

if ( CLIENT ) then
	function ENT:Draw()
		self:DrawModel()

		-- GAMEMODE.RenderCachedModel(
			-- "models/cerus/modbridge/misc/doors/door11a.mdl",
			-- self:GetPos(),
			-- self:GetAngles(),
			-- Vector( 1, 1, 1 ),
			-- nil,
			-- self:GetColor()
		-- )

		-- render.DrawBox( self:GetPos() + self:OBBCenter() - Vector( 0, 0, size ), self:GetAngles(), self:OBBMins(), self:OBBMaxs(), Color( 255, 0, 0, 120 ) )
	end
end
