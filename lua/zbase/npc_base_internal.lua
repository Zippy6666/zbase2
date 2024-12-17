util.AddNetworkString("ZBaseGlowEyes")
util.AddNetworkString("ZBaseClientRagdoll")


local NPC = ZBaseNPCs["npc_zbase"]
local NPCB = ZBaseNPCs["npc_zbase"].Behaviours
local IsMultiplayer = !game.SinglePlayer()
local Developer = GetConVar("developer")
local KeepCorpses = GetConVar("ai_serverragdolls")
local AIDisabled = GetConVar("ai_disabled")


--[[
==================================================================================================
                                           INIT BRUV
==================================================================================================
--]]


function NPC:PreSpawn()
    if #self.Weapons >= 1 then
        self:CapabilitiesAdd(CAP_USE_WEAPONS) -- Important! Or else some NPCs won't spawn with weapons.
    else
        self:SetKeyValue("additionalequipment", "") -- This NPC was not meant to have weapons, so remove them before spawn
    end

    self:CustomPreSpawn()
end


function NPC:ZBaseInit()

    -- Vars
    self:SetNWBool("IsZBaseNPC", true)
    self.NextPainSound = CurTime()
    self.NextAlertSound = CurTime()
    self.NPCNextSlowThink = CurTime()
    self.NPCNextDangerSound = CurTime()
    self.NextEmitHearDangerSound = CurTime()
    self.NextFlinch = CurTime()
    self.NextHealthRegen = CurTime()
    self.NextFootStepTimer = CurTime()
    self.NextRangeThreatened = CurTime()
    self.NextOutOfShootRangeSched = CurTime()
    self.EnemyVisible = false
    self.HadPreviousEnemy = false
    self.LastEnemy = NULL
    self.InternalDistanceFromGround = self.Fly_DistanceFromGround
    self.ZBLastHitGr = HITGROUP_GENERIC
    self.PlayerToFollow = NULL
    self.GuardSpot = self:GetPos()
    self.InternalCurrentVoiceSoundDuration = 0
    self:InitGrenades()
    self:InitSounds()


    -- Set specified internal variables
    for varname, var in pairs(self.EInternalVars or {}) do
        self:SetSaveValue(varname, var)
    end
    self.EInternalVars = nil



    self:InitModel()
    self:InitBounds()
    self:AddEFlags(EFL_NO_DISSOLVE)


    if ZBCVAR.NPCNocollide:GetBool() then
        self:SetCollisionGroup(COLLISION_GROUP_NPC_SCRIPTED)
    end


    self:SetMaxHealth(self.StartHealth*ZBCVAR.HPMult:GetFloat())
    self:SetHealth(self.StartHealth*ZBCVAR.HPMult:GetFloat())


    if self.BloodColor != false then
        self:SetBloodColor(self.BloodColor)
    end


    self:ZBWepSys_Init()


    -- Makes behaviour system function
    ZBaseBehaviourInit( self )


    self:CallOnRemove("ZBaseOnRemove"..self:EntIndex(), function()
        self:InternalOnRemove()
        self:OnRemove()
    end)


    if !self.DontAutoSetSquad then
        self:SetSquad("zbase")
    end


    self:Fire("wake")


    self:CustomInitialize()


    self:CONV_CallNextTick("InitNextTick")

end


function NPC:InitNextTick()
    -- Auto set npc class
    if self.IsZBase_SNPC && self:GetNPCClass() == -1 && ZBaseFactionTranslation_Flipped[ZBaseGetFaction(self)] then
        self:SetNPCClass(ZBaseFactionTranslation_Flipped[ZBaseGetFaction(self)])
    end

    self:CONV_CallNextTick("Init2Ticks")
end


function NPC:Init2Ticks()
    -- FOV and sight dist
    self.FieldOfView = math.cos( (self.SightAngle*(math.pi/180))*0.5 )
    self:SetSaveValue( "m_flFieldOfView", self.FieldOfView )
    self:SetMaxLookDistance(self.SightDistance)


    -- Phys damage scale
    self:Fire("physdamagescale", self.PhysDamageScale)


    self:InitCap()


    -- Set squad
    if !self.DontAutoSquad then
        local function SetSquad()
            if !IsValid(self) then return end
            self:SetSquad(self.ZBaseFaction)
        end

        conv.callNextTick(SetSquad)
    end
end


function NPC:InitSounds()
    -- Get names of sound variables
    self.SoundVarNames = {}
    for k, v in pairs(ZBaseNPCs[self.NPCName]) do
        if isstring(v) && #v > 0 && string.EndsWith(k, "Sounds") then
            self.SoundVarNames[v] = k
        end
    end

end


function NPC:InitModel()
    self:SetRenderMode(self.RenderMode)

    for k, v in pairs(self.SubMaterials) do
        self:SetSubMaterial(k - 1, v)
    end

    -- Set model
    if self.SpawnModel then

        -- Default collision bounds
        local mins, maxs = self:GetCollisionBounds()

        -- Set model but maintain bounds and give animation
        self:SetModel(self.SpawnModel)
        self:SetCollisionBounds(mins, maxs)
        self:ResetIdealActivity(ACT_IDLE)

    end


    -- Glowing eyes
    if self:ShouldGlowEyes() then
        self:GlowEyeInit()
    end
end



function NPC:InitGrenades()
    if ZBCVAR.GrenAltRand:GetBool() then

        -- Random grenades and alts

        if ZBCVAR.GrenCount:GetInt() == -1 then
            self.GrenCount = -1
        else
            self.GrenCount = math.random(0, ZBCVAR.GrenCount:GetInt())
        end

        if ZBCVAR.AltCount:GetInt() == -1 then
            self.AltCount = -1
        else
            self.AltCount = math.random(0, ZBCVAR.AltCount:GetInt())
        end

    else

        -- Fixed number or grenades and alts

        self.GrenCount = ZBCVAR.GrenCount:GetInt()
        self.AltCount = ZBCVAR.AltCount:GetInt()

    end
end



function NPC:InitBounds()


    if self.CollisionBounds then

        self:SetCollisionBounds( self.CollisionBounds.min, self.CollisionBounds.max )
        self:SetSurroundingBounds(self.CollisionBounds.min*1.3, self.CollisionBounds.max*1.3)

    end


    if self.HullType then
        self:SetHullType(self.HullType)
        self:SetHullSizeNormal()
    end

end


function NPC:InitCap()

    -- https://wiki.facepunch.com/gmod/Enums/CAP


    -- Squad
    self:CapabilitiesAdd(CAP_SQUAD)


    -- Weapon
    if istable(self.Weapons) && #self.Weapons >= 1 then
        self:CapabilitiesAdd(CAP_USE_WEAPONS)
        self:CapabilitiesAdd(CAP_DUCK)
        self:CapabilitiesAdd(CAP_MOVE_SHOOT)
        self:CapabilitiesAdd(CAP_USE_SHOT_REGULATOR)
    else
        self:CapabilitiesRemove(CAP_USE_WEAPONS)
    end


    -- Door/button stuff
    if self.CanOpenDoors then self:CapabilitiesAdd(CAP_OPEN_DOORS) end
    if self.CanOpenAutoDoors then self:CapabilitiesAdd(CAP_AUTO_DOORS) end
    if self.CanPushButtons then self:CapabilitiesAdd(CAP_USE) end


    -- Jump
    if self.CanJump && self:SelectWeightedSequence(ACT_JUMP) != -1 then
        self:CapabilitiesAdd(CAP_MOVE_JUMP)
    end


    -- Melee1
    if self:SelectWeightedSequence(ACT_MELEE_ATTACK1) != -1 then
        self:CapabilitiesAdd(CAP_INNATE_MELEE_ATTACK1)
    end


    -- Melee2
    if self:SelectWeightedSequence(ACT_MELEE_ATTACK2) != -1 then
        self:CapabilitiesAdd(CAP_INNATE_MELEE_ATTACK2)
    end


    -- Range1
    if self:SelectWeightedSequence(ACT_RANGE_ATTACK1) != -1 then
        self:CapabilitiesAdd(CAP_INNATE_RANGE_ATTACK1)
    end


    -- Range2
    if self:SelectWeightedSequence(ACT_RANGE_ATTACK2) != -1 then
        self:CapabilitiesAdd(CAP_INNATE_RANGE_ATTACK2)
    end


    -- Aim pose parameters
    if self:CheckHasAimPoseParam() && !self.IsZBase_SNPC then
        self:CapabilitiesAdd(CAP_AIM_GUN)
    end


    -- Has face
    if self:GetFlexNum() > 0 then
        self:CapabilitiesAdd(CAP_TURN_HEAD)
        self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    end


    -- Movement
	if self.IsZBase_SNPC && self.SNPCType == ZBASE_SNPCTYPE_FLY then

		self:SetNavType(NAV_FLY)

    elseif self:GetMoveType()==MOVETYPE_STEP then

        self:CapabilitiesAdd(CAP_MOVE_GROUND)
        self:CapabilitiesAdd(CAP_SKIP_NAV_GROUND_CHECK)

	end


    self:OnInitCap()

end


function NPC:GlowEyeInit()

    if !ZBCVAR.SvGlowingEyes:GetBool() then return end


    local Eyes = ZBaseGlowingEyes[self:GetModel()]
    if !Eyes then return end


    Eyes = table.Copy(Eyes)


    for _, eye in pairs(Eyes) do
        eye.bone = self:LookupBone(eye.bone)
    end


    -- Try applying eyes right away to players that can see it
    timer.Simple(0.5, function()
        if IsValid(self) then
            net.Start("ZBaseAddGlowEyes")
            net.WriteEntity(self)
            net.WriteTable(Eyes)
            net.SendPVS(self:GetPos())
        end
    end)


    -- Make sure all clients see the NPCs glowing eyes
    timer.Create("ApplyGlowEyes"..self:EntIndex(), 3, 0, function()

        if !IsValid(self) then
            timer.Remove("ApplyGlowEyes"..self:EntIndex())
            return
        end


        for _, ply in player.Iterator() do
            if !ply.NPCsWithGlowEyes then ply.NPCsWithGlowEyes = {} end


            if !ply.NPCsWithGlowEyes[self:EntIndex()] then
                net.Start("ZBaseAddGlowEyes")
                net.WriteEntity(self)
                net.WriteTable(Eyes)
                net.Send(ply)
            end
        end

    end)
end


--[[
==================================================================================================
                                           THINK
==================================================================================================
--]]


local StrNPCStates = {
    [NPC_STATE_NONE] = "NPC_STATE_NONE",
    [NPC_STATE_IDLE] = "NPC_STATE_IDLE",
    [NPC_STATE_SCRIPT] = "NPC_STATE_SCRIPT",
    [NPC_STATE_ALERT] = "NPC_STATE_ALERT",
    [NPC_STATE_COMBAT] = "NPC_STATE_COMBAT",
    [NPC_STATE_INVALID] = "NPC_STATE_INVALID",
    [NPC_STATE_DEAD] = "NPC_STATE_DEAD",
    [NPC_STATE_PLAYDEAD] = "NPC_STATE_PLAYDEAD",
    [NPC_STATE_PRONE] = "NPC_STATE_PRONE",
}




function NPC:ZBaseThink()

    -- Don't think if has EFL_NO_THINK_FUNCTION
    if bit.band(self:GetFlags(), EFL_NO_THINK_FUNCTION )==EFL_NO_THINK_FUNCTION then
        return
    end

    local isAIEnabled = !AIDisabled:GetBool()


    if isAIEnabled then
        local ene = self:GetEnemy()
        local sched = self:GetCurrentSchedule()
        local seq = self:GetSequence()
        local act = self:GetActivity()
        local GP = self:GetGoalPos()


        -- Enemy visible
        self.EnemyVisible = IsValid(ene) && (self:HasCondition(COND.SEE_ENEMY) or self:Visible(ene))


        -- Slow think, for performance
        if self.NPCNextSlowThink < CurTime() then
            self:DoSlowThink()
            self.NPCNextSlowThink = CurTime()+0.4
        end


        -- Enemy updated
        if ene != self.ZBase_LastEnemy then
            self:DoNewEnemy()
            self.ZBase_LastEnemy = ene
        end


        -- Activity change detection
        if act != self.ZBaseLastACT then
            self:NewActivityDetected( act )
            self.ZBaseLastACT = act
        end



        -- Sequence change detection
        if seq != self.ZBaseLastSequence then
            self:NewSequenceDetected( seq, self:GetSequenceName(seq) )
            self.ZBaseLastSequence = seq
        end



        -- Engine schedule change detection
        if sched != self.ZBaseLastESched then

            local name = ZBaseSchedDebug(self)

            self:NewSchedDetected( sched, name )

            -- These should be set after self.NewSchedDetected is called!!
            self.ZBaseLastESched = sched
            self.ZBaseLastESchedName = name

        end


        if !GP:IsZero() && self.ZBaseLastValidGoalPos != GP then
            self.ZBaseLastValidGoalPos = GP
            self:CONV_TempVar("ZBaseLastGoalPos_ValidForFallBack", true, 3 )
        end


        -- Handle danger
        if self.LastLoudestSoundHint then
            self:HandleDanger()
        end


        -- Sched and state debug
        if ZBCVAR.ShowSched:GetBool() then

            conv.overlay( "Text", function()

                return {
                    self:WorldSpaceCenter()+self:GetUp()*50,
                    "sched: "..tostring(ZBaseSchedDebug(self)), --..", state: "..StrNPCStates[self:GetNPCState()],
                    0.13,
                }

            end)

        end


        -- Base regen
        if self.HealthRegenAmount > 0 && self:Health() < self:GetMaxHealth() && self.NextHealthRegen < CurTime() then
            self:SetHealth(math.Clamp(self:Health()+self.HealthRegenAmount, 0, self:GetMaxHealth()))
            self.NextHealthRegen = CurTime()+self.HealthCooldown
        end


        -- Foot steps
        if self.NextFootStepTimer < CurTime() && self:GetNavType()==NAV_GROUND && !self.HavingConversation then
            self:FootStepTimer()
        end


        -- Move anim override
        local moveact = self:OverrideMovementAct()
        self.MovementOverrideActive = isnumber(moveact) or nil
        if self.MovementOverrideActive then
            self:SetMovementActivity(moveact)
        end

    end

    -- Weapon system
    self:ZBWepSys_Think()


    -- Stuff to make play anim work as intended
    if self.DoingPlayAnim then
        self:DoPlayAnim()
    end


    if self.DoingPlayAnim && self.IsZBase_SNPC then
        self:ExecuteWalkFrames()
    end


    -- -- Controller
    -- if self.IsZBPlyControlled then
    --     self:ControllerThink()
    -- end


    -- Custom think
    self:CustomThink()


