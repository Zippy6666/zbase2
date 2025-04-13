TOOL.AddToMenu = true
TOOL.Category = "ZBASE"

local toolname = "ZBASE: Mover"
TOOL.Name = toolname
TOOL.Description = "Move NPCs."

if SERVER then
    util.AddNetworkString("ZBaseToolHalo")
end

local help = "Left-click: Select NPCs to move. Right-click: Move the NPCs to the position."
if CLIENT then
    language.Add("tool.zbase_mover.name", TOOL.Name)
    language.Add("tool.zbase_mover.desc", TOOL.Description)
    language.Add("tool.zbase_mover.0", help)
end

function TOOL:LeftClick( trace )
    local ent = trace.Entity
    local own = self:GetOwner()
    if !IsValid(own) then return end

    if IsValid(ent) && ent:IsNPC() && !ent.IsVJBaseSNPC then
        if SERVER then

            self.NPCsToMove = self.NPCsToMove or {}
            local didNotRemove = table.RemoveByValue(self.NPCsToMove, ent) == false
            if didNotRemove then
                ent:CONV_StoreInTable(self.NPCsToMove)
            end

            net.Start("ZBaseToolHalo")
            net.WriteEntity(ent)
            net.WriteString("ZBase_MoverNPCs")
            net.WriteBool(didNotRemove)
            net.Send(own)
        end

        return true
    end
end

function TOOL:RightClick( trace )
    local own = self:GetOwner()
    if !IsValid(own) then return end

    if SERVER && istable(self.NPCsToMove) && #self.NPCsToMove > 0 then
        for _, npc in ipairs(self.NPCsToMove) do
            if npc.IsZBaseNPC then
                npc:FullReset()
            else
                npc:TaskComplete()
                npc:ClearGoal()
                npc:ClearSchedule()
                npc:StopMoving()
                npc:SetMoveVelocity(vector_origin)
            end

            npc:SetLastPosition(trace.HitPos)
            npc:SetSchedule(SCHED_FORCED_GO_RUN)
            npc:SetNPCState(NPC_STATE_ALERT)
        end

        own:SendLua(
            'notification.AddLegacy( "Moving NPCs to ('..math.floor(trace.HitPos.x)..", "..math.floor(trace.HitPos.y)..", "
            ..math.floor(trace.HitPos.z).." "..')" , NOTIFY_GENERIC, 2 )'
        )
    end

    return true
end

function TOOL:Reload( trace )
end

if CLIENT then
    -- Shared CLIENT code for all tools
    local toolnames = {
        ["ZBASE: Mover"] = true,
        ["ZBASE: Guard"] = true,
    }

    local ToolHaloColors = {
        ["ZBase_Guards"] = Color(0, 100, 255),
        ["ZBase_MoverNPCs"] = Color(255, 255, 255),
    }

    local function tableHasValue(t, val)
        for k, v in ipairs( t ) do
            if ( v == val ) then return true end
        end
        return false
    end

    local function ToggleNPCHalo( npc, tblname )
        if table.RemoveByValue(LocalPlayer()[tblname], npc) == false then
            npc:CONV_StoreInTable(LocalPlayer()[tblname])
        end
    end
    
    hook.Add( "PreDrawHalos", "ZBaseToolHalos", function()
        local wep = LocalPlayer():GetActiveWeapon()

        if !( IsValid( wep ) && wep:GetClass() == "gmod_tool" && LocalPlayer():GetTool()
        && toolnames[LocalPlayer():GetTool().Name] ) then return end
        if !LocalPlayer().ZBaseToolTableNames then return end

        for _, tblname in ipairs(LocalPlayer().ZBaseToolTableNames) do
            local tbl = LocalPlayer()[tblname]

            halo.Add(tbl, ToolHaloColors[tblname] or color_white, 2, 2, 1, true, true)
        end
    end)

    net.Receive("ZBaseToolHalo", function()
        local ent = net.ReadEntity()
        local tblname = net.ReadString()
        local bool = net.ReadBool()

        if !IsValid(ent) then return end

        LocalPlayer()[tblname] = LocalPlayer()[tblname] or {}

        if (tableHasValue(LocalPlayer()[tblname], ent) && bool == false)
        or (!tableHasValue(LocalPlayer()[tblname], ent) && bool == true)
        then
            ToggleNPCHalo(ent, tblname)
        end
        
        LocalPlayer().ZBaseToolTableNames = LocalPlayer().ZBaseToolTableNames or {}
        if !tableHasValue(LocalPlayer().ZBaseToolTableNames, tblname) then
            table.insert(LocalPlayer().ZBaseToolTableNames, tblname)
        end
    end)

    -- Panel for this tool only
    function TOOL.BuildCPanel(panel)
        panel:Help(help)
    end
end

