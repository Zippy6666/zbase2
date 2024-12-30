TOOL.AddToMenu = true
TOOL.Category = "ZBASE"

local toolname = "ZBASE: Mover"
TOOL.Name = toolname
TOOL.Description = "Move NPCs."

if SERVER then
    util.AddNetworkString("ZBaseMoverHalo")
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
            if table.RemoveByValue(self.NPCsToMove, ent) == false then
                ent:CONV_StoreInTable(self.NPCsToMove)
            end

            if game.SinglePlayer() then
                net.Start("ZBaseMoverHalo")
                net.WriteEntity(ent)
                net.Send(own)
            end
        end

        return true
    end

end


function TOOL:RightClick( trace )

    local own = self:GetOwner()
    if !IsValid(own) then return end

    if SERVER then
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
    local function ToggleMoveNPCClient( npc )

        LocalPlayer().ZBaseMoveToolEnts = LocalPlayer().ZBaseMoveToolEnts or {}
    
        if table.RemoveByValue(LocalPlayer().ZBaseMoveToolEnts, npc) == false then
            npc:CONV_StoreInTable(LocalPlayer().ZBaseMoveToolEnts)
            notification.AddLegacy( "NPC Selected" , NOTIFY_GENERIC, 2 )
        else
            notification.AddLegacy( "NPC Deselected" , NOTIFY_UNDO, 2 )
        end
    end

    
    hook.Add( "PreDrawHalos", "ZBaseMoverHalos", function()
        local wep = LocalPlayer():GetActiveWeapon()

        if !( IsValid( wep ) && wep:GetClass() == "gmod_tool" && LocalPlayer():GetTool()
        && LocalPlayer():GetTool().Name == toolname ) then return end

        
        local tbl = LocalPlayer().ZBaseMoveToolEnts
        if tbl then
            halo.Add(tbl, color_white, 2, 2, 1, true, true)
        end
    end)


    function TOOL.BuildCPanel(panel)
        panel:Help(help)
    end


    net.Receive("ZBaseMoverHalo", function()
        local ent = net.ReadEntity()

        if !IsValid(ent) then return end

        ToggleMoveNPCClient(ent)
    end)
end

