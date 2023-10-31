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
NPC.IdleSound_OnlyNearAllies = true -- Only do IdleSounds if there is another NPC in the same faction nearby

NPC.AlertSounds = "ZBaseElitePolice.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "ZBaseElitePolice.Idle" -- Sounds emitted while there is no enemy
NPC.IdleSounds_HasEnemy = "ZBaseElitePolice.IdleEnemy" -- Sounds emitted while there is an enemy
NPC.PainSounds = "ZBaseElitePolice.Pain" -- Sounds emitted on hurt
NPC.DeathSounds = "ZBaseElitePolice.Death" -- Sounds emitted on death
NPC.KilledEnemySound = "ZBaseElitePolice.KilledEnemy" -- Sounds emitted when the NPC kills an enemy

---------------------------------------------------------------------------------------------------------------------=#

    -- Return a new sound name to play that sound instead.
    -- Return false to prevent the sound from playing.
function NPC:CustomOnEmitSound( sndData )
    local sndName = sndData.OriginalSoundName

    if sndName == "ZBaseElitePolice.Death" && self:IsOnFire() then
        return "ZBaseElitePolice.FireDeath"
    end

    local ene = self:GetEnemy()

    if sndName == "ZBaseElitePolice.Alert" && IsValid(ene) && IsValid(ene:GetActiveWeapon()) then
        return "ZBaseElitePolice.AlertArmed"
    end

    if sndName == "ZBaseElitePolice.EnemyIdle" && IsValid(ene) && !self:Visible(enemy) then
        return "ZBaseElitePolice.IdleEnemyOccluded"
    end
end
---------------------------------------------------------------------------------------------------------------------=#