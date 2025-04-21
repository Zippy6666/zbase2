AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Crowbar"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_crowbar.mdl" )

SWEP.NPCIsMeleeWep = true
SWEP.Weight = 0
SWEP.NPCMeleeWep_Damage = {10, 20} -- Melee weapon damage {min max}
SWEP.NPCHoldType =  "melee" -- https://wiki.facepunch.com/gmod/Hold_Types