local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))

/*
        -- Example --

BEHAVIOUR.SayWhat = {

    MustHaveEnemy = false, -- Should it only run the behaviour if it has an enemy? 
    MustNotHaveEnemy = false, --  Don't run the behaviour if the NPC doesn't have an enemy
    MustHaveVisibleEnemy = false, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = false, -- Only run the behaviour if the NPC is facing its enemy

}
------------------------------------------------------------------------=#
-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.SayWhat:ShouldDoBehaviour( self )
    return true
end
------------------------------------------------------------------------=#
-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.SayWhat:Delay( self )
end
------------------------------------------------------------------------=#
-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to delay the behaviour (cooldown)
function BEHAVIOUR.SayWhat:Run( self )
    PrintMessage(HUD_PRINTTALK, "WHAT")
    ZBaseDelayBehaviour( 3 )
end
------------------------------------------------------------------------=#
*/
