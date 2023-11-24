local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 40 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour

NPC.ZBaseStartFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"

NPC.HasArmor = {
    [HITGROUP_CHEST] = true,
}

NPC.BaseMeleeAttack = true
NPC.MeleeDamage_Delay = 0.5
NPC.MeleeAttackAnimations = {
    "Swing",
}

local SF_ARREST = 2097152
NPC.SpawnFlagTbl = {SF_ARREST, SF_NPC_DROP_HEALTHKIT}
NPC.KeyValues = {weapondrawn="1"}


--]]==============================================================================================]]
function NPC:CustomInitialize()
end
--]]==============================================================================================]]