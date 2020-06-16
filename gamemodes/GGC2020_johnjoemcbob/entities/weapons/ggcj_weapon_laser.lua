--
-- GGC2020_johnjoemcbob
-- 15/06/20
--
-- Shared Weapon - Laser
--

AddCSLuaFile()

SWEP.Base = "ggcj_weapon_base"

SWEP.PrintName		= "Laser"
SWEP.Slot = 3
if ( CLIENT ) then
	SWEP.Sprite			= {
		MAT_GUNS_FUTURE,
		{
			Vector( 743, 187 ),
			Vector( 149, 89 )
		},
		Vector( -20, -5 ),
		Vector( -10, 7 ),
		Scale = 2,
	}
	SWEP.Muzzle = {
		MAT_MUZZLEFLASHES[3],
		1,
		Off = Vector( 0, 100 ),
		Solid = true,
	}
end

SWEP.ReloadDuration = 0.2
SWEP.ReloadSound = "weapons/cguard/charging.wav"
function SWEP:OnReloadFinish()
	self:EmitSound( "weapons/grenade/tick1.wav", 75, math.random( 50, 100 ) )
end

SWEP.Primary.ClipSize = 400
SWEP.Primary.DefaultClip = 400
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 2
SWEP.Primary.TakeAmmo = 2
SWEP.Primary.Spread = 2
SWEP.Primary.NumberofShots = 5
SWEP.Primary.Recoil = 5
SWEP.Primary.Delay = 0
SWEP.Primary.Force = 0.03
SWEP.Primary.SelfForce = 20
SWEP.Primary.MaxDistance = 500
SWEP.Primary.ShootSound = "thrusters/mh2.wav"

function SWEP:Shoot()
	self.LastShoot = CurTime()

	local tr = util.TraceLine( {
		start = self.Owner:EyePos(),
		endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * self.Primary.MaxDistance,
		filter = self.Owner
	} )

	if ( tr.Hit ) then
		self.LastTraceLength = tr.Fraction * self.Primary.MaxDistance

		local alive = tr.Entity and ( GAMEMODE:IsNPC( tr.Entity ) or tr.Entity:IsPlayer() )

		-- Force player backwards
		--if ( tr.Hit ) then
			self.Owner:SetVelocity( -self.Owner:EyeAngles():Forward() * self.Primary.SelfForce )
		--end

		-- Scorch ground
		if ( tr.HitWorld or !alive ) then
			util.Decal( "FadingScorch", self.Owner:EyePos(), self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * self.Primary.MaxDistance, ply )
		end

		-- Damage enemy
		if ( SERVER ) then
			if ( alive ) then
				tr.Entity:TakeDamage( self.Primary.Damage, self.Owner, self )
			end

			local force = self.Owner:EyeAngles():Forward() * self.Primary.Force
			local phys = tr.Entity:GetPhysicsObject()
			if ( phys and phys:IsValid() ) then
				phys:AddVelocity( force * phys:GetMass() )
			else
				tr.Entity:SetVelocity( force )
			end
		end
	else
		self.LastTraceLength = self.Primary.MaxDistance
	end
end

function SWEP:ShootEffects()
	if ( CLIENT ) then
		-- Screenshake
		util.ScreenShake( self.Owner:GetPos(), 0.2, 5, 0.1, 1 )
	end

	-- Sound
	if ( !self.SoundLoop ) then
		self.SoundLoop = CreateSound( self, self.Primary.ShootSound )
	end
	if ( !self.SoundLoop:IsPlaying() ) then
		self.SoundLoop:Play()
	end
end

function SWEP:Think()
	if ( self.LastShoot and self.LastShoot + 0.1 <= CurTime() ) then
		if ( self.SoundLoop ) then
			self.SoundLoop:Stop()
		end
	end
end

function SWEP:OnRemove()
	if ( self.SoundLoop ) then
		self.SoundLoop:Stop()
		self.SoundLoop = nil
	end
end

if ( CLIENT ) then
	function SWEP:Crosshair( x, y )
		if ( self.LastShoot and self.LastShoot + 0.1 >= CurTime() ) then return end

		local rad = 12
		local segs = 32
		local thick = 4
		local between = 4

		return {
			COLOUR_WHITE,
			{ x - between, y, rad, segs, thick, 0, 50 },
			{ x + between, y, rad, segs, thick, 50, 50 },
		}
	end

	local colour = Color( 255, 0, 157, 255 )
	local MAT_BEAM = Material( "hunter/myplastic" )
	function SWEP:DrawViewModelCustom( viewmodel, ply )
		if ( self.LastShoot and self.LastShoot + 0.1 >= CurTime() ) then
			local anim = math.sin( CurTime() * 5 )
			local length = self.LastTraceLength
			local width = 3 + anim * 3
			local finish = ply:EyePos() + ply:EyeAngles():Forward() * length
			render.SetMaterial( MAT_BEAM )
			render.SetColorMaterial()
			render.DrawBeam(
				ply.ViewModelPos + 
					ply.ViewModelAngles:Forward() * -70 +
					ply.ViewModelAngles:Right() * 10 +
					ply.ViewModelAngles:Up() * -2,
				finish,
				width,
				0,
				2 + anim,
				colour
			)
			--render.SetMaterial( nil )
			render.DrawSphere( finish, width * 1.2, 30, 30, colour )
		end
	end
end
