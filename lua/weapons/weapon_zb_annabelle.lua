AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Annabelle"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.Weight = 2
SWEP.WorldModel = Model( "models/weapons/w_annabelle.mdl" )

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.PrimaryShootSound = "Weapon_Shotgun.NPC_Single"
SWEP.PrimarySpread = 0.02 
SWEP.PrimaryDamage = 25
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Ammo = "357" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1" 
SWEP.Primary.ShellType = "ShellEject" -- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.NumShots = 1
SWEP.Primary.MuzzleFlashFlags = 7
SWEP.NPCBurstMin = 1
SWEP.NPCBurstMax = 1
SWEP.NPCFireRate = 0
SWEP.NPCFireRestTimeMin = 0.75 
SWEP.NPCFireRestTimeMax = 1.25
SWEP.NPCBulletSpreadMult = 0.5
SWEP.NPCReloadSound = "Weapon_Shotgun.NPC_Reload" 
SWEP.NPCShootDistanceMult = 1.5
SWEP.Weight = 4
SWEP.NPCHoldType =  "shotgun" -- https://wiki.facepunch.com/gmod/Hold_Types