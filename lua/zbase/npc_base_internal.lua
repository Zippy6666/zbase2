util.AddNetworkString("ZBaseGlowEyes")


local NPC = ZBaseNPCs["npc_zbase"]
local NPCB = ZBaseNPCs["npc_zbase"].Behaviours


--[[
==================================================================================================
                                           INIT BRUV
==================================================================================================
--]]


function NPC:ZBaseInit()
    if !self.BeforeSpawnDone then
        self:BeforeSpawn()
    end

    -- Vars
    self.NextPainSound = CurTime()
    self.NextAlertSound = CurTime()
    self.NPCNextSlowThink = CurTime()
    self.NPCNextDangerSound = CurTime()
    self.NextEmitHearDangerSound = CurTime()
    self.NextFlinch = CurTime()
    self.NextHealthRegen = CurTime()
    self.EnemyVisible = false
    self.InternalDistanceFromGround = self.Fly_DistanceFromGround
    self.LastHitGroup = 0
    self.SchedDebug = GetConVar("developer"):GetBool()


    -- Network shit
    self:SetNWBool("IsZBaseNPC", true)
    self:SetNWString("ZBaseName", self.Name)


     -- Starts with no field of view
    self:SetSaveValue("m_flFieldOfView", 1)


    -- Some calls based on attributes
    self:SetCurrentWeaponProficiency(self.WeaponProficiency)
    self:SetBloodColor(self.BloodColor)
    self:SetRenderMode(self.RenderMode)
    if self.HullType && !self.IsZBase_SNPC then
        self:SetHullType(self.HullType)
    end


    -- Submaterials
    for k, v in pairs(self.SubMaterials) do
        self:SetSubMaterial(k-1, v)
    end


    -- Extra capabilities given
    for _, v in ipairs(self.ExtraCapabilities) do
        self:CapabilitiesAdd(v)
    end


    -- Capabilities
    if self.CanJump && self:SelectWeightedSequence(ACT_JUMP) != -1 then
        self:CapabilitiesAdd(CAP_MOVE_JUMP)
    end


    -- Set specified internal variables
    for k, v in pairs(self:GetTable()) do
        if string.StartWith(k, "m_") then
            self:SetSaveValue(k, v)
        end
    end


    -- Bounds
    if self.CollisionBounds then
        self:SetCollisionBounds(self.CollisionBounds.min, self.CollisionBounds.max)
        self:SetSurroundingBounds(self.CollisionBounds.min*1.25, self.CollisionBounds.max*1.25)
    end


    -- Phys damage scale
    self:Fire("physdamagescale", self.PhysDamageScale)


    -- Can dissolve
    if !self.CanDissolve then
        self:AddEFlags(EFL_NO_DISSOLVE)
    end


    self:CallOnRemove("ZBaseOnRemove", function() self:OnRemove() end)


    -- No squad if faction is none
    if self.ZBaseFaction == "none" && self:SquadName()!="" then
        self:SetSquad("")
    end


    -- Glowing eyes
    self:GlowEyeInit()


    -- Makes behaviour system function
    ZBaseBehaviourInit( self )


    -- Custom init
    self:CustomInitialize()
end


function NPC:GlowEyeInit()
    if !ZBCVAR.SvGlowingEyes:GetBool() then return end


    local Eyes = ZBaseGlowingEyes[self:GetModel()]
    if !Eyes then return end


    Eyes = table.Copy(Eyes)


    for _, eye in ipairs(Eyes) do
        eye.bone = self:LookupBone(eye.bone)
    end


    net.Start("ZBaseAddGlowEyes")
    net.WriteEntity(self)
    net.WriteTable(Eyes)
    net.Broadcast()
end


function NPC:CanHaveWeapons()
    return self:GetClass()!="npc_zbase_snpc"
end


function NPC:BeforeSpawn()
    
    self:CapabilitiesAdd(bit.bor(
        CAP_SQUAD,
        CAP_TURN_HEAD,
        CAP_ANIMATEDFACE,
        CAP_SKIP_NAV_GROUND_CHECK
    ))


    if self:CanHaveWeapons() then
        self:CapabilitiesAdd(CAP_USE_WEAPONS)
        self:CapabilitiesAdd(CAP_USE_SHOT_REGULATOR)
    end


    self.AllowedCustomEScheds = {}
    self.ProhibitCustomEScheds = false

    self.BeforeSpawnDone = true

end


--[[
==================================================================================================
                                           THINK
==================================================================================================
--]]


function NPC:ZBaseThink()
    local ene = self:GetEnemy()


    -- Enemy visible
    self.EnemyVisible = self:HasCondition(COND.SEE_ENEMY) or (IsValid(ene) && self:Visible(ene))


    -- Slow think
    if self.NPCNextSlowThink < CurTime() then
        self:DoSlowThink()
        self.NPCNextSlowThink = CurTime()+0.3
    end


    -- NPC think (not SNPC)
    if !self.IsZBase_SNPC then
        self:HL2NPCThink()
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


    -- Sched debug
    if self.SchedDebug then
        local ent = IsValid(self.Navigator) && self.Navigator or self
        local sched = ( (ent.GetCurrentCustomSched && ent:GetCurrentCustomSched()) or ZBaseEngineSchedName(ent:GetCurrentSchedule()) )
        or self.AllowedCustomEScheds[ent:GetCurrentSchedule()] or "schedule "..tostring(ent:GetCurrentSchedule())

        if sched then
            debugoverlay.Text(self:WorldSpaceCenter(), sched, 0.13)

            if self.Debug_ProhibitedCusESched then
                MsgN("NPC ["..self:EntIndex().."] prohibited sched "..self.Debug_ProhibitedCusESched)
                self.Debug_ProhibitedCusESched = false
            end
        end
    end

    -- Base regen
    if self.HealthRegenAmount > 0 && self:Health() < self:GetMaxHealth() && self.NextHealthRegen < CurTime() then
        self:SetHealth(math.Clamp(self:Health()+self.HealthRegenAmount, 0, self:GetMaxHealth()))
        self.NextHealthRegen = CurTime()+self.HealthCooldown
    end


    self:CustomThink()
end


function NPC:HL2NPCThink()
    local ene = self:GetEnemy()


    if self.ProhibitCustomEScheds then
        local state = self:GetNPCState()
        local sched = self:GetCurrentSchedule()


        if sched > 88 && !self.AllowedCustomEScheds[sched] then
            self.Debug_ProhibitedCusESched = sched

            self:SetSchedule(
                (state==NPC_STATE_IDLE && SCHED_IDLE_STAND)
                or (state==NPC_STATE_ALERT && SCHED_ALERT_STAND)
                or (state==NPC_STATE_COMBAT && SCHED_COMBAT_FACE)
            )
        end
    end


    -- Reload now if hiding spot is too far away
    if (self:IsCurrentSchedule(SCHED_HIDE_AND_RELOAD)
    or ( self:GetClass()=="npc_combine_s" && self:IsCurrentSchedule(ZBaseESchedID("SCHED_COMBINE_HIDE_AND_RELOAD")) ) )
    && self:ZBaseDist(self:GetGoalPos(), {away=1000}) then
        self:SetSchedule(SCHED_RELOAD)
    end


    -- Don't take cover from enemy if we have a melee attack
    -- Chase instead
    if IsValid(ene) && self:IsCurrentSchedule(SCHED_TAKE_COVER_FROM_ENEMY)
    && self:Disposition(ene)==D_HT && self.BaseMeleeAttack then
        self:SetSchedule(SCHED_CHASE_ENEMY)
    end


    -- Run up to enemy to use melee weapons
    if self:HasMeleeWeapon()
    && (self:IsCurrentSchedule(SCHED_MOVE_TO_WEAPON_RANGE)
    or self:IsCurrentSchedule(SCHED_ESTABLISH_LINE_OF_FIRE)
    or self:IsCurrentSchedule(SCHED_COMBAT_FACE)) then
        self:SetSchedule(SCHED_CHASE_ENEMY)
    end
end


function NPC:DoSlowThink()
    local ene = self:GetEnemy()
    
    -- Flying SNPCs should get closer to the ground during melee --
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
    ---------------------------------------------------------------=#


    self:InternalDetectDanger()


    -- Loose enemy
    if IsValid(ene) && !self.EnemyVisible && self:GetEnemyLastKnownPos():DistToSqr(ene:GetPos()) > 10000 then
        self:MarkEnemyAsEluded()
        self:LostEnemySound()

        -- debugoverlay.Text(self:GetPos(), "lost enemy", 2)
        -- debugoverlay.Text(self:GetEnemyLastKnownPos()+Vector(0, 0, 100), "last seen enemy pos", 2)
        -- debugoverlay.Cross(self:GetEnemyLastKnownPos(), 40, 2, Color( 255, 0, 0 ))
    end
    -----------------------=#


    -- Stop being alert after some time
    if self:GetNPCState() == NPC_STATE_ALERT && !self.NextStopAlert then
        self.NextStopAlert = CurTime()+math.Rand(15, 20)
    end

    if self.NextStopAlert && self.NextStopAlert < CurTime() then
        self:SetNPCState(NPC_STATE_IDLE)
        self.NextStopAlert = nil
    end
    --------------------------=#

    if self.ZBaseFaction == "none" && self:SquadName()!="" then
        self:SetSquad("")
    end

end


--[[
==================================================================================================
                                           ANIMATION
==================================================================================================
--]]


function NPC:InternalPlayAnimation( anim, duration, playbackRate, sched,forceFace, faceSpeed, loop, onFinishFunc, isGest, isTransition, noTransitions)
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
        else
            self:SetLayerPlaybackRate(id, (playbackRate or 1) )
        end


        return -- Stop here
    end
    --------------------------------------=#


    -- Main function --
    local function playAnim()
        -- Reset stuff
        self:FullReset()


        -- Set schedule
        if sched then self:SetSchedule(sched) end


        -- Set state to scripted
        self.PreAnimNPCState = self:GetNPCState()
        self:SetNPCState(NPC_STATE_SCRIPT)

        
        if isnumber(anim) then
            -- Anim is activity
            -- Play as activity first, fixes shit
            self:ResetIdealActivity(anim)
            self:SetActivity(anim)

             -- Convert activity to sequence
            anim = self:SelectWeightedSequence(anim)
        else
            -- Fixes jankyness for some NPCs
            self:ResetIdealActivity(ACT_IDLE)
            self:SetActivity(ACT_IDLE)
        end


        -- Play the sequence
        self:ResetSequenceInfo()
        self:SetCycle(0)
        self:ResetSequence(anim)


        -- Decide duration
        duration = duration or self:SequenceDuration(anim)*0.9
        if playbackRate then
            duration = duration/playbackRate
        end

        -- Anim stop timer --
        timer.Create("ZBasePlayAnim"..self:EntIndex(), duration, 1, function()
            if !IsValid(self) then return end

            self:InternalStopAnimation(isTransition or noTransitions)

            if onFinishFunc then
                onFinishFunc()
            end
        end)
        --------------------------------------------------=#


        -- Face
        if forceFace!=nil then
            self.PlayAnim_Face = forceFace
            self.PlayAnim_FaceSpeed = faceSpeed
            self.PlayAnim_LockAng = self:GetAngles()
        end


        self.PlayAnim_PlayBackRate = playbackRate
        self.PlayAnim_Seq = anim
        self.DoingPlayAnim = true
    end
    ----------------------------------------------------------------=#


    -- Transition --
    local goalSeq = isstring(anim) && self:LookupSequence(anim) or self:SelectWeightedSequence(anim)
    local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )
    local transitionAct = self:GetSequenceActivity(transition)

    if !noTransitions
    && transition != -1
    && transition != goalSeq then
        -- Recursion
        self:InternalPlayAnimation( transitionAct != -1 && transitionAct or self:GetSequenceName(transition), nil, playbackRate,
        SCHED_NPC_FREEZE, forceFace, faceSpeed, false, playAnim, false, true )
        return -- Stop here
    end
    -----------------------------------------------------------------=#


    -- No transition, just play the animation
    playAnim()
end


function NPC:DoPlayAnim()
    -- Don't stop playing the sequence
    -- if self:GetSequenceName(self:GetSequence())!=self.PlayAnim_Seq then
    --     self:SetSequence(self.PlayAnim_Seq)
    -- end


    -- Handle movement during PlayAnimation
    self:AutoMovement( self:GetAnimTimeInterval() )


    -- Face during PlayAnimation
    if self.PlayAnim_Face != nil then
        if self.PlayAnim_Face == false then
            timer.Remove("ZBaseFace"..self:EntIndex())
            self:SetAngles(self.PlayAnim_LockAng)
        else
            self:Face(self.PlayAnim_Face, nil, self.PlayAnim_FaceSpeed)
        end
    end


    -- Playback rate for the animation
    self:SetPlaybackRate(self.PlayAnim_PlayBackRate or 1.05)


    -- Stop movement
    self:SetSaveValue("m_flTimeLastMovement", 2)
end


function NPC:InternalStopAnimation(dontTransitionOut)
    if !dontTransitionOut then
        -- Out transition --
        local goalSeq = self:SelectWeightedSequence(ACT_IDLE)
        local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )
        local transitionAct = self:GetSequenceActivity(transition)

        if transition != -1
        && transition != goalSeq then
            -- Recursion
            self:InternalPlayAnimation( transitionAct != -1 && transitionAct or self:GetSequenceName(transition), nil, playbackRate,
            SCHED_NPC_FREEZE, forceFace, faceSpeed, false, nil, false )
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
    self.PlayAnim_LockAng = nil
    self.PlayAnim_Seq = nil


    timer.Remove("ZBasePlayAnim"..self:EntIndex())
end


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


function NPC:DoCustomMoveAnim()
    local cusMoveAnim = self.MoveActivityOverride[self:GetNPCState()]
    if cusMoveAnim && self:SelectWeightedSequence(cusMoveAnim) != -1 then
        self:SetMovementActivity(cusMoveAnim)
    end
end


function NPC:HandleAnimEvent(event, eventTime, cycle, type, options)       
    self:SNPCHandleAnimEvent(event, eventTime, cycle, type, options)     
end


--[[
==================================================================================================
                                           SOUND
==================================================================================================
--]]


ZBase_DontSpeakOverThisSound = false


local SoundIndexes = {}
local ShuffledSoundTables = {}


function NPC:RestartSoundCycle( sndTbl, data )
    SoundIndexes[data.OriginalSoundName] = 1

    local shuffle = table.Copy(sndTbl.sound)
    table.Shuffle(shuffle)
    ShuffledSoundTables[data.OriginalSoundName] = shuffle

    -- MsgN("-----------------", data.OriginalSoundName, "-----------------")
    -- MsgN(ShuffledSoundTables[data.OriginalSoundName])
    -- MsgN("--------------------------------------------------")
end


