---------------------------------------------------------------------------------------=#
function ZBaseDelayBehaviour( ent, BehaviourName, delay )
    ent.ZBase_Behaviour_Delays[BehaviourName] = CurTime() + delay
end
---------------------------------------------------------------------------------------=#
local function BehaviourTimer( ent )
    for BehaviourName, Behaviour in pairs(ent.Behaviours) do

        local delay = Behaviour.Delay && Behaviour:Delay( ent )
        if delay then
            ZBaseDelayBehaviour( ent, BehaviourName, delay )
        end

        if ent.ZBase_Behaviour_Delays[BehaviourName] > CurTime() or !Behaviour:ShouldDoBehaviour( ent ) then
            continue
        end

        Behaviour:Run( ent )

    end
end
---------------------------------------------------------------------------------------=#
function ZBaseBehaviourInit( ent )

    ent.ZBase_Behaviour_Delays = {}

    for BehaviourName in pairs(ent.Behaviours) do
        ent.ZBase_Behaviour_Delays[BehaviourName] = CurTime()
    end
    
    local function timerFunc()
        if !IsValid(ent) then return false end
        BehaviourTimer( ent )
        return true
    end

    table.insert(ZBaseBehaviourTimerFuncs, timerFunc)

end
---------------------------------------------------------------------------------------=#
timer.Create("ZBaseBehaviourTimer", 0.5, 0, function()

    for k, func in ipairs(ZBaseBehaviourTimerFuncs) do
        local entValid = func()
        if !entValid then
            table.remove(ZBaseBehaviourTimerFuncs, k)
        end
    end

end)
---------------------------------------------------------------------------------------=#