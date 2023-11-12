include("shared.lua")


-- Variables --


-- General
ENT.Models = ZBASE_TBL({}) -- Models to spawn with, add as many as you want
ENT.StartHealth = 100
ENT.m_fMaxYawSpeed = 28 -- Max turning speed
ENT.StartHullType = HULL_HUMAN -- https://wiki.facepunch.com/gmod/Enums/HULL
ENT.BloodColor = BLOOD_COLOR_RED -- https://wiki.facepunch.com/gmod/Enums/BLOOD_COLOR
ENT.SightDistance = 10000

-- Faction
-- You can make up your own factions and call them whatever you want
-- Common factions:
-- CLASS_COMBINE - Friendly towards combies
-- CLASS_ZOMBIE - Friendly towards zombies
-- CLASS_ANTLION - Friendly towards antlions
-- CLASS_PLAYER_ALLY - Friendly towards players and rebels and such
ENT.ZBase_Factions = ZBASE_TBL({"CLASS_PLAYER_ALLY"}) -- Add as many as you want

-- Patrol type:
-- "none"
-- "walk"
-- "run"
-- "turn"
ENT.Patrol = "none"

-- Alert allies
ENT.AlertAllyDistance = 2000 -- Max distance that it can alert an ally from, allies will alert each other in a chain
ENT.AlertAllyDistanceInfinite = false -- Call allies from anywhere, realistic if the NPC has a radio for example

-- Shooting
ENT.WeaponProficiency = WEAPON_PROFICIENCY_AVERAGE -- https://wiki.facepunch.com/gmod/Enums/WEAPON_PROFICIENCY
ENT.ShootDistanceMax = 3000 -- Maximum shooting distance
ENT.ShootMovingTypes = ZBASE_TBL({"WALK", "RUN"}) -- In what ways can the SNPC move while firing? Leave empty to never move while firing. Only "WALK" and "RUN" are accepted.

