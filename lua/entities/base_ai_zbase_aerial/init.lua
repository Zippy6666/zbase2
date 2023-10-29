include("shared.lua")
util.AddNetworkString("base_ai_zbase_client_ragdoll")

--------------------------------------------------------------------------------=#
function ENT:Initialize()

	-- Some default calls to make the NPC function
	self:SetModel( "models/Advisor.mdl" )
	self:SetHullType( HULL_LARGE_CENTERED )
	self:SetHullSizeNormal()
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	self:SetNavType(NAV_FLY)

	self:CapabilitiesAdd(bit.bor(

		-- Navigation essentials
		CAP_MOVE_FLY,
		CAP_SKIP_NAV_GROUND_CHECK,
		--=#

		-- Makes them not act like robots
		CAP_TURN_HEAD,
		CAP_ANIMATEDFACE
		--=#

	))

	self:SetHealth( 100 )

end
--------------------------------------------------------------------------------=#