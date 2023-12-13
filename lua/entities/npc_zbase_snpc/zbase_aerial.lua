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
    self:AerialResetNav()
 
    -- Navigator --
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
--]]======================================================================================================]]
function ENT:AerialResetNav()
    self.AerialGoal = nil

    if IsValid(self.Navigator) then
        self.Navigator:Remove()
    end
end
--]]======================================================================================================]]
function ENT:AerialCalcGoal( pos )
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
--]]======================================================================================================]]
function ENT:AerialThink()
    self:Aerial_CalcVel()


    local ene = self:GetEnemy()


    if self.Aerial_CurSpeed > 0 && !timer.Exists("ZBaseFace"..self:EntIndex()) && !timer.Exists("ZBaseFace_Range"..self:EntIndex()) then
        self:Face( (self.Fly_FaceEnemy && self.EnemyVisible && ene) or self.Aerial_CurrentDestination )
    end


    local vec = !GetConVar("ai_disabled"):GetBool() && self:SNPCFlyVelocity(self.Aerial_LastMoveDir, self.Aerial_CurSpeed) or Vector()
    if self.ShouldMoveFromGround then
        vec = vec+Vector(0,0,35)
    else
        vec = vec+Vector(0,0,30)
    end
    self:SetLocalVelocity(vec)


    if self.AerialGoal then
        self.LastAerialGoalPos = self.AerialGoal
    end


    if self.LastAerialGoalPos then
        debugoverlay.Sphere(self.LastAerialGoalPos, 25, 0.13, Color( 0, 0, 255 ))
    end
end
--]]======================================================================================================]]