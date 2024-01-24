AddCSLuaFile()



SWEP.Base = "weapon_zbase"
SWEP.PrintName = "TF2 Test"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.WorldModel = Model( "models/weapons/w_models/w_smg.mdl" )


SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list


-- NPC Stuff
SWEP.NPCOnly = true -- Should only NPCs be able to use this weapon?
SWEP.NPCCanPickUp = true -- Can NPCs pick up this weapon from the ground
SWEP.NPCBurstMin = 1 -- Minimum amount of bullets the NPC can fire when firing a burst
SWEP.NPCBurstMax = 1 -- Maximum amount of bullets the NPC can fire when firing a burst
SWEP.NPCFireRate = 0.1 -- Shoot delay in seconds
SWEP.NPCFireRestTimeMin = 0.1 -- Minimum amount of time the NPC rests between bursts in seconds
SWEP.NPCFireRestTimeMax = 0.1 -- Maximum amount of time the NPC rests between bursts in seconds
SWEP.NPCBulletSpreadMult = 1 -- Higher number = worse accuracy
SWEP.NPCReloadSound = "Weapon_MP5K.Reload" -- Sound when the NPC reloads the gun
SWEP.NPCShootDistanceMult = 1 -- Multiply the NPCs shoot distance by this number with this weapon


-- Basic primary attack stuff
SWEP.Primary.DefaultClip = 30 -- Clipsize for NPCs
SWEP.PrimaryDamage = 3
SWEP.PrimaryShootSound = "Weapon_MP5K_Z.NPC_Fire"
SWEP.PrimarySpread = 0.02
SWEP.Primary.Ammo = "SMG1" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1" -- Set to the name of an attachment to enable shell ejection


-- idk
SWEP.ZBase_ActTranslateOverride = {
	[ACT_IDLE_PISTOL] = ACT_MP_ATTACK_STAND_SECONDARY,
	[ACT_IDLE_ANGRY_PISTOL] = ACT_MP_ATTACK_STAND_SECONDARY,
}


function SWEP:Initialize()
	self:SetHoldType( "smg" )
end
