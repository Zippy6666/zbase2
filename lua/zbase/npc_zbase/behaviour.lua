/*
    In this file you can add your own NPC behaviours
*/


local NPC = FindZBaseTable(debug.getinfo(1,'S'))
NPC.Behaviours = {}


---------------------------------------------------------------------------------------------------------------------=#


    -- Example --
/*
NPC.Behaviours.SayWhat = {}
NPC.Behaviours.SayWhat.MustHaveVisibleEnemy = true
---------------------------------------------------------------------------------------------------------------------=#
function NPC.Behaviours.SayWhat:ShouldDoBehaviour( self )
    return true
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC.Behaviours.SayWhat:Run( self )

    PrintMessage(HUD_PRINTTALK, "WHAT")
    ZBaseDelayBehaviour( 3 )

end
---------------------------------------------------------------------------------------------------------------------=#
*/



NPC.Behaviours.BehaviourName = {}
NPC.Behaviours.BehaviourName.MustHaveEnemy = false -- Should it only run the behaviour if it has a enemy?
NPC.Behaviours.BehaviourName.MustHaveVisibleEnemy = false -- Should it only run the behaviour if it has a enemy, and its enemy is visible?


-- Return true to allow the behaviour to run, otherwise return false
function NPC.Behaviours.BehaviourName:ShouldDoBehaviour( self )
    return false
end

-- Called before running the behaviour
-- Return a number to delay the behaviour by said number (in seconds)
function NPC.Behaviours.BehaviourName:Delay( self )

end

-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to delay the behaviour (cooldown)
function NPC.Behaviours.BehaviourName:Run( self )
    
end
---------------------------------------------------------------------------------------------------------------------=#