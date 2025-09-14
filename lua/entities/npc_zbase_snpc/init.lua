include("shared.lua")
include("zbase_ai.lua")
include("zbase_aerial.lua")
include("zbase_poseparam.lua")

ENT.IsZBase_SNPC = true

function ENT:Initialize()
	if !self.UseVPhysics then
		-- Use normal physics

		self:SetSolid(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_STEP)
	end

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

	self.ZBase_HasLUAFlyCapability = true -- Set to false whenever flying SNPCs should not be able to make new goals.

	-- Register frame tick function for SNPC
    self:CONV_AddHook("Tick", function()
        -- Frame tick every frame
        self:FrameTick()
	end, "FrameSNPC")
end

function ENT:Think()
	-- Make sure we stay invisible when we are dead
	-- TODO: Does this still happpen?
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

	self:PoseParamThink()

	self:ZBaseThink()
end

-- Removes the SNPC and spawns a ragdoll
function ENT:SNPCDeath(dmginfo)
	if self:GetShouldServerRagdoll() || dmginfo:IsDamageType(DMG_DISSOLVE) then
		-- Server ragdoll

		-- LUA BecomeRagdoll code
		self:MakeShiftRagdoll()

		-- Remove me soon
		SafeRemoveEntityDelayed(self, 0.1)
	else
		-- Client ragdoll 
		
		self:StopMoving()
		self:ClearGoal()
		self:CapabilitiesClear()
		self:SetCollisionBounds(vector_origin, vector_origin)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetNPCState(NPC_STATE_DEAD)
		SafeRemoveEntityDelayed(self, 1)
		net.Start("ZBaseClientRagdoll")
		net.WriteEntity(self)
		net.SendPVS(self:GetPos())
	end
end

function ENT:OnTakeDamage( dmginfo )
	-- On hurt behaviour
	self:SNPCOnHurt(dmginfo)

	-- Decrease health
	self:SetHealth( self:Health() - dmginfo:GetDamage() )

	-- Die
	if self:Health() <= 0 && !self.Dead then
		-- Run OnNPCKilled
		hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
		
		-- Become ragdoll
		self:SNPCDeath(dmginfo)
	end
end