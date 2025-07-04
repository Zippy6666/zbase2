function ENT:PoseParamThink()
    if !self.LookPoseParams then return end

    -- Looking pose parameter logic

    local center        = self:WorldSpaceCenter()
    local idealLookAng  = self:GetAngles()
    local ene           = self:GetEnemy()

    if IsValid(ene) then
        self:ZBWepSys_SuppressionThink()

        if IsValid(ene) then
            local eneLookPos = ene:GetPos() + Vector(0, 0, ene:OBBMaxs().z*0.6)
            local lookVec = eneLookPos - center
            idealLookAng = lookVec:Angle()
        end
    end

    debugoverlay.Line(center, center + idealLookAng:Forward() * 100, 0.1, Color(255, 0, 0), true)


    idealLookAng = self:WorldToLocalAngles(idealLookAng)
    local idealYaw          = idealLookAng.yaw
    local idealPitch        = idealLookAng.pitch
    self.CurPoseParamYaw    = Lerp(0.5, self.CurPoseParamPitch or idealYaw, idealYaw)
    self.CurPoseParamPitch  = Lerp(0.5, self.CurPoseParamPitch or idealPitch, idealPitch)

    for i = 1, #self.LookPoseParamNames.Yaw do
        self:SetPoseParameter(self.LookPoseParamNames.Yaw[i], self.CurPoseParamYaw)
    end

    for i = 1, #self.LookPoseParamNames.Pitch do
        self:SetPoseParameter(self.LookPoseParamNames.Pitch[i], self.CurPoseParamPitch)
    end
end