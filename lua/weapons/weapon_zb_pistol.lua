AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Pistol"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.Weight = 2
SWEP.WorldModel = Model( "models/weapons/w_pistol.mdl" )

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.PrimaryShootSound = "Weapon_Pistol.NPC_Single"
SWEP.PrimaryDamage = 3
SWEP.Primary.DefaultClip = 18 
SWEP.Primary.Ammo = "Pistol" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1" 
SWEP.Primary.ShellType = "ShellEject" -- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.NumShots = 1

SWEP.NPCBurstMin = 1
SWEP.NPCBurstMax = 1
SWEP.NPCFireRate = 0.2
SWEP.NPCFireRestTimeMin = 0.2
SWEP.NPCFireRestTimeMax = 0.6
SWEP.NPCBulletSpreadMult = 1.5
SWEP.NPCReloadSound = "Weapon_Pistol.Reload"
SWEP.NPCShootDistanceMult = 0.75

SWEP.NPCHoldType =  "pistol" -- https://wiki.facepunch.com/gmod/Hold_Types