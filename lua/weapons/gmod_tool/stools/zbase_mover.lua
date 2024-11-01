TOOL.AddToMenu = true
TOOL.Category = "ZBASE"

local toolname = "ZBASE: Mover"
TOOL.Name = toolname
TOOL.Description = "Move NPCs."



if CLIENT then
    local help = "Left-click: Select an NPC. Right-click: Move the NPC to the position. Reload: WIP"

    language.Add("tool.zbase_mover.name", TOOL.Name)
    language.Add("tool.zbase_mover.desc", TOOL.Description)
    language.Add("tool.zbase_mover.0", help)
end


function TOOL:Deploy()

end


function TOOL:LeftClick( trace )

    local ent = trace.Entity

    if IsValid(ent) && ent:IsNPC() && !ent.IsVJBaseSNPC then
        self.CurrentNPC = ent

        if CLIENT then
            LocalPlayer().ZBaseMoveToolEnts = {}
            self.CurrentNPC:CONV_StoreInTable(LocalPlayer().ZBaseMoveToolEnts)
        end

        return true
    end

end


function TOOL:RightClick( trace )
    if IsValid(self.CurrentNPC) then

        if SERVER then
            if self.CurrentNPC.IsZBaseNPC then
                self.CurrentNPC:FullReset()
            else
                self.CurrentNPC:TaskComplete()
                self.CurrentNPC:ClearGoal()
                self.CurrentNPC:ClearSchedule()
                self.CurrentNPC:StopMoving()
                self.CurrentNPC:SetMoveVelocity(vector_origin)
            end

            self.CurrentNPC:SetLastPosition(trace.HitPos)
            self.CurrentNPC:SetSchedule(SCHED_FORCED_GO_RUN)
        end

        return true
    end
end


function TOOL:Reload( trace )

end



if CLIENT then
    local mat = Material("effects/blueflare1")
    local startoffset = Vector(0, 0, 50)
    local endoffset = Vector(0, 0, 400)
    local up = Vector(0, 0, 1)

    hook.Add( "RenderScreenspaceEffects", "ZBaseMoverEffects", function()
        local wep = LocalPlayer():GetActiveWeapon()

        if !( IsValid( wep ) && wep:GetClass() == "gmod_tool" && LocalPlayer():GetTool()
        && LocalPlayer():GetTool().Name == toolname ) then return end

        
        local tbl = LocalPlayer().ZBaseMoveToolEnts
        if tbl then
            for _, v in ipairs(tbl) do
                cam.Start3D()
                    local tr = util.TraceLine({
                        start = v:GetPos()+startoffset,
                        endpos = v:GetPos()-endoffset,
                        mask = MASK_NPCWORLDSTATIC,
                    })
                    if tr.Hit then
                        render.SetMaterial( mat )
                        render.DrawQuadEasy( tr.HitPos+tr.HitNormal*1.5, up, 75, 75, Color(170, 0, 255), ( CurTime() * 300 ) % 360 )
                    end
                cam.End3D()
            end
        end
    end)

    function TOOL.BuildCPanel(panel)
        panel:Help("This tool is WIP!")
    end
end

