AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "HL1 .357"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.Weight = 2
SWEP.WorldModel = Model( "models/weapons/w_357_hls.mdl" )
SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.PrimaryShootSound = "HL1Weapon_357.Single"
SWEP.NPCReloadSound = "HL1Weapon_357.Reload" 
SWEP.NPCFireRestTimeMin = 0.5 
SWEP.NPCFireRestTimeMax = 1
SWEP.Weight = 5
SWEP.NPCHoldType =  "revolver" -- https://wiki.facepunch.com/gmod/Hold_Types
SWEP.NPCBulletSpreadMult = 0.75
SWEP.NPCShootDistanceMult = 0.75
SWEP.Primary.Damage = 30
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Ammo = "357" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = false 