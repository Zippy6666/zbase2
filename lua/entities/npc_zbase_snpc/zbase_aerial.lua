local AIDisabled = GetConVar("ai_disabled")

function ENT:GetAerialOptimizedSched()
	-- Return better schedule and goal for aerial NPCs

	if IsValid(self.Navigator) && IsValid(self:GetEnemy()) then
		if self.Navigator:IsCurrentZSched("CombatChase") && self.EnemyVisible then
            return "AerialChase_NoNav", self:GetEnemy():GetPos()
		end

		if self.Navigator:IsCurrentZSched("BackAwayFromEnemy") && self.EnemyVisible then
			return "AerialBackAway_NoNav", self:GetPos()+( self:GetPos() - self:GetEnemy():GetPos() ):GetNormalized()*300
		end
	end
end

function ENT:AerialSetSchedule(sched)
    -- Called when NewSched is called
    -- Set up a navigator that can use ground nodes to navigate for us (assuming we should move in this schedule)

    self:AerialResetNav()

    local lastpos = self:GetInternalVariable("m_vecLastPosition")

    local Navigator = ents.Create("zbase_navigator")
    Navigator:SetPos(self:AerialNavigatorPos())
    Navigator:SetAngles(Angle(0, self:GetAngles().yaw, 0))
    Navigator.Sched = sched
    Navigator.ForceEnemy = self:GetEnemy()
    Navigator.ForcedLastPos = lastpos
    Navigator:SetOwner(self)
    Navigator:Spawn()
    self:DeleteOnRemove(Navigator)
    self.Navigator = Navigator

    -- SafeRemoveEntity(self.ScannerNavigator)
    -- self.ScannerNavigator = ents.Create("npc_cscanner")
    -- self.ScannerNavigator:AddFlags(FL_NOTARGET)
    -- self.ScannerNavigator:AddFlags(EFL_DONTBLOCKLOS)
	-- self.ScannerNavigator:SetMaterial("models/wireframe")
    -- self.ScannerNavigator:SetPos(self:GetPos())
    -- self.ScannerNavigator:SetMaxLookDistance(1)
    -- self.ScannerNavigator:Spawn()
    -- self.ScannerNavigator:SetLastPosition(lastpos)
    -- self.ScannerNavigator:SetSchedule(SCHED_FORCED_GO_RUN)
end

-- The navigators start position
function ENT:AerialNavigatorPos()
    local start = self:GetPos() + self:GetForward()*self:OBBMaxs().x*2.5

    local trFront = util.TraceLine({
        start = self:GetPos(),
        endpos = start,
        mask = MASK_NPCWORLDSTATIC,
    })
    if trFront.Hit then
        start = self:GetPos() - self:GetForward()*self:OBBMaxs().x*2.5
    end

    local tr = util.TraceLine({
        start = start,
        endpos = start - Vector(0, 0, 10000),
        mask = MASK_NPCWORLDSTATIC,
    })

    return tr.HitPos+tr.HitNormal*5
end

-- For deciding a position the aerial SNPC should patrol to
local function RandomXYVector()
    local angle = math.random() * math.pi * 2

    local length = math.Rand(300, 720)

    local x = math.cos(angle) * length
    local y = math.sin(angle) * length

    return Vector(x, y, 0)
end

function ENT:SetPursueAerialGoalSched()
    self.CurrentSchedule = ZSched.FLY_TO_GOAL
    self.CurrentTaskID = 1
    self:SetTask( ZSched.FLY_TO_GOAL:GetTask( 1 ) )
end

-- A real translate schedule function for aerial NPCs
function ENT:AerialTranslateSched( sched )
    if self.bControllerBlock then return end -- Don't do anything if being controlled

    local lastpos = self:GetInternalVariable("m_vecLastPosition")
    local npcstate = self:GetNPCState()
    local hasAerialGoal = false

    if sched == SCHED_FORCED_GO or sched == SCHED_FORCED_GO_RUN then

        -- Forced go: calculate goal to last position
        self:AerialCalcGoal(lastpos)
        hasAerialGoal = true

    elseif sched == SCHED_TARGET_CHASE then

        -- Target chase: calculate goal to targets position
        local target = self:GetTarget()
        local targetpos = IsValid(target) && target:GetPos()

        self:AerialCalcGoal(targetpos)
        hasAerialGoal = true

    elseif sched == SCHED_PATROL_WALK or sched == SCHED_PATROL_RUN then

        local patrolPos = self:GetPos() + RandomXYVector()

        self:AerialCalcGoal(patrolPos)
        hasAerialGoal = true
        
    end

    if hasAerialGoal then
        self:CONV_CallNextTick("SetPursueAerialGoalSched")
        return SCHED_IDLE_STAND
    end
