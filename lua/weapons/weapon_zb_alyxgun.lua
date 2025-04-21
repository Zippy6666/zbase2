AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Alyx's Gun"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.Weight = 2
SWEP.WorldModel = Model( "models/weapons/w_alyx_gun.mdl" )

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.PrimaryShootSound = "Weapon_Alyx_Gun.NPC_Single"
SWEP.PrimaryDamage = 4
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Ammo = "Pistol" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1" 
SWEP.Primary.ShellType = "ShellEject" -- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.NumShots = 1

SWEP.NPCBurstMin = 1
SWEP.NPCBurstMax = 1
SWEP.NPCFireRate = 0.1
SWEP.NPCFireRestTimeMin = 0.1
SWEP.NPCFireRestTimeMax = 0.1
SWEP.NPCBulletSpreadMult = 0.75
SWEP.NPCReloadSound = "Weapon_Alyx_Gun.NPC_Reload"
SWEP.NPCShootDistanceMult = 1

SWEP.NPCHoldType =  "pistol" -- https://wiki.facepunch.com/gmod/Hold_Types