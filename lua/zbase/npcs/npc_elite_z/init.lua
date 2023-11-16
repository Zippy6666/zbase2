local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/Combine_Super_Soldier.mdl"}
NPC.WeaponProficiency = WEAPON_PROFICIENCY_PERFECT -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 70 -- Max health

NPC.m_iNumGrenades = 5
NPC.m_nKickDamage = 20
NPC.m_iTacticalVariant = 1

NPC.DeathAnimations = {"rappel_a"} -- Death animations to use, leave empty to disable the base death animation
NPC.DeathAnimationSpeed = 1 -- Speed of the death animation
NPC.DeathAnimationChance = 2 --  Flinch animation chance 1/x