-- Melee Attack
ENT.MeleeAttack = false -- Should it melee attack?
ENT.MeleeAttackAnimations = ZBASE_TBL({ACT_MELEE_ATTACK1}) -- Sequence name, or activity (https://wiki.facepunch.com/gmod/Enums/ACT), as many as you want
ENT.MeleeAttackSequenceDuration = 1 -- How long should the AI remain "paused" then doing melee sequence, false = duration of the animation
ENT.MeleeAttackDamage = 10 -- Melee attack damage
ENT.MeleeAttackDamageDelay = 0.5 -- Time until damage

--------------------------------------------------------------------------------=#


-- Functions that you can change --


--------------------------------------------------------------------------------=#
function ENT:CustomOnInitialize() end
--------------------------------------------------------------------------------=#
function ENT:CustomOnThink() end
--------------------------------------------------------------------------------=#
function ENT:BeforeTakeDamage( dmginfo )
	return true -- Return false to prevent the damage from being applied
end
--------------------------------------------------------------------------------=#
function ENT:AfterTakeDamage( dmginfo ) end
--------------------------------------------------------------------------------=#
function ENT:OnDeathAnimation( dmginfo ) end
--------------------------------------------------------------------------------=#
function ENT:OnDeath( dmginfo, corpse ) end
--------------------------------------------------------------------------------=#


-- Functions that you can call --


--------------------------------------------------------------------------------=#
/*
	-- self:PlayAnimation( anim, duration, face ) --
	anim - String sequence name, or an activity (https://wiki.facepunch.com/gmod/Enums/ACT).
	duration - Duration that it won't allow the sequence to be interupted.
	face - What direction will it face when doing the sequence?
		"none" - The SNPC will face whatever direction it wants to (lets you change it manually)
		"lock" - The SNPC will constantly face the direction the sequence started with
		"enemy" - The SNPC will face the enemy if it has one
		"enemy_visible" - Same as enemy, but the enemy has to be visible

*/
function ENT:PlayAnimation( anim, duration, face )

	if !face then face = "none" end
	self.SequenceFaceType = face
	self.AnimFacePos = self:GetPos()+self:GetForward()*100

	self.CurrentAnimation = anim

	if isstring(anim) then

		local act = self:GetSequenceActivity(self:LookupSequence(anim))
		if act == -1 then
			self:ResetSequence(self.CurrentAnimation)
		end
	
	else

		self:ResetIdealActivity(anim)
	
	end

	self:StopAndPreventSelectSchedule( duration )

	timer.Create("ZNPC_StopPlayAnimation"..self:EntIndex(), duration, 1, function()
		if !IsValid(self) then return end
		self.CurrentAnimation = nil
		self.SequenceFaceType = nil
		self.AnimFacePos = nil
		self:ResetIdealActivity(ACT_IDLE) -- Helps reseting the animation
	end)

end
--------------------------------------------------------------------------------=#
/*
	-- self:Face( face ) --
	face - A position or an entity to face, or a number representing the yaw.
*/
function ENT:Face( face )

	local function turn( yaw )

		self:SetIdealYawAndUpdate(yaw)

		-- Turning aid
		local myAngs = self:GetAngles()
		local newAng = Angle(myAngs.pitch, yaw, myAngs.roll)
		self:SetAngles(LerpAngle(self.m_fMaxYawSpeed/100, myAngs, newAng))

	end

	if isnumber(face) then
		turn(face)
	elseif IsValid(face) then
		turn( (face:GetPos() - self:GetPos()):Angle().y )
	elseif isvector(face) then
		turn( (face - self:GetPos()):Angle().y )
	end

end
--------------------------------------------------------------------------------=#
/*
	-- self:WithinDistance( entOrPos, min, max ) --
	entOrPos - An entity or position to do the distance check on.
	min - Minimum distance.
	max - Maximum distance, set to false to not use it.
*/
function ENT:WithinDistance( entOrPos, min, max )
	local pos = isvector(entOrPos) && entOrPos or entOrPos:GetPos()
	local distSqr = self:GetPos():DistToSqr(pos)
	if distSqr > min^2 && (max==false or distSqr < max^2) then return true end
	return false
end
--------------------------------------------------------------------------------=#


-- DON'T CHANGE/USE ANYTING BELOW THIS LINE!!


--------------------------------------------------------------------------------=#
function ENT:Initialize()

	self:SetModel( table.Random(self.Models()) )
	self:SetHullType( self.StartHullType )
	self:SetHullSizeNormal()
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )

	self:CapabilitiesAdd(bit.bor(
		CAP_MOVE_GROUND,
		CAP_OPEN_DOORS,
		CAP_ANIMATEDFACE,
		CAP_SKIP_NAV_GROUND_CHECK, -- Saved my life
		CAP_USE_WEAPONS,
		CAP_DUCK,
		CAP_MOVE_SHOOT,
		CAP_TURN_HEAD,
		CAP_MOVE_JUMP,
		CAP_AUTO_DOORS,
		CAP_OPEN_DOORS,
		CAP_USE
	))

	self:SetMaxHealth(self.StartHealth)
	self:SetHealth(self.StartHealth)
	self:SetBloodColor(self.BloodColor)
	self.m_iClass = CLASS_NONE
	self:Fire("setmaxlookdistance", tostring(self.SightDistance))

	self:InitVars()

	self:CustomOnInitialize()

end
--------------------------------------------------------------------------------=#
function ENT:InitVars()

	self.Reloading = false
	self.MeleeAttacking = false
	self.WeaponSchedType = false -- "walk", "stand", "run" or false
	self.FiringWeapon = false

	self.CurrentWepPoseYaw = 0
	self.CurrentWepPosePitch = 0

	self.NextChangeIdleTurn = CurTime()+math.Rand(3, 8)
	self.NextAlertAllies = CurTime()+2
	self.TimeUntilStartShooting = CurTime()

	self.IdleTurnCurrentYaw = self:GetAngles().y

end
--------------------------------------------------------------------------------=#
function ENT:TaskStart_FindEnemy( data )
	print("test")
