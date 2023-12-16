local NPC = ZBaseNPCs["npc_zbase"]


--[[
==================================================================================================
                                           ANIMATION
==================================================================================================
--]]


    -- Play an activity or sequence
    -- 'anim' - The sequence (as a string) or activity (https://wiki.facepunch.com/gmod/Enums/ACT) to play
    -- 'faceEnemy' - Set to true to constantly face enemy while the animation is playing
    -- 'extraData' (table)
        -- extraData.isGesture - If true, it will play the animation as a gesture
        -- extraData.face - Position or entity to constantly face, if set to false, it will face the direction it started the animation in
        -- extraData.speedMult - Speed multiplier for the animation
        -- extraData.duration - The animation duration
        -- extraData.faceSpeed - Face turn speed
        -- extraData.noTransitions - If true, it won't do any transition animations
function NPC:PlayAnimation( anim, faceEnemy, extraData )
    extraData = extraData or {}


    local enemy = self:GetEnemy()
    local face = extraData.face
    or (faceEnemy && IsValid(enemy) && enemy)
    or nil

    if extraData.face == false then
        face = false
    end


    self:InternalPlayAnimation(anim, extraData.duration, extraData.speedMult,
    SCHED_NPC_FREEZE, face, extraData.faceSpeed, extraData.loop, nil, extraData.isGesture, nil, extraData.noTransitions)


    -- if extraData.duration && extraData.speedMult then
    --     return extraData.duration/extraData.speedMult
    -- end
    
    -- if !extraData.duration && extraData.speedMult then
    --     return self:SequenceDuration()/extraData.speedMult
    -- end

    -- if extraData.duration && !extraData.speedMult then
    --     return extraData.duration
    -- end
end


    -- Stops the current NPC:PlayAnimation() animation from playing
function NPC:StopCurrentAnimation()
    self:InternalStopAnimation()
end


    -- Check if the NPC is currently busy playing an animation
function NPC:BusyPlayingAnimation()
    return self.DoingPlayAnim
end


--[[
==================================================================================================
                                           MELEE ATTACK
==================================================================================================
--]]


    -- Triggers the base melee attack
function NPC:MeleeAttack()
        -- Animation --
    if !table.IsEmpty(self.MeleeAttackAnimations) then
        self:MeleeAnimation()
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


    -- Triggers the base melee attack damage code
    -- Returns the entities that was hit by the damage
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


    return self:InternalMeleeAttackDamage(dmgData)
end


--[[
==================================================================================================
                                           RANGE ATTACK
==================================================================================================
--]]


    -- Triggers the base range attack
function NPC:RangeAttack()
        -- Animation --
    if !table.IsEmpty(self.RangeAttackAnimations) then
        self:RangeAttackAnimation()
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


        local TimerName = "ZBaseFace_Range"..self:EntIndex()
        timer.Create(TimerName, 0, 0, function()
            if !IsValid(self) or self.TimeUntilStopFace < CurTime() then
                timer.Remove(TimerName)
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


    -- Returns the ideal position to face while range attacking
function NPC:RangeAttack_IdealFacePos()
    local ene = self:GetEnemy()
    local pos = IsValid(ene) && self.EnemyVisible && ene:WorldSpaceCenter() or self:Projectile_TargetPos()
    -- debugoverlay.Cross(pos, 20)
    return pos
end


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


    -- Returns the target position for the NPC's projectile
function NPC:Projectile_TargetPos()
    local ene = self:GetEnemy()

    if IsValid(ene) && self.EnemyVisible then
        self.RangeAttack_LastEnemyPos = ene:WorldSpaceCenter()
    end

    return self.RangeAttack_LastEnemyPos or self:Projectile_SpawnPos()+self:GetForward()*400
end

--[[
==================================================================================================
                                           GRENADE
==================================================================================================
--]]


    -- Throw a grenade
function NPC:ThrowGrenade()
    self:GrenadeAnimation()
    self:EmitSound_Uninterupted(self.OnGrenadeSounds)

    timer.Simple(self.GrenadeReleaseTime, function()
        if !IsValid(self) then return end

        local grenade = ents.Create(self.GrenadeEntityClass)
        grenade.IsZBaseGrenade = true
        grenade.IsZBaseDMGInfl = true
        grenade:SetPos(self:GrenadeSpawnPos())
        grenade:SetOwner(self)
        grenade:Spawn()
        grenade:Activate()
        grenade:Fire("SetTimer", "4")

        local phys = grenade:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(self:GrenadeVelocity()+Vector(0, 0, 100))
            phys:SetAngleVelocity(VectorRand()*self.GrenadeMaxSpin)
        end
    end)
end


--[[
==================================================================================================
                                           OTHER
==================================================================================================
--]]


-- Check if the NPC is facing a position or entity
-- 'maxYawDifference' - If the yaw difference is less than this, we are facing the entity/position (default 22.5 degrees)
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



    -- Creates a gib entity with the given model
    -- Returns the gib so that you can do whatever you want with it after creation
    -- 'model' - The model to use
    -- 'data' (table)
        -- 'data.offset' - Vector position offset relative to itself
        -- 'data.DontBleed' - If true, the gib will not have blood effects
function NPC:CreateGib( model, data )
    return self:InternalCreateGib( model, data )
end


    -- Just like Entity:EmitSound(), except it will prevent certain sounds from playing over it
function NPC:EmitSound_Uninterupted( ... )
    ZBase_DontSpeakOverThisSound = true
    self:EmitSound(...)
    ZBase_DontSpeakOverThisSound = false
end


    -- Check if an entity is allied with the NPC
function NPC:IsAlly( ent )
    if !IsValid(ent) then return false end
    if ent==self then return false end
    if self.ZBaseFaction == "none" then return false end

    return ent.ZBaseFaction == self.ZBaseFaction
end


    -- Get nearby allies within a in a certain radius
    -- Returns an empty table if none was found
function NPC:GetNearbyAllies( radius )
    local allies = {}

    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if v == self then continue end
        if !v:IsNPC() && !v:IsPlayer() then continue end

        if self:IsAlly(v) then
            table.insert(allies, v)
        end
    end

    return allies
end


    -- Get the nearest allied within a in a certain radius
    -- Returns nil if none was found
function NPC:GetNearestAlly( radius )
    local mindist
    local ally

    for _, v in ipairs(self:GetNearbyAllies(radius)) do
        local dist = self:GetPos():DistToSqr(v:GetPos())

        if !mindist or dist < mindist then
            mindist = dist
            ally = v
        end
    end

    return ally
end


    -- Returns the name of the NPC's squad
function NPC:SquadName()
    return self:GetKeyValues().squadname
end


    -- Give zombie NPCs headcrabs
function NPC:Zombie_GiveHeadCrabs()
    self:SetSaveValue("m_fIsHeadless", false)
    self:SetBodygroup(1, 1)

    if self:GetClass()=="npc_poisonzombie" then
        self:SetSaveValue("m_nCrabCount", 3)
        self:SetSaveValue("m_bCrabs", {true, true, true})

        for i = 2, 4 do
            self:SetBodygroup(i, 1)
        end
    end
end