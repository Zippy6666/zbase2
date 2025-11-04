AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Pistol"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.Weight = 4

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_shotgun.mdl" )

SWEP.PrimaryShootSound = "Weapon_Shotgun.Single"
SWEP.PrimarySpread = 0.03
SWEP.PrimaryDamage = 2
SWEP.Primary.DefaultClip = 8 
SWEP.Primary.Ammo = "Buckshot" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1" 
SWEP.Primary.ShellType = "ShotgunShellEject" -- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.NumShots = 11
SWEP.Primary.MuzzleFlashFlags = 7
SWEP.NPCBurstMin = 1
SWEP.NPCBurstMax = 1
SWEP.NPCFireRate = 0.66
SWEP.NPCFireRestTimeMin = 0.66 
SWEP.NPCFireRestTimeMax = 1
SWEP.NPCBulletSpreadMult = 1 
SWEP.NPCReloadSound = "Weapon_Shotgun.NPC_Reload" 
SWEP.NPCShootDistanceMult = 0.5

SWEP.NPCHoldType =  "shotgun" -- https://wiki.facepunch.com/gmod/Hold_Types