end
--------------------------------------------------------------------------------=#
function ENT:StartWeaponFiring()
	local mvTbl = self.ShootMovingTypes()
	local Type = math.random(1, 2)==1 && "stand" or (!table.IsEmpty(mvTbl) && table.Random(mvTbl)) or "stand"

	local function shootMoving( _type )
		local sched = ai_schedule.New( "FireWeapon".._type )
		sched:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  50 )
		sched:EngTask( "TASK_".._type.."_PATH",  0 )
		sched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
		self:StartSchedule( sched )
	end

	if Type == "stand" then

		local duration = math.Rand(2, 3)
		local sched = ai_schedule.New( "FireWeapon"..Type )
		sched:EngTask( "TASK_WAIT",  duration )
		self:ResetIdealActivity(ACT_RANGE_ATTACK1)
		self:StartSchedule( sched )

	else
		shootMoving(Type)
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
function ENT:ShouldStartWeaponFiring()
	local enemy = self:GetEnemy()
	local wep = self:GetActiveWeapon()
	return IsValid(enemy) && IsValid(wep) && self:Visible(enemy) && !self:FireLineBlocked() && self:WithinDistance(enemy, 0, self.ShootDistanceMax)
end
--------------------------------------------------------------------------------=#
-- Goes to last seen enemy position, pretty much...
local chaseSched1 = ai_schedule.New( "ChaseLastEnemyPos" )
chaseSched1:EngTask( "TASK_GET_PATH_TO_ENEMY_LKP_LOS",  0 )
chaseSched1:EngTask( "TASK_RUN_PATH",  0 )
chaseSched1:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )

-- Will go straight to enemy even if it hasn't been seen
local chaseSched2 = ai_schedule.New( "ChaseEnemyOmniscient" )
chaseSched2:EngTask( "TASK_GET_PATH_TO_ENEMY",  0 )
chaseSched2:EngTask( "TASK_RUN_PATH",  0 )
chaseSched2:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )

function ENT:SelectSchedule()
	if self.PreventSelectSched then return end

	local enemy = self:GetEnemy()

	if IsValid(enemy) then

		-- Has Enemy
		if self:ShouldStartWeaponFiring() then
			-- Has weapon and can fire it
			self:StartWeaponFiring()
		else
			-- No weapon, or can't fire it
			-- Start chasing
			self:StartSchedule(self.EnemyChase_Omniscient && chaseSched2 or chaseSched1)
		end

	else

		-- No enemy
		-- Patrol or stand
		if self.Patrol == "none" or self.Patrol == "turn" then
			self:SetSchedule(SCHED_IDLE_STAND)
		elseif self.Patrol == "walk" then
			self:SetSchedule(SCHED_PATROL_WALK)
		elseif self.Patrol == "run" then
			self:SetSchedule(SCHED_PATROL_RUN)
		end

	end
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
function ENT:RunAI( strExp )
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
function ENT:HurtBehavior()

	if !self.DoingHurtBehaviour then return end

	-- Turn towards hurt position if there is no enemy
	if !IsValid(self:GetEnemy()) then
		self:Face(self.HurtFacePos)
	end

end
--------------------------------------------------------------------------------=#
function ENT:IdleTurning()
	if self.Patrol != "turn" then return end
	if IsValid(self:GetEnemy()) then return end
	if self.DoingHurtBehaviour then return end
	if self.CurrentAnimation then return end

	if self.NextChangeIdleTurn < CurTime() then

		local yawAdd = math.random(90, 180)
		if math.random(1, 2) == 1 then yawAdd = -yawAdd end

		self.IdleTurnCurrentYaw = self:GetAngles().y + yawAdd
		self.NextChangeIdleTurn = CurTime()+math.Rand(3, 8)
		
	end

	self:Face(self.IdleTurnCurrentYaw)
