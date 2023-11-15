local NPC = ZBaseNPCs["npc_zbase"]


NPC.IsZBaseNPC = true


local ReloadActs = {
    [ACT_RELOAD] = true,
    [ACT_RELOAD_SHOTGUN] = true,
    [ACT_RELOAD_SHOTGUN_LOW] = true,
    [ACT_RELOAD_SMG1] = true,
    [ACT_RELOAD_SMG1_LOW] = true,
    [ACT_RELOAD_PISTOL] = true,
    [ACT_RELOAD_PISTOL_LOW] = true,
}

local hl2wepShootDistMult = {
    ["weapon_shotgun"] = 0.5,
    ["weapon_crossbow"] = 2,
}


---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseInit()
    -- Vars
    self.NextPainSound = CurTime()
    self.NextAlertSound = CurTime()
    self.NPCNextSlowThink = CurTime()
    self.NPCNextDangerSound = CurTime()
    self.EnemyVisible = false
    self.InternalDistanceFromGround = self.Fly_DistanceFromGround


     -- Starts with no field of view
    self:SetSaveValue("m_flFieldOfView", 1)


    -- Some calls based on attributes
    self:SetCurrentWeaponProficiency(self.WeaponProficiency)
    self:SetBloodColor(self.BloodColor)

    if self.HullType && !self.IsZBase_SNPC then
        self:SetHullType(self.HullType)
    end


    -- Extra capabilities given
    for _, v in ipairs(self.ExtraCapabilities) do
        self:CapabilitiesAdd(v)
    end


    -- Capabilities
    self:CapabilitiesAdd(bit.bor(
        CAP_SQUAD,
        CAP_TURN_HEAD,
        CAP_ANIMATEDFACE,
        CAP_SKIP_NAV_GROUND_CHECK,
        CAP_FRIENDLY_DMG_IMMUNE
    ))
    if self.CanJump && self:SelectWeightedSequence(ACT_JUMP) != -1 then
        self:CapabilitiesAdd(CAP_MOVE_JUMP)
    end


    -- Set specified internal variables
    self:ZBaseSetSaveValues()


    -- Makes behaviour system function
    ZBaseBehaviourInit( self )


    -- Bounds
    self:ZBaseSetupBounds()


    -- Should it have a death ragdoll?
    self:SetNWBool("ZBaseNoRag", !self.HasDeathRagdoll)


    -- Phys damage scale
    self:Fire("physdamagescale", self.PhysDamageScale)

    if !self.CanDissolve then
        self:AddEFlags(EFL_NO_DISSOLVE)
    end


    -- Custom init
    self:CustomInitialize()
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSetupBounds()
    if !self.CollisionBounds then return end

    self:SetCollisionBounds(self.CollisionBounds.min, self.CollisionBounds.max)
    self:SetSurroundingBounds(self.CollisionBounds.min*1.25, self.CollisionBounds.max*1.25)

    if self.CollisionBounds.min.z < 0 then
        local tr = util.TraceLine({
            start = self:GetPos(),
            endpos = self:GetPos() + Vector(0, 0, -self.CollisionBounds.min.z),
            mask = MASK_NPCWORLDSTATIC,
        })

        self:SetPos(tr.HitPos + tr.HitNormal*5)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:GetCurrentWeaponShootDist()
    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then return end

    local mult = hl2wepShootDistMult[wep:GetClass()] or wep.NPCShootDistanceMult or 1

    return self.MaxShootDistance*mult
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ShootTargetTooFarAway()
    local ene = self:GetEnemy()

    return IsValid(ene)
    && IsValid(self:GetActiveWeapon())
    && self:ZBaseDist(ene, {away=self:GetCurrentWeaponShootDist()})
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:PreventFarShoot()
    self:SetSaveValue("m_flFieldOfView", 1)
    self:SetMaxLookDistance(self:GetCurrentWeaponShootDist())
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnKilledEnt( ent )
    if ent == self:GetEnemy() then
        self:EmitSound_Uninterupted(self.KilledEnemySounds)
    end
    
    self:CustomOnKilledEnt( ent )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnHurt( dmg )
    if self.NextPainSound < CurTime() then
        self:EmitSound(self.PainSounds)
        self.NextPainSound = CurTime()+ZBaseRndTblRange( self.PainSoundCooldown )
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSetSaveValues()
    for k, v in pairs(self:GetTable()) do
        if string.StartWith(k, "m_") then
            self:SetSaveValue(k, v)
        end
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:NewActivityDetected( act )
    -- Reload ZBase weapon sound:
    local wep = self:GetActiveWeapon()
    if ReloadActs[act] && IsValid(wep) && wep.IsZBaseWeapon && wep.NPCReloadSound != "" then
        wep:EmitSound(wep.NPCReloadSound)
    end

    self:CustomNewActivityDetected( act )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseAlertSound()
    if self.NextAlertSound > CurTime() then return end
    if self:SquadMemberIsSpeaking({"AlertSounds"}) then return end

    -- ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown), self, "DoIdleEnemySound")
    self:EmitSound_Uninterupted(self.AlertSounds)

    self.NextAlertSound = CurTime() + ZBaseRndTblRange(self.AlertSoundCooldown)
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnEmitSound( data )
    local sndVarName
    for _, v in ipairs(self.SoundVarNames) do
        if self[v] == data.OriginalSoundName then
            sndVarName = v
            break
        end
    end

    
    local val = self:CustomOnEmitSound( data, sndVarName )
    local squad = self:GetKeyValues().squadname


    -- Make sure squad doesn't speak over each other
    if squad != "" && ZBase_DontSpeakOverThisSound then
        ZBaseSpeakingSquads[squad] = sndVarName or true

        timer.Create("ZBaseUnmute_"..squad, SoundDuration(data.SoundName), 1, function()
            ZBaseSpeakingSquads[squad] = nil
        end)
    end


    return val
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SquadMemberIsSpeaking( soundList )
    local squadSpeakSndVar = ZBaseSpeakingSquads[self:GetKeyValues().squadname]


    if soundList then
        for _, v in ipairs(soundList) do
            print(v, v == squadSpeakSndVar)
            if v == squadSpeakSndVar then return true end
        end

        return false
    end


    return squadSpeakSndVar && true or false
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:DangerSound( isGrenade )
    if self.NPCNextDangerSound > CurTime() then return end
    self:EmitSound(isGrenade && self.SeeGrenadeSounds!="" && self.SeeGrenadeSounds or self.SeeDangerSounds)
    self.NPCNextDangerSound = CurTime()+math.Rand(2, 4)
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:HandleDanger()
    if self.InternalLoudestSoundHint.type != SOUND_DANGER then return end
    local dangerOwn = self.InternalLoudestSoundHint.owner


    if IsValid(dangerOwn)
    && (dangerOwn.IsZBaseGrenade or dangerOwn:GetClass() == "npc_grenade_frag") then
        self:DangerSound(true)
    else
        self:DangerSound(false)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseThink()
    if self:GetNPCState() == NPC_STATE_DEAD then return end


    local ene = self:GetEnemy()
    if self.NPCNextSlowThink < CurTime() then


        -- Flying SNPCs should get closer to the ground during melee
        if self.IsZBase_SNPC
        && self.BaseMeleeAttack
        && self.SNPCType == ZBASE_SNPCTYPE_FLY
        && self.Fly_DistanceFromGround_IgnoreWhenMelee
        && IsValid(ene)
        && self:WithinDistance(ene, self.MeleeAttackDistance*1.75) then
            self.InternalDistanceFromGround = ene:WorldSpaceCenter():Distance(ene:GetPos())
        else
            self.InternalDistanceFromGround = self.Fly_DistanceFromGround
        end


        self.EnemyVisible = self:HasCondition(COND.SEE_ENEMY) or (IsValid(ene) && self:Visible(ene))


        self:InternalDetectDanger()


        self.NPCNextSlowThink = CurTime()+0.3
    end


    -- Enemy updated
    if ene != self.ZBase_LastEnemy then
        -- print(self.ZBase_LastEnemy, "------>", ene)

        self.ZBase_LastEnemy = ene

        if IsValid(ene) then
            -- New enemy
            self:ZBaseAlertSound()
        elseif !self.EnemyDied then
            -- Check if enemy was lost
            -- Wait some time until confirming the enemy is lost
            timer.Simple(math.Rand(1, 2), function()
                if !IsValid(self) then return end

                -- Enemy lost
                if !IsValid(self:GetEnemy())
                && !self:SquadMemberIsSpeaking( {"LostEnemySounds"} ) then
                    self:EmitSound_Uninterupted(self.LostEnemySounds)
                end
            end)
        end
    end


    -- Activity change detection
    local act = self:GetActivity()
    if act && act != self.ZBaseCurrentACT then
        self.ZBaseCurrentACT = act
        self:NewActivityDetected( self.ZBaseCurrentACT )
    end


    -- Handle movement during PlayAnimation
    if self.DoingPlayAnim then
        self:AutoMovement( self:GetAnimTimeInterval() )
    end


    -- Handle danger
    if self.InternalLoudestSoundHint then
        self:HandleDanger()
    end


    self:CustomThink()
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:HasCapability( cap )
    return bit.band(self:CapabilitiesGet(), cap)==cap
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnOwnedEntCreated( ent )
    self:CustomOnOwnedEntCreated( ent )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:AnimShouldBeSequence( anim )
    if !isstring(anim) then return false end

    return self:GetSequenceActivity(self:LookupSequence(anim)) == -1
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:InternalSetAnimation( anim )
	if isstring(anim) then
        -- Sequence
        if self.IsZBase_SNPC then
            self.ZBaseSNPCSequence = anim
        elseif !self:AnimShouldBeSequence(anim) then
            self:SetActivity(self:GetSequenceActivity(self:LookupSequence(anim)))
        end

	elseif isnumber(anim) then
        -- Activity
		self:SetActivity(anim)

	end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:FullReset()
    self:TaskComplete()
    self:ClearGoal()
    self:ClearSchedule()
    self:StopMoving()
    self:SetMoveVelocity(Vector())

    if self.IsZBase_SNPC then
        self:AerialResetNav()
        self:ScheduleFinished()
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:InternalPlayAnimation( anim, duration, playbackRate, sched, forceFace, faceSpeed, loop, onFinishFunc )
    if GetConVar("ai_disabled"):GetBool() then return end

    -- Main function --
    local function playAnim()
        self.DoingPlayAnim = true


        -- Reset stuff --
        self:FullReset()


        -- Set state to scripted
        self.PreAnimNPCState = self:GetNPCState()
        self:SetNPCState(NPC_STATE_SCRIPT)


        -- Set schedule
        if sched then
            self:SetSchedule(sched)
        end


        -- Play sequence if that is what the animation is
        if self:AnimShouldBeSequence(anim) then
            self:ResetSequence(anim)
            self:ResetSequenceInfo()
            self:SetCycle(0)
        end


        -- Duration stuff
        self:InternalSetAnimation(anim) -- So that SequenceDuration gives the right value
        duration = duration or self:SequenceDuration()
        if playbackRate then
            duration = duration/playbackRate
        end


        -- Face
        if forceFace && !loop then
            self:Face(forceFace, duration, faceSpeed)
        end


        -- Timer --
        self.TimeUntilStopAnimOverride = CurTime()+duration
        self.NextAnimTick = CurTime()+0.1

        timer.Create("ZBasePlayAnim"..self:EntIndex(), 0, 0, function()
            if !IsValid(self)
            or (!loop && self.TimeUntilStopAnimOverride < CurTime()) then

                if IsValid(self) then
                    self:StopCurrentAnimation()

                    if onFinishFunc then
                        onFinishFunc()
                    end
                else
                    timer.Remove("ZBasePlayAnim"..self:EntIndex())
                end

                return
            end
            
            if self.NextAnimTick > CurTime() then return end


            -- Play animation
            self:SetPlaybackRate(playbackRate or 1)
            self:InternalSetAnimation(anim)


            -- Face
            if forceFace && loop then
                self:Face(forceFace, nil, faceSpeed)
            end


            self.NextAnimTick = CurTime()+0.1
        end)
        --------------------------------------------------=#
    end
    ----------------------------------------------------------------=#


    -- Transition --
    local goalSeq = isstring(anim)
    && self:LookupSequence(anim) or self:SelectWeightedSequence(anim)

    local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )

    if transition != -1
    && transition != goalSeq then
        self:InternalPlayAnimation(
            self:GetSequenceName(transition),
            nil,
            playbackRate,
            SCHED_NPC_FREEZE,
            forceFace,
            faceSpeed,
            false,
            playAnim
        )

        return
    end
    -----------------------------------------------------------------=#


    playAnim()
