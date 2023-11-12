local NPC = ZBaseNPCs["npc_zbase"]


NPC.IsZBaseNPC = true


local VJ_Translation = {
    ["CLASS_COMBINE"] = "combine",
    ["CLASS_ZOMBIE"] = "zombie",
    ["CLASS_ANTLION"] = "antlion",
    ["CLASS_PLAYER_ALLY"] = "ally",
}

local VJ_Translation_Flipped = {
    ["combine"] = "CLASS_COMBINE",
    ["zombie"] = "CLASS_ZOMBIE",
    ["antlion"] = "CLASS_ANTLION",
    ["ally"] = "CLASS_PLAYER_ALLY",
}

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


    self:SetSaveValue("m_flFieldOfView", 1) -- Starts with no field of view


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
    

    -- Group in squads
    timer.Simple(1, function()
        if !IsValid(self) then return end
        self:ZBaseSquad()
    end)


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
    if self.CollisionBounds then
        timer.Simple(0, function()
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
        end)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:GetCurrentWeaponShootDist()
    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then return end

    local mult = hl2wepShootDistMult[wep:GetClass()] or 1

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
function NPC:OnEmitSound( data )
    local val = self:CustomOnEmitSound( data )
    local squad = self:GetKeyValues().squadname

    if isstring(val) then
        return val
    elseif val == false then
        return false
    elseif squad != "" && ZBase_DontSpeakOverThisSound then
        -- Make sure squad doesn't speak over each other
        ZBaseSpeakingSquads[squad] = true
        timer.Create("ZBaseUnmute_"..squad, SoundDuration(data.SoundName), 1, function()
            ZBaseSpeakingSquads[squad] = nil
        end) 
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnKilledEnt( ent )
    if ent == self:GetEnemy() then
        self:EmitSound_Uninterupted(self.KilledEnemySound)
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
function NPC:ZBaseSquad()
    if self.ZBaseFaction == "none" then return end


    local squadName = self.ZBaseFaction.."1"
    local i = 1
    while true do
        local squadMemberCount = 0

        for _, v in ipairs(ZBaseNPCInstances) do
            if IsValid(v) && v:GetKeyValues().squadname == squadName then
                squadMemberCount = squadMemberCount+1
            end
        end

        if squadMemberCount >= 6 then
            i = i+1
            squadName = self.ZBaseFaction..i
        else
            break
        end
    end


    self:SetKeyValue("squadname", squadName)
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

    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown), self, "DoIdleEnemySound")
    self:EmitSound_Uninterupted(self.AlertSounds)

    self.NextAlertSound = CurTime() + ZBaseRndTblRange(self.AlertSoundCooldown)
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseThink()
    local ene = self:GetEnemy()


    -- New enemy detected
    if ene != self.ZBase_LastEnemy then
        self.ZBase_LastEnemy = ene

        if self.ZBase_LastEnemy then
            -- if self:ShootTargetTooFarAway() then
            --     self:PreventFarShoot()
            -- end

            self:ZBaseAlertSound()
        end
    end
    

    -- Activity change detection
    local act = self:GetActivity()
    if act && act != self.ZBaseCurrentACT then
        self.ZBaseCurrentACT = act
        self:NewActivityDetected( self.ZBaseCurrentACT )
    end


    self:Relationships()
    self:InternalDetectDanger()

end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SetRelationship( ent, rel )
    self:AddEntityRelationship(ent, rel, 99)

    if ent.IsZBase_SNPC && ent:GetClass()==self:GetClass() && IsValid(ent.Bullseye) then
        self:AddEntityRelationship(ent.Bullseye, rel, 99)
    end

    if !ent.IsZBaseNPC && ent:IsNPC() then
        ent:AddEntityRelationship(self, rel, 99)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBase_VJFriendly( ent )
    if !ent.IsVJBaseSNPC then return false end

    for _, v in ipairs(ent.VJ_NPC_Class) do
        if VJ_Translation[v] == self.ZBaseFaction then return true end
    end

    return false
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:Relationship( ent )
    -- Me or the ent has faction neutral, like
    if self.ZBaseFaction == "neutral" or ent.ZBaseFaction=="neutral" then
        self:SetRelationship( ent, D_LI )
        return
    end

    -- My faction is none, hate everybody
    if self.ZBaseFaction == "none" then
        self:SetRelationship( ent, D_HT )
        return
    end

    -- Are their factions the same?
    if self.ZBaseFaction == ent.ZBaseFaction or self:ZBase_VJFriendly( ent ) then
        self:SetRelationship( ent, D_LI )
    else
        self:SetRelationship( ent, D_HT )
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:Relationships()

    if VJ_Translation_Flipped[self.ZBaseFaction] then
        self.VJ_NPC_Class = {VJ_Translation_Flipped[self.ZBaseFaction]}
    end

    for _, v in ipairs(ZBaseNPCInstances) do
        if !IsValid(v) then continue end
        if v != self then self:Relationship(v) end
    end

    for _, v in ipairs(ZBase_NonZBaseNPCs) do
        self:Relationship(v)
    end

    for _, v in ipairs(player.GetAll()) do
        self:Relationship(v)
    end

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
function NPC:InternalPlayAnimation( anim, duration, playbackRate, sched, forceFace, faceSpeed )
    if GetConVar("ai_disabled"):GetBool() then return end

    self.DoingPlayAnim = true


    -- Reset stuff
    self:TaskComplete()
    self:ClearGoal()
    if self.IsZBase_SNPC then
        self:ScheduleFinished()
    end
    self:ClearSchedule()
    self:StopMoving()
    self:SetMoveVelocity(Vector())


    local NPC_STATE = self:GetNPCState()
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


    -- SNPC sequence stuff
    if self.ZBaseSNPCSequence then
        self.BaseDontSetPlaybackRate = false
        self.StopPlaySeqTime = CurTime()+duration*0.8
    end


    -- Face
    if forceFace then
        self:Face(forceFace, duration, faceSpeed)
    end


    -- Timer
    self.TimeUntilStopAnimOverride = CurTime()+duration
    self.NextAnimTick = CurTime()+0.1
    local timerName = "ZBaseMeleeAnimOverride"..self:EntIndex()
    timer.Create(timerName, 0, 0, function()
        if !IsValid(self)
        or self.TimeUntilStopAnimOverride < CurTime() then

            if self.ZBaseSNPCSequence then
                self:SetNPCState(NPC_STATE)
            end

            self.DoingPlayAnim = false
            self.ZBaseSNPCSequence = nil

            if sched && IsValid(self) then
                self:ClearSchedule()
            end

            timer.Remove(timerName)

            return
        end

        if self.NextAnimTick > CurTime() then return end

        if !self.DontSetPlaybackRate then
            self:SetPlaybackRate(playbackRate or 1)
        end

        self:InternalSetAnimation(anim)
        self.NextAnimTick = CurTime()+0.1
    end)
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
	self.InternalCurrentDanger = sound.GetLoudestSoundHint(SOUND_DANGER, self:GetPos())
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