end
--------------------------------------------------------------------------------=#
function ENT:AlertAllies()
	local enemy = self:GetEnemy()
	if !IsValid(enemy) then self.NextAlertAllies = CurTime()+2 return end
	if self.NextAlertAllies > CurTime() then return end

	local closestAlly
	local minDist

	local tbl = ents.FindInSphere(self:WorldSpaceCenter(), self.AlertAllyDistance)
	if self.AlertAllyDistanceInfinite then tbl = ents.FindByClass("npc_*") end

	for _, ent in ipairs(tbl) do
		if !ent:IsNPC() then continue end -- Must be NPC
		if ent == self then continue end -- Not self

		if self:Disposition(ent) != D_LI && self:Disposition(ent) != D_NU then continue end -- Only allies
		if IsValid(ent:GetEnemy()) then continue end -- Ally already has enemy, don't alert

		local dist = self:GetPos():DistToSqr(ent:GetPos())
		if !minDist or dist < minDist then
			minDist = dist
			closestAlly = ent
		end

	end

	if closestAlly then

		closestAlly:UpdateEnemyMemory(enemy, enemy:GetPos())

		-- Ally becomes omniscient, can chase enemy even if it hasn't been seen, only if the caller can see the enemy
		if self:Visible(enemy) && closestAlly.IsZBaseSNPC then
			closestAlly.EnemyChase_Omniscient = true
			timer.Simple(2, function() if IsValid(closestAlly) then
				closestAlly.EnemyChase_Omniscient = false
			end end)
		end

	end

	self.NextAlertAllies = CurTime() + math.Rand(2.5, 4)
end
--------------------------------------------------------------------------------=#
function ENT:DoMelee()
	if !self.MeleeAttack then return end
	if self.MeleeAttacking then return end

	local enemy = self:GetEnemy()

	if IsValid(enemy) &&
	self:WithinDistance(enemy, 0, 70) &&
	!table.IsEmpty(self.MeleeAttackAnimations()) then

		self.MeleeAttacking = true
		self:PlayAnimation(table.Random((self.MeleeAttackAnimations())), self.MeleeAttackSequenceDuration, "enemy")

		timer.Simple(self.MeleeAttackDamageDelay, function()
			if !IsValid(self) then return end

			if IsValid(enemy) && self:WithinDistance(enemy, 0, 80) then
				local dmg = DamageInfo()
				dmg:SetDamage(self.MeleeAttackDamage)
				dmg:SetDamageType(DMG_SLASH)
				dmg:SetAttacker(self)
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(enemy:WorldSpaceCenter())
				enemy:TakeDamageInfo(dmg)
			end
		end)

		timer.Simple(self.MeleeAttackSequenceDuration, function() if IsValid(self) then
			self.MeleeAttacking = false
		end end)
	end

end
--------------------------------------------------------------------------------=#
function ENT:FireLineBlocked()
	local trStart = self:GetPos() + self:GetUp()*(self:OBBMaxs().z-20)
	local tr = util.TraceLine({
		start = trStart,
		endpos = self:ZBase_ShootTargetPos(),
		mask = MASK_SHOT,
		filter = {self, self:GetEnemy()}
	})

	return tr.Hit
end
--------------------------------------------------------------------------------=#
WEAPON_ZBASE_CALL = false

function ENT:DoFireWeapon()
	local weapon = self:GetActiveWeapon()
	local enemy = self:GetEnemy()
	local shootTargetPos = self:ZBase_ShootTargetPos()

	-- Must have valid weapon, enemy
	if !IsValid(weapon) then return end
	if !IsValid(enemy) then return end
	if self:FireLineBlocked() then return end -- Fire line blocked, don't continue

	-- Reload
	if !self.Reloading && weapon:Clip1() <= 0 then
		local reloadDuration = 1.5
		self.Reloading = true
		self:PlayAnimation(ACT_RELOAD, reloadDuration)
		timer.Simple(reloadDuration, function() if IsValid(self) then
			self.Reloading = false
			weapon:SetClip1(weapon:GetMaxClip1())
		end end)
	end

	local isShooting = self.WeaponSchedType && weapon:Clip1() > 0 && !self.Reloading

	self.FiringWeapon = isShooting

	-- Shooting
	if isShooting && weapon:GetNextPrimaryFire() < CurTime() then
		-- Fire ZBase weapon:
		WEAPON_ZBASE_CALL = true
		weapon:PrimaryAttack()
		WEAPON_ZBASE_CALL = false
	end
