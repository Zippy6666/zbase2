local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))


/*
    -- In this file you can add custom NPC behaviours


    -- Example --
BEHAVIOUR.SayWhat = {
    MustHaveEnemy = false, -- Should it only run the behaviour if it has an enemy?
    MustHaveVisibleEnemy = false, -- Should it only run the behaviour if it has a enemy, and its enemy is visible?
    MustNotHaveEnemy = false, -- Should it only run the behaviour if it doesn't have an enemy?
}

-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.SayWhat:ShouldDoBehaviour( self )
    return true
end

-- Called before running the behaviour
-- Return a number to delay the behaviour by said number (in seconds)
function BEHAVIOUR.SayWhat:Delay( self )
end

-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to delay the behaviour (cooldown)
function BEHAVIOUR.SayWhat:Run( self )
    PrintMessage(HUD_PRINTTALK, "WHAT")
    ZBaseDelayBehaviour( 3 )
end
*/


------------------------------------------------------------------------=#

    -- Base behaviours --
BEHAVIOUR.Patrol = {
    MustNotHaveEnemy = true, -- Should it only run the behaviour if it doesn't have an enemy?
}

function BEHAVIOUR.Patrol:ShouldDoBehaviour( self )
    return self.CanPatrol
end

function BEHAVIOUR.Patrol:Run( self )
    self:SetSchedule(SCHED_PATROL_WALK)
    ZBaseDelayBehaviour(math.random(5, 10))
end

------------------------------------------------------------------------=#