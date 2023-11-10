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

    -- In distance
    if !self:ZBaseDist(self:Projectile_TargetPos(), {away=self.RangeAttackDistance[1], within=self.RangeAttackDistance[2]}) then return false end

    local seeEnemy = IsValid(ene) && self:Visible(ene)

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
        -- Animation --
    self:InternalPlayAnimation(
        table.Random(self.RangeAttackAnimations),
        nil,
        self.RangeAttackAnimationSpeed,
        SCHED_NPC_FREEZE,
        nil
    )
    local duration = self:SequenceDuration() + 0.25
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


    -- Special face code
    self.TimeUntilStopFace = CurTime()+duration

    timer.Create("ZBaseFace"..self:EntIndex(), 0, 0, function()
        if !IsValid(self) or self.TimeUntilStopFace < CurTime() then
            timer.Remove("ZBaseFace"..self:EntIndex())
            return
        end

        if GetConVar("ai_disabled"):GetBool() then return end

        local ene = self:GetEnemy()
        local seeEnemy = IsValid(ene) && self:Visible(ene)
        local facePos = seeEnemy && ene:WorldSpaceCenter() or self:Projectile_TargetPos()
        local yaw = (facePos - self:GetPos()):Angle().y

        self:SetIdealYawAndUpdate(yaw, self.RangeAttackTurnSpeed)
    end)
    -----------------------------------------------------------------=#


    ZBaseDelayBehaviour(duration + ZBaseRndTblRange(self.RangeAttackCooldown))
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