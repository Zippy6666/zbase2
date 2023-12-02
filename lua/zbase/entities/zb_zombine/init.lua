local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.StartHealth = 120 -- Max health


NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
}