AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = ".357"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_357.mdl" )

SWEP.PrimaryShootSound = "Weapon_357.Single"
SWEP.NPCReloadSound = "Weapon_357.RemoveLoader" 
SWEP.NPCFireRestTimeMin = 0.5 
SWEP.NPCFireRestTimeMax = 1
SWEP.Weight = 7
SWEP.NPCHoldType =  "revolver" -- https://wiki.facepunch.com/gmod/Hold_Types
SWEP.NPCBulletSpreadMult = 0.75
SWEP.NPCShootDistanceMult = 0.75
SWEP.PrimaryDamage = 30
SWEP.Primary.DefaultClip = 6 
SWEP.Primary.Ammo = "357" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = false 