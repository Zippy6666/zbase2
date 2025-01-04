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
        if !ent.ZBase_Guard_HasMovementSet && bool == true then

            if ent.ZBase_Guard_HadGroundMovement then
                ent:CapabilitiesAdd(CAP_MOVE_GROUND)
                ent.ZBase_Guard_HadGroundMovement = nil
            end

            ent.ZBase_Guard_HasMovementSet = true

        elseif ent.ZBase_Guard_HasMovementSet && bool == false then

            if ent:CONV_HasCapabiltity(CAP_MOVE_GROUND) then
                ent:CapabilitiesRemove(CAP_MOVE_GROUND)
                ent.ZBase_Guard_HadGroundMovement = true
            end

            ent.ZBase_Guard_HasMovementSet = nil

        end
    end

    local function GuardThink(ent)
        local shouldHaveMovement = false

        if ent:DistToSqr(ent.ZBase_GuardPosition) > GuardPosSlack then
            shouldHaveMovement = true
        end

        SetHasMovement(ent, shouldHaveMovement)
    end

    hook.Add("Think", "ZBase_GuardThink", function()
        if AIDisabled:GetBool() then return end
        if NextGuardThink > CurTime() then return end

        for k, v in ipairs(ZBase_Guards) do GuardThink(v) end

        NextGuardThink = CurTime() + 2
    end)

    local function SetGuard(ent, bool)
        if bool == true then
            -- Stop moving essentially
            ent:ClearSchedule()
            ent:ClearGoal()

            ent.ZBase_GuardPosition = ent:GetPos()

            ent:CONV_StoreInTable(ZBase_Guards)

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

