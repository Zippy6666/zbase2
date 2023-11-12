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
	if self.PreventSelectSched then
		return
	end

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
	return sched == self:GetCurrentCustomSched()
end
--------------------------------------------------------------------------------=#
function ENT:DoingChaseFallbackSched()
	return self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_DoCover")
	or self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_MoveRandom")
end
--------------------------------------------------------------------------------=#
function ENT:PreventSelectSchedule( duration )
	self.PreventSelectSched = true

	timer.Create("StopPreventSelectSched"..self:EntIndex(), duration, 1, function()
		if !IsValid(self) then return end

		self.PreventSelectSched = false
	end)
end
--------------------------------------------------------------------------------=#
function ENT:DetermineNewSchedule()
	-- if self.NextDetermineNewSched > CurTime() then return end

	
	local enemy = self:GetEnemy()
	local enemyValid = IsValid(enemy)
	local enemyVisible = enemyValid && self:Visible(enemy)
	local enemyUnreachable = enemyValid && self:IsUnreachable(enemy)


	-- Can't reach the enemy when chasing
	if self:IsCurrentCustomSched("CombatChase")
	&& enemyValid
	&& self:IsNavStuck() then
		self:RememberUnreachable( enemy, math.Rand(3, 6) )
		self:PreventSelectSchedule(3)

		if enemyVisible then
			-- Do CombatChase_CannotReachEnemy_DoCover if enemy is visible
			return "CombatChase_CannotReachEnemy_DoCover"
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


	-- If we are doing CombatChase_CannotReachEnemy_DoCover but we can't find a place to hide:
	if self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_DoCover")
	&& self:IsNavStuck() then
		-- Move randomly instead
		return "CombatChase_CannotReachEnemy_MoveRandom"
	end


	-- Enemy is reachable, stop doing chase fallback
	if self:DoingChaseFallbackSched()
	&& !enemyUnreachable then
		return false
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
	self:DoNPCState()
	


	-- Play sequence:
	if self.ZBaseSNPCSequence then
		local dontRunAI = self:DoSequence()
		
		if dontRunAI then return end
	end



	-- Check if waypoint has been 0,0,0 for some time
	self:DetermineNavStuck() 

	-- print(self:GetCurrentCustomSched())

	-- Stop, or replace schedules that shouldn't play right now
	if self.NextDetermineNewSched < CurTime() then
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
				debugoverlay.Text(self:GetPos()+VectorRand()*50, "newsched = "..tostring(newsched), 4)
			end
		end

		-- self.PreventSelectSched = true
		self.NextDetermineNewSched = CurTime()+1
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