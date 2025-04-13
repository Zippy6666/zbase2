ZBASE_CONTROLLER = {}

hook.Add("CalcView", "ZBASE_CONTROLLER", function(ply, pos, ang, fov, znear, zfar)
    local camEnt = ply:GetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)

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