end
---------------------------------------------------------------------------------------------------------------------=#
    -- Depricated
function NPC:WithinDistance( ent, maxdist, mindist )
    if !IsValid(ent) then return false end

    local dSqr = self:GetPos():DistToSqr(ent:GetPos())
    if mindist && dSqr < mindist^2 then return false end
    if maxdist && dSqr > maxdist^2 then return false end

    return true
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:HandleAnimEvent(event, eventTime, cycle, type, options)       
    self:SNPCHandleAnimEvent(event, eventTime, cycle, type, options)     
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnBulletHit(ent, tr, dmginfo, bulletData)
    -- Bullet reflection
    if self.ArmorReflectsBullets then
        ZBaseReflectedBullet = true

        local ent = ents.Create("base_gmodentity")
        ent:SetPos(tr.HitPos)
        ent:Spawn()

        ent:FireBullets({
            Src = tr.HitPos,
            Dir = tr.HitNormal,
            Spread = Vector(0.33, 0.33),
            Num = bulletData.Num,
            Attacker = dmginfo:GetAttacker(),
            Inflictor = dmginfo:GetAttacker(),
            Damage = math.random(1, 3),
            IgnoreEntity = self,
        })

        ent:Remove()

        ZBaseReflectedBullet = false
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:InternalDetectDanger()
	self.InternalLoudestSoundHint = sound.GetLoudestSoundHint(SOUND_DANGER, self:GetPos())
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:InternalDamageScale(dmg)
    local infl = dmg:GetInflictor()

    if infl:GetClass()=="prop_combine_ball" then
        dmg:ScaleDamage(self.EnergyBallDamageScale)
        
        if self.ExplodeEnergyBall then
            infl:Fire("Explode")
        end
    end

    for dmgType, mult in pairs(self.DamageScaling) do
        if dmg:IsDamageType(dmgType) then
            dmg:ScaleDamage(mult)
        end
    end
end
---------------------------------------------------------------------------------------------------------------------=#

