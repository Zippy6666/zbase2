local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours

BEHAVIOUR.MeleeAttack = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}

-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:ShouldDoBehaviour( self )
    return self.BaseMeleeAttack
    && self:WithinDistance(self:GetEnemy(), self.BaseMeleeAttackDistance)
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:Run( self )
    local duration, anim = table.Random(self.BaseMeleeAttackAnimations)


    -- Animation override --
    self.TimeUntilStopMeleeAnimOverride = CurTime()+duration

    self:InternalSetAnimation(anim)

    local timerName = "ZBaseMeleeAnimOverride"..self:EntIndex()
    timer.Create(timerName, 0, 0, function()
        if !IsValid(self) or self.TimeUntilStopMeleeAnimOverride < CurTime() then
            timer.Remove(timerName)
            return
        end

        self:InternalSetAnimation(anim)

        if !self:IsCurrentSchedule(SCHED_MELEE_ATTACK1)
        && !self:IsCurrentSchedule(SCHED_NPC_FREEZE) then
            self:SetSchedule(SCHED_NPC_FREEZE)
            print("test")
        end
    end)
    ---------------------------------------------=#


    self:SetSchedule(SCHED_MELEE_ATTACK1)

    
    timer.Simple(duration, function()
        if !IsValid(self) then return end

        self:ClearSchedule()
        self:SetActivity(ACT_IDLE)

        print("done")
    end)


    ZBaseDelayBehaviour(duration + ZBaseRndTblRange(self.BaseMeleeAttackCooldown))
end
-----------------------------------------------------------------------------------------------------------------------------------------=#