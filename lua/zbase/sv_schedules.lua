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
        local sched = ai_schedule.New( "SCHED_ZBASE_"..k )
        
        func( ZSched, sched )
        ZSched[k] = sched
    end
end


--[[
======================================================================================================================================================
                                           COMBAT CHASE SCHEDULES
======================================================================================================================================================
--]]

 
function ZSched:COMBAT_CHASE( sched )
    sched:EngTask( "TASK_GET_PATH_TO_ENEMY",  0 )
    sched:EngTask( "TASK_RUN_PATH",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end


function ZSched:COMBAT_CHASE_FAIL_COVER_ORIGIN( sched )
    sched:EngTask( "TASK_FIND_COVER_FROM_ORIGIN",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end


function ZSched:COMBAT_CHASE_FAIL_COVER_ENE( sched )
    sched:EngTask( "TASK_FIND_NODE_COVER_FROM_ENEMY",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end


function ZSched:COMBAT_CHASE_FAIL_MOVE_RANDOM( sched )
    sched:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  512 )
    sched:EngTask( "TASK_RUN_PATH",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end

function ZSched:ESTABLISH_LINE_OF_FIRE( sched )
    sched:EngTask( "TASK_GET_FLANK_RADIUS_PATH_TO_ENEMY_LOS",  512 )
    sched:EngTask( "TASK_RUN_PATH",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end

--[[
======================================================================================================================================================
                                           AERIAL
======================================================================================================================================================
--]]

function ZSched:FLY_CHASE_NO_NAV( sched )
    sched:EngTask( "TASK_WAIT",  3 )
end

function ZSched:FLY_AWAY_NO_NAV( sched )
    sched:EngTask( "TASK_WAIT",  3 )
end

function ZSched:FLY_TO_GOAL( sched )
    sched:EngTask("TASK_WAIT_INDEFINITE", 0)
end

--[[
======================================================================================================================================================
                                           OTHER SCHEDULES
======================================================================================================================================================
--]]


function ZSched:COMBAT_FACE( sched )
    sched:EngTask( "TASK_WAIT_FACE_ENEMY_RANDOM",  3 )
end


function ZSched:FACE_LASTPOS( sched )
    sched:EngTask( "TASK_FACE_LASTPOSITION",  0 )
end


function ZSched:BACK_AWAY( sched )
    sched:EngTask( "TASK_FIND_COVER_FROM_ENEMY",  0 )
    sched:EngTask( "TASK_RUN_PATH",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end


function ZSched:RUN_RANDOM( sched )
    sched:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  128 )
    sched:EngTask( "TASK_RUN_PATH",  1 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  1 )
end


function ZSched:WALK_RANDOM( sched )
    sched:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  128 )
    sched:EngTask( "TASK_RUN_PATH",  1 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  1 )
end


SetupScheds()