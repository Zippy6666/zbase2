local NPC = ZBaseNPCs["npc_zbase"]
local BEHAVIOUR = NPC.Behaviours

BEHAVIOUR.RangeAttack = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
}
BEHAVIOUR.PreRangeAttack = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
}

-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.RangeAttack:ShouldDoBehaviour( self )
    if !self.BaseRangeAttack
    or !self:ZBaseDist(self:GetEnemy(), {away=self.RangeAttackDistance[1], within=self.RangeAttackDistance[2]}) then return false end

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
        self.RangeAttackFaceEnemy && self:GetEnemy(),
        self.RangeAttackTurnSpeed
    )
    -----------------------------------------------------------------=#

        -- Projectile --
    if self.RangeProjectile_Delay then
        timer.Simple(self.RangeProjectile_Delay, function()
            if !IsValid(self) then return end
            if self:GetNPCState()==NPC_STATE_DEAD then return end

            self:RangeAttackProjectile()
        end)
    end
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