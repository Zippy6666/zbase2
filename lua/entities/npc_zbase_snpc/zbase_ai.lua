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
function ENT:DoNPCState()
	local enemy = self:GetEnemy()
	local enemyInvalidPlayer = IsValid(enemy) && enemy:IsPlayer() && (!enemy:Alive() or GetConVar("ai_ignoreplayers"):GetBool())


	-- If there is no valid enemy and the NPC state is combat, set to idle
	if !(IsValid(enemy) && !enemyInvalidPlayer)
	&& self:GetNPCState() == NPC_STATE_COMBAT then
		self:SetNPCState(NPC_STATE_IDLE)
	end
end
--]]======================================================================================================]]
function ENT:DoSequence()
	if self.StopPlaySeqTime < CurTime() then
		self:SetPlaybackRate(1)
		self:ResetIdealActivity(ACT_IDLE)
		self.BaseDontSetPlaybackRate = true
	end
end
--]]======================================================================================================]]
function ENT:SelectSchedule( iNPCState )
	self:SNPCSelectSchedule( iNPCState )
end
--]]======================================================================================================]]
function ENT:GetCurrentCustomSched(checkNavigator)
	if checkNavigator && IsValid(self.Navigator) then
		return self.Navigator.CurrentSchedule && self.Navigator.CurrentSchedule.DebugName
	else
		return self.CurrentSchedule && self.CurrentSchedule.DebugName
	end
end
--]]======================================================================================================]]
function ENT:IsCurrentCustomSched( sched, checkNavigator )
	return "ZSched"..sched == self:GetCurrentCustomSched(checkNavigator)
end
--]]======================================================================================================]]
function ENT:DoingChaseFallbackSched(checkNavigator)
	return self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_DoCover", checkNavigator)
	or self:IsCurrentCustomSched("CombatChase_CannotReachEnemy_MoveRandom", checkNavigator)
	or self:IsCurrentCustomSched("CombatChase_CantReach_CoverEnemy", checkNavigator)
end
--]]======================================================================================================]]
function ENT:DetermineNewSchedule()
	local enemy = self:GetEnemy()
	local enemyValid = IsValid(enemy)
	local enemyVisible = enemyValid && self.EnemyVisible
	local enemyUnreachable = enemyValid && self:IsUnreachable(enemy)
	local hasReachedEnemy = self:ZBaseDist(enemy, {within=self:OBBMaxs().x*2})


	-- Can't reach the enemy when chasing fallback
	if self:IsCurrentCustomSched("CombatChase")
	&& enemyValid
	&& !hasReachedEnemy -- We have reached the enemy, no fallback needed
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


	-- We have reached the enemy, no need to keep chasing
	if self:IsCurrentCustomSched("CombatChase")
	&& hasReachedEnemy then
		return "CombatFace"
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
		if (self:IsMoving() or self.AerialGoal)
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
	end


	if self:TaskFinished() then
		self:NextTask( schedule )
	end
end
--]]======================================================================================================]]
function ENT:RunAI( strExp )
	-- NPC State stuff
	self:DoNPCState()
	

	if self.DoingPlayAnim or self.DoingAerialMoveAnim then
		return
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
	if ( self:DoingEngineSchedule()
	or (IsValid(self.Navigator) && self.Navigator:DoingEngineSchedule()) ) then
		return true
	end


	-- If we're currently running a schedule then run it.
	if ( self.CurrentSchedule ) then
		self:DoSchedule( self.CurrentSchedule )
	end


	-- If we have no schedule (schedule is finished etc)
	-- Then get the derived NPC to select what we should be doing
	if ( !self.CurrentSchedule && !self.Navigator.CurrentSchedule ) then

		self:SelectSchedule()

		-- If chase schedule was selected and the NPC is flying
		-- Do this crap
		if self.SNPCType==ZBASE_SNPCTYPE_FLY
		&& self:IsCurrentCustomSched("CombatChase") then
			local ene = self:GetEnemy()
			local seeEnemy = IsValid(ene) && self.EnemyVisible

			self.AerialGoal = seeEnemy && ene:GetPos()
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
function ENT:SNPCHandleDanger()
	local hint = self.InternalLoudestSoundHint
end
--]]======================================================================================================]]