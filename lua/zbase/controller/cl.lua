ZBASE_CONTROLLER = {}

hook.Add("CalcView", "ZBASE_CONTROLLER", function(ply, pos, ang, fov, znear, zfar)
    local camEnt = ply:GetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)

    if IsValid(camEnt) then
        local _, modelmaxs = camEnt:GetModelBounds()
        local forward = ang:Forward()
        local camViewPos = camEnt:GetPos()+camEnt:GetUp()*modelmaxs.z - ( forward * (200+modelmaxs.x) )

        return {
            origin = camViewPos,
            angles = ang,
            fov = fov,
            drawviewer = true,
        }
    end
end)

hook.Add("PlayerFootstep", "ZBASE_CONTROLLER", function(ply)
    local camEnt = ply:GetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)
    return IsValid(camEnt)
end)