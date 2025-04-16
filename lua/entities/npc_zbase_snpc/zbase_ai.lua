local AIDisabled = GetConVar("ai_disabled")
local DeprecatedScheduleTranslation = {
	CombatChase = "COMBAT_CHASE",
	CombatChase_CantReach_CoverOrigin = "COMBAT_CHASE_FAIL_COVER_ORIGIN",
	CombatChase_CantReach_CoverEnemy = "COMBAT_CHASE_FAIL_COVER_ENE",
	CombatChase_CantReach_MoveRandom = "COMBAT_CHASE_FAIL_MOVE_RANDOM",
	AerialChase_NoNav = "FLY_CHASE_NO_NAV",
	AerialBackAway_NoNav = "FLY_AWAY_NO_NAV",
	PursueAerialGoal = "FLY_TO_GOAL",
	CombatFace = "COMBAT_FACE",
	FaceLastPos = "FACE_LASTPOS",
	BackAwayFromEnemy = "BACK_AWAY",
	RunRandom = "RUN_RANDOM",
	WalkRandom = "WALK_RANDOM"
}

function ENT:StartSchedule( sched )
	-- Start sched for aerial mfs, set up navigator and shid
    if self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialSetSchedule(table.Copy(sched))
    end

	-- Regular start sched
	self.CurrentSchedule = sched
	self.CurrentTaskID = 1
	self:SetTask( sched:GetTask( 1 ) )
end

function ENT:NewSched( newsched )
	-- Conviniently set any kind of schedule

	self:FullReset()

	if isnumber(newsched) then
		self:SetSchedule(newsched)
	elseif isstring(newsched) then
		newsched = DeprecatedScheduleTranslation[newsched] or newsched
		self:StartSchedule(ZSched[newsched])
	elseif istable(newsched) then
		if isstring( newsched.DebugName ) then
			local schedName = string.Replace(newsched.DebugName, "ZSched", "")
			local deprecatedSchedTrans = DeprecatedScheduleTranslation[schedName]
			if deprecatedSchedTrans then
				newsched = ZSched[deprecatedSchedTrans]
			end
		end

		self:StartSchedule(newsched)
	end
end

function ENT:SelectSchedule( iNPCState )
	local ene = self:GetEnemy()

	-- Schedule given by user
	local sched = self:SNPCSelectSchedule( iNPCState )

	-- Fixes enemy not being registered as visible after some bs happends idk
	-- Plz don't remove future zippy :(
	if !self.EnemyVisible then
    	self.EnemyVisible = IsValid(ene) && self:Visible(ene)
	end

	-- Don't start chase if we are too close
	if (sched==ZSched.CombatChase or sched==ZSched.COMBAT_CHASE) && self:TooCloseForCombatChase() then
		sched = self:SNPCChase_TooClose()
	end

	-- Start/set the schedule
	self:NewSched( sched )
end

-- Get the name of the current custom schedule
function ENT:GetCurrentCustomSched()
	return self.CurrentSchedule && self.CurrentSchedule.DebugName
end

-- Check if we are doing a certain ZSched, by name
function ENT:IsCurrentZSched( sched )
	local curCusSchd = self:GetCurrentCustomSched()
	if "ZSched"..sched == curCusSchd
	or "SCHED_ZBASE_"..(DeprecatedScheduleTranslation[sched] or "") == curCusSchd
	or "SCHED_ZBASE_"..sched == curCusSchd then
		return true
	end
end

function ENT:DoingChaseFallbackSched()
	return self:IsCurrentZSched("CombatChase_CannotReachEnemy_DoCover")
	or self:IsCurrentZSched("CombatChase_CannotReachEnemy_MoveRandom")
	or self:IsCurrentZSched("CombatChase_CantReach_CoverEnemy")
end

function ENT:DoingChaseSched()
	return self:IsCurrentZSched("CombatChase") or self:IsCurrentZSched("AerialChase_NoNav")
