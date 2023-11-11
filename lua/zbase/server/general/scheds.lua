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


SetupScheds()