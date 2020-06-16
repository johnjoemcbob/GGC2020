--
-- GGC2020_johnjoemcbob
-- 15/06/20
--
-- Shared Weapon - Shotgun
--

AddCSLuaFile()

SWEP.Base = "ggcj_weapon_base"

SWEP.PrintName		= "Shotgun"
SWEP.Slot = 1
if ( CLIENT ) then
	SWEP.Sprite			= {
		MAT_GUNS_MODERN,
		{
			Vector( 336, 8 ),
			Vector( 160, 72 )
		},
		Vector( -10, -5 ),
		Vector( -10, 0 ),
		Scale = 2,
	}
	SWEP.Muzzle = {
		MAT_MUZZLEFLASHES[10],
		5,
		Off = Vector( 50, 30 ),
	}
end

SWEP.ReloadDuration = 0.2
function SWEP:OnReloadFinish()
	self:EmitSound( "weapons/m3/m3_pump.wav", 75, math.random( 50, 100 ) )
end

SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 15
SWEP.Primary.TakeAmmo = 2
SWEP.Primary.Spread = 2
SWEP.Primary.NumberofShots = 5
SWEP.Primary.Recoil = 5
SWEP.Primary.Delay = 0.5
SWEP.Primary.Force = 20
SWEP.Primary.ShootSound = "weapons/m3/m3-1.wav"
function SWEP:OnPrimaryFire()
	if ( CLIENT ) then
		-- Punch view model
		LocalPlayer().ViewModelAngles:RotateAroundAxis( LocalPlayer().ViewModelAngles:Up(), 300 )
	end
end

if ( CLIENT ) then
	function SWEP:Crosshair( x, y )
		local rad = 64
		local segs = 6
		local thick = 6
		local between = 32

		return {
			COLOUR_WHITE,
			{ x, y - between, rad, segs, thick, 25, 55 },
			{ x, y + between, rad, segs, thick, 75, 55 },
		}
	end
end