end

function ENT:TooCloseForCombatChase()
	return self.ChaseMinDistance > 0 && self.EnemyVisible && self:ZBaseDist(self:GetEnemy(), {within=self.ChaseMinDistance})
end

-- TODO: ENT.IsUnreachable and ENT.IsNavStuck, what is the difference?
function ENT:GetBetterSchedule()
	if self.NextGetBetterSchedule > CurTime() then return end

	local enemy = self:GetEnemy()
	local enemyValid = IsValid(enemy)
	local enemyUnreachable = enemyValid && self:IsUnreachable(enemy)
	local hasReachedEnemy = self:ZBaseDist(enemy, { within=ZBaseRoughRadius( self ) })

	-- Can't reach the enemy when chasing
	-- Start fallback
	if self:DoingChaseSched() && enemyValid && !hasReachedEnemy && self:IsNavStuck() then

		self:RememberUnreachable( enemy, 4 )
	
		if self.EnemyVisible then

			if self.CantReachEnemyBehaviour == ZBASE_CANTREACHENEMY_HIDE then
	
				return (math.random(1, 2) == 1 && "CombatChase_CantReach_CoverOrigin")
				or "CombatChase_CantReach_CoverEnemy"

			elseif self.CantReachEnemyBehaviour == ZBASE_CANTREACHENEMY_FACE then

				return "CombatFace"
		
			elseif self.CantReachEnemyBehaviour == ZBASE_CANTREACHENEMY_GO_NEAR then

				self:SetSaveValue("m_vSavePosition", enemy:GetPos())
				return "ESTABLISH_LINE_OF_FIRE"

			end

		else

			if self.CantReachEnemyBehaviour == ZBASE_CANTREACHENEMY_GO_NEAR then

				self:SetSaveValue("m_vSavePosition", enemy:GetPos())
				return "ESTABLISH_LINE_OF_FIRE"

			end
			return SCHED_COMBAT_PATROL -- Patrol if enemy is not visible

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
		return SCHED_RUN_RANDOM
	end

	-- Enemy is reachable, stop doing chase fallback
	if self:DoingChaseFallbackSched() && !enemyUnreachable then
		return false
	end

	self.NextGetBetterSchedule = CurTime()+math.Rand(1, 1.5)
end

function ENT:IsNavStuck()
	if self.SNPCType != ZBASE_SNPCTYPE_WALK then return false end

	return self.NextStuck < CurTime()
end

function ENT:SetNotNavStuck()

	self.NextStuck = CurTime()+0.3

end

function ENT:DetermineNavStuck()

	if self:IsGoalActive() && self:GetCurWaypointPos()!=vector_origin then
		self:SetNotNavStuck()
	end

end

function ENT:DoSchedule( schedule )
	-- Stop schedule if current task makes it move and SNPC does not have movement
	-- TODO: Is this used?
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

function ENT:RunAI( strExp )
	if self.Dead or self.DoingPlayAnim then
		return
	end

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
		local newsched, aerialGoal = self:GetAerialOptimizedSched()

		if newsched then
			self:NewSched(newsched)
		end

		if aerialGoal then
			self:AerialCalcGoal(aerialGoal)
		end
	end

	-- Do engine schedule
	if self:DoingEngineSchedule() then
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

function ENT:TranslateSchedule(sched)
	if self.SNPCType == ZBASE_SNPCTYPE_FLY then
		return self:AerialTranslateSched(sched)
	end
end

function ENT:FaceHurtPos(dmginfo)
	if !IsValid(self:GetEnemy()) && self.NextFaceHurtPos < CurTime() && !self.DoingPlayAnim && IsValid(dmginfo:GetInflictor()) then
		self:FullReset()
		self:SetTarget(dmginfo:GetInflictor())
		self:SetSchedule(SCHED_TARGET_FACE)

		self.NextFaceHurtPos = CurTime() + math.Rand(2, 3)
	end
end
