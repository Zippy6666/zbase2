local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/Combine_Super_Soldier.mdl"}
NPC.WeaponProficiency = WEAPON_PROFICIENCY_PERFECT -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 70 -- Max health

NPC.m_nKickDamage = 30