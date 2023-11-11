include("shared.lua")

--------------------------------------------------------------------------------=#
function ENT:Initialize_Aerial()
	self:CapabilitiesAdd(CAP_MOVE_FLY)
	self:SetNavType(NAV_FLY)
end
--------------------------------------------------------------------------------=#