local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours

BEHAVIOUR.MeleeAttack = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}

------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:ShouldDoBehaviour( self )
    return self.BaseMeleeAttack
    && self:WithinDistance(self:GetEnemy(), self.BaseMeleeAttackDistance)
end
------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:Run( self )
    local anim, duration = table.Random(self.BaseMeleeAttackAnimations)
    self:PlayAnimation(anim, duration)
end
------------------------------------------------------------------------=#