end
--------------------------------------------------------------------------------=#
function ENT:WeaponPoseParameters()
	local weapon = self:GetActiveWeapon()
	local shootTargetPos = self:ZBase_ShootTargetPos()

	if !shootTargetPos then return end
	if !IsValid(weapon) then return end
	
	if self.FiringWeapon then
		local poseAng = self:WorldToLocalAngles( (shootTargetPos - self:WorldSpaceCenter() ):GetNormalized():Angle() )
		local poseYaw = poseAng.yaw
		local posePitch = poseAng.pitch

		-- Otherwise it looks weird when it moves
		if self:IsMoving() then
			poseYaw = poseYaw*0.2
		end

		self.CurrentWepPoseYaw = poseYaw
		self.CurrentWepPosePitch = posePitch
	else
		local lerpNum = 0.2
		self.CurrentWepPoseYaw = Lerp(lerpNum, self.CurrentWepPoseYaw, 0)
		self.CurrentWepPosePitch = Lerp(lerpNum, self.CurrentWepPosePitch, 0)
	end

	self:SetPoseParameter("aim_yaw", self.CurrentWepPoseYaw)
	self:SetPoseParameter("aim_pitch", self.CurrentWepPosePitch)
end
--------------------------------------------------------------------------------=#
function ENT:ZBase_ShootTargetPos()
	local enemy = self:GetEnemy()

	if IsValid(enemy) && self:Visible(enemy) then

		local enemyHuman = (enemy:IsPlayer() or (enemy:IsNPC() && enemy:GetHullType()==HULL_HUMAN))
		if enemyHuman then
			-- Head/Upper body on human enemies
			self.LastShootTargetPos = enemy:WorldSpaceCenter()+enemy:GetUp()*20
		else
			-- Center on normal enemies
			self.LastShootTargetPos = enemy:WorldSpaceCenter()
		end

	end

	return self.LastShootTargetPos
end
--------------------------------------------------------------------------------=#
function ENT:ZBase_GetShootPos()

	local wep = self:GetActiveWeapon()

	if IsValid(wep) && wep.IsZBaseSWEP && IsValid(wep.bulletprop1) then
		return wep.bulletprop1:GetPos()
	end

	-- Fallback
	return self:GetShootPos()

end
--------------------------------------------------------------------------------=#

local proficiencyNums = {
	[WEAPON_PROFICIENCY_POOR] = 20,
	[WEAPON_PROFICIENCY_AVERAGE] = 35,
	[WEAPON_PROFICIENCY_GOOD] = 50,
	[WEAPON_PROFICIENCY_VERY_GOOD] = 65,
	[WEAPON_PROFICIENCY_PERFECT] = 80,
}

function ENT:ZBase_AimVector()

	local tPos = self:ZBase_ShootTargetPos()
	local sPos = self:ZBase_GetShootPos()
	local dist = tPos:Distance(sPos)

	local mult = dist/proficiencyNums[self:GetCurrentWeaponProficiency()]
	
	local enemy = self:GetEnemy()
	local selfMove = self:IsMoving()&&1.5 or 1
	local targetMove = IsValid(enemy) && ((enemy:IsNPC() && enemy:IsMoving() && 2) or (enemy:IsPlayer() && enemy:GetVelocity():LengthSqr() > 100 && 2)) or 1

	local inaccuracy = VectorRand()*mult*selfMove*targetMove
	local vec = tPos && ( (tPos - sPos+inaccuracy) ):GetNormalized() or nil

	self.LastZBaseAimVector = vec
	return vec

end
--------------------------------------------------------------------------------=#
local shootStandScheds = {
	["FireWeaponstand"] = true,
}

local shootWalkScheds = {
	["FireWeaponWALK"] = true,
}

local shootRunScheds = {
	["FireWeaponRUN"] = true,
	["AvoidDanger"] = true,
}