end


function NPC:DoSlowThink()

    -- Remove squad if faction is 'none'
    if self.ZBaseFaction == "none" && self:SquadName()!="" then
        self:SetSquad("")
    end


    -- Config weapon proficiency
    if self:GetCurrentWeaponProficiency() != self.WeaponProficiency then
        self:SetCurrentWeaponProficiency(self.WeaponProficiency)
        debugoverlay.Text(self:GetPos(), "ZBASE NPC's weapon proficiency set to its 'self.WeaponProficiency'", 0.5)
    end


    self:AITick_Slow()

end


function NPC:FrameTick()

    if AIDisabled:GetBool() then return end

    if self.MoveSpeedMultiplier != 1 && !self.DoingPlayAnim && self:IsMoving() then
        self:DoMoveSpeed()
    end

    if self.DoingPlayAnim && !self.IsZBase_SNPC then
        self:ExecuteWalkFrames(0.3)
    end

    if self.ZBWepSys_AllowShoot then
        self:ZBWepSys_Shoot()
        self:InternalOnFireWeapon()
        self:OnFireWeapon()
        self.ZBWepSys_AllowShoot = false
    end

    if self.ZBase_CurrentFace_Yaw then
        self:SetIdealYawAndUpdate(self.ZBase_CurrentFace_Yaw, self.ZBase_CurrentFace_Speed or 15)
    end

end


--[[
==================================================================================================
            RELATIONSHIPS
==================================================================================================
--]]


local VJTranslation = {
    ["combine"] = "CLASS_COMBINE",
    ["zombie"] = "CLASS_ZOMBIE",
    ["antlion"] = "CLASS_ANTLION",
    ["ally"] = "CLASS_PLAYER_ALLY",
    ["xen"] = "CLASS_XEN",
    ["hecu"] = "CLASS_UNITED_STATES",
    ["blackops"] = "CLASS_BLACKOPS",
    ["racex"] = "CLASS_RACE_X",
    ["clonecop"] = "CLASS_AIDEN",
    ["snark"] = "CLASS_SNARK",
}


function NPC:DecideRelationship( myFaction, ent )
    
    local theirFaction = ent.ZBaseFaction

    -- Me or the ent has faction neutral, like
    if myFaction == "neutral" or theirFaction=="neutral" then
        self:ZBASE_SetMutualRelationship( ent, D_LI )
        return
    end


    -- My faction is none, hate everybody
    if myFaction == "none" then
        self:ZBASE_SetMutualRelationship( ent, D_HT )
        return
    end

  
    if myFaction == theirFaction or self.ZBaseFactionsExtra[theirFaction]
    or ( ent.IsZBaseNPC && ent.ZBaseFactionsExtra && ent.ZBaseFactionsExtra[myFaction] ) then
        self:ZBASE_SetMutualRelationship( ent, D_LI )
    else
        self:ZBASE_SetMutualRelationship( ent, D_HT )
    end
end
 

function NPC:UpdateRelationships()
    -- Set my VJ class
    if VJTranslation[self.ZBaseFaction] then
        self.VJ_NPC_Class = {VJTranslation[self.ZBaseFaction]}
    end

    -- Update relationships between all NPCs
    for _, v in ipairs(ZBaseRelationshipEnts) do
        if v != self then
            self:DecideRelationship(self.ZBaseFaction, v)
        end
    end

    -- Update relationships with players
    for _, v in player.Iterator() do
        self:DecideRelationship(self.ZBaseFaction, v)
    end
end

--[[
==================================================================================================
                                    PLAYER CONTROL SYSTEM

    >> TODO <<
    - Space -> fly up, otherwise jump
    - Ctrl -> fly down
    - Control priority system
    - Some way to get control help, with hints i guess
    - Just make it feel good


    >> Control Priority Sys <<
    First two controls are left and right click, the rest are gonna be 1, 2, 3, 4, 5, and so on.
    1. Use weapon
    2. Fire secondary
    3. Range attack
    4. Melee attack
    5. Grenade attack
    6. User defined attacks
    7. "Free attack"

==================================================================================================
--]]


function NPC:Controller_Move( pos )

    -- Move to pos
    local tr = util.TraceLine({
        start = self:WorldSpaceCenter(),
        endpos = pos,
        mask = MASK_SOLID,
        filter = self,
    })
    dest = tr.HitPos+tr.HitNormal*15
    self.CurrentControlDest = (self.CurrentControlDest && Lerp(0.33, self.CurrentControlDest, dest)) or dest
    self:SetLastPosition( self.CurrentControlDest )
    self:SetSchedule(SCHED_FORCED_GO)

    -- Decide movement act
    if !self.MovementOverrideActive then
        self:SetMovementActivity(self.ZBPlyController:KeyDown(IN_SPEED) && ACT_RUN or ACT_WALK)
    end

end


function NPC:Controller_ButtonDown(ply, btn)
end


function NPC:Controller_KeyPress(ply, key)
end


function NPC:ControllerThink()
    local ply = self.ZBPlyController


    local camEnt = ply:GetNWEntity("ZBCtrlSysCamEnt", NULL)
    if !IsValid(camEnt) then return end


    -- Camera tracer
    local eyeangs = ply:EyeAngles()
    local forward = eyeangs:Forward()
    local right = eyeangs:Right()
    local camViewPos = camEnt:GetPos()
    local camTrace = util.TraceLine({
        start = camViewPos,
        endpos = camViewPos+forward*100000,
        mask = MASK_VISIBLE_AND_NPCS,
        filter = self,
    })


    -- The controller "target"
    if IsValid(self.ZBControlTarget) then

        -- Position target at cursor
        self.ZBControlTarget:SetPos(camTrace.HitPos+camTrace.HitNormal*5)

        -- Be enemy to target
        if !IsValid(self:GetEnemy()) then
            self:AddEntityRelationship(self.ZBControlTarget, D_HT, 0)
            self:UpdateEnemyMemory(self.ZBControlTarget, camTrace.HitPos+camTrace.HitNormal*5)
            self:SetEnemy(self.ZBControlTarget)
            self:SetUnforgettable( self.ZBControlTarget )
        end

    end


    -- Decide move direction
    local moveDir = Vector(0, 0, 0)
    if ply:KeyDown(IN_FORWARD) then
        moveDir = moveDir + Vector(forward.x, forward.y, 0):GetNormalized()
    end
    if ply:KeyDown(IN_BACK) then
        moveDir = moveDir - Vector(forward.x, forward.y, 0):GetNormalized()
    end
    if ply:KeyDown(IN_MOVELEFT) then
        moveDir = moveDir - Vector(right.x, right.y, 0):GetNormalized()
    end
    if ply:KeyDown(IN_MOVERIGHT) then
        moveDir = moveDir + Vector(right.x, right.y, 0):GetNormalized()
    end
    moveDir = moveDir:GetNormalized() -- Normalize the accumulated movement direction


    -- Move
    self:Controller_Move(self:WorldSpaceCenter() + moveDir * self:OBBMaxs().x*20)

end


--[[
==================================================================================================
                                           WEAPON SYSTEM
==================================================================================================
--]]



function NPC:ZBWepSys_Init()

    self.ZBWepSys_Inventory = {}
    self.ZBWepSys_NextBurst = CurTime()
    self.ZBWepSys_NextShoot = CurTime()
    self.ZBWepSys_InShootDist = false
    self.ZBWepSys_LastShootCooldown = 0
    self.ZBWepSys_Stored_AIWantsToShoot = false
    self.ZBWepSys_Stored_FacingEne = false
    self.ZBWepSys_NextCheckIsFacingEne = CurTime()


    local wep = self:GetActiveWeapon()
    if IsValid(wep) && !wep:IsScripted() then
        wep:SetNoDraw(true)
    end

end


-- function NPC:ZBWepSys_HasPlayerModel()
--     local SubModels = self:GetSubModels()
--     return istable(SubModels) && SubModels[1] && SubModels[1].name && SubModels[1].name=="models/m_anm.mdl"
-- end


function NPC:ZBWepSys_Reload()

    -- On reload weapon


    local wep = self:GetActiveWeapon()


    -- Reload announce sound
    if math.random(1, self.OnReloadSound_Chance) == 1 then
        self:EmitSound_Uninterupted(self.OnReloadSounds)
    end


    -- Weapon reload sound
    if wep.IsZBaseWeapon && wep.NPCReloadSound != "" then
        wep:EmitSound(wep.NPCReloadSound)
    end


    -- Refill ammo
    timer.Create("ZBaseReloadWeapon"..self:EntIndex(), self:SequenceDuration()*0.8 / self:GetPlaybackRate(), 1, function()

        if !IsValid(self) or !IsValid(self:GetActiveWeapon()) then return end

        local CurrentStrAct = self:GetSequenceActivityName( self:GetSequence() )

        self.ZBWepSys_PrimaryAmmo = self:GetActiveWeapon().Primary.DefaultClip

        self:ClearCondition(COND.LOW_PRIMARY_AMMO)
        self:ClearCondition(COND.NO_PRIMARY_AMMO)

    end)

end


-- https://wiki.facepunch.com/gmod/Hold_Types
local HoldTypeFallback = {
    ["pistol"] = "revolver",
    ["smg"] = "ar2",
    ["grenade"] = "passive",
    ["ar2"] = "shotgun",	
    ["shotgun"] = "ar2",	
    ["rpg"] = "ar2",	
    ["physgun"] = "shotgun",	
    ["crossbow"] = "shotgun",	
    ["melee"] = "passive",	
    ["slam"] = "passive",	
    ["fist"] = "passive",	
    ["melee2"] = "passive",	
    ["knife"] = "passive",	
    ["duel"] = "pistol",	
    ["camera"] = "revolver",
    ["magic"] = "passive", 
    ["revolver"] = "pistol", 
    ["passive"] = "normal",
}
local HoldTypeActCheck = {
    ["pistol"] = ACT_RANGE_ATTACK_PISTOL,
    ["smg"] = ACT_RANGE_ATTACK_SMG1,
    ["ar2"] = ACT_RANGE_ATTACK_AR2,
    ["shotgun"] =ACT_RANGE_ATTACK_SHOTGUN,
    ["rpg"] = ACT_RANGE_ATTACK_RPG,
    ["passive"] = ACT_IDLE,
}
function NPC:ZBWepSys_SetHoldType( wep, startHoldT, isFallBack, lastFallBack, isFail )
    -- Set hold type, use fallbacks if npc does not have supporting anims
    -- Priority:
    -- Original -> Fallback -> "smg" -> "normal"


    if !isFail && (!HoldTypeActCheck[startHoldT] or self:SelectWeightedSequence(HoldTypeActCheck[startHoldT]) == -1) then

        -- Doesn't support this hold type

        if lastFallBack then

            -- "normal"
            self:ZBWepSys_SetHoldType( wep, "normal", false, false, true )
            return

        elseif isFallBack then

            -- "smg"
            self:ZBWepSys_SetHoldType( wep, "smg", false, true )
            return

        else

            -- Fallback
            self:ZBWepSys_SetHoldType( wep, HoldTypeFallback[startHoldT], true )
            return

        end


    end


    wep:SetHoldType(startHoldT)

end


