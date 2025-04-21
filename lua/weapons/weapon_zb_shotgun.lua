AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Pistol"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_shotgun.mdl" )

SWEP.PrimaryShootSound = "Weapon_Shotgun.Single"
SWEP.PrimarySpread = 0.02 
SWEP.PrimaryDamage = 3
SWEP.Primary.DefaultClip = 8 
SWEP.Primary.Ammo = "Buckshot" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1" 
SWEP.Primary.ShellType = "ShotgunShellEject" -- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.NumShots = 7
SWEP.Primary.MuzzleFlashFlags = 7
SWEP.NPCBurstMin = 1
SWEP.NPCBurstMax = 1
SWEP.NPCFireRate = 0
SWEP.NPCFireRestTimeMin = 0.75 
SWEP.NPCFireRestTimeMax = 1.25
SWEP.NPCBulletSpreadMult = 1.5 
SWEP.NPCReloadSound = "Weapon_Shotgun.NPC_Reload" 
SWEP.NPCShootDistanceMult = 0.5
SWEP.Weight = 4
SWEP.NPCHoldType =  "shotgun" -- https://wiki.facepunch.com/gmod/Hold_Types