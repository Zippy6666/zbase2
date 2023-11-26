--]]======================================================================================================]]
function ENT:AerialNavigatorPos(sched)
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
    self:AerialResetNav()

    -- debugoverlay.Text(self:GetPos()+Vector(0,0,75), "aerial sched: "..tostring(sched), 3)

    -- Navigator --
    local Navigator = ents.Create("zbase_navigator")
    Navigator:SetPos(self:AerialNavigatorPos(sched))
    Navigator:SetAngles(Angle(0, self:GetAngles().yaw, 0))
    Navigator.Sched = sched
    Navigator:SetOwner(self)
    Navigator:Spawn()
    Navigator.ForceEnemy = self:GetEnemy()

    self:DeleteOnRemove(Navigator)
    self.Navigator = Navigator
end
--]]======================================================================================================]]
function ENT:AerialResetNav()
    self.AerialGoal = nil

    if IsValid(self.Navigator) then
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

        self.Aerial_CurrentDestination = (seeEnemy && ene:GetPos()+Vector(0, 0, self.InternalDistanceFromGround)) or self.AerialGoal

    elseif self.Aerial_NextMoveFromGroundCheck < CurTime() then
        -- Are we too close to the ground?
       
        local distCheckGround = self:Aerial_TooCloseToGround()
        self.ShouldMoveFromGround = isnumber(distCheckGround)
        self.Aerial_NextMoveFromGroundCheck = CurTime()+2

        -- if self.ShouldMoveFromGround then
        --     debugoverlay.Line(myPos, myPos-Vector(0, 0, distCheckGround), 1.5, Color( 255, 50, 0 ))
        -- end
    end


    -- Is near destination, reset navigation
    if self.Aerial_CurrentDestination && self:ZBaseDist(self.Aerial_CurrentDestination, {within=30}) then
        self:AerialResetNav()
    end


    local curMoveDir = self.Aerial_CurrentDestination && (self.Aerial_CurrentDestination - myPos):GetNormalized()
    local speedLimit = self.Fly_MoveSpeed -- self.ShouldMoveFromGround && math.Clamp(self.InternalDistanceFromGround*0.33, 0, self.Fly_MoveSpeed) or self.Fly_MoveSpeed
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
function ENT:AerialMoveAnim()
    if self.Aerial_CurSpeed > 0 then
        local cusMoveAnim = self.Fly_MovementAnims[self:GetNPCState()]
        if cusMoveAnim && self:SelectWeightedSequence(cusMoveAnim) != -1 then
            self:SetActivity(cusMoveAnim)


            if !self.DoingAerialMoveAnim then
                self:SetCycle(0)
            end

            if self:IsSequenceFinished() then
                self:ResetSequence(self:SelectWeightedSequence(cusMoveAnim))
            end


            self.DoingAerialMoveAnim = true
        end
    else
        if self.DoingAerialMoveAnim then
            self:SetActivity(ACT_IDLE)
        end


        self.DoingAerialMoveAnim = false
    end
end
--]]======================================================================================================]]