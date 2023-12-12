include("shared.lua")
include("zbase_ai.lua")
include("zbase_aerial.lua")
util.AddNetworkString("base_ai_zbase_client_ragdoll")


local NPCMETA = FindMetaTable("NPC")


if !ZBase_OldGetNearestSquadMember then
	ZBase_OldGetNearestSquadMember = NPCMETA.GetNearestSquadMember
end


ENT.m_iClass = CLASS_NONE
ENT.IsZBase_SNPC = true


--]]======================================================================================================]]
function ENT:Initialize()
	self:SetHullType(self.HullType or HULL_MEDIUM)
	self:SetHullSizeNormal()
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_STEP)


	if self.SNPCType == ZBASE_SNPCTYPE_WALK then
		self:CapabilitiesAdd(CAP_MOVE_GROUND)
	elseif self.SNPCType == ZBASE_SNPCTYPE_FLY then
		self:CapabilitiesAdd(CAP_MOVE_FLY)
		self:SetNavType(NAV_FLY)
	end


	self.Bullseye = ents.Create("npc_bullseye")
	self.Bullseye:SetPos(self:GetPos())
	self.Bullseye:SetAngles(self:GetAngles())
	self.Bullseye:SetNotSolid(true)
	self.Bullseye:SetParent(self)
	self.Bullseye:AddEFlags(EFL_DONTBLOCKLOS)
	self.Bullseye:Spawn()
	self.Bullseye:Activate()


	self:SNPCInitVars()
end
--]]======================================================================================================]]
function ENT:SNPCInitVars()
	self.NextDetermineNewSched = CurTime()
	self.Move_AvoidSquadMembers = CurTime()
	self.Aerial_NextMoveFromGroundCheck = CurTime()
	self:SetNotNavStuck()
	self.Navigator = NULL
	self.Aerial_CurSpeed = 0
	self.Aerial_LastMoveDir = self:GetForward()
	self.SNPCNextSlowThink = CurTime()
	self.NextFaceHurtPos = CurTime()
	self.NextGetBetterSchedule = CurTime()
	self.NextSelectSchedule = CurTime()
end
--]]======================================================================================================]]
function ENT:Think()
	if ZBCVAR.NoThink:GetBool() then return end


	if self.SNPCType == ZBASE_SNPCTYPE_FLY then
		self:AerialThink()
	end


	self:ZBaseThink()
end
--]]======================================================================================================]]
function NPCMETA:SetSchedule( sched )
    if self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialSetSchedule(sched)
    end

    return ZBase_OldSetSchedule(self, sched)
end
--]]======================================================================================================]]
function NPCMETA:GetNearestSquadMember( radius, zbaseSNPCOnly )
	if !self.IsZBase_SNPC then return ZBase_OldGetNearestSquadMember(self) end

	local mindist
	local squadmember

	for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius or 256)) do
		if v == self then continue end
		if !v:IsNPC() then continue end
		if zbaseSNPCOnly && !v.IsZBase_SNPC then continue end

		if self:SquadName() == v:GetKeyValues().squadname then
			local dist = self:GetPos():DistToSqr(v:GetPos())

			if !mindist or dist < mindist then
				mindist = dist
				squadmember = v
			end
		end
	end

	return squadmember
end
--]]======================================================================================================]]
function ENT:OnTakeDamage( dmginfo )
	-- On hurt behaviour
	self:SNPCOnHurt(dmginfo)


	-- Decrease health
	self:SetHealth( self:Health() - dmginfo:GetDamage() )


	-- Die
	if self:Health() <= 0 then
		hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	end
end
--]]======================================================================================================]]
function ENT:OnRemove()
    self:SetSquad("") -- To prevent m_bDidDeathCleanup from crashing game.
    if self.Dead then self:SetSaveValue("m_bDidDeathCleanup", true) end
end
--]]======================================================================================================]]