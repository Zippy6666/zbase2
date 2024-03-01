
// Control ZBase NPCs

ZBCtrlSys = {}


if CLIENT then
    hook.Add("CalcView", "ZBCtrlSys", function(ply, pos, ang, fov, znear, zfar)
        local camEnt = ply:GetNWEntity("ZBCtrlSysCamEnt", NULL)


        if IsValid(camEnt) then
            local _, modelmaxs = camEnt:GetModelBounds()
            

            return {
                origin = camEnt:GetPos()+camEnt:GetUp()*modelmaxs.z*1.1 - ( ang:Forward() * modelmaxs.x*4 ),
                ang = ang,
                fov = fov,
                drawviewer = true,
            }
        end
    end)
end



if SERVER then
    function ZBCtrlSys:StartControlling( ply, npc )

        npc.IsZBPlyControlled = true

        npc.ZBViewEnt = ents.Create("base_gmodentity")
        npc.ZBViewEnt:SetPos( npc:GetPos() + (npc:GetUp()*npc:OBBMaxs().z*1.25) - (npc:GetForward()*npc:OBBMaxs().x*4) )
        npc.ZBViewEnt:SetAngles(npc:GetAngles())
        npc.ZBViewEnt:SetParent(npc)
        npc.ZBViewEnt:SetNoDraw(true)
        npc.ZBViewEnt:Spawn()
        npc:DeleteOnRemove(npc.ZBViewEnt)
        npc:SetSaveValue( "m_flFieldOfView", 1 ) -- No FOV, cant see shid
        npc:CallOnRemove("StopControllingZB", function()
            self:StopControlling(ply, npc)
        end)


        ply:SetNWEntity("ZBCtrlSysCamEnt", npc)


        self:UpdateRelationShips()

    end


    function ZBCtrlSys:StopControlling( ply, npc )

        if IsValid(npc) then
            npc:SetSaveValue( "m_flFieldOfView", npc.FieldOfView )
            npc.IsZBPlyControlled  = false

            if IsValid(npc.ZBViewEnt) then
                npc.ZBViewEnt:Remove()
            end

        end


        if IsValid(ply) then
            ply:SetNWEntity("ZBCtrlSysCamEnt", NULL)
        end

        
        self:UpdateRelationShips()

    end


    function ZBCtrlSys:UpdateRelationShips()
        for _, v in ipairs(ZBaseRelationshipEnts) do
            v:ZBaseUpdateRelationships()
        end
    end


    concommand.Add("ZBaseControlTest", function()
        local ply = Entity(1)
        local npc = ply:GetEyeTrace().Entity

        if IsValid(npc) && npc.IsZBaseNPC then
            ZBCtrlSys:StartControlling( ply, npc )
        end
    end)
end