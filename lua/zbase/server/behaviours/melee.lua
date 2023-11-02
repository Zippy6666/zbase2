local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours

BEHAVIOUR.MeleeAttack = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}

local BusyScheds = {
    [SCHED_MELEE_ATTACK1] = true,
    [SCHED_MELEE_ATTACK2] = true,
    [SCHED_RANGE_ATTACK1] = true,
    [SCHED_RANGE_ATTACK2] = true,
    [SCHED_RELOAD] = true,
}

-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:ShouldDoBehaviour( self )
    local sched = self:GetCurrentSchedule()

    return self.BaseMeleeAttack
    && !BusyScheds[sched]
    && sched <= 88 -- Doing some wacky schedule
    && self:WithinDistance(self:GetEnemy(), self.MeleeAttackDistance)
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:Run( self )
    local anim = table.Random(self.MeleeAttackAnimations)

    self:InternalPlayAnimation(anim, nil, nil, SCHED_MELEE_ATTACK1)
    ZBaseDelayBehaviour(self:SequenceDuration() + ZBaseRndTblRange(self.MeleeAttackCooldown))
end
-----------------------------------------------------------------------------------------------------------------------------------------=#