local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/zippy/elitepolice.mdl"}
NPC.StartHealth = 60 -- Max health

NPC.HasArmor = {
    [HITGROUP_CHEST] = true,
    [HITGROUP_HEAD] = true,
}

        -- CUSTOM SOUNDS --
        -- Use sound scripts to alter pitch and level etc..

NPC.MuteDefaultVoice = true -- Mute all default voice sounds emitted by this NPC, use ZBaseEmitSound instead of EmitSound if this is set to true!
NPC.UseCustomSounds = true -- Should the NPC be able to use custom sounds?

NPC.AlertSounds = "ZBaseElitePolice.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "ZBaseElitePolice.Idle" -- Sounds emitted while there is no enemy
NPC.IdleSounds_HasEnemy = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "ZBaseElitePolice.Pain" -- Sounds emitted on hurt
NPC.DeathSounds = "ZBaseElitePolice.Death" -- Sounds emitted on death