local shootScheds = {
	["FireWeaponstand"] = true,
	["FireWeaponWALK"] = true,
	["FireWeaponRUN"] = true,
	["AvoidDanger"] = true,
}

function ENT:DetermineShootingType()

	if !self.CurrentSchedule then self.WeaponSchedType = false return end

	local sched = self.CurrentSchedule.DebugName

	-- Start shooting a while after the shoot schedule started
	if shootScheds[sched] && !self.GoingToStartShooting && !self.WeaponSchedType then
		self.TimeUntilStartShooting = CurTime()+math.Rand(0.2, 0.4)
		self.GoingToStartShooting = true
	end
	if self.TimeUntilStartShooting > CurTime() then return end
	self.GoingToStartShooting = false

	if shootWalkScheds[sched] then
		self.WeaponSchedType = "walk"
	elseif shootRunScheds[sched] then
		self.WeaponSchedType = "run"
	elseif shootStandScheds[sched] then
		self.WeaponSchedType = "stand"
	else
		self.WeaponSchedType = false
	end

	if (self.WeaponSchedType == "walk" or self.WeaponSchedType == "run") && self:GetPathTimeToGoal() < 0.5 then
		self.WeaponSchedType = false
	end

end
--------------------------------------------------------------------------------=#
function ENT:DoShootAnim()

	if !self.WeaponSchedType then return end

	if self.WeaponSchedType == "walk" then
		self:SetMovementActivity(ACT_WALK_AIM)
	elseif self.WeaponSchedType == "run" then
		self:SetMovementActivity(ACT_RUN_AIM)
	elseif self.WeaponSchedType == "stand" then
		self:SetActivity(ACT_RANGE_ATTACK1)
	end

	self:Face(self:ZBase_ShootTargetPos())

end
--------------------------------------------------------------------------------=#
function ENT:ClearNonEngineSched()
	self:ClearGoal() -- Fix gliding around (potantially)
	self.CurrentSchedule = nil
end
--------------------------------------------------------------------------------=#
local chaseScheds = {
	["ChaseEnemyOmniscient"] = true,
	["ChaseLastEnemyPos"] = true,
}

local shootScheds = {
	["FireWeaponWALK"] = true,
	["FireWeaponRUN"] = true,
	["FireWeaponstand"] = true,
}

-- Stops, or changes unwanted schedules
function ENT:StopUnwantedSchedules()
	local sched = self.CurrentSchedule && self.CurrentSchedule.DebugName
	local doingEnemyChase = chaseScheds[sched]
	local doingShoot = shootScheds[sched]
	local enemy = self:GetEnemy()
	
	-- If we can shoot at enemy while in chase sched, stop the chase sched to allow weapon firing sched instead
	if doingEnemyChase && self:ShouldStartWeaponFiring() then
		self:ClearNonEngineSched()
	end

	-- Don't do chase enemy sched or shoot enemy sched with no enemy
	if (doingEnemyChase or doingShoot) && !IsValid(enemy) then
		self:ClearNonEngineSched()
	end

	if IsValid(enemy) && doingEnemyChase && self:IsNavStuck() then
		-- Can't reach the enemy when chasing
		if self:Visible(enemy) then
			-- Take cover if enemy is visible
			self:ClearNonEngineSched()
			self:SetSchedule(SCHED_TAKE_COVER_FROM_ENEMY)
		else
			-- Patrol if enemy is not visible
			self:ClearNonEngineSched()
			self:SetSchedule(SCHED_COMBAT_PATROL)
		end
	end

	-- Don't combat patrol if enemy is seen
	if IsValid(enemy) && self:Visible(enemy) && self:IsCurrentSchedule(SCHED_COMBAT_PATROL) then
		self:ClearSchedule()
	end

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
function ENT:IsNavStuck()
	if !self.NextStuck then
		return false
	end
	return self.NextStuck < CurTime()
end
--------------------------------------------------------------------------------=#
function ENT:DetermineNavStuck()
	if self:IsGoalActive() && self:GetCurWaypointPos()!=Vector() then
		self.NextStuck = CurTime()+0.3
	end
