local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.StartHealth = 100 -- Max health

-- Armor
NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
}

-- Footstep
NPC.FootStepSounds = "ZBaseCombine.Step"

-- Torso / legs models
NPC.TorsoModel = "models/zombie/zombie_soldier_torso.mdl"
NPC.LegsModel = "models/zombie/zombie_soldier_legs.mdl"