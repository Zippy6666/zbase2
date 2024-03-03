
// Control ZBase NPCs

ZBCtrlSys = {}


if CLIENT then
    local ang0 = Angle()
    hook.Add("CalcView", "ZBCtrlSys", function(ply, pos, ang, fov, znear, zfar)
        local camEnt = ply:GetNWEntity("ZBCtrlSysCamEnt", NULL)


        if IsValid(camEnt) then

            local _, modelmaxs = camEnt:GetModelBounds()
            local forward = ang:Forward()
            local camViewPos = camEnt:GetPos()+camEnt:GetUp()*modelmaxs.z*1.1 - ( forward * modelmaxs.x*4 )


            -- local camTrace = util.TraceLine({
            --     start = camViewPos,
            --     endpos = camViewPos+forward*100000,
            --     mask = MASK_VISIBLE,
            -- })



            -- debugoverlay.Axis(camTrace.HitPos, ang0, 50, 0.1)


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
        -- Set NPC_STATE and enemy!


        npc.ZBControlTarget = ents.Create("base_gmodentity")
        npc.ZBControlTarget:SetPos( npc:GetPos() )
        npc.ZBControlTarget:SetNoDraw(true)
        npc.ZBControlTarget:Spawn()


        npc.ZBViewEnt = ents.Create("base_gmodentity")
        npc.ZBViewEnt:SetPos( npc:GetPos() )
        npc.ZBViewEnt:SetAngles(npc:GetAngles())
        npc.ZBViewEnt:SetParent(npc)
        npc.ZBViewEnt:SetNoDraw(true)
        npc.ZBViewEnt:Spawn()
        npc:DeleteOnRemove(npc.ZBViewEnt)


        -- npc:SetSaveValue( "m_flFieldOfView", 1 ) -- No FOV, cant see shid
        npc:CallOnRemove("StopControllingZB", function()
            self:StopControlling(ply, npc)
        end)


        ply:SetNWEntity("ZBCtrlSysCamEnt", npc)
        ply.ZBControlledNPC = npc
        ply.ZBLastMoveType = ply:GetMoveType()
        ply.ZBLastNoTarget = bit.band(ply:GetFlags(), FL_NOTARGET)==FL_NOTARGET
        ply:SetNoTarget(true)
        ply:SetMoveType(MOVETYPE_NONE)


        self:UpdateRelationShips()

    end


    function ZBCtrlSys:StopControlling( ply, npc )

        if IsValid(npc) then
            -- npc:SetSaveValue( "m_flFieldOfView", npc.FieldOfView )
            npc.IsZBPlyControlled  = false
            npc.ZBPlyController  = nil
            ply.ZBControlledNPC = nil

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
        for _, v in ipairs(ZBaseRelationshipEnts) do
            v:ZBaseUpdateRelationships()
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


    concommand.Add("ZBaseControlTest", function()
        local ply = Entity(1)
        local npc = ply:GetEyeTrace().Entity

        if IsValid(npc) && npc.IsZBaseNPC then
            ZBCtrlSys:StartControlling( ply, npc )
        end
    end)

end