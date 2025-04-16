local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.MoveSpeedMultiplier = 1.33 -- Multiply the NPC's movement speed by this amount (ground NPCs)
NPC.StartHealth = 60 -- Max health

-- Footstep
NPC.FootStepSounds = "NPC_FastZombie.FootstepLeft"

-- Torso / legs models
NPC.TorsoModel = "models/gibs/fast_zombie_torso.mdl"
NPC.LegsModel = "models/gibs/fast_zombie_legs.mdl"