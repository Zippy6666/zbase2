local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))


    -- "Behaviour system"
    -- Useful for making new attacks for example
    -- You can add as many as you want to your NPC


--[[
==================================================================================================
                                           Attack 1
==================================================================================================
--]]


BEHAVIOUR.ExampleAttack = {
    MustHaveEnemy = false, -- Should it only run the behaviour if it has an enemy? 
    MustNotHaveEnemy = false, --  Don't run the behaviour if the NPC doesn't have an enemy
    MustHaveVisibleEnemy = false, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = false, -- Only run the behaviour if the NPC is facing its enemy
}


-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.ExampleAttack:ShouldDoBehaviour( self )
    return false
end


-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.ExampleAttack:Delay( self )
end


-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to put the behaviour on a cooldown
function BEHAVIOUR.ExampleAttack:Run( self )
end


--[[
==================================================================================================
                                           Attack 2
==================================================================================================
--]]


BEHAVIOUR.ExampleAttack2 = {
    MustHaveEnemy = false, -- Should it only run the behaviour if it has an enemy? 
    MustNotHaveEnemy = false, --  Don't run the behaviour if the NPC doesn't have an enemy
    MustHaveVisibleEnemy = false, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = false, -- Only run the behaviour if the NPC is facing its enemy
}


-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.ExampleAttack2:ShouldDoBehaviour( self )
    return false
end


-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.ExampleAttack2:Delay( self )
end


-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to put the behaviour on a cooldown
function BEHAVIOUR.ExampleAttack2:Run( self )
end