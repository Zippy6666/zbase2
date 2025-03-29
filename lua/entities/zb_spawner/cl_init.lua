include("shared.lua")

ENT.CreatedRecently    = nil

function ENT:Initialize()
    self:CONV_TempVar("CreatedRecently", true, 2)
end

local function bLocalPlayerHasTool()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if !IsValid(wep) then return false end

    local strWepCls = wep:GetClass()
    if strWepCls != "gmod_tool" && strWepCls != "weapon_physgun" then return false end

    return true
end

function ENT:shouldDrawModel()
    return self.CreatedRecently == true or bLocalPlayerHasTool()
end

function ENT:Draw()
    if self:shouldDrawModel() then
        self:DrawModel()
    end
end