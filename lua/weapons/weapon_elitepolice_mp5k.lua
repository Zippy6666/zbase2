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
    level = 75,
    pitch = 100,
    channel = CHAN_STATIC,
    volume = 0.4,
    sound = "weapons/zippy/mp5k/mp5k_reload.wav",
})

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Elitecop MP5K"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.WorldModel = Model( "models/weapons/zippy/w_mp5k.mdl" )

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = true -- Add to NPC weapon list

SWEP.NPCBurstMin = 1 -- Minimum amount of bullets the NPC can fire when firing a burst
SWEP.NPCBurstMax = 1 -- Maximum amount of bullets the NPC can fire when firing a burst
SWEP.NPCFireRate = 0.1 -- Shoot delay in seconds
SWEP.NPCFireRestTimeMin = 0.1 -- Minimum amount of time the NPC rests between bursts in seconds
SWEP.NPCFireRestTimeMax = 0.1 -- Maximum amount of time the NPC rests between bursts in seconds

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30

SWEP.PrimaryDamage = 3
SWEP.PrimaryShootSound = "Weapon_MP5K_Z.NPC_Fire"
SWEP.PrimarySpread = 0.02
SWEP.Primary.Ammo = "SMG1" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types

SWEP.NPCHoldType =  "smg"
SWEP.NPCReloadSound = "Weapon_MP5K.Reload"