function NPC:ZBWepSys_EngineCloneAttrs( zbasewep, engineClass )

    -- Some defaults
    zbasewep.IsZBaseWeapon = true
    zbasewep.PrimaryShootSound = "common/null.wav"
    zbasewep.PrimarySpread = 0
    zbasewep.PrimaryDamage = 2
    zbasewep.NPCBurstMin = 1
    zbasewep.NPCBurstMax = 1
    zbasewep.NPCFireRate = 0.2
    zbasewep.NPCFireRestTimeMin = 0.2
    zbasewep.NPCFireRestTimeMax = 1
    zbasewep.NPCBulletSpreadMult = 1
    zbasewep.NPCReloadSound = "common/null.wav"
    zbasewep.NPCShootDistanceMult = 0.75
    zbasewep.NPCHoldType =  "smg" -- https://wiki.facepunch.com/gmod/Hold_Types


    table.Merge( zbasewep.Primary, {
        DefaultClip = 30,
        Ammo = "SMG1", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
        ShellEject = "1",
        ShellType = "ShellEject", -- https://wiki.facepunch.com/gmod/Effects
        NumShots = 1,
    } )


    if ZBase_EngineWeapon_Attributes[ engineClass ] then

        for varname, var in pairs( ZBase_EngineWeapon_Attributes[ engineClass ] ) do

            if istable(var) then
                table.Merge( zbasewep[varname], var )
            else
                zbasewep[varname] = var
            end

        end

    end


    zbasewep.IsEngineClone = true
    zbasewep.EngineCloneMaxClip = zbasewep.Primary.DefaultClip
    zbasewep.EngineCloneClass = engineClass

end

local barely_visible = Color(5,5,5,5)
local engineWeapon_HasReservedReplacement = {
    weapon_zb_pistol = true,
    weapon_zb_smg1 = true,
    weapon_zb_shotgun = true,
    weapon_zb_stunstick = true,
    weapon_zb_crowbar = true,
    weapon_zb_rpg = true,
    weapon_zb_crossbow = true,
    weapon_zb_ar2 = true,
    weapon_zb_357 = true,
}
function NPC:ZBWepSys_SetActiveWeapon( class )
    if !self.ZBWepSys_Inventory[class] then return end

    local WepData = self.ZBWepSys_Inventory[class]


    if !WepData.isScripted then

        local zbwepclass = "weapon_zb_" .. string.Right(class, #class - 7)
        local Weapon
        if engineWeapon_HasReservedReplacement[zbwepclass] then
            Weapon = self:Give( zbwepclass )
        else
            Weapon = self:Give("weapon_zbase")
            Weapon:SetNWString("ZBaseNPCWorldModel", WepData.model)
        end

        self:ZBWepSys_EngineCloneAttrs( Weapon, class )

        Weapon.FromZBaseInventory = true

        self:ZBWepSys_SetHoldType( Weapon, Weapon.NPCHoldType )
        self.ZBWepSys_PrimaryAmmo = Weapon.Primary.DefaultClip
    else

        self:CONV_TimerSimple(0.1, function()
            local Weapon = self:Give( class )

            Weapon.FromZBaseInventory = true

            if Weapon.IsZBaseWeapon then
                self.ZBWepSys_PrimaryAmmo = Weapon.Primary.DefaultClip
                self:ZBWepSys_SetHoldType( Weapon, Weapon.NPCHoldType )
            end
        end)

    end
end


function NPC:ZBWepSys_StoreInInventory( wep )

    self.ZBWepSys_Inventory[wep:GetClass()] = {model=wep:GetModel(), isScripted=wep:IsScripted()}
    wep:Remove()

end


function NPC:ZBNWepSys_NewNumShots()
    local wep = self:GetActiveWeapon()

    if IsValid(wep) && wep.ZBaseGetNPCBurstSettings then
        local ShotsMin, ShotsMax = wep:ZBaseGetNPCBurstSettings()

        local RndShots = math.random(ShotsMin, ShotsMax)
        return RndShots
    end

    return 1
end


function NPC:ZBWepSys_Shoot()
    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then return end

    wep:PrimaryAttack()
    local _, _, cooldown = wep:ZBaseGetNPCBurstSettings()

    self.ZBWepSys_ShotsLeft = self.ZBWepSys_ShotsLeft && (self.ZBWepSys_ShotsLeft - 1) or self:ZBNWepSys_NewNumShots()-1

    if self.ZBWepSys_ShotsLeft <= 0 then

        local RestTimeMin, RestTimeMax = wep:GetNPCRestTimes()
        local RndRest = math.Rand(RestTimeMin, RestTimeMax)

        self.ZBWepSys_NextBurst = CurTime()+RndRest
        self.ZBWepSys_ShotsLeft = nil

        self.ZBWepSys_LastShootCooldown = RndRest
    
    else
        self.ZBWepSys_LastShootCooldown = cooldown
    end

    if self.ZBWepSys_PrimaryAmmo <= 0 then
        self:SetCondition(COND.NO_PRIMARY_AMMO)
    end

    self.ZBWepSys_NextShoot = CurTime()+cooldown
end



function NPC:ZBWepSys_TooManyAttacking( ply )
    local attacking, max = 0, ZBCVAR.MaxNPCsShootPly:GetInt()

    for k in pairs(ply.AttackingZBaseNPCs) do

        if k == self then continue end

        attacking = attacking+1

        if attacking >= max then
            ply.TooManyZBaseAttackers = true
            return true
        end

    end

    return false
end


local AIWantsToShoot_ACT_Blacklist = {
    [ACT_JUMP] = true,
    [ACT_GLIDE] = true,
    [ACT_LAND] = true,
    [ACT_SIGNAL1] = true,	
    [ACT_SIGNAL2] = true,
    [ACT_SIGNAL3] = true,
    [ACT_SIGNAL_ADVANCE] = true,
    [ACT_SIGNAL_FORWARD] = true,
    [ACT_SIGNAL_GROUP] = true,
    [ACT_SIGNAL_HALT] = true,
    [ACT_SIGNAL_LEFT] = true,
    [ACT_SIGNAL_RIGHT] = true,
    [ACT_SIGNAL_TAKECOVER] = true,
}
local AIWantsToShoot_SCHED_Blacklist = {
    [SCHED_RELOAD] = true,
    [SCHED_HIDE_AND_RELOAD] = true,
    [SCHED_SCENE_GENERIC] = true,
}
function NPC:ZBWepSys_AIWantsToShoot()
    if AIDisabled:GetBool() then return false end
    if !self.EnemyVisible or !self.ZBWepSys_InShootDist then return false end

    if AIWantsToShoot_ACT_Blacklist[self:GetActivity()] then return false end

    local sched = self:GetCurrentSchedule()
    if AIWantsToShoot_SCHED_Blacklist[sched] or (self.Patch_AIWantsToShoot_SCHED_Blacklist && self.Patch_AIWantsToShoot_SCHED_Blacklist[sched]) then
        return false
    end

    if self.ZBWepSys_NextCheckIsFacingEne < CurTime() then
        local ene = self:GetEnemy()
        self.ZBWepSys_Stored_FacingEne = self:IsFacing(ene)
        self.ZBWepSys_NextCheckIsFacingEne = CurTime()+0.7
    end

    if !self.ZBWepSys_Stored_FacingEne then
        return false
    end

    if ZBCVAR.MaxNPCsShootPly:GetBool() then
        local ene = self:GetEnemy()

        if ene:IsPlayer() && istable(ene.AttackingZBaseNPCs) && self:ZBWepSys_TooManyAttacking(ene) then
            return false
        end
    end

    return true
end


function NPC:ZBWepSys_WantsToShoot()

    return !self.DoingPlayAnim

    && self:ShouldFireWeapon()

    && self:ZBWepSys_AIWantsToShoot()

end


function NPC:ZBWepSys_CanFireWeapon()

    return self:ZBWepSys_WantsToShoot()

    && self:ZBWepSys_HasShootAnim()

    && self.ZBWepSys_NextShoot < CurTime()

    && self.ZBWepSys_NextBurst < CurTime()

    && !self.ComballAttacking

end


local strNeedles = {
    "_AIM",
    "RANGE_ATTACK",
    "ANGRY_PISTOL",
    "ANGRY_SMG1",
    "ANGRY_AR2",
    "ANGRY_RPG",
    "ANGRY_SHOTGUN",
}
function NPC:ZBWepSys_HasShootAnim()
    local seq, moveSeq = self:GetSequence(), self:GetMovementSequence()
    local strMoveAct, strAct = self:GetSequenceActivityName(seq), self:GetSequenceActivityName(moveSeq)

    for _, needle in ipairs(strNeedles) do
        if string.find(strAct, needle) or string.find(strMoveAct, needle) then
            return true
        end
    end

    local seqAct, moveSeqAct = self:GetSequenceActivity(seq), self:GetSequenceActivity(moveSeq)

    if self.ExtraFireWeaponActivities[seqAct] or self.ExtraFireWeaponActivities[moveSeqAct] then
        return true
    end

    return false
end


function NPC:ZBWepSys_GetActTransTbl()
    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then return end

    return wep.ActivityTranslateAI
end


local holdtypesDontGesture = {
    shotgun = true,
}
function NPC:ZBWepSys_ShouldUseFireGesture( isMoving )
    local wep = self:GetActiveWeapon()

    if IsValid(wep) && wep:IsWeapon() && holdtypesDontGesture[wep:GetHoldType()] then
        return false
    end

    return isMoving or !IsMultiplayer 
end


function NPC:ZBWepSys_TranslateAct(act, translateTbl)
    if AIDisabled:GetBool() then return end

    local useLegacyAnimSys = ( (self.WeaponFire_Activities or self.WeaponFire_MoveActivities) && (true or false) )
    local shouldForceShootStance = self.ForceShootStance && !useLegacyAnimSys
    if !shouldForceShootStance then return end


    local translatedAct
    local wep = self:GetActiveWeapon()
    if self.ZBWepSys_Stored_AIWantsToShoot && !self:HasCondition(COND.NO_PRIMARY_AMMO) then

        if self.ZBase_IsMoving then

            local translatedMoveAct = translateTbl[ACT_RUN_AIM] -- Run shooting
            if !self.MovementOverrideActive && self:SelectWeightedSequence(translatedMoveAct) != -1 && self:GetMovementActivity() != translatedMoveAct then
                self:SetMovementActivity(translatedMoveAct)
            end
            
        elseif !self:ZBWepSys_ShouldUseFireGesture(self.ZBase_IsMoving) then

            translatedAct =  translateTbl[ act ]
        
        else

            translatedAct =  translateTbl[ ACT_IDLE_ANGRY ]

        end

    end


    -- Don't put this activity if it has no animation for it
    if translatedAct && self:SelectWeightedSequence(translatedAct) == -1 then
        return
    end


    return translatedAct

end


local attackingResetDelay = 1 -- Time until a zbase npc is not considered to attack a player, after hurting them
function NPC:InternalOnFireWeapon()
    local wep = self:GetActiveWeapon()
    local ene = self:GetEnemy()

    if !wep:IsValid() then return end

    local actTranslateTbl = self:ZBWepSys_GetActTransTbl()


    -- Trigger firing animations
    if actTranslateTbl && actTranslateTbl[ACT_GESTURE_RANGE_ATTACK1] && self:ZBWepSys_ShouldUseFireGesture(self.ZBase_IsMoving) then
        self:PlayAnimation(actTranslateTbl[ACT_GESTURE_RANGE_ATTACK1], false, {isGesture=true})
    else
        self:ResetIdealActivity(ACT_RANGE_ATTACK1)
    end


    -- AI when shooting at players
    if ZBCVAR.MaxNPCsShootPly:GetBool() && IsValid(ene) && ene:IsPlayer() then

        local ply = ene
        ply.AttackingZBaseNPCs = ply.AttackingZBaseNPCs or {}
        ply.AttackingZBaseNPCs[self]=true


        ply:ConvTimer("RemoveFromAttackingZBaseNPCs"..self:EntIndex(), attackingResetDelay, function()
            -- No longer considered to be attacking
            if ply.AttackingZBaseNPCs[self] then
                ply.AttackingZBaseNPCs[self] = nil
            end
        end)

    end

end


local OutOfShootRangeSched = SCHED_FORCED_GO_RUN
function NPC:ZBWepSys_FireWeaponThink()

    local ene = self:GetEnemy()
    local wep = self:GetActiveWeapon()
    self.ZBWepSys_CheckDist = {within=self.MaxShootDistance*wep.NPCShootDistanceMult, away=self.MinShootDistance}


    -- In shoot dist check
    self.ZBWepSys_InShootDist = IsValid(ene) && self:ZBaseDist(ene, self.ZBWepSys_CheckDist)



    -- Force move to enemy, do so if:
    -- > Enemy is outside of the shooting range
    -- > Enemy is visible
    -- > We are not currently doing any schedule that causes the NPC to move
    if !ZBCVAR.Static:GetBool() && IsValid(ene) && !self.ZBWepSys_InShootDist && !self:BusyPlayingAnimation() && self:SeeEne()
    && !self:IsMoving() && !self:IsCurrentSchedule(OutOfShootRangeSched) && self.NextOutOfShootRangeSched < CurTime() then

        local lastpos = ene:GetPos()
        self:SetLastPosition(lastpos)
        self:SetSchedule(OutOfShootRangeSched)
        self.OutOfShootRange_LastPos = lastpos
        self.NextOutOfShootRangeSched = CurTime()+3

    end


    -- Here is where the fun begins
    if self:ZBWepSys_CanFireWeapon() then

        self.ZBWepSys_AllowShoot = self.ZBWepSys_PrimaryAmmo > 0


        -- Should shoot
        if self.ZBWepSys_AllowShoot then

            -- Make sure yaw is precise when standing and shooting
            if !self.ZBase_IsMoving && IsValid(ene) then
                self:SetIdealYawAndUpdate((ene:WorldSpaceCenter() - self:GetShootPos()):Angle().yaw, -2)
            end

        end

    end

end



function NPC:ZBWepSys_MeleeThink()

    local ene = self:GetEnemy()

    if IsValid(ene) then

        if !self.DoingPlayAnim && self:ZBaseDist(ene, {within=ZBaseRoughRadius(ene)})
        && !( ene:IsPlayer() && !ene:Alive() ) then

            self:Weapon_MeleeAnim()

            timer.Simple(self.MeleeWeaponAnimations_TimeUntilDamage, function()
                if IsValid(self) && IsValid(self:GetActiveWeapon()) && !self.Dead then
                    self:GetActiveWeapon():NPCMeleeWeaponDamage()
                end
            end)

        end


        if !self:IsMoving() then
            self:SetTarget(ene)
            self:SetSchedule(SCHED_CHASE_ENEMY)
        end

    end

end


function NPC:ZBWepSys_Think()
    local Weapon = self:GetActiveWeapon()
    local ene = self:GetEnemy()


    -- No weapon, don't do anything
    if !IsValid(Weapon) then

        -- Reset sight distance to its default
        if self:GetMaxLookDistance()!=self.SightDistance then
            self:SetMaxLookDistance(self.SightDistance)
        end

        return -- Stop here
    end


    -- Store in inventory
    local WeaponCls = Weapon:GetClass()
    if !Weapon.FromZBaseInventory then
        self:ZBWepSys_StoreInInventory( Weapon )
        self:ZBWepSys_SetActiveWeapon( WeaponCls )
        return -- Stop here
    end


    if !AIDisabled:GetBool() then


        -- Weapon think
        if Weapon.IsZBaseWeapon then
            if Weapon.NPCIsMeleeWep then
                self:ZBWepSys_MeleeThink()
            else
                self:ZBWepSys_FireWeaponThink()
            end
        end


        -- Adjust sight distance to match shoot distance when the enemy is valid
        -- Adjust sight distance back to normal when enemy is not valid
        local maxShootDist = self.ZBWepSys_CheckDist && self.ZBWepSys_CheckDist.within
        local alteredSightDist = false
        if IsValid(ene) && maxShootDist && self:GetMaxLookDistance()!=maxShootDist then

            self:SetMaxLookDistance(maxShootDist)

        elseif !IsValid(ene) && self:GetMaxLookDistance()!=self.SightDistance then
            self:SetMaxLookDistance(self.SightDistance)
        end

    end

end


--[[
==================================================================================================
                                           INTERNAL UTIL
==================================================================================================
--]]



function NPC:Face( face, duration, speed )
    if !face then return end

    local turnSpeed = speed or self:GetInternalVariable("m_fMaxYawSpeed") or 15
    local yaw

    if !isnumber(face) then
        
        if IsValid(face) then
            yaw = ( face:GetPos()-self:GetPos() ):Angle().yaw
        elseif isvector(face) then
            yaw = ( face-self:GetPos() ):Angle().yaw
        end

    else

        yaw = face
        
    end

    if duration && duration > 0 then
        self:CONV_TempVar("ZBase_CurrentFace_Yaw", yaw, duration)
        self:CONV_TempVar("ZBase_CurrentFace_Speed", turnSpeed, duration)
    else
        self:SetIdealYawAndUpdate(yaw, turnSpeed)
    end

end


-- Runs full reset and then applied SCHED_TARGET_FACE
function NPC:Face_Simple( ent_or_pos )
    if isvector(ent_or_pos) then
        local FaceEnt = ents.Create("zb_temporary_ent")
        FaceEnt.ShouldRemain = true
        FaceEnt:SetPos(ent_or_pos)
        FaceEnt:SetNoDraw(true)
        FaceEnt:Spawn()
        SafeRemoveEntityDelayed(FaceEnt, 5)
        self:SetTarget(FaceEnt)
        self:SetSchedule(SCHED_TARGET_FACE)
    elseif IsValid(ent_or_pos) then
        self:SetTarget(ent_or_pos)
        self:SetSchedule(SCHED_TARGET_FACE)
    end
end


function NPC:CheckHasAimPoseParam()

    for i=0, self:GetNumPoseParameters() - 1 do

        local name, min, max = self:GetPoseParameterName(i), self:GetPoseParameterRange( i )

        if (name == "aim_yaw" or name == "aim_pitch") && (math.abs(min)>0 or math.abs(max)>0) then
            return true
        end

    end


    return false

end


function NPC:FullReset(dontStopZBaseMove)
    self:TaskComplete()
    self:ClearGoal()
    self:ClearSchedule()
    self:StopMoving()
    self:SetMoveVelocity(vector_origin)

    if self.IsZBase_SNPC then
        self:AerialResetNav()
        self:ScheduleFinished()
    end

    if !dontStopZBaseMove then
        ZBaseMoveEnd(self)
    end
end


--[[
==================================================================================================
                                           ANIMATION
==================================================================================================
--]]


function NPC:InternalPlayAnimation(anim, duration, playbackRate, sched, forceFace, faceSpeed, loop, onFinishFunc, isGest, isTransition, noTransitions, moreArgs)
    if self.Dead or self.DoingDeathAnim then return end
    if !anim then return end



    if isGest && !self.IsZBase_SNPC && IsMultiplayer then return end -- Don't do gestures on non-scripted NPCs in multiplayer, it seems to be broken


    moreArgs = moreArgs or {}


    local extraData = {}
    extraData.isGesture = isGest -- If true, it will play the animation as a gesture
    extraData.face = forceFace -- Position or entity to constantly face, if set to false, it will face the direction it started the animation in
    extraData.speedMult = playbackRate -- Speed multiplier for the animation
    extraData.duration = duration -- The animation duration
    extraData.faceSpeed = faceSpeed -- Face turn speed
    extraData.noTransitions = moreArgs.freezeForever or noTransitions -- If true, it won't do any transition animations, will be true if this is a "freezeForver animation"
    self:OnPlayAnimation( anim, forceFace==self:GetEnemy() && forceFace!=nil, extraData )



    -- Do anim as gesture if it is one --
    -- Don't do the rest of the code after that --
    if isGest then

        -- Make sure gest is act
        local gest = isstring(anim) &&
        self:GetSequenceActivity(self:LookupSequence(anim)) or
        isnumber(anim) && anim


        -- Don't play the same gesture again, remove the old one first
        if self:IsPlayingGesture(gest) then
            self:RemoveGesture(gest)
        end


        -- Play gesture and get ID
        local id = self:AddGesture(gest)


        -- Gest options
        self:SetLayerBlendIn(id, 0.2)
        self:SetLayerBlendOut(id, 0.2)


        -- Playback rate
        if self.IsZBase_SNPC then
            self:SetLayerPlaybackRate(id, (playbackRate or 1)*0.5 )
        else
            self:SetLayerPlaybackRate(id, (playbackRate or 1) )
        end


        return -- Stop here

    end

    -- Main function --
    local function playAnim()
        -- Reset stuff
        if !moreArgs.skipReset then
            self:FullReset(moreArgs.dontStopZBaseMove)
        end


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
        if !duration then
            duration = (self:SequenceDuration(anim)*0.9)/(playbackRate or 1)
        elseif isnumber(duration) then
            duration = duration/(playbackRate or 1)
        end


        -- Anim stop timer --
        timer.Create("ZBasePlayAnim"..self:EntIndex(), duration, 1, function()
            if !IsValid(self) then return end


            if moreArgs.freezeForever != true then -- if freezeforever is enabled, never end the animation

                self:InternalStopAnimation(isTransition or noTransitions)
                self:OnAnimEnded( anim, forceFace==self:GetEnemy() && forceFace!=nil, extraData )

            end


            -- Old
            -- Used by transition animations
            if onFinishFunc then
                onFinishFunc()
            end


            if moreArgs.onFinishFunc then

                if istable(moreArgs.onFinishFuncArgs) then
                    moreArgs.onFinishFunc( unpack(moreArgs.onFinishFuncArgs) )
                else
                    moreArgs.onFinishFunc()
                end

            end


        end)



        -- Face
        if forceFace!=nil then
            self.PlayAnim_Face = forceFace
            self.PlayAnim_FaceSpeed = faceSpeed

            if forceFace == false then
                self:SetMoveYawLocked(true)
            else
                self:Face(self.PlayAnim_Face, duration, self.PlayAnim_FaceSpeed)
            end
        end


        -- Vars
        self.PlayAnim_PlayBackRate = playbackRate
        self.PlayAnim_Seq = anim
        self.DoingPlayAnim = true


    end
    
    


    -- Transition --
    local goalSeq = isstring(anim) && self:LookupSequence(anim) or self:SelectWeightedSequence(anim)
    local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )
    local transitionAct = self:GetSequenceActivity(transition)

    if !noTransitions
    && transition != -1
    && transition != goalSeq then
        -- Recursion
        self:InternalPlayAnimation( transitionAct != -1 && transitionAct or self:GetSequenceName(transition), nil, playbackRate,
        SCHED_SCENE_GENERIC, forceFace, faceSpeed, false, playAnim, false, true )
        return -- Stop here
    end

    

    -- No transition, just play the animation
    playAnim()
