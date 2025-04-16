ZBASE_CONTROLLER    = ZBASE_CONTROLLER or {}

--[[
=======================================================================================================
        ZOOM STUFF
=======================================================================================================
]]--

hook.Add("InitPostEntity", "ZBASE_CONTROLLER", function()
    LocalPlayer().ZBASE_ControllerZoomDist = 0 
    LocalPlayer().ZBASE_ControllerCamUp = 0 
end)

local function controllerZoom(amount)
    local ply = LocalPlayer()

    ply.ZBASE_ControllerZoomDist = math.Clamp(
        ply.ZBASE_ControllerZoomDist - amount*6, 
        ZBASE_CONTROLLER.ZOOM_MIN, 
        ZBASE_CONTROLLER.ZOOM_MAX
    )
end

hook.Add("InputMouseApply", "ZBASE_CONTROLLER", function(cmd, x, y, angle)
    local ply = LocalPlayer()
    local camEnt = ply:GetNWEntity("ZBASE_ControllerCamEnt", NULL)
    if !IsValid(camEnt) then return end

    local scroll = cmd:GetMouseWheel()
    
    if scroll != 0 then
        controllerZoom(scroll)
    end
end)

concommand.Add("zbase_controller_zoom", function(_, _, args)
    local iZoomAmount = args[1]
    controllerZoom(tonumber(iZoomAmount))
end)

hook.Add("PlayerBindPress", "ZBASE_CONTROLLER", function(ply, bind, pressed)
    local ply = LocalPlayer()
    local camEnt = ply:GetNWEntity("ZBASE_ControllerCamEnt", NULL)
    if !IsValid(camEnt) then return end

    -- Catch player pressing slots
    if string.StartWith(bind, "slot") then
        local num = tonumber(string.sub(bind, 5))

        print("SENDING", num)

        net.Start("ZBASE_Ctrlr_SlotBindPress")
        net.WriteUInt(num, 4)
        net.SendToServer()
        return true
    end

    if bind == "+lookup" then
        ply.ZBASE_ControllerCamUp = ply.ZBASE_ControllerCamUp+15
        return
    elseif bind == "+lookdown" then
        ply.ZBASE_ControllerCamUp = ply.ZBASE_ControllerCamUp-15
        return
    end

    -- Block weapon switching via scroll (reserved for zoom)
    if bind == "invprev" or bind == "invnext" then
        return true 
    end
end)

--[[
=======================================================================================================
        CAMERA POSITIONING
=======================================================================================================
]]--

hook.Add("CalcView", "ZBASE_CONTROLLER", function(ply, pos, ang, fov, znear, zfar)
    local idealViewPos = ZBASE_CONTROLLER:GetViewPos(ply, ang:Forward())
    if !idealViewPos then return end

    -- Lerp view position
    ply.ZBASE_Controller_ViewPos = LerpVector(0.5, ply.ZBASE_Controller_ViewPos or idealViewPos, idealViewPos)

    return {
        origin = ply.ZBASE_Controller_ViewPos,
        angles = ang,
        fov = fov,
        drawviewer = true,
    }
end)