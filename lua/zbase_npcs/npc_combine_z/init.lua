local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 50 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour

NPC.ZBaseFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"

NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
    [HITGROUP_HEAD] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
    [HITGROUP_LEFTARM] = false,
    [HITGROUP_RIGHTARM] = false,
    [HITGROUP_LEFTLEG] = true,
    [HITGROUP_RIGHTLEG] = true,
    [HITGROUP_GEAR] = false,
}

NPC.m_iNumGrenades = 5
NPC.m_iTacticalVariant = 1