function NPC:OnEmitSound( data )
    local altered = false
    local sndVarName


    -- What sound variable was it? if any
    for _, v in ipairs(self.SoundVarNames) do
        if self[v] == data.OriginalSoundName then
            sndVarName = v
            break
        end
    end


    -- Mute default "engine" voice
    if !ZBase_EmitSoundCall
    && SERVER
    && self.MuteDefaultVoice
    && (data.SoundName == "invalid.wav" or data.Channel == CHAN_VOICE) then
        return false
    end


        -- Avoid sound repitition --
    local sndTbl = sound.GetProperties(data.OriginalSoundName)

    if sndTbl && istable(sndTbl.sound) && table.Count(sndTbl.sound) > 1 && ZBase_EmitSoundCall then
        if !SoundIndexes[data.OriginalSoundName] then
            self:RestartSoundCycle(sndTbl, data)
        else
            if SoundIndexes[data.OriginalSoundName] == table.Count(sndTbl.sound) then
                self:RestartSoundCycle(sndTbl, data)
            else
                SoundIndexes[data.OriginalSoundName] = SoundIndexes[data.OriginalSoundName] + 1
            end
        end

        local snds = ShuffledSoundTables[data.OriginalSoundName]
        data.SoundName = snds[SoundIndexes[data.OriginalSoundName]]
        altered = true

        -- MsgN(SoundIndexes[data.OriginalSoundName], data.SoundName)
    end
    -----------------------------------------------=#


    -- Custom on emit sound, allow the user to replace what sound to play
    local value = self:CustomOnEmitSound( data, sndVarName )
    if isstring(value) then

        self.TempSoundCvar = sndVarName


        if ZBase_DontSpeakOverThisSound then
            self:EmitSound_Uninterupted(value)
        else
            self:EmitSound(value)
        end


        self.TempSoundCvar = nil
        return false

    elseif value == false then
        return false
    end


    -- Make sure squad doesn't speak over each other
    local squad = self:GetKeyValues().squadname
    if squad != "" && ZBase_DontSpeakOverThisSound then
        ZBaseSpeakingSquads[squad] = self.TempSoundCvar or sndVarName or true

        timer.Create("ZBaseUnmute_"..squad, SoundDuration(data.SoundName), 1, function()
            ZBaseSpeakingSquads[squad] = nil
        end)
    end


    self.InternalCurrentSoundDuration = SoundDuration(data.SoundName)


    if altered then
        return true
    end
end


function NPC:SquadMemberIsSpeaking( soundList )
    local squad = self:SquadName()
    if squad == "" then return end


    local squadSpeakSndVar = ZBaseSpeakingSquads[squad] or false


    if soundList then
        for _, v in ipairs(soundList) do
            if v == squadSpeakSndVar then
                return v
            end
        end
    else
        return squadSpeakSndVar
    end


    return false
end


--[[
==================================================================================================
                                           IDLE SOUNDS
==================================================================================================
--]]


NPCB.DoIdleSound = {
    MustNotHaveEnemy = true, 
}


function NPCB.DoIdleSound:ShouldDoBehaviour( self )
    if self.IdleSounds == "" then return false end
    if self:GetNPCState() != NPC_STATE_IDLE then return false end
    if self.HavingConversation then return false end

    return true
end


function NPCB.DoIdleSound:Delay( self )
    if self:SquadMemberIsSpeaking({"IdleSounds"}) or math.random(1, self.IdleSound_Chance)==1 then
        return ZBaseRndTblRange(self.IdleSoundCooldown)
    end
end


function NPCB.DoIdleSound:Run( self )
    self:EmitSound_Uninterupted(self.IdleSounds)
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSoundCooldown))
end


--[[
==================================================================================================
                                           IDLE ENEMY SOUNDS
==================================================================================================
--]]


NPCB.DoIdleEnemySound = {
    MustHaveEnemy = true,
}


function NPCB.DoIdleEnemySound:ShouldDoBehaviour( self )
    if self.Idle_HasEnemy_Sounds == "" then return false end
    if self:GetNPCState() == NPC_STATE_DEAD then return false end

    return true
end


function NPCB.DoIdleEnemySound:Delay( self )
    if self:SquadMemberIsSpeaking() then
        return ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown)
    end
end


function NPCB.DoIdleEnemySound:Run( self )

    local snd = self.Idle_HasEnemy_Sounds
    local enemy = self:GetEnemy()

    self:EmitSound_Uninterupted(snd)
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown))

end


--[[
==================================================================================================
                                           DIALOGUE
==================================================================================================
--]]


NPCB.Dialogue = {
    MustNotHaveEnemy = true, 
}


function NPCB.Dialogue:ShouldDoBehaviour( self )
    if self.Dialogue_Question_Sounds == "" then return false end
    if self:GetNPCState() != NPC_STATE_IDLE then return false end
    if self.HavingConversation then return false end

    return true
end


function NPCB.Dialogue:Delay( self )
    if self:SquadMemberIsSpeaking() or self.HavingConversation or math.random(1, self.IdleSound_Chance)==1 then
        return ZBaseRndTblRange(self.IdleSoundCooldown)
    end
end


function NPCB.Dialogue:Run( self )
    local ally = self:GetNearestAlly(350)


    local extraBehaviourDelay = 0


    if IsValid(ally)
    && ally.IsZBaseNPC
    && !IsValid(ally:GetEnemy())
    && !ally.HavingConversation
    && self:Visible(ally)
    && ally.Dialogue_Answer_Sounds != "" then
        self:EmitSound_Uninterupted(self.Dialogue_Question_Sounds)

        self:FullReset()
        self:Face(ally, self.InternalCurrentSoundDuration+0.2)
        self.HavingConversation = true
        self.DialogueMate = ally

        ally:FullReset()
        ally:Face(self, self.InternalCurrentSoundDuration+0.2)
        ally.HavingConversation = true
        ally.DialogueMate = self

        extraBehaviourDelay = self.InternalCurrentSoundDuration+0.2

        timer.Create("DialogueAnswer"..ally:EntIndex(), self.InternalCurrentSoundDuration+0.4, 1, function()
            if IsValid(ally) then
                ally:EmitSound_Uninterupted(ally.Dialogue_Answer_Sounds)
                ally:Face(self, ally.InternalCurrentSoundDuration)

                timer.Simple(ally.InternalCurrentSoundDuration, function()
                    if !IsValid(ally) then return end
                    ally:CancelConversation()
                end)

                ZBaseDelayBehaviour( ZBaseRndTblRange(ally.IdleSoundCooldown), ally, "Dialogue" )
            end

            if IsValid(self) then
                self:Face(ally, ally.InternalCurrentSoundDuration)

                timer.Simple(ally.InternalCurrentSoundDuration or 0, function()
                    if !IsValid(self) then return end
                    self:CancelConversation()
                end)
            end
        end)
    end


    ZBaseDelayBehaviour( ZBaseRndTblRange(self.IdleSoundCooldown)+extraBehaviourDelay )
end


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


--[[
==================================================================================================
                                           PATROL
==================================================================================================
--]]


NPCB.Patrol = {
    MustNotHaveEnemy = true, 
}


local SchedsToReplaceWithPatrol = {
    [SCHED_IDLE_STAND] = true,
    [SCHED_ALERT_STAND] = true,
    [SCHED_ALERT_FACE] = true,
    [SCHED_ALERT_WALK] = true,
}


function NPCB.Patrol:ShouldDoBehaviour( self )
    return self.CanPatrol
    && SchedsToReplaceWithPatrol[self:GetCurrentSchedule()]
    && self:GetMoveType() == MOVETYPE_STEP
end


