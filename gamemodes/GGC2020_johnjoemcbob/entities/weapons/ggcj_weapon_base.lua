--
-- GGC2020_johnjoemcbob
-- 05/06/20
--
-- Shared Base Weapon
--

AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.Author			= "johnjoemcbob"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
 
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= true

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

if ( CLIENT ) then
	MAT_GUNS_FUTURE = Material( "guns_future.png", "nocull 1 smooth 0" )
	MAT_GUNS_INDUSTRIAL = Material( "guns_industrial.png", "nocull 1 smooth 0" )
	MAT_GUNS_MODERN = Material( "guns_modern.png", "nocull 1 smooth 0" )
		-- MAT_GUNS_FUTURE:SetInt( "$flags", bit.bor( MAT_GUNS_FUTURE:GetInt( "$flags" ), 2 ^ 8 ) )

		MAT_GUNS_FUTURE_WIDTH = 1024
		MAT_GUNS_FUTURE_HEIGHT = 1024
		GUNSCALE = 0.3

	MAT_MUZZLEFLASH = Material( "muzzleflash.png", "nocull 1 smooth 0" )
	MAT_MUZZLEFLASHES = {}
	for i = 1, 16 do
		MAT_MUZZLEFLASHES[i] = Material( "muzzle/m_" .. i .. ".png", "nocull 1 smooth 0" )
	end
end

SWEP.ViewModel		= "models/weapons/c_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol.mdl"
if ( CLIENT ) then
	SWEP.Sprite			= {
		MAT_GUNS_FUTURE,
		{
			Vector( 103, 92 ),
			Vector( 176, 76 )
		},
		Vector( 0, 0 ),
		Vector( 0, 0 ),
		Scale = 1,
	}
	SWEP.Muzzle = {
		MAT_MUZZLEFLASHES[1],
		3,
		Off = Vector( 0, -20 ),
	}
end

SWEP.ReloadDuration = 0.2
SWEP.ReloadSound = "weapons/m3/m3_insertshell.wav"

SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 15
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Recoil = .2
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 1
SWEP.Primary.ShootSound = "weapons/brenmk3/shoot.wav"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Reload()
	if ( self.ReloadingTime and CurTime() <= self.ReloadingTime ) then return end
	
	if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		--self:DefaultReload( ACT_VM_RELOAD )
		timer.Simple( self.ReloadDuration, function()
			if ( self and self:IsValid() ) then
				local ammo = math.min( self.Primary.ClipSize, self.Owner:GetAmmoCount( self.Primary.Ammo ) )
				self.Owner:RemoveAmmo( ammo - self:Clip1(), self.Primary.Ammo )
				self:SetClip1( ammo )

				if ( self.OnReloadFinish ) then
					self:OnReloadFinish()
				end
			end
		end )

		local AnimationTime = self.ReloadDuration
		self.ReloadingTime = CurTime() + AnimationTime
		self:SetNWFloat( "ReloadTime", self.ReloadingTime )
		self:SetNextPrimaryFire( CurTime() + AnimationTime )
		self:SetNextSecondaryFire( CurTime() + AnimationTime )

		self:EmitSound( self.ReloadSound, 75, math.random( 80, 120 ) )

		if ( CLIENT ) then
			self.Owner.Reloading = CurTime()
		end
	end
end

function SWEP:Think()

end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() and self.Owner:IsPlayer() ) then return end

		self:Shoot()
		self:ShootEffects()
		self:TakePrimaryAmmo( self.Primary.TakeAmmo )
		if ( self.OnPrimaryFire ) then
			self:OnPrimaryFire()
		end
	self:SetLastShootTime( CurTime() )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
end

function SWEP:SecondaryAttack()

end

function SWEP:Shoot()
	local bullet = {}
		bullet.Num = self.Primary.NumberofShots
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( self.Primary.Spread * 0.1, self.Primary.Spread * 0.1, 0 )
		bullet.Tracer = 1
		bullet.Force = self.Primary.Force
		bullet.Damage = self.Primary.Damage
		bullet.AmmoType = self.Primary.Ammo
	self.Owner:FireBullets( bullet )
end

function SWEP:ShootEffects()
	local rnda = self.Primary.Recoil * -1
	local rndb = self.Primary.Recoil * math.random( -1, 1 )

	self:EmitSound( self.Primary.ShootSound, 75, math.random( 50, 100 ) )
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
end

if CLIENT then
	function SWEP:GetSprite()
		return self.Sprite
	end

	function SWEP:RenderCrosshair( x, y )
		local cross = self:Crosshair( 0, 0 )
		if ( !cross ) then return end
		LocalPlayer().LastCrosshair = LocalPlayer().LastCrosshair or cross

		-- Lerp
		-- TODO lerp colour
		local d = FrameTime() * 30
		for c = 2, 3 do
			local circ = LocalPlayer().LastCrosshair[c]
			local targ = cross[c]
			for i = 1, 7 do
				circ[i] = Lerp( d, circ[i], targ[i] )
			end
		end

		-- Render
		surface.SetDrawColor( LocalPlayer().LastCrosshair[1] )
		local c = LocalPlayer().LastCrosshair[2]
		draw.CircleSegment( c[1], c[2], c[3], c[4], c[5], c[6], c[7] )
		local c = LocalPlayer().LastCrosshair[3]
		draw.CircleSegment( c[1], c[2], c[3], c[4], c[5], c[6], c[7] )
	end

	function SWEP:Crosshair( x, y )
		local rad = 4
		local segs = 3
		local thick = 4

		return {
			COLOUR_WHITE,
			{ x, y, rad, segs, thick, 0, 100 },
			{ x, y, rad, segs, thick, 50, 50 },
		}
	end

	hook.Add( "PlayerSwitchWeapon", HOOK_PREFIX .. "Weapon_PlayerSwitchWeapon", function( ply, oldwep, newwep )
		ply.SwitchWeaponLast = oldwep
		ply.SwitchWeaponTime = CurTime()

		ply.LastViewModelAngles = nil
		ply.ViewModelAngles = ply:EyeAngles()
	end )
end
