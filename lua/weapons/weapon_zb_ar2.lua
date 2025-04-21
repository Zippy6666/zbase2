AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Pulse-Rifle"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_irifle.mdl" )

SWEP.PrimaryShootSound = "Weapon_AR2.NPC_Single"
SWEP.PrimaryDamage = 3
SWEP.Primary.DefaultClip = 30 
SWEP.Primary.Ammo = "AR2" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = false 
SWEP.Primary.NumShots = 1
SWEP.Primary.MuzzleFlashFlags = 5
SWEP.Primary.TracerName = "AR2Tracer"
SWEP.Primary.TracerChance = 1
SWEP.NPCBurstMin = 3
SWEP.NPCBurstMax = 8
SWEP.NPCFireRate = 0.1
SWEP.NPCFireRestTimeMin = 0.2 
SWEP.NPCFireRestTimeMax = 0.5
SWEP.NPCBulletSpreadMult = 0.25 
SWEP.NPCReloadSound = "Weapon_AR2.NPC_Reload" 
SWEP.NPCShootDistanceMult = 1
SWEP.Weight = 5
SWEP.NPCHoldType =  "ar2" -- https://wiki.facepunch.com/gmod/Hold_Types

SWEP.EngineCloneClass = "weapon_ar2"