AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "ZBase"
SWEP.Author = "Zippy"
SWEP.WorldModel = Model( "models/weapons/w_irifle.mdl" )
SWEP.IsZBaseSWEP = true

SWEP.Primary.Damage = 8 -- The damage of the bullet
SWEP.Primary.ClipSize = 30 -- Clip size
SWEP.Primary.ShootSound = "Weapon_AR2.NPC_Single" -- Shoot sound
SWEP.Primary.ShootDelay = 0.1 -- Shoot cooldown in seconds
SWEP.HoldType = "ar2" -- https://wiki.facepunch.com/gmod/Hold_Typess

SWEP.Primary.Burst = 5 -- Fire this amount of bullets before doing the "SWEP.Primary.BurstCoolDown", this will ignore "SWEP.Primary.ShootDelayMax", false to disable

SWEP.TracerEffectName = "AirboatGunTracer" -- https://wiki.facepunch.com/gmod/Effects
SWEP.ZBase_MuzzleFlashFlag = 2 -- 1 = Normal, 2 = AR2