end


function NPC:ExecuteWalkFrames(mult)
    if mult then
        self:AutoMovement(self:GetAnimTimeInterval()*mult)
    else
        self:AutoMovement(self:GetAnimTimeInterval())
    end
end


function NPC:DoPlayAnim()

    -- Playback rate for the animation
    self:SetPlaybackRate(self.PlayAnim_PlayBackRate or 1)

    -- Stop movement
    self:SetSaveValue("m_flTimeLastMovement", 2)

end


function NPC:InternalStopAnimation(dontTransitionOut)
    if !self.DoingPlayAnim then return end


    if !dontTransitionOut then
        -- Out transition --
        local goalSeq = self:SelectWeightedSequence(ACT_IDLE)
        local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )
        local transitionAct = self:GetSequenceActivity(transition)

        if transition != -1
        && transition != goalSeq then
            -- Recursion
            self:InternalPlayAnimation( transitionAct != -1 && transitionAct or self:GetSequenceName(transition), nil, playbackRate,
            SCHED_SCENE_GENERIC, forceFace, faceSpeed, false, nil, false )
            return -- Stop here
        end
        
    end


    self:SetActivity(ACT_IDLE)
    self:ExitScriptedSequence()
    self:ClearSchedule()
    self:SetNPCState(self.PreAnimNPCState)
    self:SetMoveYawLocked(false)


    self.DoingPlayAnim = false
    self.PlayAnim_Face = nil
    self.PlayAnim_FaceSpeed = nil
    self.PlayAnim_PlayBackRate = nil
    self.PlayAnim_Seq = nil


    timer.Remove("ZBasePlayAnim"..self:EntIndex())
end


function NPC:HandleAnimEvent(event, eventTime, cycle, type, options)
    if self.Dead then return end

    self:SNPCHandleAnimEvent(event, eventTime, cycle, type, options)
end


--[[
==================================================================================================
                                           AI GENERAL
==================================================================================================
--]]


local RangeAttackActs = {
    [ACT_RANGE_ATTACK1] = true,
    [ACT_RANGE_ATTACK2] = true,
    [ACT_SPECIAL_ATTACK1] = true,
    [ACT_SPECIAL_ATTACK2] = true,
}


function NPC:AITick_Slow()
    -- Update current danger
    self:InternalDetectDanger()


    -- Reload if we cannot see enemy and we have no ammo
    if self.ZBWepSys_PrimaryAmmo && IsValid(self:GetActiveWeapon()) && self.ZBWepSys_PrimaryAmmo <= 0
    && !self.EnemyVisible then
        self:SetSchedule(SCHED_RELOAD)
        debugoverlay.Text(self:GetPos(), "Doing SCHED_RELOAD because enemy occluded")
    end


    -- Follow player that we should follow
    if self:CanPursueFollowing() then
        self:PursueFollowing()
    end


    -- Stop following if no longer allied
    if IsValid(self.PlayerToFollow) && !self:IsAlly(self.PlayerToFollow) then
        self:StopFollowingCurrentPlayer(true)
    end

    if ( self:IsCurrentSchedule(SCHED_FORCED_GO) or self:IsCurrentSchedule(SCHED_FORCED_GO_RUN) )
    && (ZBaseMoveIsActive(self, "MoveFallback") or self.OutOfShootRange_LastPos == self:GetInternalVariable("m_vecLastPosition") )
    && (self.EnemyVisible && self.ZBWepSys_InShootDist) then
        self:FullReset()
    end


    self.ZBase_IsMoving = self:IsMoving() or nil

end


function NPC:ShouldPreventSetSched( sched )

    -- Forced go will run no matter what
    if sched==SCHED_FORCED_GO then return false end
    if sched==SCHED_FORCED_GO_RUN then return false end


    -- Prevent SetSchedule from being ran if these conditions apply:
    return self.HavingConversation
    or self.DoingPlayAnim

end


function NPC:OnKilledEnt( ent )
    if ent == self:GetEnemy() then
        self:EmitSound_Uninterupted(self.KilledEnemySounds)
    end

    self:CustomOnKilledEnt( ent )
end


