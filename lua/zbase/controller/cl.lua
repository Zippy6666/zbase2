ZBASE_CONTROLLER    = ZBASE_CONTROLLER or {}

--[[
=======================================================================================================
        ZOOM STUFF
=======================================================================================================
]]--

hook.Add("InitPostEntity", "ZBASE_CONTROLLER", function()
    LocalPlayer().ZBASE_ControllerZoomDist  = 0 
    LocalPlayer().ZBASE_ControllerCamUp     = 0 
    LocalPlayer().ZBASE_ControllerCamRight  = 0
    LocalPlayer().ZBASE_ControlledNPCHealth = 0
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

        net.Start("ZBASE_Ctrlr_SlotBindPress")
        net.WriteUInt(num, 4)
        net.WriteBool(pressed)
        net.SendToServer()
        return true
    end

    if pressed then
        if bind == "+lookup" then
            ply.ZBASE_ControllerCamUp = ply.ZBASE_ControllerCamUp+8
            return true
        elseif bind == "+lookdown" then
            ply.ZBASE_ControllerCamUp = ply.ZBASE_ControllerCamUp-8
            return true 
        elseif bind == "+right" then
            ply.ZBASE_ControllerCamRight = ply.ZBASE_ControllerCamRight+8
            return true
        elseif bind == "+left" then
            ply.ZBASE_ControllerCamRight = ply.ZBASE_ControllerCamRight-8
            return true
        end
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

--[[
=======================================================================================================
        HUD STUFF
=======================================================================================================
]]--

local mat           = Material("sprites/hud/v_crosshair1")
local iCrosshairLen = 35

local hudW, hudH    = 260, 40
local hudMrgn       = 5
local barMrgn       = 5
local barH          = 10

local hide = {
	["CHudHealth"]      = true,
	["CHudBattery"]     = true,
    ["CHudAmmo"]        = true,
    ["CHudCrosshair"]   = true,
    ["CHUDQuickInfo"]   = true,
    ["CHudSuitPower"]   = true
}

hook.Add("HUDPaint", "ZBASE_CONTROLLER", function()
    local ply = LocalPlayer()
    local camEnt = ply:GetNWEntity("ZBASE_ControllerCamEnt", NULL)
    if !IsValid(camEnt) then return end

    -- Display crosshair
    local targetEnt = camEnt:GetNWEntity("ZBASE_ControlTarget")
    if IsValid(targetEnt) then
        local pos = targetEnt:GetPos()
        local tbl = pos:ToScreen()
        surface.SetMaterial(mat)
        surface.SetDrawColor(175, 255, 0, 255)
        surface.DrawTexturedRect(tbl.x-iCrosshairLen*0.5, tbl.y-iCrosshairLen*0.5, iCrosshairLen, iCrosshairLen)
    end

    -- Display hud background
    local x, y = ScrW()*0.5 - hudW*0.5, hudMrgn
    surface.SetDrawColor(0, 0, 0, 125)
    surface.DrawRect(x, y, hudW, hudH)

    -- Display name of NPC
    surface.SetTextColor(255,255,255,255)
    local npcname = language.GetPhrase(ply.ZBASE_ControlledNPCName)
    surface.SetFont("TargetID")
    local nameW, nameH = surface.GetTextSize(npcname)
    surface.SetTextPos(x+hudW*0.5 - nameW*0.5, y)
    surface.DrawText(npcname)

    -- Draw health bar
    surface.SetDrawColor(75, 0 ,0, 255)
    surface.DrawRect(x+barMrgn, y+nameH+3, hudW-barMrgn*2, barH)
    surface.SetDrawColor(255, 0 ,0, 255)
    surface.DrawRect(x+barMrgn, y+nameH+3, (hudW-barMrgn*2) * (ply.ZBASE_ControlledNPCHealth/camEnt:GetMaxHealth()), barH)
end)

net.Receive("ZBASE_Ctrlr_SetNameOnClient", function()
    LocalPlayer().ZBASE_ControlledNPCName = net.ReadString()
end)

net.Receive("ZBASE_Ctrlr_UpdateNPCHealth", function()
    LocalPlayer().ZBASE_ControlledNPCHealth = net.ReadUInt(16)
end)

-- Hide hud elements when in controller
hook.Add( "HUDShouldDraw", "HideHUD", function( name )
    -- Check if we should hide hud elements
    -- because we are controlling an NPC
    local ply = LocalPlayer()
    if !IsValid(ply) then return end

    local camEnt = ply:GetNWEntity("ZBASE_ControllerCamEnt", NULL)
    if !IsValid(camEnt) then return end

    if hide[name] then
		return false
	end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )