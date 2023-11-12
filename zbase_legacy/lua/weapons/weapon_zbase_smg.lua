AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "ZBase"
SWEP.Author = "Zippy"
SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" )
SWEP.IsZBaseSWEP = true

SWEP.Primary.Damage = 4 -- The damage of the bullet
SWEP.Primary.ClipSize = 45 -- Clip size
SWEP.Primary.ShootSound = "Weapon_SMG1.NPC_Single" -- Shoot sound
SWEP.Primary.ShootDelay = 0.1 -- Shoot cooldown in seconds
SWEP.HoldType = "smg" -- https://wiki.facepunch.com/gmod/Hold_Types