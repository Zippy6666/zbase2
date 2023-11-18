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


local modelsWithPhysics = {}


--------------------------------------------------------------------------------=#
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

	self.NextDetermineNewSched = CurTime()
	self.Move_AvoidSquadMembers = CurTime()
	self.Aerial_NextMoveFromGroundCheck = CurTime()
	self:SetNotNavStuck()
	self.Navigator = NULL
	self.Aerial_CurSpeed = 0
	self.Aerial_LastMoveDir = self:GetForward()
	self.SNPCNextSlowThink = CurTime()


	local mdl = self:GetModel()
	if modelsWithPhysics[self:GetModel()] == nil then
		local phystest = ents.Create("prop_ragdoll")
		phystest:SetModel(mdl)
		phystest:Spawn()

		modelsWithPhysics[mdl] = IsValid(phystest:GetPhysicsObject())

		phystest:Remove()
	end
	self.ModelHasPhys = modelsWithPhysics[mdl]
end
--------------------------------------------------------------------------------=#
function ENT:Think()
	if !self.ModelHasPhys && self.SNPCNextSlowThink < CurTime() then
		-- Phys object workaround
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetPos(self:GetPos())
			-- debugoverlay.Sphere(self:GetPos(), 100, 0.2, Color(255, 255, 255, 25))
		end


		self.SNPCNextSlowThink = CurTime()+0.2
	end


	-- Aerial movement
	if self.SNPCType == ZBASE_SNPCTYPE_FLY then
	
		self:Aerial_CalcVel()

		
        local ene = self:GetEnemy()
        local seeEnemy = IsValid(ene) && self.EnemyVisible


		if self.Aerial_CurrentDestination then
        	self:Face( (self.Fly_FaceEnemy && seeEnemy && ene) or self.Aerial_CurrentDestination )
		end


		local vec = self:SNPCFlyVelocity(self.Aerial_LastMoveDir, self.Aerial_CurSpeed)
		if self.ShouldMoveFromGround then
			vec = vec+Vector(0,0,35)
		else
			vec = vec+Vector(0,0,30)
		end
		self:SetLocalVelocity(vec)


		self:AerialMoveAnim()
	end


	self:ZBaseThink()
end
--------------------------------------------------------------------------------=#
function NPCMETA:SetSchedule( sched )
    if self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialSetSchedule(sched)
    end

    return ZBase_OldSetSchedule(self, sched)
end
--------------------------------------------------------------------------------=#
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
--------------------------------------------------------------------------------=#
function ENT:ServerRagdoll( dmginfo )
	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self:GetModel())
	rag:SetPos(self:GetPos())
	rag:SetAngles(self:GetAngles())
	rag:SetSkin(self:GetSkin())
	rag:SetColor(self:GetColor())
	rag:SetMaterial(self:GetMaterial())
	rag:Spawn()
	local ragPhys = rag:GetPhysicsObject()

	if !IsValid(ragPhys) then
		rag:Remove()
		return
	end

	-- Ragdoll force
	if dmginfo:IsBulletDamage() then
		ragPhys:SetVelocity(dmginfo:GetDamageForce()*0.1)
	else
		ragPhys:SetVelocity(dmginfo:GetDamageForce())
	end

	-- Placement
	local physcount = rag:GetPhysicsObjectCount()
	for i = 0, physcount - 1 do
		local physObj = rag:GetPhysicsObjectNum(i)
		local pos, ang = self:GetBonePosition(self:TranslatePhysBoneToBone(i))
		physObj:SetPos( pos )
		physObj:SetAngles( ang )
	end

	-- Hook
	hook.Run("CreateEntityRagdoll", self, rag)

	-- Dissolve
	if dmginfo:IsDamageType(DMG_DISSOLVE) then
		rag:SetName( "base_ai_ext_rag" .. rag:EntIndex() )

		local dissolve = ents.Create("env_entity_dissolver")
		dissolve:SetKeyValue("target", rag:GetName())
		dissolve:SetKeyValue("dissolvetype", dmginfo:IsDamageType(DMG_SHOCK) && 2 or 0)
		dissolve:Fire("Dissolve", rag:GetName())
		dissolve:Spawn()
		rag:DeleteOnRemove(dissolve)

		rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		undo.ReplaceEntity( rag, NULL )
		cleanup.ReplaceEntity( rag, NULL )
	end

	-- Ignite
	if self:IsOnFire() then
		rag:Ignite(math.Rand(4,8))
	end
end
--------------------------------------------------------------------------------=#
function ENT:ClientRagdoll( dmginfo )
	net.Start("base_ai_zbase_client_ragdoll")
	net.WriteEntity(self)
	net.WriteVector(dmginfo:GetDamageForce())
	net.Broadcast()
end
--------------------------------------------------------------------------------=#
function ENT:Die( dmginfo )

	if self.Dead then return end
	self.Dead = true

	-- Death notice and other stuff
	hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	--self:SetNPCState(NPC_STATE_DEAD)

	if self:GetShouldServerRagdoll() or dmginfo:IsDamageType(DMG_DISSOLVE) then
		self:ServerRagdoll( dmginfo )
		self:Remove()
	else
		self:ClientRagdoll( dmginfo )
        self:AddFlags(FL_NOTARGET)
        self:SetCollisionBounds(Vector(), Vector())
        self:SetBloodColor(-1)
        self:CapabilitiesClear()
        self:SetNoDraw(true)
        -- SafeRemoveEntityDelayed(self, 0.66)
	end

end
--------------------------------------------------------------------------------=#
function ENT:OnTakeDamage( dmginfo )
	-- On hurt behaviour
	self:SNPCOnHurt(dmginfo)

	-- Decrease health
	self:SetHealth( self:Health() - dmginfo:GetDamage() )

	-- Die
	if self:Health() <= 0 then
		self:Die( dmginfo )
	end
end
--------------------------------------------------------------------------------=#
function ENT:OnRemove()
    self:SetSquad("") -- To prevent m_bDidDeathCleanup from crashing game.
    if self.Dead then self:SetSaveValue("m_bDidDeathCleanup", true) end
end
--------------------------------------------------------------------------------=#