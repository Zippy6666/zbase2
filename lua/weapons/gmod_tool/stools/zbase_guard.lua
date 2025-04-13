TOOL.AddToMenu = true
TOOL.Category = "NPC"

local toolname = "Enable Guarding"
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
    local GuardPosDistTolerance = 50^2

    ZBase_Guards = ZBase_Guards or {}

    local function SetHasMovement(self, bool)
        -- ENABLE MOVEMENT
        if !self.ZBase_Guard_HasMovementSet && bool == true then
            -- Regular ground NPC/SNPCs
            if self.ZBase_Guard_HadGroundMovement then
                self:CapabilitiesAdd(CAP_MOVE_GROUND)
                self.ZBase_Guard_HadGroundMovement = nil
            end

            -- Flying SNPCs
            if self.ZBase_HasLUAFlyCapability == false then
                self.ZBase_HasLUAFlyCapability = true
                conv.devPrint("Enabling fly capability for " .. tostring(self))
            end
 
            self.ZBase_Guard_HasMovementSet = true

        -- DISABLE MOVEMENT
        elseif self.ZBase_Guard_HasMovementSet && bool == false then
            -- Regular ground NPC/SNPCs
            if self:CONV_HasCapability(CAP_MOVE_GROUND) then
                self:CapabilitiesRemove(CAP_MOVE_GROUND)
                self.ZBase_Guard_HadGroundMovement = true
            end

            -- Flying SNPCs
            if self.ZBase_HasLUAFlyCapability == true then
                self.ZBase_HasLUAFlyCapability = false
                conv.devPrint("Disabling fly capability for " .. tostring(self))
            end

            self.ZBase_Guard_HasMovementSet = nil
        end
    end

    local function InDanger(self)
        local hint = sound.GetLoudestSoundHint(SOUND_DANGER, self:GetPos())
        local IsDangerHint = (istable(hint) && hint.type==SOUND_DANGER)

        if IsDangerHint then
            return true
        end

        if self.ZBase_InDanger then
            return true
        end

        return false
    end

    local function GuardThink(self)
        local shouldHaveMovement = false
        local inDanger = InDanger(self)

        if self:GetPos():DistToSqr(self.ZBase_GuardPosition) > GuardPosDistTolerance then
            if !inDanger && !self:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
                self:SetLastPosition(self.ZBase_GuardPosition)
                self:SetSchedule(SCHED_FORCED_GO_RUN)
            end

            shouldHaveMovement = true
        end

        if !shouldHaveMovement && inDanger then
            if !self.ZBase_Guard_InDangerDontClearSched then
                self:CONV_CallNextTick("ClearSchedule")
                self:CONV_TempVar("ZBase_Guard_InDangerDontClearSched", true, 2)
            end

            shouldHaveMovement = true
        end

        SetHasMovement(self, shouldHaveMovement)
    end

    function ZBaseUpdateGuard( self )
        if !self.ZBase_Guard then return end
        GuardThink(self)
    end

    hook.Add("Think", "ZBase_GuardThink", function()
        if AIDisabled:GetBool() then return end
        if NextGuardThink > CurTime() then return end

        for _, npc in ipairs(ZBase_Guards) do ZBaseUpdateGuard(npc) end

        NextGuardThink = CurTime() + 0.8
    end)

    local function SetGuard(self, bool)
        if bool == true && !self.ZBASE_IsPlyControlled then
            self.ZBase_Guard = true

            -- Stop moving essentially
            if self.IsZBaseNPC then
                -- More convenient for ZBase NPCs
                self:FullReset()
            else
                -- Other SNPCs/NPCs, would technically work for ZBase NPCs too
                self:ClearSchedule()
                self:ClearGoal()
                if self:IsScripted() then
                    self:ScheduleFinished()
                end
            end

            self.ZBase_GuardPosition = self:GetPos()

            self:CONV_StoreInTable(ZBase_Guards)

            SetHasMovement(self, true)

            duplicator.StoreEntityModifier( self, "ZBaseGuard", {true} )
        elseif bool == false then
            self.ZBase_Guard = nil

            table.RemoveByValue(ZBase_Guards, self)

            SetHasMovement(self, true)

            duplicator.StoreEntityModifier( self, "ZBaseGuard", {false} )
        end
    end

    duplicator.RegisterEntityModifier( "ZBaseGuard", function(ply, ent, data)
        if ent:IsNPC() && data[1] == true then
            ent.ZBase_Guard = false -- Reset this var
            ply:ConCommand("zbase_guard " .. ent:EntIndex())
        end
    end)

    concommand.Add("zbase_guard", function(ply, cmd, args)
        local ent = Entity(tonumber(args[1]))

        if IsValid(ent) and ent:IsNPC() then
            net.Start("ZBaseToolHalo")
            net.WriteEntity(ent)
            net.WriteString("ZBase_Guards")
            net.WriteBool(!ent.ZBase_Guard)
            net.Send(ply)

            SetGuard(ent, !ent.ZBase_Guard)
        end
    end)
end


function TOOL:LeftClick( trace )
    local own = self:GetOwner()
    local ent = trace.Entity

    if IsValid(ent) and ent:IsNPC() && !ent.IsVJBaseSNPC then
        if SERVER then
            own:ConCommand("zbase_guard " .. ent:EntIndex())
        end

        return true
    end
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

