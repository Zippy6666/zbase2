ZBASE_CANTREACHENEMY_HIDE = 1
ZBASE_CANTREACHENEMY_FACE = 2

--------------------------------------------------------------------------------=#
function ENT:DoNPCState()
	local enemy = self:GetEnemy()
	local enemyInvalidPlayer = IsValid(enemy) && enemy:IsPlayer() && (!enemy:Alive() or GetConVar("ai_ignoreplayers"):GetBool())


	-- If there is no valid enemy and the NPC state is combat, set to idle
	if !(IsValid(enemy) && !enemyInvalidPlayer)
	&& self:GetNPCState() == NPC_STATE_COMBAT then
		self:SetNPCState(NPC_STATE_IDLE)
	end
end
--------------------------------------------------------------------------------=#
function ENT:DoSequence()
	if self.StopPlaySeqTime > CurTime() then
		-- self:SetSequence(self.ZBaseSNPCSequence)
	else
		self:SetPlaybackRate(1)
		self:ResetIdealActivity(ACT_IDLE)
		self.BaseDontSetPlaybackRate = true
	end

	return true
end
--------------------------------------------------------------------------------=#
function ENT:SelectSchedule( iNPCState )
	self:SNPCSelectSchedule( iNPCState )
end
--------------------------------------------------------------------------------=#
function ENT:FullReset()
    self:TaskComplete()
    self:ClearGoal()
    self:ScheduleFinished()
    self:ClearSchedule()
    self:StopMoving()
    self:SetMoveVelocity(Vector())
end
--------------------------------------------------------------------------------=#
function ENT:GetCurrentCustomSched()
	return self.CurrentSchedule && self.CurrentSchedule.DebugName
end
--------------------------------------------------------------------------------=#
function ENT:IsCurrentCustomSched( sched )
	return "ZSched"..sched == self:GetCurrentCustomSched()
end
--------------------------------------------------------------------------------=#
function ENT:DoingChaseFallbackSched()
	return self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_DoCover")
	or self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_MoveRandom")
	or self:IsCurrentCustomSched("CombatChase_CantReach_CoverEnemy")
end
--------------------------------------------------------------------------------=#
function ENT:DetermineNewSchedule()
	local enemy = self:GetEnemy()
	local enemyValid = IsValid(enemy)
	local enemyVisible = enemyValid && self:Visible(enemy)
	local enemyUnreachable = enemyValid && self:IsUnreachable(enemy)


	-- Can't reach the enemy when chasing fallback
	if self:IsCurrentCustomSched("CombatChase")
	&& enemyValid
	&& !self:ZBaseDist(enemy, {within=100}) -- We have reached the enemy, no fallback needed
	&& self:IsNavStuck() then
		self:RememberUnreachable( enemy, 4 )
	
		if enemyVisible then
			if self.CantReachEnemyBehaviour == ZBASE_CANTREACHENEMY_HIDE then
				return (math.random(1, 2) == 1 && "CombatChase_CantReach_CoverOrigin")
				or "CombatChase_CantReach_CoverEnemy"

			elseif self.CantReachEnemyBehaviour == ZBASE_CANTREACHENEMY_FACE then
				return "CombatFace"

			end
		else
			-- Patrol if enemy is not visible
			return SCHED_COMBAT_PATROL
		end
	end



	-- Don't combat patrol if enemy is seen
	if self:IsCurrentSchedule(SCHED_COMBAT_PATROL)
	&& enemyVisible then
		return false
	end


	-- Still can't navigate while doing fall back, do move random
	if self:DoingChaseFallbackSched()
	&& self:IsNavStuck() then
		return "CombatChase_CantReach_MoveRandom"
	end


	-- Enemy is reachable, stop doing chase fallback
	if self:DoingChaseFallbackSched()
	&& !enemyUnreachable then
		return false
	end


	-- Give space to squadmembers while moving
	if self.Move_AvoidSquadMembers < CurTime() then
		if self:IsMoving()
		&& self:GetNPCState()==NPC_STATE_COMBAT then
			local squadmember = self:GetNearestSquadMember( nil, true )

			if IsValid(squadmember)
			&& squadmember:IsMoving()
			&& squadmember:GetNPCState() == NPC_STATE_COMBAT
			&& self:ZBaseDist(squadmember, {within=squadmember.SquadGiveSpace}) then
				debugoverlay.Text(self:GetPos(), "giving space: "..squadmember.SquadGiveSpace, 2)
				return "CombatFace" -- Face instead
			end
		end

		self.Move_AvoidSquadMembers = CurTime()+2
	end
end
--------------------------------------------------------------------------------=#
function ENT:IsNavStuck()
	return self.NextStuck < CurTime()
end
--------------------------------------------------------------------------------=#
function ENT:SetNotNavStuck()
	self.NextStuck = CurTime()+0.3
end
--------------------------------------------------------------------------------=#
function ENT:DetermineNavStuck()
	if self:IsGoalActive() && self:GetCurWaypointPos()!=Vector() then
		self:SetNotNavStuck()
	end
end
--------------------------------------------------------------------------------=#
function ENT:RunAI( strExp )
	-- NPC State stuff
	self:DoNPCState()
	

	-- Play sequence:
	if self.ZBaseSNPCSequence then
		local dontRunAI = self:DoSequence()
		
		if dontRunAI then return end
	end


	-- Check if waypoint has been 0,0,0 for some time
	self:DetermineNavStuck() 


	-- Stop, or replace schedules that shouldn't play right now
	-- newsched == false -> stop schedule
	-- newsched == nil -> do nothing
	local newsched = self:DetermineNewSchedule()
	if newsched or newsched==false then
		self:FullReset()

		if isnumber(newsched) then
			self:SetSchedule(newsched)
		elseif isstring(newsched) then
			self:StartSchedule(ZSched[newsched])
		end

		if GetConVar("developer"):GetBool() then
			timer.Create("ZSchedDebug"..self:EntIndex(), 0.5, 1, function()
				if !IsValid(self) then return end
				debugoverlay.Text(self:GetPos()+VectorRand()*50, "newsched = "..tostring(newsched), 4)
			end)
		end
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
function ENT:FaceHurtPos(dmginfo)
	self:FullReset()
	self:SetLastPosition(dmginfo:GetDamagePosition())

	timer.Simple(0.1, function()
		if !IsValid(self) then return end
		self:StartSchedule(ZSched.FaceLastPos)
	end)
end
--------------------------------------------------------------------------------=#