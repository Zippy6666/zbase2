AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Pistol"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_stunbaton.mdl" )

SWEP.NPCIsMeleeWep = true
SWEP.Weight = 0
SWEP.NPCHoldType =  "melee" -- https://wiki.facepunch.com/gmod/Hold_Types
SWEP.NPCMeleeWep_Damage = {5, 10} -- Melee weapon damage {min max}
SWEP.NPCMeleeWep_DamageType = DMG_SHOCK -- Melee weapon damage type
SWEP.NPCMeleeWep_HitSound = "Weapon_StunStick.Melee_Hit" -- Sound when the melee weapon hits an entity
SWEP.NPCMeleeWep_DamageAngle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
SWEP.NPCMeleeWep_DamageDist = 100 -- Melee weapon damage reach distance