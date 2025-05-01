function ENT:PoseParamThink()
    if !self.LookPoseParams then return end

    -- Looking pose parameter logic
    
    local center        = self:WorldSpaceCenter()
    local idealLookAng  = self:GetLocalAngles()
    local ene           = self:GetEnemy()

    if IsValid(ene) then
        self:ZBWepSys_SuppressionThink()
        
        if IsValid(ene) then
            local eneLookPos = ene:GetPos() + Vector(0, 0, ene:OBBMaxs().z*0.6)
            local lookVec = eneLookPos - center
            idealLookAng = self:WorldToLocalAngles(lookVec:Angle())
        end
    end

    local idealYaw          = idealLookAng.yaw
    local idealPitch        = idealLookAng.pitch
    self.CurPoseParamYaw    = Lerp(0.2, self.CurPoseParamPitch or idealYaw, idealYaw)
    self.CurPoseParamPitch  = Lerp(0.2, self.CurPoseParamPitch or idealPitch, idealPitch)

    for _, v in ipairs(self.LookPoseParamNames.Yaw) do
        self:SetPoseParameter(v, self.CurPoseParamYaw)
    end

    for _, v in ipairs(self.LookPoseParamNames.Pitch) do
        self:SetPoseParameter(v, self.CurPoseParamPitch)
    end
end