function NPCB.Patrol:Delay(self)
    if self:IsMoving()
    or self.DoingPlayAnim then
        return math.random(8, 15)
    end
end


function NPCB.Patrol:Run( self )
    if self:GetNPCState() == NPC_STATE_ALERT then
        self:SetSchedule(SCHED_PATROL_RUN)
    else
        self:SetSchedule(SCHED_PATROL_WALK)
    end
    
    ZBaseDelayBehaviour(math.random(8, 15))
end


--[[
==================================================================================================
                                           CALL FOR HELP
==================================================================================================
--]]


NPCB.FactionCallForHelp = {
    MustHaveEnemy = true,
}


function NPCB.FactionCallForHelp:ShouldDoBehaviour( self )
    return self.CallForHelp!=false && self.ZBaseFaction != "none"
end


function NPCB.FactionCallForHelp:Run( self )
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), self.CallForHelpDistance)) do

        if !v:IsNPC() then continue end
        if v == self then continue end
        if v.ZBaseFaction == "none" then continue end
        if IsValid(v:GetEnemy()) then continue end -- Ally already busy with an enemy

        if v.ZBaseFaction == self.ZBaseFaction then
            local ene = self:GetEnemy()
            v:UpdateEnemyMemory(ene, ene:GetPos())
            v:AlertSound()
        end

    end

    ZBaseDelayBehaviour(math.Rand(2, 3.5))
end


--[[
==================================================================================================
                                           WEAPON HANDLING
==================================================================================================
--]]


local hl2wepShootDistMult = {
    ["weapon_shotgun"] = 0.5,
    ["weapon_crossbow"] = 2,
}


function NPC:GetCurrentWeaponShootDist()
    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then return end

    local mult = hl2wepShootDistMult[wep:GetClass()] or wep.NPCShootDistanceMult or 1

    return self.MaxShootDistance*mult
end


function NPC:ShootTargetTooFarAway()
    local ene = self:GetEnemy()

    return IsValid(ene)
    && IsValid(self:GetActiveWeapon())
    && self:ZBaseDist(ene, {away=self:GetCurrentWeaponShootDist()})
end


function NPC:PreventFarShoot()
    self:SetSaveValue("m_flFieldOfView", 1)
    self:SetMaxLookDistance(self:GetCurrentWeaponShootDist())
end


NPCB.AdjustSightAngAndDist = {}


function NPCB.AdjustSightAngAndDist:ShouldDoBehaviour( self )
    return true
end


function NPCB.AdjustSightAngAndDist:Run( self )
    local ene = self:GetEnemy()

    if self.DoingDeathAnim then
        self:SetSaveValue("m_flFieldOfView", 1)
        self:SetMaxLookDistance(1)
    elseif self:ShootTargetTooFarAway() then
        self:PreventFarShoot()
    else
        local fieldOfView = math.cos( (self.SightAngle*(math.pi/180))*0.5 )
        self:SetSaveValue("m_flFieldOfView", fieldOfView)
        self:SetMaxLookDistance(self.SightDistance)
    end
end


--[[
==================================================================================================
                                           SECONDARY FIRE
==================================================================================================
--]]


ZBaseComballOwner = NULL


NPCB.SecondaryFire = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}


local SecondaryFireWeapons = {
    ["weapon_ar2"] = {dist=4000, mindist=100},
    ["weapon_smg1"] = {dist=1500, mindist=250},
}


function SecondaryFireWeapons.weapon_ar2:Func( self, wep, enemy )
    local seq = self:LookupSequence("shootar2alt")
    if seq != -1 then
        -- Has comball animation, play it
        self:PlayAnimation("shootar2alt", true)
    else
        -- Charge sound (would normally play in the comball anim)
        wep:EmitSound("Weapon_CombineGuard.Special1")
    end


    timer.Simple(0.75, function()
        if !(IsValid(self) && IsValid(wep) && IsValid(enemy)) then return end
        if self:GetNPCState() == NPC_STATE_DEAD then return end


        local startPos = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos

        local ball_launcher = ents.Create( "point_combine_ball_launcher" )
        ball_launcher:SetAngles( (enemy:WorldSpaceCenter() - startPos):Angle() )
        ball_launcher:SetPos( startPos )
        ball_launcher:SetKeyValue( "minspeed",1200 )
        ball_launcher:SetKeyValue( "maxspeed", 1200 )
        ball_launcher:SetKeyValue( "ballradius", "10" )
        ball_launcher:SetKeyValue( "ballcount", "1" )
        ball_launcher:SetKeyValue( "maxballbounces", "100" )
        ball_launcher:Spawn()
        ball_launcher:Activate()
        ball_launcher:Fire( "LaunchBall" )
        ball_launcher:Fire("kill","",0)
        timer.Simple(0.01, function()
            if IsValid(self)
            && self:GetNPCState() != NPC_STATE_DEAD then
                for _, ball in ipairs(ents.FindInSphere(self:GetPos(), 100)) do
                    if ball:GetClass() == "prop_combine_ball" then

                        ball:SetOwner(self)
                        ball.ZBaseComballOwner = self

                        timer.Simple(math.Rand(4, 6), function()
                            if IsValid(ball) then
                                ball:Fire("Explode")
                            end
                        end)
                    end
                end
            end
        end)
    
        local effectdata = EffectData()
        effectdata:SetFlags(5)
        effectdata:SetEntity(wep)
        util.Effect( "MuzzleFlash", effectdata, true, true )

        wep:EmitSound("Weapon_IRifle.Single")
    end)
end


function SecondaryFireWeapons.weapon_smg1:Func( self, wep, enemy )

    local startPos = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos
    local grenade = ents.Create("grenade_ar2")
    grenade:SetOwner(self)
    grenade:SetPos(startPos)
    grenade:Spawn()
    grenade:SetVelocity((enemy:GetPos() - startPos):GetNormalized()*1250 + Vector(0,0,200))
    grenade:SetLocalAngularVelocity(AngleRand())
    wep:EmitSound("Weapon_AR2.Double")

    local effectdata = EffectData()
    effectdata:SetFlags(7)
    effectdata:SetEntity(wep)
    util.Effect( "MuzzleFlash", effectdata, true, true )

end


function NPCB.SecondaryFire:ShouldDoBehaviour( self )
    if !self.CanSecondaryAttack then return false end
    if self.DoingPlayAnim then return false end

    local wep = self:GetActiveWeapon()

    if !IsValid(wep) then return false end

    local wepTbl = SecondaryFireWeapons[wep:GetClass()]
    if !wepTbl then return false end

    if self:GetActivity()!=ACT_RANGE_ATTACK1 then return false end

    return self:ZBaseDist( self:GetEnemy(), {within=wepTbl.dist, away=wepTbl.mindist} )
end


function NPCB.SecondaryFire:Delay( self )

    if math.random(1, 2) == 1 then
        return math.Rand(4, 8)
    end

end


function NPCB.SecondaryFire:Run( self )
    local enemy = self:GetEnemy()
    local wep = self:GetActiveWeapon()
    SecondaryFireWeapons[wep:GetClass()]:Func( self, wep, enemy )
    ZBaseDelayBehaviour(math.Rand(4, 8))
end


--[[
==================================================================================================
                                           MELEE ATTACK
==================================================================================================
--]]


NPCB.MeleeAttack = {
    MustHaveEnemy = true,
}


NPCB.PreMeleeAttack = {
    MustHaveEnemy = true,
}


