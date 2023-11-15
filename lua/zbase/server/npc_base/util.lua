local NPC = ZBaseNPCs["npc_zbase"]


        -- These are functions you can call --


---------------------------------------------------------------------------------------------------------------------=#


    -- Check if an entity is allied with the NPC
function NPC:IsAlly( ent )
    if self.ZBaseFaction == "none" then return false end
    return ent.ZBaseFaction == self.ZBaseFaction
end
---------------------------------------------------------------------------------------------------------------------=#


    -- Get the nearest allied within a in a certain radius
    -- Returns nil if none was found
function NPC:GetNearestAlly( radius )
    local mindist
    local ally

    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if v == self then continue end
        if !v:IsNPC() then continue end

        if self:IsAlly(v) then
            local dist = self:GetPos():DistToSqr(v:GetPos())

            if !mindist or dist < mindist then
                mindist = dist
                ally = v
            end
        end
    end

    return ally
end
---------------------------------------------------------------------------------------------------------------------=#


    -- Returns the name of the NPC's squad
function NPC:SquadName()
    return self:GetKeyValues().squadname
end
---------------------------------------------------------------------------------------------------------------------=#


    -- Check if an entity or position is within a certain distance
    -- If tbl.within is given, return true if the entity is within x units from itself
    -- If tbl.away is given, return true if the entity is x units away from itself
    -- Example: self:ZBaseDist( self:GetEnemy(), {within=400, away=200} ) --> Returns true if enemy is 200 units away, but still within 400 units
function NPC:ZBaseDist( ent_or_pos, tbl )
    local dSqr

    if isvector(ent_or_pos) then
        dSqr = self:GetPos():DistToSqr(ent_or_pos)
    elseif IsValid(ent_or_pos) then
        dSqr = self:GetPos():DistToSqr(ent_or_pos:GetPos())
    end

    if !dSqr then return false end
    if tbl.away && dSqr < tbl.away^2 then return false end
    if tbl.within && dSqr > tbl.within^2 then return false end

    return true
end
---------------------------------------------------------------------------------------------------------------------=#


    -- Check if the NPC is facing a position or entity
function NPC:IsFacing( ent_or_pos, maxYawDifference )
    if !ent_or_pos then return end
    if ent_or_pos == NULL then return end

    local ang
    if isvector(ent_or_pos) then
        ang = (ent_or_pos - self:GetPos()):Angle()
    elseif IsValid(ent_or_pos) then
        ang = (ent_or_pos:GetPos() - self:GetPos()):Angle()
    end

    local yawDif = math.abs(self:WorldToLocalAngles(ang).Yaw)
    return yawDif < (maxYawDifference or 22.5)
end
--------------------------------------------------------------------------------=#


	-- Make the NPC face certain directions
	-- 'face' - A position or an entity to face, or a number representing the yaw.
    -- 'duration' - Face duration, if not set, you can run the function in think for example
    -- 'speed' - Turn speed, if not set, it will be the default turn speed
function NPC:Face( face, duration, speed )

	local function turn( yaw )
        if GetConVar("ai_disabled"):GetBool() then return end
        if self:IsMoving() then return end


        local sched = self:GetCurrentSchedule()
        if sched > 88 then return end
        if ZBaseForbiddenFaceScheds[sched] then return end
        

        local turnSpeed = speed
        or (self.IsZBase_SNPC && self.m_fMaxYawSpeed)
        or 10
        

		self:SetIdealYawAndUpdate(yaw, turnSpeed)
	end


    local faceFunc
    local faceIsEnt = false
	if isnumber(face) then
		faceFunc = function() turn(face) end
	elseif IsValid(face) then
		faceFunc = function() turn( (face:GetPos() - self:GetPos()):Angle().y ) end
        faceIsEnt = true
	elseif isvector(face) then
		faceFunc = function() turn( (face - self:GetPos()):Angle().y ) end
	end
    if !faceFunc then return end


    if duration then

        self.TimeUntilStopFace = CurTime()+duration
        timer.Create("ZBaseFace"..self:EntIndex(), 0, 0, function()
            if !IsValid(self) or (faceIsEnt && !IsValid(face)) or self.TimeUntilStopFace < CurTime() then
                timer.Remove("ZBaseFace"..self:EntIndex())
                return
            end
            faceFunc()
        end)

    else

        if timer.Exists("ZBaseFace"..self:EntIndex()) then
            timer.Remove("ZBaseFace"..self:EntIndex())
        end
        faceFunc()

    end
