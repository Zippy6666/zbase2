AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "ZBase"
SWEP.Author = "Zippy"
SWEP.WorldModel = Model( "models/weapons/w_pistol.mdl" )
SWEP.IsZBaseSWEP = true

SWEP.Primary.Damage = 5 -- The damage of the bullet
SWEP.Primary.ClipSize = 20 -- Clip size
SWEP.Primary.ShootSound = "Weapon_Pistol.Single" -- Shoot sound
SWEP.Primary.ShootDelay = 0.3 -- Shoot cooldown in seconds
SWEP.Primary.ShootDelayMax = 0.6 -- If set to a number, the shoot cooldown will be a random number between this and "SWEP.Primary.ShootDelay"
SWEP.HoldType = "pistol" -- https://wiki.facepunch.com/gmod/Hold_Typess