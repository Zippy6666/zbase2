AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "ZBase"
SWEP.Author = "Zippy"
SWEP.WorldModel = Model( "models/weapons/w_rif_ak47.mdl" )
SWEP.IsZBaseSWEP = true

SWEP.Primary.Damage = 6 -- The damage of the bullet
SWEP.Primary.ClipSize = 30 -- Clip size
SWEP.Primary.ShootSound = "Weapon_AR2.NPC_Single" -- Shoot sound
SWEP.Primary.ShootDelay = 0.1 -- Shoot cooldown in seconds
SWEP.HoldType = "ar2" -- https://wiki.facepunch.com/gmod/Hold_Typess

SWEP.Primary.Burst = 3 -- Fire this amount of bullets before doing the "SWEP.Primary.BurstCoolDown", this will ignore "SWEP.Primary.ShootDelayMax", false to disable
SWEP.Primary.BurstMax = 9 -- -- If set to a number, the burst will fire a random number of bullets between this and "SWEP.Primary.Burst"