end
--------------------------------------------------------------------------------=#
local dangerAvoidSched = ai_schedule.New( "AvoidDanger" )
dangerAvoidSched:EngTask( "TASK_FIND_COVER_FROM_ORIGIN",  0 )
dangerAvoidSched:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )

function ENT:DetectDanger()

	local hint = sound.GetLoudestSoundHint(SOUND_DANGER, self:GetPos())
	local sched = self.CurrentSchedule && self.CurrentSchedule.DebugName

	-- Grenade
	if hint && IsValid(hint.owner) && hint.owner:GetClass()=="npc_grenade_frag" && sched != "AvoidDanger" then
		self:StartSchedule(dangerAvoidSched)
	end

end
--------------------------------------------------------------------------------=#
function ENT:Think()
	self.FiringWeapon = false -- Is set to true in DoFireWeapon if we are firing
	self:DetermineNavStuck()

	if !GetConVar("ai_disabled"):GetBool() then

		self:IdleTurning()
		self:HurtBehavior()
		self:DoMelee()
		self:AlertAllies()
		self:DetectDanger()
		self:StopUnwantedSchedules()
		
		self:DetermineShootingType()
		self:DoShootAnim()
		self:DoFireWeapon()
		self:WeaponPoseParameters()

	end

	self:SetCurrentWeaponProficiency(self.WeaponProficiency)

	self:DoNPCState()
	self:DoRelationShips()

	self:CustomOnThink()

end
--------------------------------------------------------------------------------=#
function ENT:DecideRelationship( ent )

	-- Give entity player faction if it's a player
	if ent:IsPlayer() && !ent.ZBase_Factions then
		local function faction() return "CLASS_PLAYER_ALLY" end
		ent.ZBase_Factions = faction
	end

	local hasOneFactionInCommon = false
	for _, f in ipairs(self.ZBase_Factions()) do
		if ZBASE_HAS_FACTION( ent, f ) then hasOneFactionInCommon = true break end
	end

	if hasOneFactionInCommon then
		self:AddEntityRelationship(ent, D_LI, 99)
		if ent:IsNPC() then
			ent:AddEntityRelationship(self, D_LI, 99)
		end
	else
		self:AddEntityRelationship(ent, D_HT, 99)
		if ent:IsNPC() then
			ent:AddEntityRelationship(self, D_HT, 99)
		end
	end

end
--------------------------------------------------------------------------------=#
function ENT:DoRelationShips()

	-- Relationships with normal NPCs and other ZBase SNPCs
	for _, npc in ipairs(ZBASE_NPC_TABLE) do

		if npc == self then continue end
		self:DecideRelationship(npc)

	end

	-- Relationship with players
	for _, ply in ipairs(player.GetAll()) do
		self:DecideRelationship(ply)
	end 

	-- VJ Base compatability
	self.VJ_NPC_Class = self.ZBase_Factions()