local BusyScheds = {
    [SCHED_MELEE_ATTACK1] = true,
    [SCHED_MELEE_ATTACK2] = true,
    [SCHED_RANGE_ATTACK1] = true,
    [SCHED_RANGE_ATTACK2] = true,
    [SCHED_RELOAD] = true,
}


local MeleeWeapons = {
    ["weapon_crowbar"] = true,
    ["weapon_stunstick"] = true,
}


function NPC:HasMeleeWeapon()
    local wep = self:GetActiveWeapon()


    if !IsValid(wep) then return false end


    return MeleeWeapons[wep:GetClass()] or false
end


function NPC:TooBusyForMelee()
    return self.DoingPlayAnim or self:HasMeleeWeapon()
end


function NPC:CanBeMeleed( ent )
    local mtype = ent:GetMoveType()
    return mtype == MOVETYPE_STEP -- NPC
    or mtype == MOVETYPE_VPHYSICS -- Prop
    or mtype == MOVETYPE_WALK -- Player
end


function NPC:InternalMeleeAttackDamage(dmgData)
    local mypos = self:WorldSpaceCenter()
    local soundEmitted = false
    local soundPropEmitted = false
    local hurtEnts = {}


    for _, ent in ipairs(ents.FindInSphere(mypos, dmgData.dist)) do
        if ent == self then continue end
        if ent.GetNPCState && ent:GetNPCState() == NPC_STATE_DEAD then continue end

        local disp = self:Disposition(ent)
        if (!dmgData.affectProps && disp == D_NU) then continue end

        if !self:Visible(ent) then continue end


        local entpos = ent:WorldSpaceCenter()
        local undamagable = (ent:Health()==0 && ent:GetMaxHealth()==0)
        local forcevec 


        -- Angle check
        if dmgData.ang != 360 then
            local yawDiff = math.abs( self:WorldToLocalAngles( (entpos-mypos):Angle() ).Yaw )*2
            if dmgData.ang < yawDiff then continue end
        end


        if self:CanBeMeleed(ent) then
            local tbl = self:MeleeDamageForce(dmgData)

            if tbl then
                forcevec = self:GetForward()*(tbl.forward or 0) + self:GetUp()*(tbl.up or 0) + self:GetRight()*(tbl.right or 0)

                if tbl.randomness then
                    forcevec = forcevec + VectorRand()*tbl.randomness
                end
            end
        else
            continue
        end


        -- Push
        if forcevec && !self:IsAlly(ent) then
            local phys = ent:GetPhysicsObject()

            if IsValid(phys) then
                phys:SetVelocity(forcevec)
            end

            ent:SetVelocity(forcevec)
        end


        -- Damage
        if !undamagable && !self:IsAlly(ent) then
            local dmg = DamageInfo()
            dmg:SetAttacker(self)
            dmg:SetInflictor(self)
            dmg:SetDamage(ZBaseRndTblRange(dmgData.amt))
            dmg:SetDamageType(dmgData.type)
            ent:TakeDamageInfo(dmg)

            if !(ent:IsPlayer() && dmg:IsDamageType(DMG_SLASH)) && dmg:GetDamage()>0 then
                ZBaseBleed( ent, entpos+VectorRand(-15, 15) ) -- Bleed
            end
        end
    

        -- Sound
        if disp == D_NU or undamagable && !soundPropEmitted then -- Prop probably
            sound.Play(dmgData.hitSoundProps, entpos)
            soundPropEmitted = true
        elseif !soundEmitted && disp != D_NU then
            ent:EmitSound(dmgData.hitSound)
            soundEmitted = true
        end

        table.insert(hurtEnts, ent)
    end

    return hurtEnts
end


function NPCB.MeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end


    local ene = self:GetEnemy()
    if !self.MeleeAttackFaceEnemy && !self:IsFacing(ene) then return false end

    return !self:TooBusyForMelee()
    && self:ZBaseDist(ene, {within=self.MeleeAttackDistance})
end


function NPCB.MeleeAttack:Run( self )
    self:MeleeAttack()
    ZBaseDelayBehaviour(self:SequenceDuration() + ZBaseRndTblRange(self.MeleeAttackCooldown))
end


function NPCB.PreMeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end
    if self:TooBusyForMelee() then return false end

    return true
end


function NPCB.PreMeleeAttack:Run( self )
    self:MultipleMeleeAttacks()
end


--[[
==================================================================================================
                                           RANGE ATTACK
==================================================================================================
--]]


NPCB.RangeAttack = {
    MustHaveEnemy = true,
}


NPCB.PreRangeAttack = {
    MustHaveEnemy = true,
}


function NPCB.RangeAttack:ShouldDoBehaviour( self )
    if !self.BaseRangeAttack then return false end -- Doesn't have range attack
    if self.DoingPlayAnim then return false end

    -- Don't range attack in mid-air
    if self:GetNavType() == 0
    && self:GetClass() != "npc_manhack"
    && !self:IsOnGround() then return false end
    
    
    self:MultipleRangeAttacks()


    local ene = self:GetEnemy()
    local seeEnemy = self.EnemyVisible -- IsValid(ene) && self:Visible(ene)
    local trgtPos = self:Projectile_TargetPos()


    -- Can't see target position
    if !self:VisibleVec(trgtPos) then return false end


    -- Not in distance
    if !self:ZBaseDist(trgtPos, {away=self.RangeAttackDistance[1], within=self.RangeAttackDistance[2]}) then return false end


    -- Suppress disabled, and enemy not visible
    if !self.RangeAttackSuppressEnemy && seeEnemy then return false end


    -- Don't suppress enemy with these conditions
    if (self.RangeAttackSuppressEnemy && !seeEnemy)
    && (!self.RangeAttack_LastEnemyPos
    -- or ene:GetPos():DistToSqr(trgtPos) > 400^2
    or !ene:VisibleVec(trgtPos)) then
        return false
    end


    if self:PreventRangeAttack() then return false end


    return true
end


function NPCB.RangeAttack:Run( self )
    self:RangeAttack()
    ZBaseDelayBehaviour(self:SequenceDuration() + 0.25 + ZBaseRndTblRange(self.RangeAttackCooldown))
end


--[[
==================================================================================================
                                    ENGINE SCHEDULE FUNCTION THINGS
==================================================================================================
--]]


local NPCMETA = FindMetaTable("NPC")


if !ZBase_OldSetSchedule then
	ZBase_OldSetSchedule = NPCMETA.SetSchedule
    ZBase_OldIsCurrentSchedule = NPCMETA.IsCurrentSchedule
end


function NPC:PreventSetSched( sched )
    return self.HavingConversation
    or self.DoingPlayAnim
end


function NPCMETA:SetSchedule( sched )
    if self.IsZBaseNPC && self:PreventSetSched( sched ) && sched != SCHED_FORCED_GO then return end

    if self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialSetSchedule(sched)
    end

    return ZBase_OldSetSchedule(self, sched)
end

function NPCMETA:IsCurrentSchedule( sched )
    -- i can't even explain wth this does
    -- but it's important
    if self.GetBetterSchedule_CheckSched == false or isnumber( self.GetBetterSchedule_CheckSched ) then
        return self.GetBetterSchedule_CheckSched==sched
    end

    return ZBase_OldIsCurrentSchedule(self, sched)
end


--[[
==================================================================================================
                                           DANGER DETECTION
==================================================================================================
--]]



local Class_ShouldRunRandomOnDanger = {
    [CLASS_PLAYER_ALLY_VITAL] = true,
    [CLASS_COMBINE] = true,
    [CLASS_METROPOLICE] = true,
    [CLASS_PLAYER_ALLY] = true,
}


