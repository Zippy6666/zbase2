local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/zippy/combine_medic.mdl"}
NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 45 -- Max health

NPC.SpawnFlagTbl = {SF_CITIZEN_MEDIC}

NPC.MuteDefaultVoice = true

function NPC:CustomThink()
    -- Only heal player if they are friendly to us

    local ene = self:GetEnemy()
    local eneIsPly = IsValid(ene) && ene:IsPlayer()

    if eneIsPly && self.CanHeal then
        self:Fire("SetMedicOff")
        self.CanHeal = nil
    elseif !eneIsPly && !self.CanHeal then
        self:Fire("SetMedicOn")
        self.CanHeal = true
    end
end