function NPC:RangeThreatened( threat )
    if !self:HasEnemyMemory(threat) then return end
    if self.NextRangeThreatened > CurTime() then return end
    if self.Dead or self.DoingDeathAnim then return end


    self:CONV_CallNextTick("OnRangeThreatened", threat)


    self.NextRangeThreatened = CurTime()+3
end


function NPC:NewActivityDetected( act )

    local ene = self:GetEnemy()



    if IsValid(ene) && RangeAttackActs[act] && ene.IsZBaseNPC then
        ene:RangeThreatened(self)
    end



    self:CustomNewActivityDetected( act )

end


function NPC:NewSequenceDetected( seq, seqName )

    if self:GetActiveWeapon().IsZBaseWeapon
    && string.find(self:GetSequenceActivityName(seq), "RELOAD") != nil
    && self:IsCurrentSchedule(SCHED_RELOAD) then

        self:ZBWepSys_Reload()

    end

    self:CustomNewSequenceDetected( seq, seqName )

end


function NPC:NewSchedDetected( sched, schedName )

    local assumedFailSched =

    ( string.find(schedName, "FAIL")
        or (self.Patch_IsFailSched && self:Patch_IsFailSched(sched))
    )

    && !( self.IsZBase_SNPC && self.SNPCType == ZBASE_SNPCTYPE_FLY ) -- Don't detect failures for flying mfs


    if assumedFailSched then
        if Developer:GetInt() >= 2 then
            MsgN("Had schedule failure (", schedName, ")")
        end

        self:OnDetectSchedFail()
    end

    self:CustomNewSchedDetected(sched, self.ZBaseLastESched or -1)

end


function NPC:OnDetectSchedFail()
    if !ZBCVAR.FallbackNav:GetBool() then return end
    if ZBaseMoveIsActive(self, "MoveFallback") then return end

    if Developer:GetInt() >= 2 then
        MsgN("Schedule failed, last seen sched was: "..(self.ZBaseLastESchedName or "none"))
    end

    -- If self.ZBaseLastESched == whatever then

    local fallback_MovePos
    local npcState = self:GetNPCState()
    local ene = self:GetEnemy()

    if self.ZBaseLastValidGoalPos && self.ZBaseLastGoalPos_ValidForFallBack then
        fallback_MovePos = self.ZBaseLastValidGoalPos
    else
        if IsValid(ene) then
            local eneLastPos = self:GetEnemyLastSeenPos()
            fallback_MovePos = ( eneLastPos && !eneLastPos:IsZero() && eneLastPos ) or (ene:GetPos())
        else
            -- Not combat or alert, move randomly
            fallback_MovePos = self:WorldSpaceCenter() + Vector(math.random(-300, 300), math.random(-300, 300), 0)
        end
    end

    ZBaseMove(self, fallback_MovePos, "MoveFallback")
end


function NPC:DoNewEnemy()

    local ene = self:GetEnemy()


    if IsValid(ene) then
        -- New enemy
        -- Do alert sound

        ZBaseMoveEnd(self, "MoveFallback")

        if self.NextAlertSound < CurTime() then

            self:StopSound(self.IdleSounds)
            self:CancelConversation()


            if !self:NearbyAllySpeaking({"AlertSounds"}) then
                self:EmitSound_Uninterupted(self.AlertSounds)
                self.NextAlertSound = CurTime() + ZBaseRndTblRange(self.AlertSoundCooldown)
                ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown), self, "DoIdleEnemySound")
            end

        end
    end


    -- Lost enemy
    if self.LostEnemySounds != ""
    && !IsValid(ene)
    && self.HadPreviousEnemy
    && !self.EnemyDied
    then
 
        -- Check if other allies also lost track of the enemy before saying it out loud
        local shouldDoLostEneSoundFinal = true
        local hasAllies = false
        for _, ally in ipairs(self:GetNearbyAlliesOptimized(1000)) do

            hasAllies = true

            local allyEne = ally:GetEnemy()
  
            -- This ally still has this enemy, so it still isn't lost
            if !ally.TooEarlyThoughtEnemyWasLost && IsValid(allyEne) && allyEne == self.LastEnemy then
                conv.devPrint(self:EntIndex(), " thinks enemy is lost, "..ally:EntIndex().. " knows that it isn't.")
                shouldDoLostEneSoundFinal = false 
                break
            end

        end
        shouldDoLostEneSoundFinal = shouldDoLostEneSoundFinal && hasAllies


        if shouldDoLostEneSoundFinal then
            conv.devPrint(self:EntIndex(), " concludes enemy is lost.")
            self:EmitSound_Uninterupted(self.LostEnemySounds)
        end

    end


    self:EnemyStatus(ene, self.HadPreviousEnemy)
    self.HadPreviousEnemy = ene && true or false
    self.LastEnemy = ene or self.LastEnemy

end


function NPC:AI_OnHurt( dmg, MoreThan0Damage )
    local attacker = dmg:GetAttacker()

    if self.HavingConversation then
        self:CancelConversation()
    end

    -- Pain sound
    if self.NextPainSound < CurTime() && MoreThan0Damage then
        self:EmitSound(self.PainSounds)
        self.NextPainSound = CurTime()+ZBaseRndTblRange( self.PainSoundCooldown )
    end

    -- Flinch
    if !table.IsEmpty(self.FlinchAnimations) && math.random(1, self.FlinchChance) == 1 && self.NextFlinch < CurTime() then
        local anim = self:GetFlinchAnimation(dmg, self.ZBLastHitGr)

        if self:OnFlinch(dmg, self.ZBLastHitGr, anim) != false then
            self:FlinchAnimation(anim)
            self.NextFlinch = CurTime()+ZBaseRndTblRange(self.FlinchCooldown)
        end
    end

    -- Panicked reload if out of ammo
    if ( IsValid(self:GetActiveWeapon()) && self.ZBWepSys_PrimaryAmmo <= 0 ) then
        
        self:SetSchedule(SCHED_RELOAD)

    elseif !self.DontTakeCoverOnHurt then

        -- Take cover stuff

        local hasEne = IsValid(self:GetEnemy())

        if !hasEne && !self:IsCurrentSchedule(SCHED_TAKE_COVER_FROM_ORIGIN)
        && self:Disposition(attacker) != D_LI then

            -- Become alert and try to hide when hurt by unknown source
            self:SetNPCState(NPC_STATE_ALERT)
            self:SetSchedule(SCHED_TAKE_COVER_FROM_ORIGIN)
            self:CONV_TempVar("DontTakeCoverOnHurt", true, math.Rand(6, 8))

        elseif hasEne && IsValid(self:GetActiveWeapon()) then

            self:SetSchedule(SCHED_TAKE_COVER_FROM_ENEMY)
            self:CONV_TempVar("DontTakeCoverOnHurt", true, math.Rand(6, 8))

        end

    end
end


function NPC:OnOwnedEntCreated( ent )
    self:CustomOnOwnedEntCreated( ent )
end


function NPC:MarkEnemyAsDead( ene, time )
    self:CONV_TempVar("EnemyDied", true, time)
end


function NPC:DoMoveSpeed()
    if !self.DoingPlayAnim then
        self:SetPlaybackRate(self.MoveSpeedMultiplier)
    end

    self:SetSaveValue("m_flTimeLastMovement", -0.1*self.MoveSpeedMultiplier)
end


function NPC:InternalOnReactToSound(ent, pos, loudness)
    if self:GetNPCState()==NPC_STATE_ALERT then

        self:CancelConversation()

        if !self:NearbyAllySpeaking({"HearDangerSounds"}) && self.NextEmitHearDangerSound < CurTime() then
            self:EmitSound_Uninterupted(self.HearDangerSounds)
            self.NextEmitHearDangerSound = CurTime()+math.Rand(3, 6)
        end

    end


    self:OnReactToSound(ent, pos, loudness)
end


function NPC:OnBaseSetRel( ent, rel )
    return self:CustomOnBaseSetRel(ent, rel, priority)
end


--[[
==================================================================================================
                                           STATIC/STATIONARY MODE
==================================================================================================
--]]


local ThorElg = 500

NPCB.Static = {
}

function NPCB.Static:ShouldDoBehaviour( self )
    return ZBCVAR.Static:GetBool()
end

function NPCB.Static:Delay(self)
end

function NPCB.Static:Run( self )

    -- Guard spot too far away, go back
    if self:ZBaseDist(self.GuardSpot, {away=ThorElg}) then

        local newDest = self.GuardSpot+Vector(math.random(-ThorElg*0.5, ThorElg*0.5), math.random(-ThorElg*0.5, ThorElg*0.5))

        self:FullReset()
        self:SetLastPosition(newDest)
        self:SetSchedule( (self:GetNPCState()==NPC_STATE_COMBAT && SCHED_FORCED_GO_RUN) or SCHED_FORCED_GO )

        conv.overlay("Sphere", function()
            return {newDest, 25, 3, Color(0, 0, 255)}
        end)

        conv.overlay("Text", function()
            return {self:WorldSpaceCenter(), "Returning to guard pos.", 3}
        end)

    end


    ZBaseDelayBehaviour(2)
end


--[[
==================================================================================================
                                           AI FOLLOW PLAYER
==================================================================================================
--]]


local ignorePly = GetConVar("ai_ignoreplayers")
local followPly = GetConVar("zbase_followplayers")
function NPC:CanStartFollowPlayers()
    return self.CanFollowPlayers && !ignorePly:GetBool() && !IsValid(self.PlayerToFollow)
    && self.SNPCType != ZBASE_SNPCTYPE_STATIONARY && followPly:GetBool()
end


function NPC:CurrentlyFollowingPlayer()
    return IsValid(self.PlayerToFollow) && self:IsCurrentSchedule(SCHED_FORCED_GO_RUN)
end


function NPC:StartFollowingPlayer( ply )
    if !self:IsAlly(ply) then return end
    if self:ZBaseDist(ply, {away=200}) then return end


    self:FullReset()


    self.PlayerToFollow = ply


    net.Start("ZBaseSetFollowHalo")
    net.WriteEntity(self)
    net.WriteString(self.Name)
    net.Send(self.PlayerToFollow)

    self:SetTarget(ply)
    self:SetSchedule(SCHED_TARGET_FACE)

    self:EmitSound_Uninterupted(self.FollowPlayerSounds)


    self:FollowPlayerStatus(self.PlayerToFollow)
end


function NPC:StopFollowingCurrentPlayer( noSound )
    local ply = self.PlayerToFollow

    if IsValid(ply) && self:ZBaseDist(ply, {away=200}) then
        return
    end

    net.Start("ZBaseRemoveFollowHalo")
    net.WriteEntity(self)
    net.WriteString(self.Name)
    net.Send(ply)

    self.PlayerToFollow = NULL

    if !noSound then
        self:EmitSound_Uninterupted(self.UnfollowPlayerSounds)
    end

    self:FollowPlayerStatus(NULL)
end


function NPC:CanPursueFollowing()
    return IsValid(self.PlayerToFollow) && self:ZBaseDist(self.PlayerToFollow, {away=200}) && !self:ZBWepSys_CanFireWeapon()
    && !self:IsCurrentSchedule(SCHED_TARGET_CHASE)
    && !self:IsCurrentSchedule(SCHED_FORCED_GO)
    && !self:IsCurrentSchedule(SCHED_FORCED_GO_RUN)
end

function NPC:PursueFollowing()
    self:SetTarget(self.PlayerToFollow)
    self:SetSchedule(SCHED_TARGET_CHASE)
end


--[[
==================================================================================================
                                           AI PATROL
==================================================================================================
--]]


NPCB.Patrol = {
    MustNotHaveEnemy = true,
}


local PatrolCvar = GetConVar("zbase_patrol")
local SchedsToReplaceWithPatrol = {
    [SCHED_IDLE_STAND] = true,
    [SCHED_ALERT_STAND] = true,
    [SCHED_ALERT_FACE] = true,
    [SCHED_ALERT_WALK] = true,
}


function NPCB.Patrol:ShouldDoBehaviour( self )
    return PatrolCvar:GetBool() && self.CanPatrol && SchedsToReplaceWithPatrol[self:GetCurrentSchedule()]
    && self:GetMoveType() == MOVETYPE_STEP
end


function NPCB.Patrol:Delay(self)
    if self.ZBase_IsMoving or self.DoingPlayAnim then
        return math.random(8, 15)
    end
end


function NPCB.Patrol:Run( self )
    local IsAlert = self:GetNPCState() == NPC_STATE_ALERT


    if IsValid(self.PlayerToFollow) then

        self:SetSchedule(SCHED_ALERT_SCAN)

        conv.overlay("Text", function()
            return {self:GetPos(), "SCHED_ALERT_SCAN as patrol.", 2}
        end)

    elseif IsAlert then

        self:SetSchedule(SCHED_PATROL_RUN)

        conv.overlay("Text", function()
            return {self:GetPos(), "Alert patrol.", 2}
        end)

    else

        self:SetSchedule(SCHED_PATROL_WALK)

        conv.overlay("Text", function()
            return {self:GetPos(), "Patrol.", 2}
        end)

    end


    ZBaseDelayBehaviour(IsAlert && math.random(3, 6) or math.random(8, 15))
end


--[[
==================================================================================================
                                           AI CALL FOR HELP
==================================================================================================
--]]

    // Call allies outside of squad for help

NPCB.FactionCallForHelp = {
    MustHaveEnemy = true,
}


