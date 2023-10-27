/*
    In this file you can add your own NPC behaviours
*/

local NPC = FindZBaseTable(debug.getinfo(1,'S'))
NPC.Behaviours = {}




---------------------------------------------------------------------------------------------------------------------=#


/*
    Follow this structure
*/



NPC.Behaviours.BehaviourName = {}
NPC.Behaviours.BehaviourName.MustHaveEnemy = false
NPC.Behaviours.BehaviourName.MustHaveVisibleEnemy = false

function NPC.Behaviours.BehaviourName:ShouldDoBehaviour( self )
    return true
end

function NPC.Behaviours.BehaviourName:Delay( self )
end

function NPC.Behaviours.BehaviourName:Run( self )
end
---------------------------------------------------------------------------------------------------------------------=#




    -- Example --
    
NPC.Behaviours.SayWhat = {}
---------------------------------------------------------------------------------------------------------------------=#
function NPC.Behaviours.SayWhat:ShouldDoBehaviour( self )
    return true
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC.Behaviours.SayWhat:Run( self )

    PrintMessage(HUD_PRINTTALK, "WHAT")
    ZBaseDelayBehaviour( self, "SayWhat", 3 )

end
---------------------------------------------------------------------------------------------------------------------=#