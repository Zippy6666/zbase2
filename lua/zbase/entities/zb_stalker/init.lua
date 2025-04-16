local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.StartHealth = 70 -- Max health

-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "combine"

-- Stalker internal variables
NPC.m_iPlayerAggression = 1 -- Hate players by default
NPC.m_eBeamPower = 2        -- More powerful beam

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC

NPC.FootStepSounds = "NPC_Stalker.FootstepLeft"

-- Footstep timer (if active)
NPC.FootStepSoundDelay_Walk = 0.8 -- Step cooldown when walking
NPC.FootStepSoundDelay_Run = 0.8 -- Step cooldown when running