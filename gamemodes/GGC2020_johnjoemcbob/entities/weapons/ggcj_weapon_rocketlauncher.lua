--
-- GGC2020_johnjoemcbob
-- 15/06/20
--
-- Shared Weapon - Rocket Launcher
--

AddCSLuaFile()

SWEP.Base = "ggcj_weapon_base"

SWEP.PrintName	= "Rocket Launcher"
SWEP.Slot = 4
if ( CLIENT ) then
	SWEP.Sprite			= {
		MAT_GUNS_INDUSTRIAL,
		{
			Vector( 164, 40 ),
			Vector( 224, 100 )
		},
		Vector( -20, -5 ),
		Vector( -10, 7 ),
		Scale = 2,
	}
	SWEP.Muzzle = {
		MAT_MUZZLEFLASHES[12],
		5,
		Off = Vector( 20, -20 ),
	}
end

SWEP.ReloadDuration = 1
SWEP.ReloadSound = "items/ammocrate_close.wav"
function SWEP:OnReloadFinish()
	self:EmitSound( "weapons/slam/mine_mode.wav", 75, math.random( 50, 100 ) )
end

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 15
SWEP.Primary.TakeAmmo = 2
SWEP.Primary.Spread = 2
SWEP.Primary.NumberofShots = 5
SWEP.Primary.Recoil = 5
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 20
SWEP.Primary.ShootSound = "weapons/rpg/rocketfire1.wav"
function SWEP:Shoot()
	if ( SERVER ) then
		local proj = ents.Create( "ggcj_projectile" )
		proj:Spawn()
		proj:SetOwner( self.Owner )

		local dir = self.Owner:EyeAngles():Forward()
		local goal = self.Owner:EyePos() + dir * 50
		local tr = util.TraceLine( {
			start = self.Owner:EyePos(),
			endpos = goal,
			filter = self.Owner
		} )
		if ( tr.Hit ) then
			proj:SetPos( tr.HitPos )
			proj:CollideWithEnt( tr.Entity )
		else
			proj:Launch(
				goal,
				dir * 800,
				false
			)
		end
	end
end

if ( CLIENT ) then
	function SWEP:Crosshair( x, y )
		local rad = 12
		local segs = 4
		local thick = 4
		local between = 4

		return {
			COLOUR_WHITE,
			{ x, y - between, rad, segs, thick, 25, 55 },
			{ x, y + between, rad, segs, thick, 75, 55 },
		}
	end
end
