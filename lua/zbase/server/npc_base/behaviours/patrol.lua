local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours

BEHAVIOUR.Patrol = {
    MustNotHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
}

------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:ShouldDoBehaviour( self )
    return self.CanPatrol
end
------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:Delay(self)
    if self:IsMoving() or self.DoingPlayAnim then
        debugoverlay.Text(self:WorldSpaceCenter(), "PATROL DELAYED...")

        return math.random(8, 15)
    end
end
------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:Run( self )
    debugoverlay.Text(self:WorldSpaceCenter(), "PATROL")

    self:SetSchedule(SCHED_PATROL_WALK)
    
    ZBaseDelayBehaviour(math.random(8, 15))
end
------------------------------------------------------------------------=#