function NPCB.FactionCallForHelp:ShouldDoBehaviour( self )

    if !ZBCVAR.CallForHelp:GetBool() then
        return false
    end

    local hasCallForHelp = self.AlertAllies or self.CallForHelp
    local callForHelpDist = self.AlertAlliesDistance or self.CallForHelpDistance

    if !hasCallForHelp then
        return false
    end

    return self.ZBaseFaction != "none" && self.ZBaseFaction != "neutral"

end


function NPCB.FactionCallForHelp:Run( self )
    local callForHelpDist = self.AlertAlliesDistance or self.CallForHelpDistance
    local ally = self:GetNearestAlly(callForHelpDist)

    if IsValid(ally) then
        local ene = self:GetEnemy()
        local canBeCalledForHelp = ally.CanBeAlertedByAlly or ally.CanBeCalledForHelp

        if IsValid(ally) && ally:IsNPC() && !IsValid(ally:GetEnemy()) && !ally:HasEnemyEluded(ene) && self:GetSquad()!=ally:GetSquad() then

            ally:UpdateEnemyMemory(ene, self:GetEnemyLastSeenPos())
            ally:AlertSound()


            if self.OnCallForHelp then
                self:OnCallForHelp(ally) -- Backwards compatability
            elseif self.OnAlertAllies then
                self:OnAlertAllies(ally)
            end


            conv.overlay("Text", function()
                local pos = self:GetPos()+self:GetUp()*25
                return {pos, "Was called by ally.", 2}
            end)

        end
    end

    ZBaseDelayBehaviour(math.Rand(2, 3.5))
end


