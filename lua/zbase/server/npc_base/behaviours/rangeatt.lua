local NPC = ZBaseNPCs["npc_zbase"]
local BEHAVIOUR = NPC.Behaviours

BEHAVIOUR.RangeAttack = {
}
BEHAVIOUR.PreRangeAttack = {
}

-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.RangeAttack:ShouldDoBehaviour( self )
    if !self.BaseRangeAttack then return false end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.RangeAttack:Run( self )
        -- Animation --
    self:InternalPlayAnimation(
        table.Random(self.RangeAttackAnimations),
        nil,
        self.RangeAttackAnimationSpeed,
        SCHED_NPC_FREEZE,
        self.RangeAttackFaceEnemy && self:GetEnemy()
    )
    -----------------------------------------------------------------=#

    ZBaseDelayBehaviour(self:SequenceDuration() + ZBaseRndTblRange(self.RangeAttackCooldown))
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.PreRangeAttack:ShouldDoBehaviour( self )
    if !self.BaseRangeAttack then return false end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.PreRangeAttack:Run( self )
    self:MultipleRangeAttacks()
end
-----------------------------------------------------------------------------------------------------------------------------------------=#