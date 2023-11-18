local NPC = ZBaseNPCs["npc_zbase"]
local NPCMETA = FindMetaTable("NPC")


if !ZBase_OldSetSchedule then
	ZBase_OldSetSchedule = NPCMETA.SetSchedule
end


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
    self.NextEmitHearDangerSound = CurTime()
    self.NextFlinch = CurTime()
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


    -- Can dissolve
    if !self.CanDissolve then
        self:AddEFlags(EFL_NO_DISSOLVE)
    end


    -- Custom init
    self:CustomInitialize()
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:PreventSetSched( sched )
    return self.HavingConversation
    or self.DoingPlayAnim
end
---------------------------------------------------------------------------------------------------------------------=#
function NPCMETA:SetSchedule( sched )
    if self.IsZBaseNPC && self:PreventSetSched( sched ) && sched != SCHED_FORCED_GO then return end

    if self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialSetSchedule(sched)
    end

    return ZBase_OldSetSchedule(self, sched)
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:CancelConversation()
    if !self.HavingConversation then return end

    if IsValid(self.DialogueMate) then
        self.DialogueMate.HavingConversation = false
        self.DialogueMate.DialogueMate = nil
        self.DialogueMate:FullReset()

        self.DialogueMate:StopSound(self.DialogueMate.Dialogue_Question_Sounds)
        self.DialogueMate:StopSound(self.DialogueMate.Dialogue_Answer_Sounds)

        timer.Remove("DialogueAnswer"..self.DialogueMate:EntIndex())
        timer.Remove("ZBaseFace"..self.DialogueMate:EntIndex())
    end

    self.HavingConversation = false
    self.DialogueMate = nil
    self:FullReset()

    self:StopSound(self.Dialogue_Question_Sounds)
    self:StopSound(self.Dialogue_Answer_Sounds)

    timer.Remove("DialogueAnswer"..self:EntIndex())
    timer.Remove("ZBaseFace"..self:EntIndex())
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSetupBounds()
    if !self.CollisionBounds then return end

    self:SetCollisionBounds(self.CollisionBounds.min, self.CollisionBounds.max)
    self:SetSurroundingBounds(self.CollisionBounds.min*1.25, self.CollisionBounds.max*1.25)
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
    -- Reload weapon sounds:
    local wep = self:GetActiveWeapon()
    if ReloadActs[act] && IsValid(wep) then

        if wep.IsZBaseWeapon && wep.NPCReloadSound != "" then
            wep:EmitSound(wep.NPCReloadSound)
        end

        if math.random(1, self.OnReloadSound_Chance) == 1 then
            self:EmitSound_Uninterupted(self.OnReloadSounds)
        end

    end


    self:CustomNewActivityDetected( act )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseAlertSound()
    if self.NextAlertSound > CurTime() then return end


    self:StopSound(self.IdleSounds)
    self:CancelConversation()


    if self:SquadMemberIsSpeaking({"AlertSounds"}) then return end


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
        ZBaseSpeakingSquads[squad] = sndVarName

        timer.Create("ZBaseUnmute_"..squad, SoundDuration(data.SoundName), 1, function()
            ZBaseSpeakingSquads[squad] = nil
        end)
    end


    return val
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SquadMemberIsSpeaking( soundList )
    local squad = self:SquadName()
    if squad == "" then return end
    local squadSpeakSndVar = ZBaseSpeakingSquads[squad] or false

    return squadSpeakSndVar
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

    if self.IsZBase_SNPC then
        self:SNPCHandleDanger()
    end

    if IsValid(dangerOwn)
    && (dangerOwn.IsZBaseGrenade or dangerOwn:GetClass() == "npc_grenade_frag") then
        self:DangerSound(true)
    else
        self:DangerSound(false)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:DoSlowThink()
    local ene = self:GetEnemy()
    
    
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
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:DoNewEnemy()
    local ene = self:GetEnemy()


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
---------------------------------------------------------------------------------------------------------------------=#
function NPC:DoPlayAnim()
    -- Handle movement during PlayAnimation
    self:AutoMovement( self:GetAnimTimeInterval() )


    -- Face during PlayAnimation
    if self.PlayAnim_Face then
        self:Face(self.PlayAnim_Face, nil, self.PlayAnim_FaceSpeed)
    end


    -- Playback rate for the animation
    self:SetPlaybackRate(self.PlayAnim_PlayBackRate or 1)


    -- self:SetSaveValue("m_flTimeLastMovement", 1)
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:DoCustomMoveAnim()
    local cusMoveAnim = self.MoveActivityOverride[self:GetNPCState()]
    
    if cusMoveAnim && self:SelectWeightedSequence(cusMoveAnim) != -1 then
        self:SetMovementActivity(cusMoveAnim)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseThink()
    local ene = self:GetEnemy()

    if self.NPCNextSlowThink < CurTime() then
        self:DoSlowThink()
        self.NPCNextSlowThink = CurTime()+0.3
    end


    -- Enemy updated
    if ene != self.ZBase_LastEnemy then
        self.ZBase_LastEnemy = ene
        self:DoNewEnemy()
    end


    -- Activity change detection
    if self:GetActivity() != self.ZBaseLastACT then
        self.ZBaseLastACT = self:GetActivity()
        self:NewActivityDetected( self.ZBaseLastACT )
    end


    -- Stuff to make play anim work as intended
    if self.DoingPlayAnim then
        self:DoPlayAnim()
    end


    -- Movement animation override
    if self:IsMoving() then
        self:DoCustomMoveAnim()
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
function NPC:InternalPlayAnimation( anim, duration, playbackRate, sched, forceFace, faceSpeed, loop, onFinishFunc, isGest, isTransition )
    if GetConVar("ai_disabled"):GetBool() then return end


    -- Do anim as gesture if it is one --
    -- Don't do the rest of the code after that --
    if isGest then
        local gest = isstring(anim) &&
        self:GetSequenceActivity(self:LookupSequence(anim)) or
        isnumber(anim) && anim

        local id = self:AddGesture(gest)
        if self.IsZBase_SNPC then
            self:SetLayerBlendIn(id, 0.2)
            self:SetLayerBlendOut(id, 0.2)
            self:SetLayerPlaybackRate(id, (playbackRate or 1)*0.5 )
        end

        return -- Stop here
    end
    --------------------------------------=#


    -- Main function --
    local function playAnim()
        -- Reset stuff
        self:FullReset()


        -- Set state to scripted
        self.PreAnimNPCState = self:GetNPCState()
        self:SetNPCState(NPC_STATE_SCRIPT)


        -- Set schedule
        if sched then self:SetSchedule(sched) end


        self.DoingPlayAnim = true
        self.PlayAnim_PlayBackRate = playbackRate
    

        -- Convert activity to sequence
        if isnumber(anim) then anim = self:SelectWeightedSequence(anim) end
        self.PlayAnim_Seq = anim


        -- Play the sequence
        self:ResetSequence(anim)
        self:ResetSequenceInfo()
        self:SetCycle(0)


        -- Decide duration
        duration = duration or self:SequenceDuration(anim)
        if playbackRate then
            duration = duration/playbackRate
        end


        -- Face
        if forceFace then
            self.PlayAnim_Face = forceFace
            self.PlayAnim_FaceSpeed = faceSpeed
        end


        -- Anim stop timer --
        timer.Create("ZBasePlayAnim"..self:EntIndex(), duration, 1, function()
            if !IsValid(self) then return end

            self:InternalStopAnimation(isTransition)

            if onFinishFunc then
                onFinishFunc()
            end
        end)
        --------------------------------------------------=#
    end
    ----------------------------------------------------------------=#


    -- Transition --
    local goalSeq = isstring(anim) && self:LookupSequence(anim) or self:SelectWeightedSequence(anim)
    local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )

    if transition != -1
    && transition != goalSeq then
        -- Recursion
        self:InternalPlayAnimation( self:GetSequenceName(transition), nil, playbackRate,
        SCHED_NPC_FREEZE, forceFace, faceSpeed, false, playAnim, false, true )

        debugoverlay.Text(self:GetPos() - Vector(0, 0, 50), "transition in", 2)
        return -- Stop here
    end
    -----------------------------------------------------------------=#


    -- No transition, just play the animation
    
    playAnim()
