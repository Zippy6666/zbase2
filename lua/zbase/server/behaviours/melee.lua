local NPC = ZBaseNPCs["npc_zbase"]
local BEHAVIOUR = NPC.Behaviours

BEHAVIOUR.MeleeAttack = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
}

local BusyScheds = {
    [SCHED_MELEE_ATTACK1] = true,
    [SCHED_MELEE_ATTACK2] = true,
    [SCHED_RANGE_ATTACK1] = true,
    [SCHED_RANGE_ATTACK2] = true,
    [SCHED_RELOAD] = true,
}

-----------------------------------------------------------------------------------------------------------------------------------------=#
function NPC:MeleeAttackDamage()
    local soundEmitted = false
    for _, ent in ipairs(ents.FindInSphere(self:WorldSpaceCenter(), self.MeleeDamage_Distance)) do
        if ent == self then continue end
        if ent.GetNPCState && ent:GetNPCState() == NPC_STATE_DEAD then continue end

        local disp = self:Disposition(ent)
        if disp == D_LI or disp == D_NU then continue end

        if !self:Visible(ent) then continue end

        ZBaseBleed( ent, (self:WorldSpaceCenter() + ent:WorldSpaceCenter())*0.5+VectorRand(-15, 15) )

        local dmg = DamageInfo()
        dmg:SetAttacker(self)
        dmg:SetInflictor(self)
        dmg:SetDamage(ZBaseRndTblRange(self.MeleeDamage))
        dmg:SetDamageType(self.MeleeDamage_Type)
        ent:TakeDamageInfo(dmg)

        if !soundEmitted then
            ent:EmitSound(self.MeleeDamage_Sound)
            soundEmitted = true
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end 
    if table.IsEmpty(self.MeleeAttackAnimations) then return false end


    local sched = self:GetCurrentSchedule()

    
    return !BusyScheds[sched]
    && sched <= 88 -- Doing some wacky schedule
    && self:WithinDistance(self:GetEnemy(), self.MeleeAttackDistance)
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:Run( self )
    local prevent = self:BeforeMeleeAttack()

    if prevent then
        return
    end

    -- Animation
    local anim = table.Random(self.MeleeAttackAnimations)
    self:InternalPlayAnimation(anim, nil, self.MeleeAttackAnimationSpeed, SCHED_MELEE_ATTACK1)

    -- Damage
    timer.Simple(self.MeleeDamage_Delay, function()
        if !IsValid(self) then return end
        if self:GetNPCState()==NPC_STATE_DEAD then return end
        self:MeleeAttackDamage()
    end)

    ZBaseDelayBehaviour(self:SequenceDuration() + ZBaseRndTblRange(self.MeleeAttackCooldown))
end
-----------------------------------------------------------------------------------------------------------------------------------------=#