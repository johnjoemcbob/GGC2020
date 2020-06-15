--
-- GGC2020_johnjoemcbob
-- 15/06/20
--
-- Shared Weapon - Pistol
--

AddCSLuaFile()

SWEP.Base = "ggcj_weapon_base"

SWEP.PrintName		= "Pistol"
SWEP.Slot = 0
if ( CLIENT ) then
	SWEP.Sprite			= {
		MAT_GUNS_INDUSTRIAL,
		{
			Vector( 420, 160 ),
			Vector( 116, 80 )
		},
		Vector( 13, -7 ),
		Vector( -10, 7 ),
		Scale = 1,
	}
	SWEP.Muzzle = {
		MAT_MUZZLEFLASHES[9],
		5,
		Off = Vector( 15, 5 ),
	}
end

SWEP.ReloadDuration = 0.7

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 5
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 5
SWEP.Primary.ShootSound = "weapons/p228/p228-1.wav"

function SWEP:OnPrimaryFire()
	if ( CLIENT ) then
		-- Punch view model
		LocalPlayer().ViewModelAngles:RotateAroundAxis( LocalPlayer().ViewModelAngles:Up(), -10 )
	end
end
