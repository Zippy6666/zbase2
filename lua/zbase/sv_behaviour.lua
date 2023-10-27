local ZBaseDelayEnt = NULL
local ZBaseDelayBehaviour_Name
---------------------------------------------------------------------------------------=#
function ZBaseDelayBehaviour( delay )
    if IsValid(ZBaseDelayEnt) && ZBaseDelayBehaviour_Name then
        ZBaseDelayEnt.ZBase_Behaviour_Delays[ZBaseDelayBehaviour_Name] = CurTime() + delay
    end
end
---------------------------------------------------------------------------------------=#
local function BehaviourTimer( ent )
    ZBaseDelayEnt = ent

    for BehaviourName, Behaviour in pairs(ent.Behaviours) do

        ZBaseDelayBehaviour_Name = BehaviourName

        local delay = Behaviour.Delay && Behaviour:Delay( ent )
        if delay then
            ZBaseDelayBehaviour( ent, BehaviourName, delay )
        end

        if ent.ZBase_Behaviour_Delays[BehaviourName] > CurTime() then continue end
        if !Behaviour:ShouldDoBehaviour( ent ) then continue end

        local ene = ent:GetEnemy()

        if (Behaviour.MustHaveEnemy or Behaviour.MustHaveVisibleEnemy) && !IsValid(ene) then continue end
        if IsValid(ene) then
            if Behaviour.MustHaveVisibleEnemy && !ent:Visible(ene) then continue end
        end

        Behaviour:Run( ent )

    end

    ZBaseDelayEnt = NULL
    ZBaseDelayBehaviour_Name = nil
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