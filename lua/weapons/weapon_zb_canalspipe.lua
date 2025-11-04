AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Pipe"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = true -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/props_canal/mattpipe.mdl" )

SWEP.NPCIsMeleeWep = true
SWEP.Weight = 0
SWEP.NPCMeleeWep_Damage = {20, 30} -- Melee weapon damage {min max}
SWEP.NPCHoldType =  "melee" -- https://wiki.facepunch.com/gmod/Hold_Types

SWEP.NPCMeleeWep_HitSound = "Weapon_Crowbar.Melee_HitWorld" -- Sound when the melee weapon hits an entity

SWEP.Primary.Ammo = -1