end
--------------------------------------------------------------------------------=#


    -- Play an activity or sequence
    -- 'anim' - The sequence or activity to play, accepts sequences as strings
    -- 'faceEnemy' - Set to true to constantly face enemy while the animation is playing
    -- 'extraData' (table)
        -- extraData.face - Position or entity to constantly face
        -- extraData.speedMult - Speed multiplier for the animation
        -- extraData.duration - The animation duration
        -- extraData.faceSpeed - Face turn speed
function NPC:PlayAnimation( anim, faceEnemy, extraData )
    extraData = extraData or {}

    local enemy = self:GetEnemy()
    local face = extraData.face or (faceEnemy && IsValid(enemy) && enemy) or nil

    self:InternalPlayAnimation(anim, extraData.duration, extraData.speedMult, SCHED_NPC_FREEZE, face, extraData.faceSpeed, extraData.loop )
end
--------------------------------------------------------------------------------=#


    -- Stops the current NPC:PlayAnimation() animation from playing
function NPC:StopCurrentAnimation()
    local goalSeq = self:SelectWeightedSequence(ACT_IDLE)
    local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )

    if transition != -1
    && transition != goalSeq then
        self:PlayAnimation(self:GetSequenceName(transition))
        return
    end
    
    self.DoingPlayAnim = false
    self.ZBaseSNPCSequence = nil
    self:SetActivity(ACT_IDLE)

    self:ClearSchedule()

    if self.ZBaseSNPCSequence then
        self:SetNPCState(self.PreAnimNPCState)
    end

    timer.Remove("ZBasePlayAnim"..self:EntIndex())
end
--------------------------------------------------------------------------------=#


    -- Just like entity:EmitSound(), except it will prevent certain sounds from playing over it
function NPC:EmitSound_Uninterupted( ... )
    ZBase_DontSpeakOverThisSound = true
    self:EmitSound(...)
    ZBase_DontSpeakOverThisSound = false
end
--------------------------------------------------------------------------------=#


    -- Triggers the base melee attack
function NPC:MeleeAttack()
        -- Animation --
    if !table.IsEmpty(self.MeleeAttackAnimations) then
        self:InternalPlayAnimation(
            table.Random(self.MeleeAttackAnimations),
            nil,
            self.MeleeAttackAnimationSpeed,
            SCHED_NPC_FREEZE,
            self.MeleeAttackFaceEnemy && self:GetEnemy(),
            self.MeleeAttackTurnSpeed
        )
    end
    -----------------------------------------------------------------=#


        -- Damage --
    local dmgData = {
        dist=self.MeleeDamage_Distance,
        ang=self.MeleeDamage_Angle,
        type=self.MeleeDamage_Type,
        amt=self.MeleeDamage,
        hitSound=self.MeleeDamage_Sound,
        affectProps=self.MeleeDamage_AffectProps,
        name = self.MeleeAttackName,
        hitSoundProps = self.MeleeDamage_Sound_Prop,
    }

    self.CurrentMeleeDMGData = dmgData

    if self.MeleeDamage_Delay then
        timer.Simple(self.MeleeDamage_Delay, function()
            if !IsValid(self) then return end
            if self:GetNPCState()==NPC_STATE_DEAD then return end

            self:InternalMeleeAttackDamage(dmgData)
        end)
    end
    -----------------------------------------------------------------=#


    if math.random(1, self.OnMeleeSound_Chance) == 1 then
        self:EmitSound_Uninterupted(self.OnMeleeSounds)
    end


    self:OnMelee()
