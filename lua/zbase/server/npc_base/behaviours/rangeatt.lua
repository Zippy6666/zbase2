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
    -- Doesn't have range attack
    if !self.BaseRangeAttack then return false end


    local ene = self:GetEnemy()
    local seeEnemy = self.EnemyVisible -- IsValid(ene) && self:Visible(ene)
    local trgtPos = self:Projectile_TargetPos()


    -- Can't see target position
    -- if !self:VisibleVec(trgtPos) then return false end


    -- Not in distance
    if !self:ZBaseDist(trgtPos, {away=self.RangeAttackDistance[1], within=self.RangeAttackDistance[2]}) then return false end


    -- Supress disabled, and enemy not visible
    if !self.RangeAttackSuppressEnemy && seeEnemy then return false end


    -- Don't suppress enemy if behind it for example
    if self.RangeAttackSuppressEnemy && !self:IsFacing( ene, 70 ) && !seeEnemy then
        return false
    end


    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.RangeAttack:Run( self )
    self:RangeAttack()
    ZBaseDelayBehaviour(self:SequenceDuration() + 0.25 + ZBaseRndTblRange(self.RangeAttackCooldown))
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