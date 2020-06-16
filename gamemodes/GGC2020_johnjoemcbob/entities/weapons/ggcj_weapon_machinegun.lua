--
-- GGC2020_johnjoemcbob
-- 15/06/20
--
-- Shared Weapon - Machine Gun
--

AddCSLuaFile()

SWEP.Base = "ggcj_weapon_base"

SWEP.PrintName		= "Machine Gun"
SWEP.Slot = 2
if ( CLIENT ) then
	SWEP.Sprite			= {
		MAT_GUNS_FUTURE,
		{
			Vector( 495, 415 ),
			Vector( 225, 117 )
		},
		Vector( -30, -10 ),
		Vector( -10, 15 ),
		Scale = 2,
	}
end

SWEP.ReloadDuration = 0.7

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 15
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Spread = 0.5
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 10
SWEP.Primary.ShootSound = "weapons/brenmk3/shoot.wav"

if ( CLIENT ) then
	function SWEP:Crosshair( x, y )
		local rad = 12
		local segs = 5
		local thick = 2

		return {
			COLOUR_WHITE,
			{ x, y, rad, segs, thick, 0, 120 },
			{ x, y, rad, segs, thick, 0, 0 },
		}
	end
end
