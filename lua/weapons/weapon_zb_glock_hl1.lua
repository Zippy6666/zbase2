AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "HL1 Pistol"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.WorldModel = Model( "models/weapons/w_9mmhandgun.mdl" )
SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

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
SWEP.NPCFireRestTimeMax = 1
SWEP.NPCBulletSpreadMult = 1.5
SWEP.NPCShootDistanceMult = 0.75
SWEP.Weight = 2
SWEP.NPCHoldType =  "pistol"  -- https://wiki.facepunch.com/gmod/Hold_Types
SWEP.PrimaryShootSound = "HL1Weapon_Glock.Single"
SWEP.NPCReloadSound = "Weapon_Pistol.Reload" 