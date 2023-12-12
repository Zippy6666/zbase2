-- 🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵
-- 🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵
-- 🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵
-- 🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵
-- 🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵🥵
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


	-- Don't chase if we are too close
	if sched==ZSched.CombatChase && self:TooCloseForCombatChase() then
		sched = self:SNPCChase_TooClose()
	end


	self:NewSched( sched )
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
function ENT:DoingChaseFallbackSched(checkNavigator)
	return self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_DoCover")
	or self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_MoveRandom")
	or self:IsCurrentCustomSched("CombatChase_CantReach_CoverEnemy")
end
--]]======================================================================================================]]
function ENT:TooCloseForCombatChase()
	return self.ChaseMinDistance > 0 && self.EnemyVisible && self:ZBaseDist(self:GetEnemy(), {within=self.ChaseMinDistance})
end
--]]======================================================================================================]]

-- 'sched' - The schedule to get a better replacement for
-- If not given, it will be the default schedule
function ENT:GetBetterSchedule( sched )
	if self.NextGetBetterSchedule > CurTime() then return end


	local enemy = self:GetEnemy()
	local enemyValid = IsValid(enemy)
	local enemyVisible = enemyValid && self.EnemyVisible
	local enemyUnreachable = enemyValid && self:IsUnreachable(enemy)
	local hasReachedEnemy = self:ZBaseDist(enemy, {within=self:OBBMaxs().x*3})


	-- Can't reach the enemy when chasing fallback
	if self:IsCurrentCustomSched("CombatChase") && enemyValid && !hasReachedEnemy && self:IsNavStuck() then
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


	-- Chase min distance reached, stop
	if self:IsCurrentCustomSched("CombatChase", true) && self:TooCloseForCombatChase() then
		return self:SNPCChase_TooClose()
	end


	-- We have reached the enemy, no need to keep chasing
	if self:IsCurrentCustomSched("CombatChase") && hasReachedEnemy then
		return "CombatFace"
	end


	-- Don't combat patrol if enemy is seen
	if self:IsCurrentSchedule(SCHED_COMBAT_PATROL) && enemyVisible then
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


	-- Give space to squadmembers while moving
	if self.Move_AvoidSquadMembers < CurTime() then
		if (self:IsMoving() or self.AerialGoal) && self:GetNPCState()==NPC_STATE_COMBAT then
			local squadmember = self:GetNearestSquadMember( nil, true )

			if IsValid(squadmember) && squadmember.SquadGiveSpace>0 && squadmember:IsMoving() && squadmember:GetNPCState() == NPC_STATE_COMBAT
			&& self:ZBaseDist(squadmember, {within=squadmember.SquadGiveSpace}) then
			
				debugoverlay.Text(self:GetPos(), "giving space: "..squadmember.SquadGiveSpace, 2)
				return "CombatFace" -- Face instead

			end
		end

		self.Move_AvoidSquadMembers = CurTime()+2
	end


	self.NextGetBetterSchedule = CurTime()+math.Rand(1, 1.5)
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
local ZBaseNavigatorSNPC_ForbiddenTasks = {
	["TASK_WAIT_FOR_MOVEMENT"] = true
}

function ENT:DoSchedule( schedule )
	if self.SNPCType != ZBASE_SNPCTYPE_WALK
	&& self.CurrentTask
	&& ZBaseNavigatorSNPC_ForbiddenTasks[self.CurrentTask.TaskName]
	then
		self:ScheduleFinished()
		self:ClearGoal()
		self:StopMoving()
		return
	end


	if self.CurrentTask then
		self:RunTask( self.CurrentTask )


		-- Tell aerial base to follow the player directly instead of navigating if the enemy is visible
		local task = self.CurrentTask.TaskName
		if "TASK_RUN_PATH" && self.LastTask_TASK_GET_PATH_TO_ENEMY && self.EnemyVisible then
			self.AerialShouldFollowPlayerDirectly = true
		elseif task=="TASK_GET_PATH_TO_ENEMY" then
			self.LastTask_TASK_GET_PATH_TO_ENEMY = true
		else
			self.LastTask_TASK_GET_PATH_TO_ENEMY = false
			self.AerialShouldFollowPlayerDirectly = false
		end
		
	end


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
	local CheckEnt = IsValid(self.Navigator) && self.Navigator or self


	if CheckEnt.DoingPlayAnim then
		return
	end


	if CheckEnt == self then
		self:DoNPCState()


		-- Check if waypoint has been 0,0,0 for some time
		self:DetermineNavStuck()


		-- Stop, or replace schedules that shouldn't play right now
		-- newsched == false -> stop schedule
		-- newsched == nil -> do nothing
		local newsched = self:GetBetterSchedule()
		if newsched or newsched==false then
			self:NewSched(newsched)
		end
	end


	-- If we're doing an engine schedule then return true
	-- This makes it do the normal AI stuff.
	if ( CheckEnt:DoingEngineSchedule() ) then
		return true
	end


	-- If we're currently running a schedule then run it.
	if ( CheckEnt.CurrentSchedule ) then
		CheckEnt:DoSchedule( CheckEnt.CurrentSchedule )
	end


	-- If we have no schedule (schedule is finished etc)
	-- Then get the derived NPC to select what we should be doing
	if !CheckEnt.CurrentSchedule then

		CheckEnt:SelectSchedule()

		-- Tell aerial base to follow the player directly instead of navigating if the enemy is visible
		if self.SNPCType==ZBASE_SNPCTYPE_FLY
		&& self.AerialShouldFollowPlayerDirectly then
			local ene = self:GetEnemy()

			if IsValid(ene) then
				self.AerialGoal = ene:GetPos()
			end
		end
	end


	-- Do animation system
	self:MaintainActivity()
end
--]]======================================================================================================]]
function ENT:FaceHurtPos(dmginfo)
	if !IsValid(self:GetEnemy())
	&& self.NextFaceHurtPos < CurTime()
	&& !self.DoingPlayAnim then
		self:FullReset()
		self:Face(dmginfo:GetDamagePosition(), math.Rand(2, 4), 5)
		self.NextFaceHurtPos = CurTime() + math.Rand(0.5, 1.5)
	end
end
--]]======================================================================================================]]