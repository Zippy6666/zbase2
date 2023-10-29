include("shared.lua")
util.AddNetworkString("base_ai_zbase_client_ragdoll")


ENT.m_fMaxYawSpeed = 30 -- Max turning speed
ENT.IsZBase_SNPC = true


--------------------------------------------------------------------------------=#
function ENT:Initialize()

	-- Some default calls to make the NPC function
	self:SetModel( "models/Zombie/Classic.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )

	self:CapabilitiesAdd(bit.bor(

		-- Navigation essentials
		CAP_MOVE_GROUND,
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
function ENT:SelectSchedule( iNPCState )

	-- Don't remove this line!
	if self.PreventSelectSched then return end

	-- Example
	if IsValid(self:GetEnemy()) then
		self:SetSchedule(SCHED_COMBAT_FACE)
	else
		self:SetSchedule(SCHED_IDLE_STAND)
	end

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
        SafeRemoveEntityDelayed(self, 0.66)
	end

end
--------------------------------------------------------------------------------=#
function ENT:OnTakeDamage( dmginfo )

	self:SetHealth( self:Health() - dmginfo:GetDamage() )
	if self:Health() <= 0 then
		self:Die( dmginfo )
	end

end
--------------------------------------------------------------------------------=#
function ENT:StopAndPreventSelectSchedule( duration )
	if self.PreventSelectSched then return end
	self:ClearGoal()
	self:ClearSchedule()
	self.CurrentSchedule = nil
	self.PreventSelectSched = true
	timer.Create("SomeStupidTimerIdk"..self:EntIndex(), duration, 1, function() if IsValid(self) then
		self.PreventSelectSched = false
	end end)
end
--------------------------------------------------------------------------------=#
function ENT:DoCurrentAnimation()
	-- Animation --
	if isstring(self.CurrentAnimation) then
		-- String sequence
		local act = self:GetSequenceActivity(self:LookupSequence(self.CurrentAnimation))

		if act != -1 then
			self:SetActivity(act)
		else
			self:SetSequence(self.CurrentAnimation)
		end
	else
		-- Number activity
		self:SetActivity(self.CurrentAnimation)
	end
	-----------------------------=#
	
	-- Facing stuff --
	local face = self.SequenceFaceType
	local enemy = self:GetEnemy()
	local enemyPos = IsValid(enemy) && enemy:GetPos()

	if face == "enemy" && enemyPos then
		self.AnimFacePos = enemyPos
	elseif face == "enemy_visible" && enemyPos && self:Visible(enemy) then
		self.AnimFacePos = enemyPos
	end

	if face != "none" then
		self:Face(self.AnimFacePos)
	end
	-----------------------------=#

	-- Make sure SNPC is still
	self:SetMoveVelocity(Vector())
end
--------------------------------------------------------------------------------=#
function ENT:DoNPCState()
	local enemy = self:GetEnemy()
	local enemyInvalidPlayer = IsValid(enemy) && enemy:IsPlayer() && (!enemy:Alive() or GetConVar("ai_ignoreplayers"):GetBool())
	local stateNotIdle = self:GetNPCState() != NPC_STATE_IDLE

	-- Force set to idle when there is no enemy
	if stateNotIdle && !(IsValid(enemy) && !enemyInvalidPlayer) then
		self:SetNPCState(NPC_STATE_IDLE)
	end
end
--------------------------------------------------------------------------------=#
function ENT:RunAI( strExp )
	self:DoNPCState()

	-- Play animation:
	if self.CurrentAnimation then
		self:DoCurrentAnimation()
		return
	end

	-- If we're running an Engine Side behaviour
	-- then return true and let it get on with it.
	if ( self:IsRunningBehavior() ) then
		return true
	end

	-- If we're doing an engine schedule then return true
	-- This makes it do the normal AI stuff.
	if ( self:DoingEngineSchedule() ) then
		return true
	end

	-- If we're currently running a schedule then run it.
	if ( self.CurrentSchedule ) then
		self:DoSchedule( self.CurrentSchedule )
	end

	-- If we have no schedule (schedule is finished etc)
	-- Then get the derived NPC to select what we should be doing
	if ( !self.CurrentSchedule ) then
		self:SelectSchedule()
	end

	-- Do animation system
	self:MaintainActivity()

end
--------------------------------------------------------------------------------=#