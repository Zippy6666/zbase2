ZBASE_CONTROLLER    = ZBASE_CONTROLLER or {}
ZBASE_CONTROLLER.ZOOM_MIN = -250
ZBASE_CONTROLLER.ZOOM_MAX = 1000

-- Returns the view position
-- Or nil if the player is not currently using the controller
function ZBASE_CONTROLLER:GetViewPos(ply, forward)
    local camEnt = ply:GetNWEntity("ZBASE_ControllerCamEnt", NULL)
    if !IsValid(camEnt) then return end

    local _, modelmaxs = camEnt:GetModelBounds()
    local camUp = camEnt:GetUp()
    local camOrig = camEnt:GetPos()+camUp*modelmaxs.z
    local camViewPos = camOrig + camUp*ply.ZBASE_ControllerCamUp - (forward * ( 200 + modelmaxs.x + ply.ZBASE_ControllerZoomDist ) )
    +camEnt:GetRight()*ply.ZBASE_ControllerCamRight

    -- Make camera bounce of walls and shit
    local tr = util.TraceLine({
        start = camOrig,
        endpos = camViewPos,
        mask = MASK_VISIBLE
    })

    return tr.HitPos + tr.HitNormal*25
end

-- Silence player footsteps when in control mode
hook.Add("PlayerFootstep", "ZBASE_CONTROLLER", function(ply)
    local camEnt = ply:GetNWEntity("ZBASE_ControllerCamEnt", NULL)

    if IsValid(camEnt) then
        return true
    end
end)