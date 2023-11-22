local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours

BEHAVIOUR.Patrol = {
    MustNotHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
}

local SchedsToReplaceWithPatrol = {
    [SCHED_IDLE_STAND] = true,
    [SCHED_ALERT_STAND] = true,
    [SCHED_ALERT_FACE] = true,
    [SCHED_ALERT_WALK] = true,
}

------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:ShouldDoBehaviour( self )
    return self.CanPatrol
    && SchedsToReplaceWithPatrol[self:GetCurrentSchedule()]
end
------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:Delay(self)
    if self:IsMoving()
    or self.DoingPlayAnim then
        debugoverlay.Text(self:WorldSpaceCenter(), "PATROL DELAYED...")

        return math.random(8, 15)
    end
end
------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:Run( self )
    debugoverlay.Text(self:WorldSpaceCenter(), "PATROL")

    if self:GetNPCState() == NPC_STATE_ALERT then
        self:SetSchedule(SCHED_PATROL_RUN)
    else
        self:SetSchedule(SCHED_PATROL_WALK)
    end
    
    ZBaseDelayBehaviour(math.random(8, 15))
end
------------------------------------------------------------------------=#