AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "ZBase"
SWEP.Author = "Zippy"
SWEP.WorldModel = Model( "models/weapons/w_shotgun.mdl" )
SWEP.IsZBaseSWEP = true

SWEP.Primary.Damage = 8 -- The damage of the bullet
SWEP.Primary.NumBullets = 7
SWEP.Primary.ClipSize = 8 -- Clip size
SWEP.Primary.ShootSound = "Weapon_Shotgun.NPC_Single" -- Shoot sound
SWEP.Primary.ShootDelay = 1 -- Shoot cooldown in seconds
SWEP.Primary.ShootDelayMax = 1.5 -- If set to a number, the shoot cooldown will be a random number between this and "SWEP.Primary.ShootDelay"
SWEP.Primary.BulletForce = 5 -- Amount of force that the bullet puts on physics
SWEP.HoldType = "shotgun" -- https://wiki.facepunch.com/gmod/Hold_Typess

SWEP.Primary.Spread = 0.03

SWEP.ZBase_MuzzleFlashFlag = 3 -- 1 = Normal, 2 = AR2, 2 = Shotgun