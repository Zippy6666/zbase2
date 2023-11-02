local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))

BEHAVIOUR.Patrol = {
    MustNotHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
}

------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:ShouldDoBehaviour( self )
    return self.CanPatrol
end
------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:Run( self )
    self:SetSchedule(SCHED_PATROL_WALK)
    ZBaseDelayBehaviour(math.random(8, 15))
end
------------------------------------------------------------------------=#