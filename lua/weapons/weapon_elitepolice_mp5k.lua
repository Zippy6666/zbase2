AddCSLuaFile()

sound.Add({
    name = "Weapon_MP5K_Z.NPC_Fire",
    level = 140,
    pitch = {90,110},
    channel = CHAN_WEAPON,
    volume = 0.75,
    sound = "^weapons/zippy/mp5k/mp5k_fire3.wav",
})

sound.Add({
    name = "Weapon_MP5K.Reload",
    level = 82,
    pitch = 100,
    channel = CHAN_STATIC,
    volume = 0.4,
    sound = "weapons/zippy/mp5k/mp5k_reload.wav",
})

SWEP.PrintName = "MP5K"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.Base = "weapon_zbase"
SWEP.IsZBaseWeapon = true

SWEP.WorldModel = Model( "models/weapons/zippy/w_mp5k.mdl" )
SWEP.AutoSwitchTo = false

SWEP.PrimaryDamage = 3
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.NPCOnly = true -- Should only NPCs be able to use this weapon?
SWEP.NPCCanPickUp = true -- Can NPCs pick up this weapon from the ground
SWEP.NPCBurstMin = 3 -- Minimum amount of bullets the NPC can fire when firing a burst
SWEP.NPCBurstMax = 6 -- Maximum amount of bullets the NPC can fire when firing a burst
SWEP.NPCFireRate = 0.1 -- Shoot delay in seconds
SWEP.NPCFireRestTimeMin = 0.25 -- Minimum amount of time the NPC rests between bursts in seconds
SWEP.NPCFireRestTimeMax = 0.5 -- Maximum amount of time the NPC rests between bursts in seconds
SWEP.NPCBulletSpreadMult = 1 -- Higher number = worse accuracy
SWEP.NPCReloadSound = "Weapon_MP5K.Reload" -- Sound when the NPC reloads the gun

--------------------------------------------------------=#
function SWEP:Initialize()
	self:SetHoldType( "smg" )
end
--------------------------------------------------------=#
function SWEP:Reload()
	if self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) == 0 then return end
	self:DefaultReload( ACT_VM_RELOAD )
end
--------------------------------------------------------=#
function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	local bullet = {
		Attacker = self:GetOwner(),
		Inflictor = self,
		Damage = self.PrimaryDamage,
		AmmoType = self.Primary.Ammo,
		Src = self:GetOwner():GetShootPos(),
		Dir = self:GetOwner():GetAimVector(),
		Spread = Vector(0.02,0.02,0),
		Tracer = 2
	}
	self:FireBullets(bullet)

	self:TakePrimaryAmmo(1)
	self:ShootEffects()
	self:SetNextPrimaryFire(CurTime() + 0.1)

	self:EmitSound("Weapon_MP5K_Z.NPC_Fire")
end
--------------------------------------------------------=#
function SWEP:SecondaryAttack() end
--------------------------------------------------------=#
