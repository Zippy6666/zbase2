include("shared.lua")

-- General
ENT.Models = ZBASE_TBL({"models/Police.mdl"}) -- Models to spawn with, add as many as you want

ENT.StartHealth = 40
ENT.HullType = HULL_HUMAN -- https://wiki.facepunch.com/gmod/Enums/HULL
ENT.BloodColor = BLOOD_COLOR_RED -- https://wiki.facepunch.com/gmod/Enums/BLOOD_COLOR
ENT.SightDistance = 10000

-- Faction
ENT.ZBase_Factions = ZBASE_TBL({"CLASS_COMBINE"}) -- Add as many as you want

-- Patrol type:
ENT.Patrol = "turn"

-- Melee Attack
ENT.MeleeAttack = true -- Should it melee attack?
ENT.MeleeAttackAnimations = ZBASE_TBL({"swing"}) -- Sequence name, or activity (https://wiki.facepunch.com/gmod/Enums/ACT)
ENT.MeleeAttackSequenceDuration = 0.75 -- How long should the AI remain "paused" then doing melee sequence, false = duration of the animation
ENT.MeleeAttackDamage = 10 -- Melee attack damage
ENT.MeleeAttackDamageDelay = 0.5 -- Time until damage

ENT.WeaponProficiency = WEAPON_PROFICIENCY_AVERAGE -- https://wiki.facepunch.com/gmod/Enums/WEAPON_PROFICIENCY

ENT.AlertAllyDistanceInfinite = true -- Call allies from anywhere, realistic if the NPC has a radio for example