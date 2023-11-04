local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours

BEHAVIOUR.DoIdleSound = {
    MustNotHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
}
BEHAVIOUR.DoIdleEnemySound = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
}

local idle_ally_speak_range = 250
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleSound:ShouldDoBehaviour( self )
    if self.IdleSounds == "" then return false end
    if self:GetNPCState() == NPC_STATE_DEAD then return false end
    if self.IdleSound_OnlyNearAllies && self:GetKeyValues().squadname == "" then return end -- Don't speak without a squad, for squad cooldown thingy

    if self.IdleSound_OnlyNearAllies then
        self.IdleSound_CurrentNearestAlly = self:GetNearestAlly(idle_ally_speak_range)
        return IsValid(self.IdleSound_CurrentNearestAlly)
    end

    return true
end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleSound:Delay( self )
    if ZBaseSpeakingSquads[self:GetKeyValues().squadname] or math.random(1, self.IdleSound_Chance)==1 then
        return ZBaseRndTblRange(self.IdleSoundCooldown)
    end
end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleSound:Run( self )
    self:EmitSound_Uninterupted(self.IdleSounds)
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSoundCooldown))

    -- Face each other as if they are talking
    if math.random(1, 2)==1 && IsValid(self.IdleSound_CurrentNearestAlly) then
        self:SetTarget(self.IdleSound_CurrentNearestAlly)
        self:SetSchedule(SCHED_TARGET_FACE)
        self.IdleSound_CurrentNearestAlly:SetTarget(self)
        self.IdleSound_CurrentNearestAlly:SetSchedule(SCHED_TARGET_FACE)
    end
end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleEnemySound:ShouldDoBehaviour( self )
    if self.IdleSounds_HasEnemy == "" then return false end
    if self:GetNPCState() == NPC_STATE_DEAD then return false end

    return true
end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleEnemySound:Delay( self )
    if ZBaseSpeakingSquads[self:GetKeyValues().squadname] then
        return ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown)
    end
end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleEnemySound:Run( self )

    local snd = self.IdleSounds_HasEnemy
    local enemy = self:GetEnemy()

    self:EmitSound_Uninterupted(snd)
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown))

end
------------------------------------------------------------------------=#