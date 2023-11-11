-- https://github.com/ValveSoftware/source-sdk-2013/blob/55ed12f8d1eb6887d348be03aee5573d44177ffb/mp/src/game/server/ai_task.h#L89-L502

ZSched = {}

--------------------------------------------------------------------=#
local function SetupScheds()
    for k, func in pairs(ZSched) do
        local sched = ai_schedule.New( k )
        func( ZSched, sched )
        ZSched[k] = sched
    end
end
--------------------------------------------------------------------=#
function ZSched:CombatFace( sched )
    sched:EngTask( "TASK_WAIT_FACE_ENEMY",  2 )
end
--------------------------------------------------------------------=#
function ZSched:FaceLastPos( sched )
    sched:EngTask( "TASK_FACE_LASTPOSITION",  0 )
    --sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end
--------------------------------------------------------------------=#
function ZSched:CombatChase( sched )
    sched:EngTask( "TASK_GET_PATH_TO_ENEMY",  0 )
    sched:EngTask( "TASK_RUN_PATH",  0 )
    sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
end
--------------------------------------------------------------------=#


SetupScheds()