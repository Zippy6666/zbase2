--]]======================================================================================================]]
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
--]]======================================================================================================]]
function ENT:AerialSetSchedule(sched)
    local FailSched = sched == SCHED_FAIL or sched == -1


    self:AerialResetNav(FailSched)
 

    -- Navigator --
    if !FailSched then
        local Navigator = ents.Create("zbase_navigator")
        Navigator:SetPos(self:AerialNavigatorPos())
        Navigator:SetAngles(Angle(0, self:GetAngles().yaw, 0))
        Navigator.Sched = sched
        Navigator.ForceEnemy = self:GetEnemy()
        Navigator.ForcedLastPos = self:GetInternalVariable("m_vecLastPosition")
        Navigator:SetOwner(self)
        Navigator:Spawn()
        self:DeleteOnRemove(Navigator)
        self.Navigator = Navigator
    end
end
--]]======================================================================================================]]
function ENT:AerialResetNav( DontRemoveNavigator )
    self.AerialGoal = nil

    if !DontRemoveNavigator && IsValid(self.Navigator) then
        self.Navigator:Remove()
    end
end
--]]======================================================================================================]]
function ENT:Aerial_TooCloseToGround()
    local start = self:GetPos()

    local tr = util.TraceLine({
        start = start,
        endpos = start - Vector(0, 0, self.InternalDistanceFromGround),
        mask = MASK_NPCWORLDSTATIC,
    })

    return tr.Hit && tr.Fraction*self.InternalDistanceFromGround
end
--]]======================================================================================================]]
function ENT:Aerial_CalcVel()
    local myPos = self:GetPos()
    self.Aerial_CurrentDestination = nil


    if self.AerialGoal then
        -- Move to goal aerial goal or enemy
        local ene = self:GetEnemy()
        local seeEnemy = IsValid(ene) && self.EnemyVisible

        self.Aerial_CurrentDestination = (self:IsCurrentCustomSched("CombatChase") && seeEnemy && ene:GetPos()+Vector(0, 0, self.InternalDistanceFromGround))
        or self.AerialGoal

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
--]]======================================================================================================]]
function ENT:AerialThink()
    self:Aerial_CalcVel()

    local ene = self:GetEnemy()

    if self.Aerial_CurrentDestination && !timer.Exists("ZBaseFace"..self:EntIndex()) && !timer.Exists("ZBaseRangeFace"..self:EntIndex()) then
        self:Face( (self.Fly_FaceEnemy && self.EnemyVisible && ene) or self.Aerial_CurrentDestination )
    end

    local vec = !GetConVar("ai_disabled"):GetBool() && self:SNPCFlyVelocity(self.Aerial_LastMoveDir, self.Aerial_CurSpeed) or Vector()
    if self.ShouldMoveFromGround then
        vec = vec+Vector(0,0,35)
    else
        vec = vec+Vector(0,0,30)
    end
    self:SetLocalVelocity(vec)
end
--]]======================================================================================================]]