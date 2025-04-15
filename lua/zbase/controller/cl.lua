ZBASE_CONTROLLER    = ZBASE_CONTROLLER or {}

hook.Add("InitPostEntity", "ZBASE_CONTROLLER", function()
    LocalPlayer().ZBASE_ControllerZoomDist = 0 
end)

hook.Add("InputMouseApply", "ZBASE_CONTROLLER", function(cmd, x, y, angle)
    local ply = LocalPlayer()
    local camEnt = ply:GetNW2Entity("ZBASE_ControllerCamEnt", NULL)
    if !IsValid(camEnt) then return end

    local scroll = cmd:GetMouseWheel()
    
    if scroll != 0 then
        ply.ZBASE_ControllerZoomDist = math.Clamp(ply.ZBASE_ControllerZoomDist - scroll*6, -250, 1000)
        net.Start("ZBASE_ControllerUpdateZoomOnServer")
        net.WriteInt(ply.ZBASE_ControllerZoomDist, 11)
        net.Send(ply)
    end
end)

hook.Add("PlayerBindPress", "ZBASE_CONTROLLER", function(ply, bind, pressed)
    local ply = LocalPlayer()
    local camEnt = ply:GetNW2Entity("ZBASE_ControllerCamEnt", NULL)
    if !IsValid(camEnt) then return end

    if bind:find("invprev") or bind:find("invnext") then
        return true -- Block weapon switching via scroll
    end
end)

hook.Add("CalcView", "ZBASE_CONTROLLER", function(ply, pos, ang, fov, znear, zfar)
    local idealViewPos = ZBASE_CONTROLLER:GetViewPos(ply)

    -- Lerp view position
    ply.ZBASE_Controller_ViewPos = LerpVector(0.5, ply.ZBASE_Controller_ViewPos or idealViewPos, idealViewPos)

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