end
-- ---------------------------------------------------------------------------------------------------------------------=#
function NPC:InternalStopAnimation(dontTransitionOut)
    if !dontTransitionOut then
        -- Out transition --
        local goalSeq = self:SelectWeightedSequence(ACT_IDLE)
        local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )

        if transition != -1
        && transition != goalSeq then
            -- Recursion
            self:InternalPlayAnimation( self:GetSequenceName(transition), nil, playbackRate,
            SCHED_NPC_FREEZE, forceFace, faceSpeed, false, nil, false )

            debugoverlay.Text(self:GetPos() - Vector(0, 0, 50), "transition out", 2)

            return -- Stop here
        end
        ---------------------------------------------------------------------------------=#
    end


    self:SetActivity(ACT_IDLE)
    self:ClearSchedule()
    self:SetNPCState(self.PreAnimNPCState)


    self.DoingPlayAnim = false
    self.PlayAnim_Face = nil
    self.PlayAnim_FaceSpeed = nil
    self.PlayAnim_PlayBackRate = nil
    self.PlayAnim_Seq = nil


    timer.Remove("ZBasePlayAnim"..self:EntIndex())
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
function NPC:ZBaseTakeDamage(dmg, hit_gr)

    -- Flinch
    if !table.IsEmpty(self.FlinchAnimations)
    && math.random(1, self.FlinchChance) == 1
    && self.NextFlinch < CurTime() then
        local anim = table.Random(self.FlinchAnimations)

        if self:OnFlinch(dmg, hit_gr, anim) != false then
            self:PlayAnimation(anim, false, {
                speedMult=self.FlinchAnimationSpeed,
                isGesture=self.FlinchIsGesture,
            })

            self.NextFlinch = ZBaseRndTblRange(self.FlinchCooldown)
        end
    end
    -----------------------=#

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