--[[
==================================================================================================
                                           AI SECONDARY FIRE
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


    self.ComballAttacking = true


    timer.Simple(0.75, function()
        if !(IsValid(self) && IsValid(wep) && IsValid(enemy)) then return end
        if self.Dead or self:GetNPCState() == NPC_STATE_DEAD then return end


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
            && self:GetNPCState() != NPC_STATE_DEAD && !self.Dead then
                for _, ball in ipairs(ents.FindInSphere(self:GetPos(), 100)) do
                    if ball:GetClass() == "prop_combine_ball" then

                        ball:SetOwner(self)
                        ball.ZBaseComballOwner = self
                        ball.IsZBaseDMGInfl = true

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


        sound.Play("Weapon_IRifle.Single", self:GetPos())


        self.ComballAttacking = false

    end)


    if IsValid(enemy) && enemy.IsZBaseNPC then
        enemy:RangeThreatened( self )
    end


end


function SecondaryFireWeapons.weapon_smg1:Func( self, wep, enemy )

    local startPos = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos
    local grenade = ents.Create("grenade_ar2")
    grenade:SetOwner(self)
    grenade:SetPos(startPos)
    grenade.IsZBaseDMGInfl = true
    grenade:Spawn()
    grenade:SetVelocity((enemy:GetPos() - startPos):GetNormalized()*1250 + Vector(0,0,200))
    grenade:SetLocalAngularVelocity(AngleRand())

    sound.Play("Weapon_AR2.Double", self:GetPos())

    local effectdata = EffectData()
    effectdata:SetFlags(7)
    effectdata:SetEntity(wep)
    util.Effect( "MuzzleFlash", effectdata, true, true )

    if IsValid(enemy) && enemy.IsZBaseNPC then
        enemy:RangeThreatened( self )
    end

end


function NPCB.SecondaryFire:ShouldDoBehaviour( self )

    if !self.CanSecondaryAttack then return false end
    if self.DoingPlayAnim then return false end


    local wep = self:GetActiveWeapon()


    local wepTbl = wep.EngineCloneClass && SecondaryFireWeapons[ wep.EngineCloneClass ]
    if !wepTbl then return false end


    if !self:ZBWepSys_WantsToShoot() then return end


    return (self.AltCount > 0 or self.AltCount == -1)
    && self:ZBaseDist( self:GetEnemy(), {within=wepTbl.dist, away=wepTbl.mindist} )

end


function NPCB.SecondaryFire:Delay( self )

    if math.random(1, 2) == 1 then
        return math.Rand(4, 6)
    end

end


function NPCB.SecondaryFire:Run( self )

    local enemy = self:GetEnemy()
    local wep = self:GetActiveWeapon()

    SecondaryFireWeapons[ wep.EngineCloneClass ]:Func( self, wep, enemy )

    if self.AltCount > 0 && self.AltCount != -1 then
        self.AltCount = self.AltCount - 1
    end

    ZBaseDelayBehaviour(math.Rand(4, 8))

end


--[[
==================================================================================================
                                           AI MELEE ATTACK
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
    or ent:IsNextBot() -- Bextbit
end


function NPC:InternalMeleeAttackDamage(dmgData)
    local mypos = self:WorldSpaceCenter()
    local soundEmitted = false
    local soundPropEmitted = false
    local hurtEnts = {}


    for _, ent in ipairs(ents.FindInSphere(mypos, dmgData.dist)) do
        local disp = self:Disposition(ent)
        local bullseyeDisp = ent.IsZBase_SNPC && IsValid(ent.Bullseye) && self:Disposition(ent.Bullseye)
        local entpos = ent:WorldSpaceCenter()
        local entIsUndamagable = (ent:Health()==0 && ent:GetMaxHealth()==0)
        local forcevec = self:GetForward()*100
        local isFriendlyTowardsEnt = (disp==D_LI or disp==D_NU) && bullseyeDisp!=D_HT && bullseyeDisp!=D_FR
        local isProp = (disp == D_NU or entIsUndamagable)


        if ent == self then continue end
        if ent.GetNPCState && ent:GetNPCState() == NPC_STATE_DEAD then continue end
        if (!dmgData.affectProps && disp == D_NU && self:GetEnemy() != ent) then continue end -- Don't affect neutrals if we shouldn't affect props
        if !self:CanBeMeleed(ent) then continue end


        -- Angle check
        if dmgData.ang != 360 then
            local yawDiff = math.abs( self:WorldToLocalAngles( (entpos-mypos):Angle() ).Yaw )*2
            if dmgData.ang < yawDiff then continue end
        end


        -- Not visible
        if !self:Visible(ent) then continue end


        -- Calculate force
        local tbl = self:MeleeDamageForce(dmgData)
        if tbl then
            forcevec = self:GetForward()*(tbl.forward or 0) + self:GetUp()*(tbl.up or 0) + self:GetRight()*(tbl.right or 0)
            if tbl.randomness then
                forcevec = forcevec + VectorRand()*tbl.randomness
            end
        end


        -- Push
        if !isFriendlyTowardsEnt or isProp then
            local phys = ent:GetPhysicsObject()

            if IsValid(phys) then
                phys:SetVelocity(forcevec)
            end

            ent:SetVelocity(forcevec)
        end


        -- Damage
        if !entIsUndamagable && !isFriendlyTowardsEnt then
            local dmg = DamageInfo()
            dmg:SetAttacker(self)
            dmg:SetInflictor(self)
            dmg:SetDamage(ZBaseRndTblRange(dmgData.amt))
            dmg:SetDamageType(dmgData.type)
            dmg:SetDamageForce(forcevec)
            dmg:SetDamagePosition(ent:WorldSpaceAABB())
            ent:TakeDamageInfo(dmg)
        end


        -- Sound
        if isProp && !soundPropEmitted then
            sound.Play(dmgData.hitSoundProps, entpos)
            soundPropEmitted = true
        elseif !soundEmitted && disp != D_NU then
            ent:EmitSound(dmgData.hitSound)
            soundEmitted = true
        end

        table.insert(hurtEnts, ent)
    end

    self:OnMeleeAttackDamage(hurtEnts)
    return hurtEnts
end


function NPCB.MeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end
    if self:GetActiveWeapon().NPCIsMeleeWep then return false end


    local ene = self:GetEnemy()
    if !self.MeleeAttackFaceEnemy && !self:IsFacing(ene) then return false end
    if ene:IsPlayer() && !ene:Alive() then return end


    if self:PreventMeleeAttack() then return false end


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
                                           AI RANGE ATTACK
==================================================================================================
--]]


NPCB.RangeAttack = {
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
    if !self.RangeAttackSuppressEnemy && !seeEnemy then return false end


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
    local ene = self:GetEnemy()


    if IsValid(ene) && ene.IsZBaseNPC then
        ene:RangeThreatened( self )
    end


    self:RangeAttack()


    ZBaseDelayBehaviour(self:SequenceDuration() + 0.25 + ZBaseRndTblRange(self.RangeAttackCooldown))
end


--[[
==================================================================================================
                                           AI GRENADE
==================================================================================================
--]]


NPCB.Grenade = {
    MustHaveEnemy = true,
}


function NPCB.Grenade:ShouldDoBehaviour( self )

    local lastSeenPos = self:GetEnemyLastSeenPos()

    return self.BaseGrenadeAttack
    && !self.DoingPlayAnim
    && (self.GrenCount == -1 or self.GrenCount > 0)
    && !table.IsEmpty(self.GrenadeAttackAnimations)
    && self:GetNPCState()==NPC_STATE_COMBAT
    && !lastSeenPos:IsZero()
    && self:ZBaseDist(lastSeenPos, {away=400, within=1500})
    && self:VisibleVec(lastSeenPos)
    && !(self.Patch_PreventGrenade && self:Patch_PreventGrenade())

end


function NPCB.Grenade:Delay( self )

    local should_throw_visible = self.EnemyVisible && math.random(1, self.ThrowGrenadeChance_Visible)==1
    local should_throw_occluded = !self.EnemyVisible && math.random(1, self.ThrowGrenadeChance_Occluded)==1

    if !should_throw_visible && !should_throw_occluded then
        return ZBaseRndTblRange(self.GrenadeCoolDown)
    end

    local lastSeenPos = self:GetEnemyLastSeenPos()
    if !self:IsFacing(lastSeenPos, 45) then
        return ZBaseRndTblRange(self.GrenadeCoolDown)*0.5
    end

end


function NPCB.Grenade:Run( self )

    self:ThrowGrenade()
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.GrenadeCoolDown))

end


--[[
==================================================================================================
                                           AI DANGER DETECTION
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
    if self.LastLoudestSoundHint.type != SOUND_DANGER then return end


    local dangerOwn = self.LastLoudestSoundHint.owner
    local isGrenade = IsValid(dangerOwn) && (dangerOwn.IsZBaseGrenade or dangerOwn:GetClass() == "npc_grenade_frag")


    -- Sound
    if self.NPCNextDangerSound < CurTime() then
        self:EmitSound_Uninterupted(isGrenade && self.SeeGrenadeSounds!="" && self.SeeGrenadeSounds or self.SeeDangerSounds)
        self.NPCNextDangerSound = CurTime()+math.Rand(2, 4)
    end


    if isGrenade && self:GetNPCState()==NPC_STATE_IDLE then
        self:SetNPCState(NPC_STATE_ALERT)
    end


    if (Class_ShouldRunRandomOnDanger[self:Classify()] or self.ForceAvoidDanger) && self:GetCurrentSchedule() <= 88 && !self:IsCurrentSchedule(SCHED_RUN_RANDOM) then
        self:SetSchedule(SCHED_RUN_RANDOM)
    end


    self:CancelConversation()
end


function NPC:InDanger()
    return self.LastLoudestSoundHint && self.LastLoudestSoundHint.type == SOUND_DANGER
end


function NPC:InternalDetectDanger()
	local hint = sound.GetLoudestSoundHint(SOUND_DANGER, self:GetPos())
    local IsDangerHint = (istable(hint) && hint.type==SOUND_DANGER)

    if !hint or IsDangerHint then
        if IsDangerHint then self:OnDangerDetected(hint) end
        self.LastLoudestSoundHint = hint
    end
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
end





function NPC:OnEmitSound( data )
    local altered
    local sndVarName = (data.OriginalSoundName && self.SoundVarNames[data.OriginalSoundName]) or nil
    local isVoiceSound = isnumber(data.SentenceIndex) or data.Channel == CHAN_VOICE
    local currentlySpeakingImportant = isstring(self.IsSpeaking_SoundVar)
    local goingToZBaseSpeak = (sndVarName && isVoiceSound) or false


    -- Sound is NULL
    if data.SoundName == "common/null.wav" then
        return false
    end


    -- Don't play engine voice sounds when dying
    if self.DoingDeathAnim && isVoiceSound && !IsEmitSoundCall then
        return false
    end


    -- Did not play sound because I was already playing important voice sound
    if (isVoiceSound && sndVarName!="PainSounds" && sndVarName!="DeathSounds") && currentlySpeakingImportant then
        return false
    end


    -- Don't speak over allies intentionally
    if goingToZBaseSpeak && self:NearbyAllySpeaking() then
        return false
    end


    -- Avoid voice line repetition
    if goingToZBaseSpeak then

        local sndTbl = sound.GetProperties(data.OriginalSoundName)
        if sndTbl && istable(sndTbl.sound) && #sndTbl.sound > 1 then

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

        end

    end



    -- Internal sound duration
    self.InternalCurrentSoundDuration = ZBaseSoundDuration(data.SoundName)



    -- Custom on emit sound, allow the user to replace what sound to play
    local value = self:BeforeEmitSound( data, sndVarName )
    if isstring(value) then

        -- Emit new sound
        if ZBase_DontSpeakOverThisSound then
            self:EmitSound_Uninterupted(value)
        else
            self:EmitSound(value)
        end

        -- Stop this sound
        return false

    elseif value == false then

        -- Prevent sound
        return false

    end


    if isVoiceSound then
        self.IsSpeaking = true
        self.IsSpeaking_SoundVar = sndVarName
        self.InternalCurrentVoiceSoundDuration = ZBaseSoundDuration(data.SoundName)

        timer.Create("ZBaseStopSpeaking"..self:EntIndex(), self.InternalCurrentVoiceSoundDuration+0.1, 1, function()
            self.IsSpeaking = false
            self.IsSpeaking_SoundVar = nil
        end)
    end

    
    -- Custom on sound emitted
    self:CustomOnSoundEmitted( data, self.InternalCurrentSoundDuration, sndVarName )


    return altered
end


function NPC:NearbyAllySpeaking( soundList )
    if self.Dead or self.DoingDeathAnim then return false end -- Otherwise they might not do their death sounds


    for _, ally in ipairs(self:GetNearbyAllies(850)) do
        if ally:IsPlayer() then continue end
        if !ally.IsSpeaking then continue end


        if !istable(soundList) then

            return true

        elseif istable(soundList) then
            for _, v in ipairs(soundList) do
                if v == ally.IsSpeaking_SoundVar then
                    return true
                end
            end
        end
    end


    return false
end


--[[
==================================================================================================
                                           FOOTSTEPS
==================================================================================================
--]]


function NPC:EngineFootStep()
    self:OnEngineFootStep()
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
    if self:NearbyAllySpeaking({"IdleSounds"}) or math.random(1, self.IdleSound_Chance)==1 then
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
    if self:NearbyAllySpeaking() then
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
    if self:IsCurrentSchedule(SCHED_FORCED_GO) or self:IsCurrentSchedule(SCHED_FORCED_GO_RUN)
    or self:IsCurrentSchedule(SCHED_SCENE_GENERIC) then return false end

    return true
end


function NPCB.Dialogue:Delay( self )
    if self:NearbyAllySpeaking() or self.HavingConversation or math.random(1, self.IdleSound_Chance)==1 then
        return ZBaseRndTblRange(self.IdleSoundCooldown)
    end
end


function NPCB.Dialogue:Run( self )

    -- Nearest ally
    local ally = self:GetNearestAlly(350)
    if !IsValid(ally) then return end


    local DialogueExtraCoolDown = 0



    if ally.IsZBaseNPC -- Ally is a ZBase NPC
    && !IsValid(ally:GetEnemy()) -- Ally has no enemy
    && !ally.HavingConversation -- Ally is not having conversation currently
    && self:Visible(ally) -- Ally visible from self
    && ally.Dialogue_Answer_Sounds != "" -- Ally can respond

    then

        -- Question
        self:EmitSound_Uninterupted(self.Dialogue_Question_Sounds)


        if !IsValid(self.PlayerToFollow) then
            -- Face the recipient
            self:FullReset()
            self:SetTarget(ally)
            self:SetSchedule(SCHED_TARGET_FACE)
        
            -- Recipient faces me
            ally:FullReset()
            ally:SetTarget(self)
            ally:SetSchedule(SCHED_TARGET_FACE)
        end

        -- Set vars for me
        self.HavingConversation = true
        self.DialogueMate = ally

        -- Set vars for recipient
        ally.HavingConversation = true
        ally.DialogueMate = self


        local sndDurQuestion = self.InternalCurrentVoiceSoundDuration


        timer.Create("DialogueAnswerTimer"..ally:EntIndex(), sndDurQuestion+0.4, 1, function()

            if IsValid(ally) then

                -- Recipient answers me
                ally:EmitSound(ally.Dialogue_Answer_Sounds)


                local sndDurAns = ally.InternalCurrentVoiceSoundDuration

                -- Reset recipient from dialogue state
                timer.Simple(sndDurAns, function()
                    if !IsValid(ally) then return end
                    ally:CancelConversation()
                end)

                -- Not sure if this does anything of value
                ZBaseDelayBehaviour( ZBaseRndTblRange(ally.IdleSoundCooldown), ally, "Dialogue" )


                -- Reset from dialogue state
                timer.Simple(sndDurAns, function()
                    if !IsValid(self) then return end
                    self:CancelConversation()
                end)

            end

        end)


        DialogueExtraCoolDown = sndDurQuestion+0.2


    -- Ally is player:
    elseif ally:IsPlayer() && !ignorePly:GetBool() then
        self:EmitSound_Uninterupted(self.Dialogue_Question_Sounds)
        self:SetTarget(ally)
        self:SetSchedule(SCHED_TARGET_FACE)
    end


    ZBaseDelayBehaviour( ZBaseRndTblRange(self.IdleSoundCooldown)+DialogueExtraCoolDown )

end


function NPC:CancelConversation()
    if !self.HavingConversation then return end

    if IsValid(self.DialogueMate) then
        self.DialogueMate.HavingConversation = nil
        self.DialogueMate.DialogueMate = nil
        self.DialogueMate:FullReset()

        self.DialogueMate:StopSound(self.DialogueMate.Dialogue_Question_Sounds)
        self.DialogueMate:StopSound(self.DialogueMate.Dialogue_Answer_Sounds)

        timer.Remove("DialogueAnswerTimer"..self.DialogueMate:EntIndex())
    end

    self.HavingConversation = nil
    self.DialogueMate = nil
    self:FullReset()

    self:StopSound(self.Dialogue_Question_Sounds)
    self:StopSound(self.Dialogue_Answer_Sounds)

    timer.Remove("DialogueAnswerTimer"..self:EntIndex())
end



--[[
==================================================================================================
                                           DEAL DAMAGE
==================================================================================================
--]]


function NPC:DealDamage( dmg, ent )

    local infl = dmg:GetInflictor()
    local disp = self:Disposition(ent)

    -- Friendly fire immune
    if disp==D_LI && !ZBCVAR.FriendlyFire:GetBool() then
        dmg:ScaleDamage(0)
        return true
    end

    -- Cannot suicide
    if self==ent && !(self.Patch_OnSelfDamage && self:Patch_OnSelfDamage(dmg)) then
        dmg:ScaleDamage(0)
        return true
    end

    -- Custom deal damage
    local value = self:CustomDealDamage(ent, dmg)
    if value != nil then
        return value
    end



    -- Crossbow base damage
    if infl.IsZBaseCrossbowFiredBolt then
        dmg:SetDamage(100)
    end



    -- Nerf smg nades/ energy balls etc
    if ZBCVAR.Nerf:GetBool() && IsValid(infl) && infl.IsZBaseDMGInfl && ent:IsPlayer() then

        if infl:GetClass()=="rpg_missile" or infl:GetClass()=="grenade_ar2" then

            -- RPG rocket ~ 50 dmg
            -- SMG Nade ~ 33 dmg
            dmg:ScaleDamage(0.33)

        elseif infl:GetClass() == "crossbow_bolt" then

            -- Crossbow bolt 50 dmg
            dmg:ScaleDamage(0.5)

        elseif infl:GetClass() == "prop_combine_ball" then

            dmg:SetDamage(15)

        end

    end



    dmg:ScaleDamage(ZBCVAR.DMGMult:GetFloat())

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


function NPC:StoreDMGINFO( dmg )

    local ammotype = dmg:GetAmmoType()
    local attacker = dmg:GetAttacker()
    local damage = dmg:GetDamage()
    local dmgforce = dmg:GetDamageForce()
    local dmgtype = dmg:GetDamageType()
    local dmgpos = dmg:GetDamagePosition()
    local infl = dmg:GetInflictor()

    self.LastDMGINFOTbl = {
        ammotype = ammotype,
        attacker = attacker,
        damage = damage,
        dmgforce = dmgforce,
        dmgtype = dmgtype,
        dmgpos = dmgpos,
        infl = infl,
    }

end


function NPC:LastDMGINFO( dmg )
    if !self.LastDMGINFOTbl then return end

    local lastdmginfo = DamageInfo()

    if IsValid(self.LastDMGINFOTbl.infl) then
        lastdmginfo:SetInflictor(self.LastDMGINFOTbl.infl)
    end

    if IsValid(self.LastDMGINFOTbl.attacker) then
        lastdmginfo:SetAttacker(self.LastDMGINFOTbl.attacker)
    end

    lastdmginfo:SetAmmoType(self.LastDMGINFOTbl.ammotype)
    lastdmginfo:SetDamage(self.LastDMGINFOTbl.damage)
    lastdmginfo:SetDamageForce(self.LastDMGINFOTbl.dmgforce)
    lastdmginfo:SetDamageType(self.LastDMGINFOTbl.dmgtype)
    lastdmginfo:SetDamagePosition(self.LastDMGINFOTbl.dmgpos)

    return lastdmginfo
end


    -- Called first
function NPC:OnScaleDamage( dmg, hit_gr )
    local attacker = dmg:GetAttacker()

    -- Players not hurting allies
    if !ZBCVAR.PlayerHurtAllies:GetBool() && attacker:IsPlayer() && self:IsAlly(attacker) then
        dmg:ScaleDamage(0)
        return
    end

    -- Remember stuff
    self.ZBLastHitGr = hit_gr

    -- Armor
    if self.HasArmor[hit_gr] then
        self:HitArmor(dmg, hit_gr)
    end


    -- Custom damage
    self:CustomTakeDamage( dmg, hit_gr )
    self.CustomTakeDamageDone = true


    -- Bullet blood shit idk
    if (self.CustomBloodParticles or self.CustomBloodDecals) && dmg:IsBulletDamage() then
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
    if self.DoingDeathAnim && !self.DeathAnim_Finished then
        return true
    end


    local attacker = dmg:GetAttacker()


    -- Players not hurting allies
    if !ZBCVAR.PlayerHurtAllies:GetBool() && attacker:IsPlayer() && self:IsAlly(attacker) then
        return true
    end


    if self.Patch_OnTakeDamage then
        self:Patch_OnTakeDamage(dmg)
    end


    ZBaseMoveEnd(self, "MoveFallback")


    local infl = dmg:GetInflictor()


    -- Combine balls should have dissolve damage
    if IsValid(infl) && infl:GetClass()=="prop_combine_ball" then
        dmg:SetDamageType(DMG_DISSOLVE)
    end


    -- Remember last dmginfo
    self:StoreDMGINFO( dmg )
    self.LastDamageWasBullet = dmg:IsBulletDamage()


    -- Damage scale
    local scale = self.DamageScaling[dmg:GetDamageType()]
    if scale then
        dmg:ScaleDamage(scale)
    end


    -- Custom damage
    if !self.CustomTakeDamageDone then
        self:CustomTakeDamage( dmg, HITGROUP_GENERIC )
        self.CustomTakeDamageDone = true
    end


    local goingToDie = self:Health()-dmg:GetDamage() <= 0


    if goingToDie then
        self.IsSpeaking = false
    end


    -- Prevent engine gib
    if goingToDie && ShouldPreventGib[self:GetClass()] then
        self.ZBasePreDeathDamageType = dmg:GetDamageType()
		
        if dmg:IsDamageType(DMG_DISSOLVE) or (IsValid(infl) && infl:GetClass()=="prop_combine_ball") then
            dmg:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_NEVERGIB))
        else
            dmg:SetDamageType(DMG_NEVERGIB)
        end

    end


    -- Patch
    if goingToDie && self.Patch_PreDeath then
        self:Patch_PreDeath( dmg )
    end


    -- Death animation
    if !table.IsEmpty(self.DeathAnimations) && goingToDie && math.random(1, self.DeathAnimationChance)==1 then
        self:DeathAnimation(dmg)
        return
    end
end


    -- Called last
function NPC:OnPostEntityTakeDamage( dmg )

    local MoreThan0Damage = dmg:GetDamage() > 0


    -- Custom blood
    if (self.CustomBloodParticles or self.CustomBloodDecals) && MoreThan0Damage then
        self:CustomBleed(dmg:GetDamagePosition(), dmg:GetDamageForce():GetNormalized())
    end


    -- Don't do anything if we are dead I guess?
    -- Still bleed though
    if self.Dead then
        return
    end


    -- Remember last dmginfo again for accuracy sake
    self:StoreDMGINFO( dmg )


    self:AI_OnHurt(dmg, MoreThan0Damage)


    self.CustomTakeDamageDone = nil
end



--[[
==================================================================================================
                                           DEATH
==================================================================================================
--]]


function NPC:OnDeath( attacker, infl, dmg, hit_gr )

    if self.Patch_SkipDeathRoutine then return end
    if self.Dead then return end
    self.Dead = true

    
    -- Return previous damage
    if self.ZBasePreDeathDamageType then
        dmg:SetDamageType(self.ZBasePreDeathDamageType)
    end


    -- Register as no longer speaking, this will fix death sounds not being played
    self.IsSpeaking = false
    self.IsSpeaking_SoundVar = nil


    -- Death sound
    if !self.DoingDeathAnim then
        self:EmitSound(self.DeathSounds)
    end


    -- My honest reaction
    self:Death_AlliesReact()


    local infl = dmg:GetInflictor()
    local Gibbed = self:ShouldGib(dmg, hit_gr)
    local isDissolveDMG = dmg:IsDamageType(DMG_DISSOLVE) or (IsValid(infl) && infl:GetClass()=="prop_combine_ball")
    local shouldCLRagdoll = ZBCVAR.ClientRagdolls:GetBool() && !KeepCorpses:GetBool() && !isDissolveDMG && self.HasDeathRagdoll
    local rag

    self:SetShouldServerRagdoll(!shouldCLRagdoll)


    -- Become ragdoll if we should
    if !shouldCLRagdoll && !Gibbed && !dmg:IsDamageType(DMG_REMOVENORAGDOLL) then
        local Ragdoll = self:BecomeRagdoll(dmg, hit_gr, KeepCorpses:GetBool())
        if IsValid(Ragdoll) then
            rag = Ragdoll
        end
    elseif shouldCLRagdoll then
        local Ragdoll = self:FakeRagdoll()
        if IsValid(Ragdoll) then
            rag = Ragdoll
        end
    end


    -- Drop engine weapon, not stoopid vegetable zbase weapon
    local wep = self:GetActiveWeapon()
    if IsValid(wep) && wep.EngineCloneClass then

        self:Give(wep.EngineCloneClass)

    end


    -- Item drop
    if ZBCVAR.ItemDrop:GetBool() then
        self:Death_ItemDrop(dmg)
    end


    -- Custom on death
    self:CustomOnDeath( dmg, hit_gr, rag )


    -- Weapon dissolve
    if ZBCVAR.DissolveWep:GetBool() then

        local myWep = self:GetActiveWeapon()

        conv.callNextTick(function()
            if IsValid(myWep) then

                myWep:SetName("zbase_wep_dissolve"..myWep:EntIndex())

                local dissolve = ents.Create("env_entity_dissolver")
                dissolve:SetKeyValue("target", myWep:GetName())
                dissolve:SetKeyValue("dissolvetype", 0)
                dissolve:Fire("Dissolve", myWep:GetName())
                dissolve:Spawn()
                myWep:DeleteOnRemove(dissolve)

            end
        end)

    end

    -- Byebye
    if shouldCLRagdoll && !Gibbed then
        if IsValid(rag) then

            -- This makes so that the client ragdoll has the desired bodygroups
            for k, v in pairs(rag:GetBodyGroups()) do
                self:SetBodygroup(v.id, rag:GetBodygroup(v.id))
            end

            -- And the desired model
            if rag:GetModel()!=self:GetModel() then
                self:SetModel(rag:GetModel())
            end

            -- And the desired skin
            if rag:GetSkin() != self:GetSkin() then
                self:SetSkin(rag:GetSkin())
            end

        end

        self:StopMoving()
        self:ClearGoal()
        self:CapabilitiesClear()
        self:SetCollisionBounds(vector_origin, vector_origin)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:SetNPCState(NPC_STATE_DEAD)
        SafeRemoveEntityDelayed(self, 1)

        if self.IsZBase_SNPC then
            net.Start("ZBaseClientRagdoll")
            net.WriteEntity(self)
            net.SendPVS(self:GetPos())
        elseif self.DoingDeathAnim then
            self:FullReset()
        end
    else
        self:Remove()
    end
  

end


function NPC:InternalOnAllyDeath()
    -- All nearby allies stop talking
    self:StopSound(self.IdleSounds)
    self:CancelConversation()
end


function NPC:ImTheNearestAllyAndThisIsMyHonestReaction( deathpos )
    if self.AllyDeathSound_Chance && math.random(1, self.AllyDeathSound_Chance) == 1 then
        timer.Simple(0.5, function()
            if IsValid(self) then
                self:EmitSound_Uninterupted(self.AllyDeathSounds)

                local npcstate = self:GetNPCState()

                if self.AllyDeathSounds != "" && ( npcstate==NPC_STATE_IDLE or npcstate==NPC_STATE_ALERT ) then
                    self:FullReset()
                    self:Face_Simple(deathpos)
                end
            end
        end)
    end
end


-- Called on death and makes nearby allies to me react to it
function NPC:Death_AlliesReact()
	
    local allies = self:GetNearbyAllies(600)
    for _, ally in ipairs(allies) do
        if IsValid(ally) && isfunction(ally.OnAllyDeath) && ally:Visible(self) then
            ally:InternalOnAllyDeath()
            ally:OnAllyDeath(self)
        end
    end

    local ally = self:GetNearestAlly(600)
    local deathpos = self:GetPos()
    if IsValid(ally) && ally:Visible(self) && ally.ImTheNearestAllyAndThisIsMyHonestReaction then
        ally:ImTheNearestAllyAndThisIsMyHonestReaction( deathpos )
    end
end


function NPC:Death_ItemDrop(dmg)

    -- Item drops

    local ItemArray = {}
    local DropsDone = 0


    for cls, opt in pairs(self.ItemDrops) do
        table.insert(ItemArray, {cls=cls, max=opt.max, chance=opt.chance})
    end


    table.Shuffle(ItemArray)


    for _, dropData in ipairs(ItemArray) do

        if DropsDone >= self.ItemDrops_TotalMax then break end


        for i = 1, dropData.max do
            if DropsDone >= self.ItemDrops_TotalMax then break end

            if math.random(1, dropData.chance) == 1 then
                local drop = ents.Create(dropData.cls)
                drop:SetPos(self:WorldSpaceCenter())
                drop:SetAngles(AngleRand())
                drop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                drop:Spawn()
                SafeRemoveEntityDelayed(drop, 120)

                DropsDone = DropsDone + 1
                if dmg:IsDamageType(DMG_DISSOLVE) then
                    local dissolver = ents.Create("env_entity_dissolver")
                    dissolver:SetPos(drop:GetPos())
                    dissolver:Spawn()
                    dissolver:Activate()
                    dissolver:SetKeyValue("magnitude",100)
                    dissolver:SetKeyValue("dissolvetype", math.random(0, 2))
                    drop:SetName("z_dissolve_drop")
                    dissolver:Fire("Dissolve","z_dissolve_drop")
                    dissolver:Fire("Kill", "", 0.1)
                end
            end
        end

    end


end


--[[
==================================================================================================
                                           RAGDOLL
==================================================================================================
--]]


ZBaseRagdolls = ZBaseRagdolls or {}


local RagdollBlacklist = {
    ["npc_clawscanner"] = true,
    ["npc_manhack"] = true,
    ["npc_cscanner"] = true,
    ["npc_combinegunship"] = true,
    ["npc_combinedropship"] = true,
}


function NPC:FakeRagdoll()
	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self.RagdollModel == "" && self:GetModel() or self.RagdollModel)
    rag:SetPos(self:GetPos())
    rag:SetAngles(self:GetAngles())
    rag:SetSkin(self:GetSkin())
    rag.IsZBaseRag = true
	rag:Spawn()
    rag:SetNoDraw(true)
    rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    SafeRemoveEntityDelayed(rag, 1)

    rag:SetNotSolid(true)

	local ragPhys = rag:GetPhysicsObject()
	if !IsValid(ragPhys) then
		rag:Remove()
		return
	end


	local physcount = rag:GetPhysicsObjectCount()
	for i = 0, physcount - 1 do
		local physObj = rag:GetPhysicsObjectNum(i)
        physObj:EnableMotion(false)
	end


    return rag