end

function ENT:AerialResetNav()
    self.AerialGoal = nil
    SafeRemoveEntity(self.Navigator)
end

function ENT:AerialCalcGoal( pos )
    if !self.ZBase_HasLUAFlyCapability then return end
    
    local tr = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, self.InternalDistanceFromGround),
        mask = MASK_NPCWORLDSTATIC,
    })
    if tr.Hit then
        pos = Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z+self.InternalDistanceFromGround)
    end

    self.AerialGoal = pos
end

function ENT:Aerial_TooCloseToGround()
    local start = self:GetPos()
    local tr = util.TraceLine({
        start = start,
        endpos = start - Vector(0, 0, self.InternalDistanceFromGround),
        mask = MASK_NPCWORLDSTATIC,
    })

    return tr.Hit && tr.Fraction*self.InternalDistanceFromGround
end

function ENT:Aerial_CalcVel()
    local myPos = self:GetPos()

    self.Aerial_CurrentDestination = nil

    if self.AerialGoal then
        self.Aerial_CurrentDestination = self.AerialGoal

    elseif self.Aerial_NextMoveFromGroundCheck < CurTime() then
        -- Are we too close to the ground?
       
        local distCheckGround = self:Aerial_TooCloseToGround()
        self.ShouldMoveFromGround = isnumber(distCheckGround)
        self.Aerial_NextMoveFromGroundCheck = CurTime()+2
    end

    -- Is near destination, reset navigation
    if self.Aerial_CurrentDestination && self:ZBaseDist(self.Aerial_CurrentDestination, {within=30}) then
        self:AerialResetNav()
    end

    local curMoveDir = self.Aerial_CurrentDestination && (self.Aerial_CurrentDestination - myPos):GetNormalized()

    local speedLimit = self:IsFacing(self.Aerial_CurrentDestination) && self.Fly_MoveSpeed or self.Fly_MoveSpeed*0.35
    if self:GetNPCState()==NPC_STATE_IDLE then speedLimit=speedLimit*0.5 end

    if curMoveDir then
        -- Accelerate, store last direction
        self.Aerial_LastMoveDir = LerpVector(0.25, self.Aerial_LastMoveDir, curMoveDir)
        self.Aerial_CurSpeed = math.Clamp(self.Aerial_CurSpeed+self.Fly_Accelerate, 0, speedLimit)

        debugoverlay.Line(myPos, myPos+self.Aerial_LastMoveDir*75, 0.1, Color( 0, 0, 255 ))
    elseif self.Aerial_CurSpeed > 0 then
        -- Decelerate
        self.Aerial_CurSpeed = math.Clamp(self.Aerial_CurSpeed-self.Fly_Decelerate, 0, speedLimit)
    end
end


local upVec, stationaryVec = Vector(0,0,35), Vector(0,0,30)
function ENT:AerialThink()
    -- Calculate velocity
    self:Aerial_CalcVel()

    local ene = self:GetEnemy()

    -- Face where we should go
    if self.Aerial_CurSpeed > 0 && !self.ZBase_CurrentFace_Yaw then
        self:Face( (self.Fly_FaceEnemy && self.EnemyVisible && ene) or self.Aerial_CurrentDestination )
    end

    local vec = !AIDisabled:GetBool()
    && self:SNPCFlyVelocity(self.Aerial_LastMoveDir, self.Aerial_CurSpeed) or vector_origin

    if self.ShouldMoveFromGround then
        vec = vec+upVec
    else
        vec = vec+stationaryVec
    end
    self:SetLocalVelocity(vec)

    -- DEBUG
    if self.AerialGoal then
        self.LastAerialGoalPos = self.AerialGoal
    end
    if self.LastAerialGoalPos then
        debugoverlay.Sphere(self.LastAerialGoalPos, 25, 0.13, Color( 0, 0, 255 ))
    end

    -- Flying SNPCs should get closer to the ground during melee --
	local ene = self:GetEnemy()
    if !AIDisabled:GetBool() && self.BaseMeleeAttack
    && self.Fly_DistanceFromGround_IgnoreWhenMelee && IsValid(ene)
    && self:ZBaseDist(ene, {within=self.MeleeAttackDistance*1.75}) then
        self.InternalDistanceFromGround = ene:WorldSpaceCenter():Distance(ene:GetPos())
    else
        self.InternalDistanceFromGround = self.Fly_DistanceFromGround
    end
end