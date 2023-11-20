local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/zippy/ElitePolice.mdl"}
NPC.StartHealth = 60 -- Max health

NPC.WeaponProficiency = WEAPON_PROFICIENCY_PERFECT -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.HasArmor = {
    [HITGROUP_CHEST] = true,
    [HITGROUP_HEAD] = true,
}

        -- CUSTOM SOUNDS --
        -- Use sound scripts to alter pitch and level etc..

NPC.MuteDefaultVoice = true -- Mute all default voice sounds emitted by this NPC
NPC.IdleSound_OnlyNearAllies = true -- Only do IdleSounds if there is another NPC in the same faction nearby

NPC.AlertSounds = "ZBaseElitePolice.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "ZBaseElitePolice.Idle" -- Sounds emitted while there is no enemy
NPC.IdleSounds_HasEnemy = "ZBaseElitePolice.IdleEnemy" -- Sounds emitted while there is an enemy
NPC.PainSounds = "ZBaseElitePolice.Pain" -- Sounds emitted on hurt
NPC.DeathSounds = "ZBaseElitePolice.Death" -- Sounds emitted on death
NPC.KilledEnemySound = "ZBaseElitePolice.KilledEnemy" -- Sounds emitted when the NPC kills an enemy
NPC.LostEnemySounds = "ZBaseElitePolice.LostEnemy"
NPC.SeeDangerSounds = "ZBaseElitePolice.SeeDanger"
NPC.AllyDeathSounds = "ZBaseElitePolice.AllyDeath"
NPC.HearDangerSounds = "ZBaseElitePolice.HearDanger"
NPC.Dialogue_Question_Sounds = "ZBaseElitePolice.Question"
NPC.Dialogue_Answer_Sounds = "ZBaseElitePolice.Answer"

--]]==============================================================================================]]

    -- Return a new sound name to play that sound instead.
    -- Return false to prevent the sound from playing.
function NPC:CustomOnEmitSound( sndData, sndVarName )
    if sndVarName == "DeathSounds" && self:IsOnFire() then
        return "ZBaseElitePolice.FireDeath"
    end


    local ene = self:GetEnemy()


    if sndVarName == "AlertSounds"
    && IsValid(ene)
    && self:Visible(ene)
    && self:ZBaseDist(ene, {within=1500})
    && IsValid(ene:GetActiveWeapon()) then
        return "ZBaseElitePolice.AlertArmed"
    end


    if sndVarName == "IdleSounds" && IsValid(ene) && !self:Visible(ene) then
        return "ZBaseElitePolice.IdleEnemyOccluded"
    end


    if sndVarName == "HearDangerSounds"
    && IsValid(self.HearDanger_SoundEmitter)
    && self:ZBaseDist(self.HearDanger_SoundEmitter, {within=600}) then
        return "ZBaseElitePolice.HearDangerClose"
    end
end
--]]==============================================================================================]]

    -- Called when the base detects that the NPC is playing a new activity
function NPC:CustomNewActivityDetected( act )
    -- 2152 = Deploy manhack
    if act==2152 then
        self:EmitSound_Uninterupted("ZBaseElitePolice.Deploy")
    end
end
--]]==============================================================================================]]