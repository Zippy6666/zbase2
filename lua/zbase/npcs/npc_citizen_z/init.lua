local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.WeaponProficiency = WEAPON_PROFICIENCY_AVERAGE -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.StartHealth = 30 -- Max health
NPC.CanPatrol = false -- Use base patrol behaviour


NPC.ZBaseStartFaction = "ally" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"


NPC.BaseMeleeAttack = true
NPC.MeleeAttackAnimations = {"swing"}
NPC.MeleeAttackAnimationSpeed = 1
NPC.MeleeDamage_Delay = 0.5 -- Time until the damage strikes

NPC.BloodColor = DONT_BLEED -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER
NPC.CustomBloodParticles = false -- Table of custom particles.
NPC.CustomBloodDecals = "ZBaseBloodBlue" -- String name of custom decal