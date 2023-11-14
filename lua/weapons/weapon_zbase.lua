AddCSLuaFile()


	-- You can use this weapon base for your swep to have better control over how NPCs handle it --
	-- SWEP.Base = "weapon_zbase"


SWEP.PrintName = "ZBase Weapon"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" )


-- IMPORTANT: Set this to true in your base
-- Note that your SWEP will be added to the NPC weapon menu automatically if you do
SWEP.IsZBaseWeapon = true


-- NPC Stuff
SWEP.NPCOnly = true -- Should only NPCs be able to use this weapon?
SWEP.NPCCanPickUp = true -- Can NPCs pick up this weapon from the ground
SWEP.NPCBurstMin = 1 -- Minimum amount of bullets the NPC can fire when firing a burst
SWEP.NPCBurstMax = 1 -- Maximum amount of bullets the NPC can fire when firing a burst
SWEP.NPCFireRate = 1 -- Shoot delay in seconds
SWEP.NPCFireRestTimeMin = 1 -- Minimum amount of time the NPC rests between bursts in seconds
SWEP.NPCFireRestTimeMax = 1 -- Maximum amount of time the NPC rests between bursts in seconds
SWEP.NPCBulletSpreadMult = 1 -- Higher number = worse accuracy
SWEP.NPCReloadSound = "" -- Sound when the NPC reloads the gun
SWEP.NPCShootDistanceMult = 1 -- Multiply the NPCs shoot distance by this number with this weapon


-- Basic primary attack stuff
SWEP.PrimaryShootSound = "Weapon_SMG1.NPC_Single" -- Shoot sound
SWEP.PrimarySpread = 0.02 -- Spread
SWEP.PrimaryDamage = 3 -- Damage
SWEP.Primary.DefaultClip = 30 -- Clipsize for NPCs
SWEP.Primary.Ammo = "SMG1" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types



	-- Change these to whatever you like --
--------------------------------------------------------=#
function SWEP:Initialize()
	self:SetHoldType( "smg" )
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
		Spread = Vector(self.PrimarySpread, self.PrimarySpread),
		Tracer = 2
	}
	self:FireBullets(bullet)
	self:TakePrimaryAmmo(1)
	self:ShootEffects()
	self:SetNextPrimaryFire(CurTime() + 0.1)
	self:EmitSound(self.PrimaryShootSound)
end
--------------------------------------------------------=#






	-- Don't touch anything below this! --
--------------------------------------------------------=#
hook.Add("PlayerCanPickupWeapon", "ZBASE", function( ply, wep )
	if wep.IsZBaseWeapon && wep.NPCOnly then
		ply:GiveAmmo(wep:GetMaxClip1(), wep:GetPrimaryAmmoType())
		wep:Remove()
		return false
	end
end)
--------------------------------------------------------=#
function SWEP:CanBePickedUpByNPCs()
	return true
end
--------------------------------------------------------=#
function SWEP:GetNPCRestTimes()
	return self.NPCFireRestTimeMin, self.NPCFireRestTimeMax
end
--------------------------------------------------------=#
function SWEP:GetNPCBurstSettings()
	return self.NPCBurstMin, self.NPCBurstMax, self.NPCFireRate
end
--------------------------------------------------------=#
function SWEP:GetNPCBulletSpread( proficiency )
	return (7 - proficiency)*self.NPCBulletSpreadMult
end
--------------------------------------------------------=#