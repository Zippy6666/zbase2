--]]======================================================================================================]]
function ENT:StartSchedule( sched )
    if self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialSetSchedule(table.Copy(sched))
    end

	self.CurrentSchedule = sched
	self.CurrentTaskID = 1
	self:SetTask( sched:GetTask( 1 ) )
end
--]]======================================================================================================]]
function ENT:NewSched( newsched )
	self:FullReset()

	if isnumber(newsched) then
		self:SetSchedule(newsched)
	elseif isstring(newsched) then
		self:StartSchedule(ZSched[newsched])
	elseif istable(newsched) then
		self:StartSchedule(newsched)
	end
end
--]]======================================================================================================]]
function ENT:SelectSchedule( iNPCState )
	local ene = self:GetEnemy()


	-- Schedule given by user
	local sched = self:SNPCSelectSchedule( iNPCState )


	-- Fixes enemy not being registered as visible after some bs happends idk
	-- Plz don't remove future zippy :(
	if !self.EnemyVisible then
    	self.EnemyVisible = self.EnemyVisible or (IsValid(ene) && self:Visible(ene))
	end


	-- Don't start chase if we are too close
	if sched==ZSched.CombatChase && self:TooCloseForCombatChase() then
		sched = self:SNPCChase_TooClose()
	end


	self:NewSched( sched )


	-- Tell aerial base to follow the player directly instead of navigating if the enemy is visible
	if self.SNPCType==ZBASE_SNPCTYPE_FLY && self.AerialShouldFollowPlayerDirectly then
		local ene = self:GetEnemy()

		if IsValid(ene) then
			self.AerialGoal = ene:GetPos()
		end
	end
end
--]]======================================================================================================]]
function ENT:GetCurrentCustomSched()

	return self.CurrentSchedule && self.CurrentSchedule.DebugName

end
--]]======================================================================================================]]
function ENT:IsCurrentCustomSched( sched )

	return "ZSched"..sched == self:GetCurrentCustomSched()

end
--]]======================================================================================================]]
function ENT:DoingChaseFallbackSched()

	return self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_DoCover")
	or self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_MoveRandom")
	or self:IsCurrentCustomSched("CombatChase_CantReach_CoverEnemy")

end
--]]======================================================================================================]]
function ENT:DoingChaseSched()
	return self:IsCurrentCustomSched("CombatChase") or self:IsCurrentCustomSched("AerialChase_NoNav")
end
--]]======================================================================================================]]
function ENT:TooCloseForCombatChase()

	return self.ChaseMinDistance > 0 && self.EnemyVisible && self:ZBaseDist(self:GetEnemy(), {within=self.ChaseMinDistance})

end
--]]======================================================================================================]]
function ENT:GetBetterSchedule()
	if self.NextGetBetterSchedule > CurTime() then return end


	local enemy = self:GetEnemy()
	local enemyValid = IsValid(enemy)
	local enemyUnreachable = enemyValid && self:IsUnreachable(enemy)
	local hasReachedEnemy = self:ZBaseDist(enemy, { within=ZBaseRoughRadius( self ) })


	-- Can't reach the enemy when chasing fallback
	if self:DoingChaseSched() && enemyValid && !hasReachedEnemy && self:IsNavStuck() then
		self:RememberUnreachable( enemy, 4 )
	
		if self.EnemyVisible then
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


	-- Chase min distance reached, stop
	if self:DoingChaseSched() && self:TooCloseForCombatChase() then
		return self:SNPCChase_TooClose()
	end


	-- We have reached the enemy, no need to keep chasing
	if self:DoingChaseSched() && hasReachedEnemy then
		return "CombatFace"
	end


	-- Don't combat patrol if enemy is seen
	if self:IsCurrentSchedule(SCHED_COMBAT_PATROL) && self.EnemyVisible then
		return false
	end


	-- Still can't navigate while doing fall back, do move random
	if self:DoingChaseFallbackSched() && self:IsNavStuck() then
		return "CombatChase_CantReach_MoveRandom"
	end


	-- Enemy is reachable, stop doing chase fallback
	if self:DoingChaseFallbackSched() && !enemyUnreachable then
		return false
	end


	self.NextGetBetterSchedule = CurTime()+math.Rand(1, 1.5)
