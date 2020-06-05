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

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModel		= "models/weapons/c_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol.mdl"

SWEP.ReloadDuration = 0.2

SWEP.Primary.Damage = 15
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 18
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = .2
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Reload()
	if ( self.ReloadingTime and CurTime() <= self.ReloadingTime ) then return end
	
	if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		self:DefaultReload( ACT_VM_RELOAD )

		local AnimationTime = self.ReloadDuration
		self.ReloadingTime = CurTime() + AnimationTime
		self:SetNextPrimaryFire(CurTime() + AnimationTime)
		self:SetNextSecondaryFire(CurTime() + AnimationTime)

		if ( CLIENT ) then
			self.Owner.Reloading = CurTime()
		end
	end
end

function SWEP:Think()

end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() and self.Owner:IsPlayer() ) then return end

	local bullet = {} 
	bullet.Num = self.Primary.NumberofShots 
	bullet.Src = self.Owner:GetShootPos() 
	bullet.Dir = self.Owner:GetAimVector() 
	bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
	bullet.Tracer = 1
	bullet.Force = self.Primary.Force 
	bullet.Damage = self.Primary.Damage 
	bullet.AmmoType = self.Primary.Ammo 

	local rnda = self.Primary.Recoil * -1 
	local rndb = self.Primary.Recoil * math.random(-1, 1) 

	self.Owner:FireBullets( bullet ) 
	self:EmitSound( "weapons/brenmk3/shoot.wav", 75, math.random( 50, 100 ) )
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
	self:TakePrimaryAmmo(self.Primary.TakeAmmo) 

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
end

function SWEP:SecondaryAttack()

end