end
--------------------------------------------------------------------------------=#


    -- Triggers the base melee attack damage code
function NPC:MeleeAttackDamage()
    if self:GetNPCState() == NPC_STATE_DEAD then return end


    local dmgData = self.CurrentMeleeDMGData
    if !dmgData then
        dmgData = {
            dist=self.MeleeDamage_Distance,
            ang=self.MeleeDamage_Angle,
            type=self.MeleeDamage_Type,
            amt=self.MeleeDamage,
            hitSound=self.MeleeDamage_Sound,
            affectProps=self.MeleeDamage_AffectProps,
            name = self.MeleeAttackName,
            hitSoundProps = self.MeleeDamage_Sound_Prop,
        }
    end


    self:InternalMeleeAttackDamage(dmgData)
end
--------------------------------------------------------------------------------=#


    -- Triggers the base range attack
function NPC:RangeAttack()
        -- Animation --
    if !table.IsEmpty(self.RangeAttackAnimations) then
        self:InternalPlayAnimation(
            table.Random(self.RangeAttackAnimations),
            nil,
            self.RangeAttackAnimationSpeed,
            SCHED_NPC_FREEZE,
            nil
        )
    end
    -----------------------------------------------------------------=#


        -- Projectile --
    if self.RangeProjectile_Delay then
        timer.Simple(self.RangeProjectile_Delay, function()
            if !IsValid(self) then return end
            if self:GetNPCState()==NPC_STATE_DEAD then return end

            self:RangeAttackProjectile()
        end)
    end
    -----------------------------------------------------------------=#


    -- Special face code
    if !table.IsEmpty(self.RangeAttackAnimations) then
        self.TimeUntilStopFace = CurTime()+self:SequenceDuration() + 0.25

        timer.Create("ZBaseRangeFace"..self:EntIndex(), 0, 0, function()
            if !IsValid(self) or self.TimeUntilStopFace < CurTime() then
                timer.Remove("ZBaseRangeFace"..self:EntIndex())
                return
            end

            if GetConVar("ai_disabled"):GetBool() then return end

            self:Face(self:RangeAttack_IdealFacePos(), nil, self.RangeAttackTurnSpeed)
        end)
    end
    -----------------------------------------------------------------=#


    if math.random(1, self.OnRangeSound_Chance) == 1 then
        self:EmitSound_Uninterupted(self.OnRangeSounds)
    end


    self:OnRangeAttack()
end
--------------------------------------------------------------------------------=#


    -- Returns the ideal position to face while range attacking
function NPC:RangeAttack_IdealFacePos()
    local ene = self:GetEnemy()
    local pos = IsValid(ene) && self.EnemyVisible && ene:WorldSpaceCenter() or self:Projectile_TargetPos()
    -- debugoverlay.Cross(pos, 20)
    return pos
end
--------------------------------------------------------------------------------=#


    -- Returns the spawn position for the NPC's projectile
function NPC:Projectile_SpawnPos()
    local att = self.RangeProjectile_Attachment
    local pos

    if isstring(att) then
        pos = self:GetAttachment(self:LookupAttachment(att)).Pos
    elseif isnumber(att) then
        pos = self:GetAttachment(att).Pos
    else
        pos = self:WorldSpaceCenter()
    end

    if self.RangeProjectile_Offset then
        pos = pos + self:GetForward()*(self.RangeProjectile_Offset.forward or 0)
        + self:GetUp()*(self.RangeProjectile_Offset.up or 0)
        + self:GetRight()*(self.RangeProjectile_Offset.right or 0)
    end

    return pos
end
--------------------------------------------------------------------------------=#


    -- Returns the target position for the NPC's projectile
function NPC:Projectile_TargetPos()
    local ene = self:GetEnemy()

    if IsValid(ene) && self.EnemyVisible then
        self.RangeAttack_LastEnemyPos = ene:WorldSpaceCenter()
    end

    return self.RangeAttack_LastEnemyPos or self:Projectile_SpawnPos()+self:GetForward()*400
end
--------------------------------------------------------------------------------=#