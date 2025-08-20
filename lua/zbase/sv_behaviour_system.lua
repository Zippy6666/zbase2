-- we be behavin

local ZBaseDelayEnt = NULL
local ZBaseDelayBehaviour_Name
local NextBehaviourThink = CurTime()

function ZBaseDelayBehaviour( delay, ent, name )
    local Ent = ent or ZBaseDelayEnt
    local BehaviourName = name or ZBaseDelayBehaviour_Name

    if IsValid(Ent) && BehaviourName then
        Ent.ZBase_Behaviour_Delays[BehaviourName] = CurTime() + delay
    end
end

-- Return false if we should not do behavior while in controller
local function bControllerBehaviorValidCheck( Behaviour, ent, BehaviourName )
    if !ent.ZBASE_IsPlyControlled then
        return true
    end

    if !(Behaviour.MustHaveEnemy or Behaviour.MustHaveVisibleEnemy or Behaviour.MustFaceEnemy) then
        return true
    end

    local ctrlrBlock = ent.bControllerBlock

    return !ent.bControllerBlock
end

local function BehaviourTimer( ent )
    -- Is dead, so don't do behaviour
    if ent.DoingDeathAnim then return end
    if ent.Dead then return end
    if ent:GetNPCState()==NPC_STATE_DEAD then return end
    
    -- No behaviour with EFL_NO_THINK_FUNCTION
    if bit.band(ent:GetFlags(), EFL_NO_THINK_FUNCTION )==EFL_NO_THINK_FUNCTION then
        return
    end

    -- Doing ZBaseMove, don't do behaviour
    if ZBaseMoveIsActive(ent) then return end

    -- In dynamic interaction, no behavior
    if ent:InDynamicInteraction() then
        return
    end

    ZBaseDelayEnt = ent
    for BehaviourName, Behaviour in pairs(ent.Behaviours) do
        if !Behaviour.Run then continue end
        ZBaseDelayBehaviour_Name = BehaviourName

        if ent.ZBase_Behaviour_Delays[BehaviourName] > CurTime() then continue end

        -- Checks
        local enemy = ent:GetEnemy()
        local has_ene = IsValid(enemy)
        if (Behaviour.MustHaveEnemy && !has_ene)
        or (Behaviour.MustNotHaveEnemy && has_ene)
        or (Behaviour.MustHaveVisibleEnemy && !(has_ene && ent.EnemyVisible) )
        or (Behaviour.MustFaceEnemy && !ent:IsFacing(enemy))
        or (!bControllerBehaviorValidCheck( Behaviour, ent, BehaviourName )) then
            continue
        end
        
        if Behaviour.ShouldDoBehaviour && !Behaviour:ShouldDoBehaviour( ent ) then continue end
        
        -- Delay
        local delay = Behaviour.Delay && Behaviour:Delay( ent )
        if delay then
            ZBaseDelayBehaviour( delay, ent, BehaviourName )
            return
        end

        -- Run the behaviour
        Behaviour:Run( ent )
    end

    ZBaseDelayEnt = NULL
    ZBaseDelayBehaviour_Name = nil
end

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