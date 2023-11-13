---------------------------------------------------------------------------------------------------------------------=#
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
---------------------------------------------------------------------------------------------------------------------=#
function ENT:AerialSetSchedule(sched)
    self:AerialResetNav()

    debugoverlay.Text(self:GetPos()+Vector(0,0,75), "aerial sched: "..tostring(sched), 3)

    -- Navigator --
    local Navigator = ents.Create("zbase_navigator")
    Navigator:SetPos(self:AerialNavigatorPos(sched))
    Navigator:SetAngles(self:GetAngles())
    Navigator.Sched = sched
    Navigator:SetOwner(self)
    Navigator:Spawn()
    Navigator.ForceEnemy = self:GetEnemy()

    self:DeleteOnRemove(Navigator)
    self.Navigator = Navigator
end
---------------------------------------------------------------------------------------------------------------------=#
function ENT:AerialResetNav()
    self.AerialGoal = nil

    if IsValid(self.Navigator) then
        self.Navigator:Remove()
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function ENT:Aerial_TooCloseToGround()
    local start = self:GetPos()

    local tr = util.TraceLine({
        start = start,
        endpos = start - Vector(0, 0, self.Fly_DistanceFromGround),
        mask = MASK_NPCWORLDSTATIC,
    })

    return tr.Hit
end
---------------------------------------------------------------------------------------------------------------------=#
function ENT:Aerial_CalcVel()
    local myPos = self:GetPos()
    self.Aerial_CurrentDestination = nil


    if self.AerialGoal then
        -- Move to goal aerial goal or enemy
        local ene = self:GetEnemy()
        local seeEnemy = IsValid(ene) && self.EnemyVisible

        self.Aerial_CurrentDestination = (seeEnemy && ene:GetPos()+Vector(0, 0, self.Fly_DistanceFromGround)) or self.AerialGoal

    elseif self.Aerial_NextMoveFromGroundCheck < CurTime() then
        -- Are we too close to the ground?
       
        self.ShouldMoveFromGround = self:Aerial_TooCloseToGround()
        self.Aerial_NextMoveFromGroundCheck = CurTime()+2

        if self.ShouldMoveFromGround then
            debugoverlay.Text(myPos, "too close to ground")
        end
    elseif self.ShouldMoveFromGround then

        -- Move away from the ground
        self.Aerial_CurrentDestination = myPos + self:GetUp() * 100
    end


    -- Is near destination, reset navigation
    if self.Aerial_CurrentDestination && self:ZBaseDist(self.Aerial_CurrentDestination, {within=30}) then
        self:AerialResetNav()
    end


    local curMoveDir = self.Aerial_CurrentDestination && (self.Aerial_CurrentDestination - myPos):GetNormalized()
    local speedLimit = self.ShouldMoveFromGround && math.Clamp(self.Fly_DistanceFromGround*0.33, 0, self.Fly_MoveSpeed) or self.Fly_MoveSpeed
    if curMoveDir then
        -- Accelerate, store last direction
        self.Aerial_LastMoveDir = LerpVector(0.2, self.Aerial_LastMoveDir, curMoveDir)
        self.Aerial_CurSpeed = math.Clamp(self.Aerial_CurSpeed+self.Fly_Accelerate, 0, speedLimit)

        debugoverlay.Line(myPos, myPos+self.Aerial_LastMoveDir*75, 0.1, Color( 0, 0, 255 ))
    elseif self.Aerial_CurSpeed > 0 then
        -- Decelerate
        self.Aerial_CurSpeed = math.Clamp(self.Aerial_CurSpeed-self.Fly_Decelerate, 0, speedLimit)
    end
end
---------------------------------------------------------------------------------------------------------------------=#