end


function NPC:BecomeRagdoll( dmg, hit_gr, keep_corpse )
    if !self.HasDeathRagdoll then return end
    if RagdollBlacklist[self:GetClass()] then return end

    local isDissolveDMG = dmg:IsDamageType(DMG_DISSOLVE) or (IsValid(infl) && infl:GetClass()=="prop_combine_ball")
    local shouldCLRagdoll = ZBCVAR.ClientRagdolls:GetBool() && !keep_corpse && !isDissolveDMG
    local infl = dmg:GetInflictor()
    local npc = IsValid(self.ActiveRagdoll) && self.ActiveRagdoll or self
	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self.RagdollModel == "" && self:GetModel() or self.RagdollModel)
    rag:SetPos(npc:GetPos())
    rag:SetAngles(npc:GetAngles())
	rag:SetSkin(self:GetSkin())
	rag:SetColor(self:GetColor())
	rag:SetMaterial(self:GetMaterial())
    rag.IsZBaseRag = true
	rag:Spawn()


    for k, v in ipairs(self:GetBodyGroups()) do
        rag:SetBodygroup(v.id, self:GetBodygroup(v.id))
    end


    for k, v in ipairs(self:GetMaterials()) do
        rag:SetSubMaterial( k-1, self:GetSubMaterial(k-1) )
    end


	local ragPhys = rag:GetPhysicsObject()
	if !IsValid(ragPhys) then
		rag:Remove()
		return
	end


	local physcount = rag:GetPhysicsObjectCount()
    local dmgpos = dmg:GetDamagePosition()
    local force = self.RagdollApplyForce && dmg:GetDamageForce()*0.02
	for i = 0, physcount - 1 do

		-- Placement
		local physObj = rag:GetPhysicsObjectNum(i)
		local pos, ang = npc:GetBonePosition(npc:TranslatePhysBoneToBone(i))

        if !self.RagdollUseAltPositioning then
		    physObj:SetPos( pos )
        end


        if !self.RagdollDontAnglePhysObjects then
	        physObj:SetAngles( ang )
        end


        if force then
            physObj:SetVelocity(force)
        end

	end

	-- Hook
	hook.Run("CreateEntityRagdoll", self, rag)


	-- Dissolve
	if isDissolveDMG then
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


    
    if isDissolveDMG then
        rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		undo.ReplaceEntity( rag, NULL )
		cleanup.ReplaceEntity( rag, NULL )
    elseif !keep_corpse then
        -- If we should not keep corpse, do this:


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


        -- Undo/cleanup replace entity
		undo.ReplaceEntity( rag, NULL )
		cleanup.ReplaceEntity( rag, NULL )
    end

    return rag
end

--[[
==================================================================================================
                                           GIBS
==================================================================================================
--]]


function NPC:InternalCreateGib( model, data )
    data = data or {}


    -- Create
    local entclass = !data.IsRagdoll && "zb_temporary_ent" or "prop_ragdoll"
    local Gib = ents.Create(entclass)
    Gib.ShouldRemain = true
    Gib:SetModel(model)
    Gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    Gib.IsZBaseGib = true


    -- Blood
    if ZBaseDynSplatterInstalled && !data.DontBleed then
        Gib:SetBloodColor(self:GetBloodColor())
        Gib:SetNWBool("DynSplatter", true)


        local CustomDecal = self.CustomBloodDecals
        local CustomParticle = self.CustomBloodParticles && self.CustomBloodParticles[1]


        if CustomDecal then
            Gib:SetNWString( "DynamicBloodSplatter_CustomBlood_Decal", CustomDecal )
        end


        if CustomParticle then
            Gib:SetNWString( "DynamicBloodSplatter_CustomBlood_Particle", CustomParticle )
        end


        Gib.PhysicsCollide = function(_, colData, collider)

            if colData.Speed > 200 then
                local effectdata = EffectData()
                effectdata:SetOrigin( colData.HitPos )
                effectdata:SetNormal( -colData.HitNormal )
                effectdata:SetMagnitude( 0.25 )
                effectdata:SetRadius( 1 )
                effectdata:SetEntity( Gib )
                util.Effect("dynamic_blood_splatter_effect", effectdata, true, true )
            end

        end
    end


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


    -- Dissolve if should
    local LastDMGInfo = self:LastDMGINFO()
	if LastDMGInfo && LastDMGInfo:IsDamageType(DMG_DISSOLVE) && !data.DontDissolve then
        local dissolver = ents.Create("env_entity_dissolver")
        dissolver:SetPos(Gib:GetPos())
        dissolver:Spawn()
        dissolver:Activate()
        dissolver:SetKeyValue("magnitude",100)
        dissolver:SetKeyValue("dissolvetype", math.random(0, 2))
        Gib:SetName("z_dissolve_gib")
        dissolver:Fire("Dissolve","z_dissolve_gib")
        dissolver:Fire("Kill", "", 0.1)
    end

    -- Phys stuff
	for i = 0, Gib:GetPhysicsObjectCount() - 1 do
        local phys = Gib:GetPhysicsObjectNum(i)
        if IsValid(phys) then
            phys:Wake()
            if LastDMGInfo then
                local ForceDir = LastDMGInfo:GetDamageForce()/(math.Clamp(phys:GetMass(), 40, 10000))
                phys:SetVelocity( (ForceDir) + VectorRand()*(ForceDir:Length()*0.33) )
            end
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

    if self.DeathAnimStarted then return end
    self.DeathAnimStarted = true


    self:DeathAnimation_Animation()
    self.DoingDeathAnim = true



    self:EmitSound(self.DeathSounds)


    dmg:SetDamageForce(vector_origin)
    self:StoreDMGINFO(dmg)


    dmg:ScaleDamage(0)


    self:SetHealth(1)
    self:CapabilitiesClear()


    if self.DeathAnimation_StopAttackingMe then
        self:AddFlags(FL_NOTARGET)
    end

end



function NPC:InternalOnRemove()

    -- Unregister me as a NPC that is attacking players
    for _, ply in player.Iterator() do
        if IsValid(ply) && istable(ply.AttackingZBaseNPCs) then
            ply.AttackingZBaseNPCs[self]=nil
        end
    end

end
