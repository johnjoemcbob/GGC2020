--
-- GGC2020_johnjoemcbob
-- 15/06/20
--
-- Server Projectile Entity
--

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )

sound.Add(
	{ 
		name = "ggcj_projectile_fly",
		channel = CHAN_ITEM,
		level = 75,
		volume = 1.0,
		pitch = { 140, 180 },
		sound = "weapons/fx/nearmiss/bulletltor12.wav"
	}
)

function ENT:Initialize()
	-- Visuals
	local dia = self.Scale
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:DrawShadow( false )
	self:SetModelScale( 0.01, 0 )
	self:SetModelScale( 1, 0.1 )

	-- Physics
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:PhysWake()
	self:SetTrigger( true )

	-- Variables
	self.Range = 100
	self.Collide = 0
	self.MaxDamageCollide = 1
	self.HasCollided = false
end

function ENT:OnRemove()
	self:StopSound( "prk_laser_heavy_fly" )
end

function ENT:OnTakeDamage( dmg )
	
end

function ENT:StartTouch( entity )
	self:CollideWithEnt( entity )
end

function ENT:PhysicsCollide( colData, collider )
	self:CollideWithEnt( colData.HitEntity )
end

function ENT:CollideWithEnt( ent )
	if ( self.HasCollided ) then return end

	self.HasCollided = true

	-- Damage (start explosion)
	GAMEMODE:Explode( self.Owner, self:GetPos(), self.Range, self.Damage )

	-- testing/fun
	-- if ( ent:GetClass() == "prop_physics" and !(ent:IsNPC() or ent:IsPlayer()) ) then
		local phys = ent:GetPhysicsObject()
		if ( phys and IsValid( phys ) ) then
			phys:ApplyForceOffset( ( ent:GetPos() - self:GetPos() ):GetNormalized() * 50000, self:GetPos() )
		end
	-- end

	-- Play sound
	self:EmitSound( "physics/glass/glass_impact_hard3.wav", 75, math.random( 180, 200 ), 1 )

	self:Remove()
end

function ENT:Launch( startpos, velocity, gravity )
	if ( gravity == nil ) then
		gravity = true
	end

	self:SetPos( startpos )
	local phys = self:GetPhysicsObject()
	if ( phys and IsValid( phys ) ) then
		phys:Wake()
		phys:ApplyForceCenter( velocity * phys:GetMass() )
		phys:EnableGravity( gravity )
		phys:SetMaterial( "gmod_bouncy" )
	end
	self:SetGravity( 1000 )
	self:SetAngles( velocity:Angle() )
	self:EmitSound( "ggcj_projectile_fly" )
end
