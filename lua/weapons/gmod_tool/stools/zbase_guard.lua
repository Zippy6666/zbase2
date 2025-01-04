TOOL.AddToMenu = true
TOOL.Category = "ZBASE"

local toolname = "ZBASE: Guard"
TOOL.Name = toolname
TOOL.Description = "Toggle guard mode for NPCs."


local help = "Left-click: Toggle guard mode for the NPC at your crosshair."
if CLIENT then
    language.Add("tool.zbase_guard.name", TOOL.Name)
    language.Add("tool.zbase_guard.desc", TOOL.Description)
    language.Add("tool.zbase_guard.0", help)
end


if SERVER then
    local AIDisabled = GetConVar("ai_disabled")
    local NextGuardThink = CurTime()
    local GuardPosSlack = 50^2

    ZBase_Guards = ZBase_Guards or {}

    local function SetHasMovement(ent, bool)
        -- ENABLE MOVEMENT
        if !ent.ZBase_Guard_HasMovementSet && bool == true then
            if ent.ZBase_Guard_HadGroundMovement then
                ent:CapabilitiesAdd(CAP_MOVE_GROUND)
                ent.ZBase_Guard_HadGroundMovement = nil
            end

            ent.ZBase_Guard_HasMovementSet = true

            ent:RemoveIgnoreConditions({COND.PLAYER_PUSHING})

        -- DISABLE MOVEMENT
        elseif ent.ZBase_Guard_HasMovementSet && bool == false then
            if ent:CONV_HasCapability(CAP_MOVE_GROUND) then
                conv.devPrint("Removing ground movement from " .. tostring(ent))
                ent:CapabilitiesRemove(CAP_MOVE_GROUND)
                ent.ZBase_Guard_HadGroundMovement = true
            end

            ent:SetIgnoreConditions({COND.PLAYER_PUSHING}, 1)

            ent.ZBase_Guard_HasMovementSet = nil
        end
    end

    local function InDanger(ent)
        local hint = sound.GetLoudestSoundHint(SOUND_DANGER, ent:GetPos())
        local IsDangerHint = (istable(hint) && hint.type==SOUND_DANGER)

        if IsDangerHint then
            return true
        end

        if ent.ZBase_InDanger then
            return true
        end

        return false
    end

    local function GuardThink(ent)
        local shouldHaveMovement = false

        if ent:GetPos():DistToSqr(ent.ZBase_GuardPosition) > GuardPosSlack then
            if !ent:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
                ent:SetLastPosition(ent.ZBase_GuardPosition)
                ent:SetSchedule(SCHED_FORCED_GO_RUN)
            end

            shouldHaveMovement = true
        end

        if !shouldHaveMovement && InDanger(ent) && !ent.ZBase_Guard_InDangerDontClearSched then
            ent:CONV_CallNextTick("ClearSchedule")
            ent:CONV_TempVar("ZBase_Guard_InDangerDontClearSched", true, 2)
            conv.devPrint("Clearing schedule for " .. tostring(ent))
            shouldHaveMovement = true
        end

        SetHasMovement(ent, shouldHaveMovement)
    end

    hook.Add("Think", "ZBase_GuardThink", function()
        if AIDisabled:GetBool() then return end
        if NextGuardThink > CurTime() then return end

        for k, v in ipairs(ZBase_Guards) do GuardThink(v) end

        NextGuardThink = CurTime() + 0.8
    end)

    local function SetGuard(ent, bool)
        if bool == true then
            ent.ZBase_Guard = true

            -- Stop moving essentially
            ent:ClearSchedule()
            ent:ClearGoal()

            ent.ZBase_GuardPosition = ent:GetPos()

            ent:CONV_StoreInTable(ZBase_Guards)

            SetHasMovement(ent, true)
        elseif bool == false then
            ent.ZBase_Guard = nil

            table.RemoveByValue(ZBase_Guards, ent)

            SetHasMovement(ent, true)
        end
    end

    concommand.Add("zbase_guard", function(ply, cmd, args)
        local ent = Entity(tonumber(args[1]))
        
        if IsValid(ent) and ent:IsNPC() then
            SetGuard(ent, true)
        end
    end)
end


function TOOL:LeftClick( trace )
    if SERVER then
        local own = self:GetOwner()

        local ent = trace.Entity
        if IsValid(ent) and ent:IsNPC() then
            own:ConCommand("zbase_guard " .. ent:EntIndex())

            return true
        end
    end
    local ent = trace.Entity
end


function TOOL:RightClick( trace )
end


function TOOL:Reload( trace )
end


if CLIENT then

    function TOOL.BuildCPanel(panel)
        panel:Help(help)
    end

end

