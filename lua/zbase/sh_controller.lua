
// Control ZBase NPCs

ZBCtrlSys = {}


if CLIENT then
    hook.Add("CalcView", "ZBCtrlSys", function(ply, pos, ang, fov, znear, zfar)
        local camEnt = ply:GetNWEntity("ZBCtrlSysCamEnt", NULL)


        if IsValid(camEnt) then

            -- local _, modelmaxs = camEnt:GetModelBounds()
            local forward = ang:Forward()
            local camViewPos = camEnt:GetPos()+camEnt:GetUp()*90 - ( forward * 200 )


            -- local camTrace = util.TraceLine({
            --     start = camViewPos,
            --     endpos = camViewPos+forward*100000,
            --     mask = MASK_VISIBLE,
            -- })



            -- debugoverlay.Axis(camTrace.HitPos, angle_zero, 50, 0.1)


            return {
                origin = camViewPos,
                angles = ang,
                fov = fov,
                drawviewer = true,
            }

        end
    end)
end




if SERVER then
    function ZBCtrlSys:StartControlling( ply, npc )

        npc.IsZBPlyControlled = true
        npc.ZBPlyController  =  ply


        -- Only target the target which will follow the players cursor
        npc.ZBControlTarget = ents.Create("npc_bullseye")
        npc.ZBControlTarget:SetPos( npc:WorldSpaceCenter() )
        npc.ZBControlTarget:SetNotSolid(true)
        npc.ZBControlTarget:SetHealth(math.huge)
        npc.ZBControlTarget:Spawn()
        npc.ZBControlTarget:Activate()
        npc:ClearEnemyMemory()
        self:UpdateRelationShips()


        -- Setup camera
        npc.ZBViewEnt = ents.Create("base_gmodentity")
        npc.ZBViewEnt:SetPos( npc:GetPos() )
        npc.ZBViewEnt:SetAngles(npc:GetAngles())
        npc.ZBViewEnt:SetParent(npc)
        npc.ZBViewEnt:SetNoDraw(true)
        npc.ZBViewEnt:Spawn()
        npc:DeleteOnRemove(npc.ZBViewEnt)
        ply:SetNWEntity("ZBCtrlSysCamEnt", npc)


        -- Disable jump capability for NPC
        npc.ZBHadJumpCap = npc:HasCapability(CAP_MOVE_JUMP)
        npc:CapabilitiesRemove(CAP_MOVE_JUMP)

        
        -- Player variables
        ply.ZBControlledNPC = npc
        ply.ZBLastMoveType = ply:GetMoveType()
        ply.ZBLastNoTarget = bit.band(ply:GetFlags(), FL_NOTARGET)==FL_NOTARGET
        ply:SetNoTarget(true)
        ply:SetMoveType(MOVETYPE_NONE)
        

        -- Undo stops controlling
        undo.Create("ZBase Control")
        undo.SetPlayer(ply)
        undo.AddFunction(function() self:StopControlling( ply, npc ) end)
        undo.SetCustomUndoText( "Stopped Controlling ".. npc.Name )
        undo.Finish()


        -- If the NPC is removed the controlling should also stop
        npc:CallOnRemove("StopControllingZB", function()
            self:StopControlling(ply, npc)
        end)


        -- WIP message
        ply:PrintMessage(HUD_PRINTTALK, "Warning: The ZBase controller is still WIP!")

    end


    function ZBCtrlSys:StopControlling( ply, npc )

        if IsValid(npc) then

            if npc.ZBHadJumpCap then
                npc:CapabilitiesAdd(CAP_MOVE_JUMP)
            end

            -- npc:SetSaveValue( "m_flFieldOfView", npc.FieldOfView )
            npc.IsZBPlyControlled  = false
            npc.ZBPlyController  = nil
            ply.ZBControlledNPC = nil
            npc.ZBHadJumpCap = nil

            SafeRemoveEntity(npc.ZBViewEnt)
            SafeRemoveEntity(npc.ZBControlTarget)


        end


        if IsValid(ply) then
            ply:SetNWEntity("ZBCtrlSysCamEnt", NULL)
            ply:SetMoveType(ply.ZBLastMoveType)
            ply:SetNoTarget(ply.ZBLastNoTarget)
        end

        
        self:UpdateRelationShips()

    end


    function ZBCtrlSys:UpdateRelationShips()
        for _, v in ipairs(ZBaseNPCInstances) do
            v:UpdateRelationships()
        end
    end


    hook.Add("PlayerButtonDown", "ZBCtrlSys", function(ply, btn)
        if IsValid(ply.ZBControlledNPC) then
            ply.ZBControlledNPC:Controller_ButtonDown(ply, btn)
        end
    end)


    hook.Add("KeyPress", "ZBCtrlSys", function(ply, key)
        if IsValid(ply.ZBControlledNPC) then
            ply.ZBControlledNPC:Controller_KeyPress(ply, key)
        end
    end)

end