AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Pistol"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" )

SWEP.PrimaryShootSound = "Weapon_SMG1.NPC_Single"
SWEP.PrimaryDamage = 2
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Ammo = "SMG1"-- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1"
SWEP.Primary.ShellType = "RifleShellEject"-- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.NumShots = 1
SWEP.Primary.MuzzleFlashChance = 1
SWEP.NPCBurstMin = 1
SWEP.NPCBurstMax = 1
SWEP.NPCFireRate = 0.1
SWEP.NPCFireRestTimeMin = 0.1
SWEP.NPCFireRestTimeMax = 0.1
SWEP.NPCBulletSpreadMult = 1.5
SWEP.NPCReloadSound = "Weapon_SMG1.NPC_Reload"
SWEP.NPCShootDistanceMult = 0.75
SWEP.Weight = 3
SWEP.NPCHoldType =  "smg" -- https://wiki.facepunch.com/gmod/Hold_Types

SWEP.EngineCloneClass = "weapon_smg1"