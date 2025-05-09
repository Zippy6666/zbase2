local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.SpawnFlagTbl = {SF_CITIZEN_MEDIC, SF_CITIZEN_RANDOM_HEAD_MALE}

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