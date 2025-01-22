-- TASKS
-- https://github.com/ValveSoftware/source-sdk-2013/blob/55ed12f8d1eb6887d348be03aee5573d44177ffb/mp/src/game/server/ai_task.h#L89-L502

ZSched = ZSched or {}


--[[
======================================================================================================================================================
                                           SETUP FUNCTION
======================================================================================================================================================
--]]


local function SetupScheds()
    for k, func in pairs(ZSched) do
        if !isfunction(func) then continue end
        local sched = ai_schedule.New( "ZSched"..k )
        
        func( ZSched, sched )
        ZSched[k] = sched
    end
end


--[[
======================================================================================================================================================
                                           COMBAT CHASE SCHEDULES
======================================================================================================================================================
--]]


function ZSched:CombatChase( sched )
    sched:EngTask( "TASK_GET_PATH_TO_ENEMY",  0 )
    sched:EngTask( "TASK_RUN_PATH",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end


function ZSched:CombatChase_CantReach_CoverOrigin( sched )
    sched:EngTask( "TASK_FIND_COVER_FROM_ORIGIN",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end


function ZSched:CombatChase_CantReach_CoverEnemy( sched )
    sched:EngTask( "TASK_FIND_NODE_COVER_FROM_ENEMY",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end


function ZSched:CombatChase_CantReach_MoveRandom( sched )
    sched:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  512 )
    sched:EngTask( "TASK_RUN_PATH",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end

--[[
======================================================================================================================================================
                                           AERIAL
======================================================================================================================================================
--]]

function ZSched:AerialChase_NoNav( sched )
    sched:EngTask( "TASK_WAIT",  3 )
end

function ZSched:AerialBackAway_NoNav( sched )
    sched:EngTask( "TASK_WAIT",  3 )
end

function ZSched:PursueAerialGoal( sched )
    sched:EngTask("TASK_WAIT_INDEFINITE", 0)
end

--[[
======================================================================================================================================================
                                           OTHER SCHEDULES
======================================================================================================================================================
--]]


function ZSched:CombatFace( sched )
    sched:EngTask( "TASK_WAIT_FACE_ENEMY_RANDOM",  3 )
end


function ZSched:FaceLastPos( sched )
    sched:EngTask( "TASK_FACE_LASTPOSITION",  0 )
end


function ZSched:BackAwayFromEnemy( sched )
    sched:EngTask( "TASK_FIND_COVER_FROM_ENEMY",  0 )
    sched:EngTask( "TASK_RUN_PATH",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end


function ZSched:RunRandom( sched )
    sched:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  128 )
    sched:EngTask( "TASK_RUN_PATH",  1 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  1 )
end


function ZSched:WalkRandom( sched )
    sched:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  128 )
    sched:EngTask( "TASK_RUN_PATH",  1 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  1 )
end


SetupScheds()