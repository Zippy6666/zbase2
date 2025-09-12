include("shared.lua")

ENT.m_iClass = CLASS_NONE
ENT.ZBaseFaction = "neutral"
ENT.IsZBaseNavigator = true

function ENT:Initialize()
	self:SetModel( "models/breen.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetNotSolid(true)
	self:SetMoveType( MOVETYPE_STEP )
	self:CapabilitiesAdd( bit.bor(CAP_MOVE_GROUND, CAP_SKIP_NAV_GROUND_CHECK ))
	self:AddFlags(FL_NOTARGET)
    self:AddFlags(EFL_DONTBLOCKLOS)
	self:SetMaterial("models/wireframe")
    self:SetNoDraw(!GetConVar("developer"):GetBool() or !ZBCVAR.ShowNavigator:GetBool())
	self:SetNPCState(NPC_STATE_IDLE)
	self:SetHealth(math.huge)
end

function ENT:SelectSchedule()
	if self.Sched == SCHED_DIE then return end
	if self.Sched == SCHED_DIE_RAGDOLL then return end
	
	if IsValid(self.ForceEnemy) then
		self:AddEntityRelationship(self.ForceEnemy, D_HT, 0)
		self:SetEnemy(self.ForceEnemy)
		self:UpdateEnemyMemory(self.ForceEnemy, self.ForceEnemy:GetPos())
	end

	self:SetLastPosition(self.ForcedLastPos)

	if istable(self.Sched) then
		self:StartSchedule(self.Sched)
	elseif isnumber(self.Sched) then
		self:SetSchedule(self.Sched)
	end

	local own = self:GetOwner()
	timer.Simple(0.4, function()
		if !(IsValid(self) && IsValid(own)) then return end
		
		local waypoint = self:GetCurWaypointPos()

		if waypoint:IsZero() then
			self:Remove()
		else
			self.MoveConfirmed = true
		end
	end)
end

function ENT:Think()
	if self.MoveConfirmed then
		local own = self:GetOwner()
		local waypoint = self:GetCurWaypointPos()

		if IsValid(own) then
			self:SetNPCState(own:GetNPCState())
		end

		if !waypoint:IsZero() && IsValid(own) && own.NavigatorWaypoint != waypoint then

			own.NavigatorWaypoint = waypoint
			own:AerialCalcGoal(own.NavigatorWaypoint)

		end

		if ZBCVAR.ShowNavigator:GetBool() then
			debugoverlay.Text(self:WorldSpaceCenter(), "navigator sched: "..ZBaseSchedDebug( self ), 0.13)
		end
	end
end

-- Get the name of the current custom schedule
function ENT:GetCurrentCustomSched()
	return self.CurrentSchedule && self.CurrentSchedule.DebugName
end

-- Check if we are doing a certain ZSched, by name
function ENT:IsCurrentZSched( sched )
	local curCusSchd = self:GetCurrentCustomSched()
	if "ZSched"..sched == curCusSchd
	or "SCHED_ZBASE_"..(ZBaseDepSchedTrans[sched] or "") == curCusSchd
	or "SCHED_ZBASE_"..sched == curCusSchd then
		return true
	end
end