local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 40 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour

NPC.ZBaseFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"

NPC.HasArmor = {
    [HITGROUP_CHEST] = true,
}

local arrest = 2097152
local extendedAttackRange = 33554432
NPC.KeyValues = {spawnflags=bit.bor(extendedAttackRange, arrest), weapondrawn="1"}