function NPC:HandleDanger()
    if self:BusyPlayingAnimation() then return end
    if self.InternalLoudestSoundHint.type != SOUND_DANGER then return end


    local dangerOwn = self.InternalLoudestSoundHint.owner
    local isGrenade = IsValid(dangerOwn) && (dangerOwn.IsZBaseGrenade or dangerOwn:GetClass() == "npc_grenade_frag")


    if self.IsZBase_SNPC then
        self:SNPCHandleDanger()
    end


    -- Sound
    if self.NPCNextDangerSound < CurTime() then
        self:EmitSound_Uninterupted(isGrenade && self.SeeGrenadeSounds!="" && self.SeeGrenadeSounds or self.SeeDangerSounds)
        self.NPCNextDangerSound = CurTime()+math.Rand(2, 4)
    end


    if (Class_ShouldRunRandomOnDanger[self:Classify()] or self.ForceAvoidDanger) && self:GetCurrentSchedule() <= 88 && !self:IsCurrentSchedule(SCHED_RUN_RANDOM) then
        self:SetSchedule(SCHED_RUN_RANDOM)
    end


    if self.HavingConversation then
        self:CancelConversation()
    end
end


function NPC:InternalDetectDanger()
	self.InternalLoudestSoundHint = sound.GetLoudestSoundHint(SOUND_DANGER, self:GetPos())
end



--[[
==================================================================================================
                                           DEAL DAMAGE
==================================================================================================
--]]


local ZBaseWeaponDMGs = {
    ["weapon_pistol"] = {dmg=5, inflclass="bullet"},
    ["weapon_357"] = {dmg=40, inflclass="bullet"},
    ["weapon_ar2"] = {dmg=8, inflclass="bullet"},
    ["weapon_rpg"] = {dmg=150, inflclass="bullet"},
    ["weapon_shotgun"] = {dmg=56, inflclass="bullet"},
    ["weapon_smg1"] = {dmg=4, inflclass="bullet", dmgSecondary=100, inflclassSecondary="grenade_ar2"},
    ["weapon_rpg"] = {dmg=150, inflclass="rpg_missile"},
    ["weapon_crossbow"] = {dmg=100, inflclass="crossbow_bolt"},
    ["weapon_elitepolice_mp5k"] = {dmg=5, inflclass="bullet"},
}


function NPC:DealDamage( dmg, ent )
    local infl = dmg:GetInflictor()


    local value = self:CustomDealDamage(ent, dmg)
    if value != nil then
        return value
    end


    -- Proper damage values for hl2 weapons --
    local wep = self:GetActiveWeapon()
    local ScaleForNPC = ZBCVAR.FullHL2WepDMG_NPC:GetBool() && (ent:IsNPC() or ent:IsNextBot())
    local ScaleForPlayer = ZBCVAR.FullHL2WepDMG_PLY:GetBool() && ent:IsPlayer()

    if IsValid(infl) && IsValid(wep) && (ScaleForNPC or ScaleForPlayer) then
        local dmgTbl = ZBaseWeaponDMGs[wep:GetClass()]


        if dmgTbl then
            local IsPrimaryInfl = (dmgTbl.inflclass == "bullet" && dmg:IsBulletDamage()) or infl:GetClass() == dmgTbl.inflclass
            local dmgFinal
            
            if IsPrimaryInfl then
                dmgFinal = dmgTbl.dmg
            else
                local IsSecondaryInfl = infl:GetClass() == dmgTbl.inflclassSecondary

                if IsSecondaryInfl then
                    dmgFinal = dmgTbl.dmgSecondary
                end
            end


            if dmgFinal then


                -- Shotgun damage degrade over distance
                if dmg:IsDamageType(DMG_BUCKSHOT) then
                    if self:ZBaseDist(ent, {within=200}) then
                        dmgFinal = math.random(40, 56)
                    elseif self:ZBaseDist(ent, {within=400}) then
                        dmgFinal = math.random(16, 40)
                    else
                        dmgFinal = math.random(8, 16)
                    end
                end


                -- Explosion damage degrade over distance
                if dmg:IsExplosionDamage() then
                    local Dist = ent:GetPos():DistToSqr(dmg:GetDamagePosition())
                    
                    if Dist > 100^2 then
                        -- Distant
                        dmgFinal = math.random(dmgFinal*0.66, dmgFinal)
                    elseif Dist > 50^2 then
                        -- Close
                        dmgFinal = math.random(1, dmgFinal*0.33)
                    end
                end


                -- dmg:SetDamage(dmgFinal)s
                if dmg:GetDamage() > 0 then
                    dmg:ScaleDamage((1/dmg:GetDamage())*dmgFinal)
                end
            end
        end
    end
end


--[[
==================================================================================================
                                           TAKE DAMAGE
==================================================================================================
--]]


function NPC:CustomBleed( pos, dir )
    if !self.CustomBloodParticles && !self.CustomBloodDecals then return end


    local function Bleed(posfinal, dirfinal, IsBulletDamage)
        local dmgPos = posfinal
        if !IsBulletDamage && !self:ZBaseDist( dmgPos, { within=math.max(self:OBBMaxs().x, self:OBBMaxs().z)*1.5 } ) then
            dmgPos = self:WorldSpaceCenter()+VectorRand()*15
        end


        if self.CustomBloodParticles then
            ParticleEffect(table.Random(self.CustomBloodParticles), dmgPos, -dirfinal:Angle())
        end


        if self.CustomBloodDecals then
            util.Decal(self.CustomBloodDecals, dmgPos, dmgPos+dirfinal*250+VectorRand()*50, self)
        end
    end


    if self.ZBase_BulletHits then

        for _, v in ipairs(self.ZBase_BulletHits) do
            Bleed(v.pos, v.dir, true)
        end

    else

        Bleed(pos, dir)

    end
end


function NPC:ApplyZBaseDamageScale(dmg)
    if self.HasZBScaledDamage then return end
    self.HasZBScaledDamage = true


    for dmgType, mult in pairs(self.DamageScaling) do
        if dmg:IsDamageType(dmgType) then
            dmg:ScaleDamage(mult)
        end
    end
end


    -- Called first
function NPC:OnScaleDamage( dmg, hit_gr )
    local infl = dmg:GetInflictor()
    local attacker = dmg:GetAttacker()


    -- Remember last hitgroup
    self.LastHitGroup = dmg, hit_gr


    -- Don't get hurt by NPCs in the same faction
    if self:IsAlly(attacker) then
        dmg:ScaleDamage(0)
    end

    
    self:ApplyZBaseDamageScale(dmg)


    -- Armor
    if self.HasArmor[hit_gr] then
        self:HitArmor(dmg, hit_gr)
    end


    -- Custom damage
    self:CustomTakeDamage( dmg, hit_gr )
    self.CustomTakeDamageDone = true


    -- Bullet blood shit idk
    if dmg:IsBulletDamage() then
        if !self.ZBase_BulletHits then
            self.ZBase_BulletHits = {}
        end


        table.insert(self.ZBase_BulletHits, {pos=dmg:GetDamagePosition(), dir=dmg:GetDamageForce():GetNormalized()})


        timer.Simple(0, function()
            if !IsValid(self) then return end

            self.ZBase_BulletHits = nil
        end)
    end
end


local ShouldPreventGib = {
    ["npc_zombie"] = true,
    ["npc_fastzombie"] = true,
    ["npc_fastzombie_torso"] = true,
    ["npc_poisonzombie"] = true,
    ["npc_zombie_torso"] = true,
    ["npc_zombine"] = true,
    ["npc_antlion"] = true,
    ["npc_antlion_worker"] = true,
}


    -- Called second
