ZBASE_CONTROLLER    = ZBASE_CONTROLLER or {}

-- Returns the view position
-- Or nil if the player is not currently using the controller
function ZBASE_CONTROLLER:GetViewPos(ply, forward)
    local camEnt = ply:GetNW2Entity("ZBASE_ControllerCamEnt", NULL)
    if !IsValid(camEnt) then return end

    local _, modelmaxs = camEnt:GetModelBounds()
    local camViewPos = camEnt:GetPos()+camEnt:GetUp()*modelmaxs.z - ( forward * (200+modelmaxs.x+ply.ZBASE_ControllerZoomDist) )

    -- Make camera bounce of walls and shit
    local tr = util.TraceLine({
        start = camEnt:GetPos(),
        endpos = camViewPos,
        mask = MASK_VISIBLE
    })

    return tr.HitPos + tr.HitNormal*25
end

hook.Add("PlayerFootstep", "ZBASE_CONTROLLER", function(ply)
    local camEnt = ply:GetNW2Entity("ZBASE_ControllerCamEnt", NULL)
    return IsValid(camEnt)
end)