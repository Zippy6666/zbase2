local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.StartHealth = 100 -- Max health
NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
}


NPC.MoveSpeedMultiplier = 1.33 -- Multiply the NPC's movement speed by this amount (ground NPCs)


NPC.FootStepSounds = "ZBaseCombine.Step"


NPC.TorsoModel = "models/zombie/zombie_soldier_torso.mdl"
NPC.LegsModel = "models/zombie/zombie_soldier_legs.mdl"