function NPC:OnEntityTakeDamage( dmg )
    local attacker = dmg:GetAttacker()
    local infl = dmg:GetInflictor()


    if self.DoingDeathAnim && !self.DeathAnim_Finished then
        dmg:ScaleDamage(0)
        return true
    end


    if self:IsAlly(attacker) then
        dmg:ScaleDamage(0)
        return true
    end


    -- Remember last dmginfo
    self.LastDMGINFO = dmg


    self:ApplyZBaseDamageScale(dmg)


    -- Custom damage
    if !self.CustomTakeDamageDone then
        self:CustomTakeDamage( dmg, HITGROUP_GENERIC )
        self.CustomTakeDamageDone = true
    end


    local boutaDie = self:Health()-dmg:GetDamage() <= 0 -- mf bouta die lmfao


    if boutaDie && ShouldPreventGib[self:GetClass()] then
        if dmg:IsDamageType(DMG_DISSOLVE) then
            dmg:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_NEVERGIB))
        else
            dmg:SetDamageType(DMG_NEVERGIB)
        end
    end


    -- Death animation
    if !table.IsEmpty(self.DeathAnimations) && boutaDie && math.random(1, self.DeathAnimationChance)==1 then
        self:DeathAnimation(dmg)
        return
    end
end


    -- Called last
function NPC:OnPostEntityTakeDamage( dmg )
    -- Custom blood
    if dmg:GetDamage() > 0 then
        self:CustomBleed(dmg:GetDamagePosition(), dmg:GetDamageForce():GetNormalized())
    end


    if self.Dead then return end


    -- Remember last dmginfo again for accuracy sake
    self.LastDMGINFO = dmg


    -- Fix NPCs being unkillable in SCHED_NPC_FREEZE
    if self.IsZBaseNPC && self:IsCurrentSchedule(SCHED_NPC_FREEZE) && self:Health() <= 0
    && !self.ZBaseDieFreezeFixDone then
        self:ClearSchedule()
        self:TakeDamageInfo(dmg)
        self.ZBaseDieFreezeFixDone = true
    end


    -- Pain sound
    if self.NextPainSound < CurTime() && dmg:GetDamage() > 0 then
        self:EmitSound_Uninterupted(self.PainSounds)
        self.NextPainSound = CurTime()+ZBaseRndTblRange( self.PainSoundCooldown )
    end


    -- Flinch
    if !table.IsEmpty(self.FlinchAnimations) && math.random(1, self.FlinchChance) == 1 && self.NextFlinch < CurTime() then
        local cusAnim = self:GetFlinchAnimation(dmg, self.LastHitGroup)
        local anim = (isstring(cusAnim) or isnumber(cusAnim)) && cusAnim or table.Random(self.FlinchAnimations)


        if self:OnFlinch(dmg, self.LastHitGroup, anim) != false then

            self:PlayAnimation(anim, false, {
                speedMult=self.FlinchAnimationSpeed,
                isGesture=self.FlinchIsGesture,
                face = false,
                noTransitions = true,
            })

            self.NextFlinch = CurTime()+ZBaseRndTblRange(self.FlinchCooldown)

        end
    end


    self.HasZBScaledDamage = false
    self.CustomTakeDamageDone = false
end


--[[
==================================================================================================
                                           DEATH
==================================================================================================
--]]


function NPC:OnDeath( attacker, infl, dmg, hit_gr )
    if self.Dead then return end


    self.Dead = true


    -- Stop sounds
    for _, v in ipairs(self.SoundVarNames) do
        if !isstring(v) then return end
        self:StopSound(self:GetTable()[v])
    end


    -- Death sound
    if !self.DoingDeathAnim then
        self:EmitSound(self.DeathSounds)
    end

    -- Ally death reaction
    local ally = self:GetNearestAlly(600)
    local deathpos = self:GetPos()
    if IsValid(ally) && ally:Visible(self) then
        timer.Simple(0.5, function()
            if IsValid(ally)
            && ally.AllyDeathSound_Chance
            && math.random(1, ally.AllyDeathSound_Chance) == 1 then

                ally:EmitSound_Uninterupted(ally.AllyDeathSounds)

                if ally.AllyDeathSounds != "" then
                    ally:FullReset()
                    ally:Face(deathpos, ally.InternalCurrentSoundDuration)
                end
            
            end
        end)
    end



    local Gibbed = self:ShouldGib(dmg, hit_gr)


    if !Gibbed then
        self:BecomeRagdoll(dmg, hit_gr, self:GetShouldServerRagdoll())
    end


    self:SetShouldServerRagdoll(false)
    self:Remove()
end


--[[
==================================================================================================
                                           RAGDOLL
==================================================================================================
--]]


ZBaseRagdolls = {}


local RagdollBlacklist = {
    ["npc_clawscanner"] = true,
    ["npc_manhack"] = true,
    ["npc_cscanner"] = true,
    ["npc_combinegunship"] = true,
    ["npc_combinedropship"] = true,
}


function NPC:BecomeRagdoll( dmg, hit_gr, keep_corpse )
    if !self.HasDeathRagdoll then return end
    if RagdollBlacklist[self:GetClass()] then return end


	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self:GetModel())
	rag:SetPos(self:GetPos())
	rag:SetAngles(self:GetAngles())
	rag:SetSkin(self:GetSkin())
	rag:SetColor(self:GetColor())
	rag:SetMaterial(self:GetMaterial())
    rag.IsZBaseRag = true
	rag:Spawn()


    for k, v in pairs(self:GetBodyGroups()) do
        rag:SetBodygroup(v.id, self:GetBodygroup(v.id))
    end
    

    for k, v in pairs(self.SubMaterials) do
        rag:SetSubMaterial(k-1, v)
    end


	local ragPhys = rag:GetPhysicsObject()
	if !IsValid(ragPhys) then
		rag:Remove()
		return
	end


    local totMass = 0
	local physcount = rag:GetPhysicsObjectCount()
	for i = 0, physcount - 1 do
		-- Placement
		local physObj = rag:GetPhysicsObjectNum(i)
		local pos, ang = self:GetBonePosition(self:TranslatePhysBoneToBone(i))
		physObj:SetPos( pos )
		physObj:SetAngles( ang )

        -- Sum mass
        totMass = totMass+physObj:GetMass()
	end


	-- Ragdoll force
	local force = dmg:GetDamageForce()/(totMass/120)
	if dmg:IsBulletDamage() then
		ragPhys:SetVelocity(force*0.1)
	else
		ragPhys:SetVelocity(force)
	end


	-- Hook
	hook.Run("CreateEntityRagdoll", self, rag)


	-- Dissolve
	if dmg:IsDamageType(DMG_DISSOLVE) then
		rag:SetName( "base_ai_ext_rag" .. rag:EntIndex() )

		local dissolve = ents.Create("env_entity_dissolver")
		dissolve:SetKeyValue("target", rag:GetName())
		dissolve:SetKeyValue("dissolvetype", dmg:IsDamageType(DMG_SHOCK) && 2 or 0)
		dissolve:Fire("Dissolve", rag:GetName())
		dissolve:Spawn()
		rag:DeleteOnRemove(dissolve)
	end


	-- Ignite
	if self:IsOnFire() then
		rag:Ignite(math.Rand(4,8))
	end

    
    -- Handle corpse
    if !keep_corpse or dmg:IsDamageType(DMG_DISSOLVE) then
        -- Nocollide
        rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)


        -- Put in ragdoll table
        table.insert(ZBaseRagdolls, rag)


        -- Remove one ragdoll if there are too many
        if #ZBaseRagdolls > ZBCVAR.MaxRagdolls:GetInt() then

            local ragToRemove = ZBaseRagdolls[1]
            table.remove(ZBaseRagdolls, 1)
            ragToRemove:Remove()

        end
        

        -- Remove ragdoll after delay if that is active
        if ZBCVAR.RemoveRagdollTime:GetBool() then
            SafeRemoveEntityDelayed(rag, ZBCVAR.RemoveRagdollTime:GetInt())
        end


        -- Remove from table on ragdoll removed
        rag:CallOnRemove("ZBase_RemoveFromRagdollTable", function()
            table.RemoveByValue(ZBaseRagdolls, rag)
        end)

		undo.ReplaceEntity( rag, NULL )
		cleanup.ReplaceEntity( rag, NULL )
    end