end
--------------------------------------------------------------------------------=#
function ENT:Ragdoll( dmginfo )

	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self:GetModel())
	rag:SetPos(self:GetPos())
	rag:SetAngles(self:GetAngles())
	rag:SetSkin(self:GetSkin())
	rag:SetColor(self:GetColor())
	rag:Spawn()
	local ragPhys = rag:GetPhysicsObject()

	if !IsValid(ragPhys) then

		-- Model doesn't have ragdoll, use prop instead
		rag:Remove()

		local rag = ents.Create("prop_physics")
		rag:SetModel(self:GetModel())
		rag:SetPos(self:GetPos())
		rag:SetAngles(self:GetAngles())
		rag:SetSkin(self:GetSkin())
		rag:Spawn()
	
	end

	-- Ragdoll force
	if dmginfo:IsBulletDamage() then
		ragPhys:SetVelocity(dmginfo:GetDamageForce()*0.1)
	else
		ragPhys:SetVelocity(dmginfo:GetDamageForce())
	end

	local physcount = rag:GetPhysicsObjectCount()
	for i = 0, physcount - 1 do
		local physObj = rag:GetPhysicsObjectNum(i)
		local pos, ang = self:GetBonePosition(self:TranslatePhysBoneToBone(i))
		physObj:SetPos( pos )
		physObj:SetAngles( ang )
	end

	if self:IsOnFire() then
		rag:Ignite(math.Rand(4,8))
	end

	if dmginfo:IsDamageType(DMG_DISSOLVE) then

		rag:SetName( "ZSNPCRagdoll" .. rag:EntIndex() )

		local dissolve = ents.Create("env_entity_dissolver")
		dissolve:SetKeyValue("target", rag:GetName())
		dissolve:SetKeyValue("dissolvetype", dmginfo:IsDamageType(DMG_SHOCK) && 2 or 0)
		dissolve:Fire("Dissolve", rag:GetName())
		dissolve:Spawn()
		rag:DeleteOnRemove(dissolve)

		rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	end

	-- When keep corpses isn't active:
	if !self:GetShouldServerRagdoll() then

		-- Nocollide
		rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        if !ZBASE_RAGDOLLS then
			ZBASE_RAGDOLLS = {}
		end
        table.insert(ZBASE_RAGDOLLS, rag)

		-- Remove one ragdoll if there are too many
        if #ZBASE_RAGDOLLS > GetConVar("zbase_max_ragdolls"):GetInt() then

			local ragToRemove = ZBASE_RAGDOLLS[1]
			table.remove(ZBASE_RAGDOLLS, 1)
			ragToRemove:Remove()

        end
        
		-- Remove ragdoll after delay if that is active
        if GetConVar("zbase_ragdoll_remove_time"):GetBool() then
            SafeRemoveEntityDelayed(rag, GetConVar("zbase_ragdoll_remove_time"):GetInt())
        end

		-- Remove from table on ragdoll removed
        rag:CallOnRemove("ZBase_RemoveFromRagdollTable", function()
            table.RemoveByValue(ZBASE_RAGDOLLS, rag)
        end)

	end

	hook.Run("CreateEntityRagdoll", self, rag)

	return rag

end
--------------------------------------------------------------------------------=#
function ENT:DeathFinal( dmginfo )
	local rag = self:Ragdoll( dmginfo )
	self:Remove()
	self:OnDeath( dmginfo, rag )
end
--------------------------------------------------------------------------------=#
function ENT:Die( dmginfo )

	self.Dead = true
	hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	self:DeathFinal( dmginfo )

end
--------------------------------------------------------------------------------=#
function ENT:StartHurtBehavior( dmginfo )
	if dmginfo:GetDamage() <= 0 then return end

	self.DoingHurtBehaviour = true

	local atkr = dmginfo:GetAttacker()
	local infl = dmginfo:GetInflictor()
	self.HurtFacePos = (IsValid(infl) && infl:GetPos()) or (IsValid(atkr) && atkr:GetPos()) or dmginfo:GetDamagePosition()

	local HurtBehaviorDuration = math.Rand(1, 3)
	local hurtSched = SCHED_ALERT_STAND

	if !IsValid(self:GetEnemy()) then
		self:SetSchedule(hurtSched)
	end

	timer.Create("ZNPC_EndHurtBehavior"..self:EntIndex(), HurtBehaviorDuration, 1, function()
		if !IsValid(self) then return end
		self.DoingHurtBehaviour = false
		if self:IsCurrentSchedule(hurtSched) then self:ClearSchedule() end
	end)
end
--------------------------------------------------------------------------------=#
function ENT:OnTakeDamage( dmginfo )

	local allowDamageEvent = self:BeforeTakeDamage( dmginfo )
	if !allowDamageEvent then
		return
	end

	self:SetHealth( self:Health() - dmginfo:GetDamage() )
	self:StartHurtBehavior( dmginfo )

	self:AfterTakeDamage( dmginfo )

	if !self.Dead && self:Health() <= 0 then
		self:Die( dmginfo )
	end

end
--------------------------------------------------------------------------------=#