ZBASE_CONTROLLER = {}

hook.Add("InitPostEntity", "ZBASE_CONTROLLER", function()
    LocalPlayer().ZBASE_ControllerZoomDist = 0
end)

hook.Add("InputMouseApply", "ZBASE_CONTROLLER", function(cmd, x, y, angle)
    local ply = LocalPlayer()
    local camEnt = ply:GetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)
    if !IsValid(camEnt) then return end

    local scroll = cmd:GetMouseWheel()
    
    if scroll != 0 then
        ply.ZBASE_ControllerZoomDist = math.min(ply.ZBASE_ControllerZoomDist - scroll*6, 2000)
    end
end)

hook.Add("PlayerBindPress", "BlockScrollBinds", function(ply, bind, pressed)
    local ply = LocalPlayer()
    local camEnt = ply:GetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)
    if !IsValid(camEnt) then return end

    if bind:find("invprev") or bind:find("invnext") then
        return true -- Block weapon switching via scroll
    end
end)

hook.Add("CalcView", "ZBASE_CONTROLLER", function(ply, pos, ang, fov, znear, zfar)
    local camEnt = ply:GetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)
    if !IsValid(camEnt) then return end

    local _, modelmaxs = camEnt:GetModelBounds()
    local forward = ang:Forward()
    local camViewPos = camEnt:GetPos()+camEnt:GetUp()*modelmaxs.z - ( forward * (200+modelmaxs.x+ply.ZBASE_ControllerZoomDist) )

    -- Make camera bounce of walls and shit
    local tr = util.TraceLine({
        start = camEnt:GetPos(),
        endpos = camViewPos,
        mask = MASK_VISIBLE
    })

    -- Lerp view position
    ply.ZBASE_Controller_ViewPos = LerpVector(0.5, ply.ZBASE_Controller_ViewPos or tr.HitPos+tr.HitNormal*25, tr.HitPos+tr.HitNormal*25)

    -- Handle zooming
    -- if input.IsMouseDown(MOUSE_WHEEL_UP) then
    --     ply.ZBASE_ControllerZoomDist = ply.ZBASE_ControllerZoomDist + 100
    -- elseif input.IsMouseDown(MOUSE_WHEEL_UP) then
    --     ply.ZBASE_ControllerZoomDist = ply.ZBASE_ControllerZoomDist - 100
    -- end

    return {
        origin = ply.ZBASE_Controller_ViewPos,
        angles = ang,
        fov = fov,
        drawviewer = true,
    }
end)

hook.Add("PlayerFootstep", "ZBASE_CONTROLLER", function(ply)
    local camEnt = ply:GetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)
    return IsValid(camEnt)
end)