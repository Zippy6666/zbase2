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

    self:InternalPlayAnimation(anim, duration, 1, SCHED_MELEE_ATTACK1)
    ZBaseDelayBehaviour(self:SequenceDuration() + ZBaseRndTblRange(self.BaseMeleeAttackCooldown))
end
-----------------------------------------------------------------------------------------------------------------------------------------=#