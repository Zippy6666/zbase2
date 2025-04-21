AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "HL1 Shotgun"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.WorldModel = Model( "models/weapons/w_shotgun_hls.mdl" )
SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.PrimaryShootSound = "HL1Weapon_Shotgun.Single"
SWEP.NPCReloadSound = "HL1Weapon_Shotgun.Reload"
SWEP.PrimarySpread = 0.02
SWEP.PrimaryDamage = 3
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Ammo = "Buckshot"-- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1"
SWEP.Primary.ShellType = "ShotgunShellEject"-- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.NumShots = 7
SWEP.NPCBurstMin = 1
SWEP.NPCBurstMax = 1
SWEP.NPCFireRate = 0
SWEP.NPCFireRestTimeMin = 0.5
SWEP.NPCFireRestTimeMax = 1
SWEP.NPCBulletSpreadMult = 1.5
SWEP.NPCShootDistanceMult = 0.5
SWEP.Weight = 4
SWEP.NPCHoldType =  "shotgun" -- https://wiki.facepunch.com/gmod/Hold_Types