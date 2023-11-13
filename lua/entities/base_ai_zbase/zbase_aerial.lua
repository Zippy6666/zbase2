---------------------------------------------------------------------------------------------------------------------=#
function ENT:AerialNavigatorPos()
    -- Todo:
    -- If position is in wall, try putting navigator behind itself instead
    local start = self:GetPos() + self:GetForward()*self:OBBMaxs().x*2.5
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
    Navigator:SetPos(self:AerialNavigatorPos())
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
function ENT:AerialThink()
    if self.AerialGoal then
        local myPos = self:GetPos()
        local ene = self:GetEnemy()


        -- Face
        self:Face( (self.Fly_FaceEnemy && IsValid(ene) && ene) or self.AerialGoal )


        -- Move towards aerial goal
        local moveDir = (self.AerialGoal - myPos):GetNormalized()
        self:SetLocalVelocity(moveDir*self.Fly_MoveSpeed)

    else
        -- Hover (sorta)
        self:SetLocalVelocity(Vector())
    end


    -- Is near aerial goal, reset navigation
    if self:ZBaseDist(self.AerialGoal, {within=30}) then
        self:AerialResetNav()
    end
end
---------------------------------------------------------------------------------------------------------------------=#