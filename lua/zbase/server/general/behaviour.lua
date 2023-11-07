local ZBaseDelayEnt = NULL
local ZBaseDelayBehaviour_Name
local NextBehaviourThink = CurTime()
---------------------------------------------------------------------------------------=#
function ZBaseDelayBehaviour( delay, ent, name )
    local Ent = ent or ZBaseDelayEnt
    local BehaviourName = name or ZBaseDelayBehaviour_Name

    if IsValid(Ent) && BehaviourName then
        Ent.ZBase_Behaviour_Delays[BehaviourName] = CurTime() + delay
    end
end
---------------------------------------------------------------------------------------=#
local function BehaviourTimer( ent )
    ZBaseDelayEnt = ent

    for BehaviourName, Behaviour in pairs(ent.Behaviours) do

        if !Behaviour.Run then continue end
        ZBaseDelayBehaviour_Name = BehaviourName

        if ent.ZBase_Behaviour_Delays[BehaviourName] > CurTime() then continue end
        if Behaviour.ShouldDoBehaviour && !Behaviour:ShouldDoBehaviour( ent ) then continue end

        local enemy = ent:GetEnemy()
        local has_ene = IsValid(enemy)

        if (Behaviour.MustHaveEnemy && !has_ene)
        or (Behaviour.MustNotHaveEnemy && has_ene)
        or (Behaviour.MustHaveVisibleEnemy && has_ene && !ent:Visible(enemy) )
        or (Behaviour.MustFaceEnemy && !ent:IsFacing(enemy)) then
            continue
        end

        local delay = Behaviour.Delay && Behaviour:Delay( ent )
        if delay then
            ZBaseDelayBehaviour( delay, ent, BehaviourName )
            return
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
hook.Add("Think", "ZBaseBehaviourTimer", function()
    if NextBehaviourThink > CurTime() then return end
    if GetConVar("ai_disabled"):GetBool() then return end

    for k, func in ipairs(ZBaseBehaviourTimerFuncs) do

        local entValid = func()

        if !entValid then
            table.remove(ZBaseBehaviourTimerFuncs, k)
        end

    end

    NextBehaviourThink = CurTime() + 0.4
end)
---------------------------------------------------------------------------------------=#