end

--[[
==================================================================================================
                                           GIBS
==================================================================================================
--]]


ZBaseGibs = {}


function NPC:InternalCreateGib( model, data )
    data = data or {}


    -- Create
    local Gib = ents.Create("base_gmodentity")
    Gib:SetModel(model)
    Gib.IsZBaseGib = true
    Gib.BloodColor = self:GetBloodColor()
    Gib.CustomBloodDecals = self.CustomBloodDecals
    Gib.CustomBloodParticles = self.CustomBloodParticles
    Gib.CustomBleed = self.CustomBleed
    Gib.ShouldBleed = !data.DontBleed
    Gib.ZBaseDist = self.ZBaseDist


    -- Phys collide function
    Gib.PhysicsCollide = function(_, colData, collider)

        -- Bleed
        if Gib.ShouldBleed && colData.Speed > 200 then
            ZBaseBleed( Gib, colData.HitPos, colData.HitNormal:Angle() )
        end

    end


    -- Don't collide with stuff too much m8
    -- if !ZBCVAR.GibCollide:GetBool() then
    --     Gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    -- end
    Gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)


    -- Position
    local pos = self:WorldSpaceCenter()
    if data.offset then
        pos = pos + self:GetForward()*data.offset.x + self:GetRight()*data.offset.y + self:GetUp()*data.offset.z
    end
    Gib:SetPos(pos)
    Gib:SetAngles(self:GetAngles())


    -- Initialize
    Gib:Spawn()
    Gib:PhysicsInit(SOLID_VPHYSICS)


    -- Put in gib table
    table.insert(ZBaseGibs, Gib)


    -- Remove one gib if there are too many
    if #ZBaseGibs > ZBCVAR.MaxGibs:GetInt() then
        local gibToRemove = ZBaseGibs[1]
        table.remove(ZBaseGibs, 1)
        gibToRemove:Remove()
    end


    -- Remove gib after delay if that is active
    if ZBCVAR.RemoveGibTime:GetBool() then
        SafeRemoveEntityDelayed(Gib, ZBCVAR.RemoveGibTime:GetInt())
    end


    -- Remove from table on gib removed
    Gib:CallOnRemove("ZBase_RemoveFromGibTable", function()
        table.RemoveByValue(ZBaseGibs, Gib)
    end)


    -- Phys stuff
    local phys = Gib:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()

        if self.LastDMGINFO then
            local ForceDir = self.LastDMGINFO:GetDamageForce()/(phys:GetMass()*2)
            phys:SetVelocity( (ForceDir) + VectorRand()*(ForceDir:Length()*0.33) ) 
        end
    end


    return Gib
end


--[[
==================================================================================================
                                           DEATH ANIMATION
==================================================================================================
--]]


function NPC:DeathAnimation( dmg )
    local att = dmg:GetAttacker()
    local inf = dmg:GetInflictor()
    local dmgAmt = dmg:GetDamage()
    local dmgt = dmg:GetDamageType()
    local lastDMGinfo = {
        ['att'] = att,
        ['inf'] = inf,
        ['dmgt'] = dmgt,
    }


    self.DoingDeathAnim = true
    self:EmitSound(self.DeathSounds)
    dmg:ScaleDamage(0)


    self:PlayAnimation(table.Random(self.DeathAnimations), false, {speedMult=self.DeathAnimationSpeed, face=false, duration=self.DeathAnimationDuration})

    self:SetHealth(1)
    self:AddFlags(FL_NOTARGET)
    self:CapabilitiesClear()


    timer.Simple(self.DeathAnimationDuration/self.DeathAnimationSpeed, function()
        if !IsValid(self) then return end

        self.DeathAnim_Finished = true

        -- local newDMGinfo = DamageInfo()
        -- newDMGinfo:SetAttacker( IsValid(lastDMGinfo.att) && lastDMGinfo.att or self )
        -- newDMGinfo:SetInflictor( IsValid(lastDMGinfo.inf) && lastDMGinfo.inf or self )
        -- newDMGinfo:SetDamage( 1 )

        if self.IsZBase_SNPC then
            self:Die(newDMGinfo)
        else
            GAMEMODE:OnNPCKilled(self, IsValid(lastDMGinfo.att) && lastDMGinfo.att or self, IsValid(lastDMGinfo.inf) && lastDMGinfo.inf or self)
        end
    end)
end


--[[
==================================================================================================
                                           OTHER CRAP
==================================================================================================
--]]


function NPC:SetAllowedEScheds( escheds )
    self.ProhibitCustomEScheds = true
    for _, v in ipairs(escheds) do
        self.AllowedCustomEScheds[ZBaseESchedID(v)] = v
    end
end


function NPC:OnKilledEnt( ent )
    if ent == self:GetEnemy() then
        self:EmitSound_Uninterupted(self.KilledEnemySounds)
    end
    
    self:CustomOnKilledEnt( ent )
end


local ReloadActs = {
    [ACT_RELOAD] = true,
    [ACT_RELOAD_SHOTGUN] = true,
    [ACT_RELOAD_SHOTGUN_LOW] = true,
    [ACT_RELOAD_SMG1] = true,
    [ACT_RELOAD_SMG1_LOW] = true,
    [ACT_RELOAD_PISTOL] = true,
    [ACT_RELOAD_PISTOL_LOW] = true,
}


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


function NPC:DoNewEnemy()
    local ene = self:GetEnemy()


    if IsValid(ene) then
        -- New enemy
        -- Do alert sound
        if self.NextAlertSound < CurTime() then
            self:StopSound(self.IdleSounds)
            self:CancelConversation()


            if !self:SquadMemberIsSpeaking({"AlertSounds"}) then
                self:EmitSound_Uninterupted(self.AlertSounds)
                self.NextAlertSound = CurTime() + ZBaseRndTblRange(self.AlertSoundCooldown)
                ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown), self, "DoIdleEnemySound")
            end
        end
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


function NPC:HasCapability( cap )
    return bit.band(self:CapabilitiesGet(), cap)==cap
end


function NPC:OnOwnedEntCreated( ent )
    self:CustomOnOwnedEntCreated( ent )
end


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


function NPC:MarkEnemyAsDead( ene, time )
    if self:GetEnemy() == ene then
        self.EnemyDied = true

        timer.Create("ZBaseEnemyDied_False"..self:EntIndex(), time, 1, function()
            if !IsValid(self) then return end
            self.EnemyDied = false
        end)
    end
end


function NPC:SetModel_MaintainBounds(model)
    local mins, maxs = self:GetCollisionBounds()
    self:SetModel(model)
    self:SetCollisionBounds(mins, maxs)
    self:ResetIdealActivity(ACT_IDLE)
end