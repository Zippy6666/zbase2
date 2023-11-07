include("shared.lua")

--------------------------------------------------------------------------------=#
function ENT:Initialize()

	-- Some default calls to make the NPC function
	self:SetHullType( HULL_SMALL_CENTERED )
	self:SetHullSizeNormal()
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	self:SetNavType(NAV_FLY)

end
--------------------------------------------------------------------------------=#