end
--]]======================================================================================================]]
function ENT:GetAerialTranslatedSched()
	if IsValid(self.Navigator) then
		if self.Navigator:IsCurrentCustomSched("CombatChase") && self.EnemyVisible then
			return "AerialChase_NoNav", self:GetEnemy():GetPos()
		end

		if self.Navigator:IsCurrentCustomSched("BackAwayFromEnemy") && self.EnemyVisible then
			return "AerialBackAway_NoNav", self:GetPos()+( self:GetPos() - self:GetEnemy():GetPos() ):GetNormalized()*300
		end
	end
end
--]]======================================================================================================]]
function ENT:IsNavStuck()

	if self.SNPCType != ZBASE_SNPCTYPE_WALK then return false end

	return self.NextStuck < CurTime()

end
--]]======================================================================================================]]
function ENT:SetNotNavStuck()

	self.NextStuck = CurTime()+0.3

end
--]]======================================================================================================]]
function ENT:DetermineNavStuck()
	if self:IsGoalActive() && self:GetCurWaypointPos()!=Vector() then
		self:SetNotNavStuck()
	end
end
--]]======================================================================================================]]
function ENT:DoSchedule( schedule )
	-- Stop schedule if current task makes it move and SNPC does not have movement
	if self.SNPCType != ZBASE_SNPCTYPE_WALK && self.CurrentTask && self.CurrentTask.TaskName=="TASK_WAIT_FOR_MOVEMENT" then
		self:ScheduleFinished()
		self:ClearGoal()
		self:StopMoving()
		return
	end


	-- Run da task
	if self.CurrentTask then
		self:RunTask( self.CurrentTask )
	end


	-- Task is finished, do next task
	if self:TaskFinished() then
		self:NextTask( schedule )
	end
end
--]]======================================================================================================]]
function ENT:DoNPCState()
	local state = self:GetNPCState()
	local ene = self:GetEnemy()


	if self.SNPCType==ZBASE_SNPCTYPE_FLY && state==NPC_STATE_NONE then
		self:SetNPCState(NPC_STATE_IDLE)
	end


	if !IsValid(ene) && self.LastNPCState==NPC_STATE_COMBAT then
		self:SetNPCState(NPC_STATE_ALERT)
	end


	self.LastNPCState = state
end
--]]======================================================================================================]]
function ENT:RunAI( strExp )
	-- Don't do any run AI stuff if we should play an animation from PlayAnimation()
	if self.DoingPlayAnim then
		return
	end


	-- Some essential stuff regarding NPC_STATE
	self:DoNPCState()


	-- Check if waypoint has been 0,0,0 for some time
	if self.SNPCType == ZBASE_SNPCTYPE_WALK then
		self:DetermineNavStuck()
	end


	-- Stop, or replace schedules that shouldn't play right now
	-- newsched == false -> stop schedule
	-- newsched == nil -> do nothing
	local newsched = self:GetBetterSchedule()
	if newsched or newsched==false then
		self:NewSched(newsched)
	end


	-- Aerial mfs should get scheds more optimized for them
	if self.SNPCType==ZBASE_SNPCTYPE_FLY then
		local newsched, aerialGoal = self:GetAerialTranslatedSched()


		if newsched then
			self:NewSched(newsched)
		end


		if aerialGoal then
			self:AerialCalcGoal(aerialGoal)
		end
	end


	-- Do engine schedule
	if self:DoingEngineSchedule() or (IsValid(self.Navigator) && self.Navigator:DoingEngineSchedule()) then
		return true
	end


	-- Do custom schedule
	if self.CurrentSchedule then
		self:DoSchedule( self.CurrentSchedule )
	end


	-- Select new schedule if none is playing
	if !self.CurrentSchedule && !self.Navigator.CurrentSchedule then
		self:SelectSchedule()
	end


	-- Maintain activity
	self:MaintainActivity()
end
--]]======================================================================================================]]
function ENT:FaceHurtPos(dmginfo)
	if !IsValid(self:GetEnemy()) && self.NextFaceHurtPos < CurTime() && !self.DoingPlayAnim && IsValid(dmginfo:GetInflictor()) then

		self:FullReset()
		self:SetTarget(dmginfo:GetInflictor())
		self:SetSchedule(SCHED_TARGET_FACE)

		self.NextFaceHurtPos = CurTime() + math.Rand(2, 3)

	end
end
--]]======================================================================================================]]