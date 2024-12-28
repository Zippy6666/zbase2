include("shared.lua")
include("zbase_ai.lua")
include("zbase_aerial.lua")


ENT.IsZBase_SNPC = true


function ENT:Initialize()

	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_STEP)
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	self:SetBloodColor(BLOOD_COLOR_RED)
	
	self.Bullseye = ents.Create("npc_bullseye")
	self.Bullseye:SetPos(self:GetPos())
	self.Bullseye:SetAngles(self:GetAngles())
	self.Bullseye:SetNotSolid(true)
	self.Bullseye:SetParent(self)
	self.Bullseye:SetHealth(math.huge)
	self.Bullseye:AddEFlags(EFL_DONTBLOCKLOS)
	self.Bullseye:Spawn()
	self.Bullseye:Activate()

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
	self.InternalDistanceFromGround = self.Fly_DistanceFromGround

end


function ENT:Think()

	-- Make sure we stay invisible when we are dead
	if self.Dead && !self:GetNoDraw() then
		self:SetNoDraw(true)
	end

	if self.SNPCType == ZBASE_SNPCTYPE_FLY then
		self:AerialThink()
	end

	-- Apply notarget to its bullseye
	if IsValid(self.Bullseye) then

		local hasNoTarget, bullseyeNoTarget = self:Conv_HasFlags(FL_NOTARGET), self.Bullseye:Conv_HasFlags(FL_NOTARGET)
		if hasNoTarget && !bullseyeNoTarget then
			self.Bullseye:AddFlags(FL_NOTARGET)
		elseif !hasNoTarget && bullseyeNoTarget then
			self.Bullseye:RemoveFlags(FL_NOTARGET)
		end

	end

	self:ZBaseThink()

end


function ENT:OnTakeDamage( dmginfo )
	-- On hurt behaviour
	self:SNPCOnHurt(dmginfo)


	-- Decrease health
	self:SetHealth( self:Health() - dmginfo:GetDamage() )


	-- Die
	if self:Health() <= 0 && !self.Dead then
		hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	end
end

