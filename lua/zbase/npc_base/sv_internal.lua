util.AddNetworkString("ZBaseGlowEyes")
util.AddNetworkString("ZBaseClientRagdoll")

local NPC               = ZBaseNPCs["npc_zbase"]
local BEHAVIOUR         = ZBaseNPCs["npc_zbase"].Behaviours
local bMultiplayer      = !game.SinglePlayer()
local developer         = GetConVar("developer")
local ai_serverragdolls = GetConVar("ai_serverragdolls")
local ai_disabled       = GetConVar("ai_disabled")
local ai_ignoreplayers  = GetConVar("ai_ignoreplayers")

local engineWeaponReplacements = {
    ["weapon_ar2"]          = "weapon_zb_ar2",
    ["weapon_357"]          = "weapon_zb_357",
    ["weapon_crossbow"]     = "weapon_zb_crossbow",
    ["weapon_crowbar"]      = "weapon_zb_crowbar",
    ["weapon_pistol"]       = "weapon_zb_pistol",
    ["weapon_rpg"]          = "weapon_zb_rpg",
    ["weapon_shotgun"]      = "weapon_zb_shotgun",
    ["weapon_smg1"]         = "weapon_zb_smg1",
    ["weapon_stunstick"]    = "weapon_zb_stunstick",
    ["weapon_alyxgun"]      = "weapon_zb_alyxgun",
    ["weapon_annabelle"]    = "weapon_zb_annabelle",
    ["weapon_357_hl1"]      = "weapon_zb_357_hl1",
    ["weapon_glock_hl1"]    = "weapon_zb_glock_hl1",
    ["weapon_shotgun_hl1"]  = "weapon_zb_shotgun_hl1"
}

local engineWeaponFlipped = {
    ["weapon_zb_ar2"]          = "weapon_ar2",
    ["weapon_zb_357"]          = "weapon_357",
    ["weapon_zb_crossbow"]     = "weapon_crossbow",
    ["weapon_zb_crowbar"]      = "weapon_crowbar",
    ["weapon_zb_pistol"]       = "weapon_pistol",
    ["weapon_zb_rpg"]          = "weapon_rpg",
    ["weapon_zb_shotgun"]      = "weapon_shotgun",
    ["weapon_zb_smg1"]         = "weapon_smg1",
    ["weapon_zb_stunstick"]    = "weapon_stunstick",
    ["weapon_zb_alyxgun"]      = "weapon_alyxgun",
    ["weapon_zb_annabelle"]    = "weapon_annabelle",
    ["weapon_zb_357_hl1"]      = "weapon_357_hl1",
    ["weapon_zb_glock_hl1"]    = "weapon_glock_hl1",
    ["weapon_zb_shotgun_hl1"]  = "weapon_shotgun_hl1"
}

--[[
==================================================================================================
                                           INIT BRUV
==================================================================================================
--]]

function NPC:PreSpawn()
    -- First and foremost...
    self:SetNWBool("IsZBaseNPC", true)

    if #self.Weapons >= 1 then
        self:CapabilitiesAdd(CAP_USE_WEAPONS) -- Important! Or else some NPCs won't spawn with weapons.
    else
        self:SetKeyValue("additionalequipment", "") -- This NPC was not meant to have weapons, so remove them before spawn
    end

    if self.Patch_PreSpawn then
        self:Patch_PreSpawn()
    end

    self.DontAutoSetSquad = self.DontAutoSetSquad || !ZBCVAR.AutoSquad:GetBool()

    self:CustomPreSpawn()
end

function NPC:ZBaseInit()
    -- Variables
    self.NextPainSound                      = CurTime()
    self.NextAlertSound                     = CurTime()
    self.NPCNextSlowThink                   = CurTime()
    self.NPCNextDangerSound                 = CurTime()
    self.NextEmitHearDangerSound            = CurTime()
    self.NextFlinch                         = CurTime()
    self.NextHealthRegen                    = CurTime()
    self.NextFootStepTimer                  = CurTime()
    self.NextRangeThreatened                = CurTime()
    self.NextOutOfShootRangeSched           = CurTime()
    self.EnemyVisible                       = false
    self.HadPreviousEnemy                   = false
    self.LastEnemy                          = NULL
    self.InternalDistanceFromGround         = self.Fly_DistanceFromGround
    self.ZBLastHitGr                        = HITGROUP_GENERIC
    self.PlayerToFollow                     = NULL
    self.GuardSpot                          = self:GetPos()
    self.InternalCurrentVoiceSoundDuration  = 0
    self.ZBase_ExpectedSightDist            = ( (self.SightDistance == ZBASE_DEFAULT_SIGHT_DIST || ZBCVAR.SightDistOverride:GetBool()) && ZBCVAR.SightDist:GetInt() ) || self.SightDistance
    self.ZBaseLuaAnimationFrames            = {}
    self.ZBaseLuaAnimEvents                 = {}
    self.ZBaseFrameLast                     = -1
    self.ZBaseSeqLast                       = -1

    self:InitGrenades()
    self:InitSounds()
    self:InitInternalVars()
    self:InitModel()
    self:InitBounds()
    self:AddEFlags(self.AddNoDissolveFlag && EFL_NO_DISSOLVE || 0)
    self:SetMaxHealth(self.StartHealth*ZBCVAR.HPMult:GetFloat())
    self:SetHealth(self.StartHealth*ZBCVAR.HPMult:GetFloat())

    -- No collide if we should
    if ZBCVAR.NPCNocollide:GetBool() then
        self:SetCollisionGroup(COLLISION_GROUP_NPC_SCRIPTED)
    end

    -- Blood color
    if self.BloodColor != false then
        self:SetBloodColor(self.BloodColor)
    end

    -- Makes behaviour system function
    ZBaseBehaviourInit( self )

    -- On remove function
    self:CallOnRemove("ZBaseOnRemove"..self:EntIndex(), function()
        self:InternalOnRemove()
        self:OnRemove()
    end)

    -- Set to 'zbase' squad initially before we know faction
    -- if we should
    if !self.DontAutoSetSquad then
        self:SetSquad("zbase")
    end

    -- For use with hammer inputs
    self:Fire("wake")

    -- Apply custom class name
    -- This will be networked
    self:ApplyCustomClassName(self.NPCName)

    -- If we have an engine-based weapon
    -- Replace it with a ZBASE equivalent
    -- so that we get more control over it
    local wep       = self:GetActiveWeapon()
    if IsValid(wep) then
        local wepcls = wep:GetClass()
        if engineWeaponReplacements[wepcls] then
            self:Give(engineWeaponReplacements[wepcls])
        end
    end

    -- Start LUA thinking if non-scripted
    if !self:IsScripted() then
        self:EngineNPC_StartLuaThink()
    end

    -- User defined init
    self:CustomInitialize()

    -- Init more stuff next tick
    self:CONV_CallNextTick("InitNextTick")

    self.RanInit = true
end

-- Start LUA thinking if non-scripted
function NPC:EngineNPC_StartLuaThink()
    self.EngineNPC_NextLUAThink = CurTime()
    self:CONV_AddHook("Think", function()
        -- Frame tick every frame
        self:FrameTick()

        -- Regular think every 0.1 seconds
        if self.EngineNPC_NextLUAThink < CurTime() then
            self:ZBaseThink()

            if self.Patch_Think then
                self:Patch_Think()
            end

            self.EngineNPC_NextLUAThink = CurTime()+0.1
        end
    end, 
    "EngineNPC_LUAThink")
end

function NPC:InitSharedAnimEvents()
    -- Add footsteps when landing after a jump
    self.JumpLandSequence = self:GetSequenceName( self:SelectWeightedSequence(ACT_LAND) )

    if self.JumpLandSequence != "Not Found!" then
        self:AddAnimationEvent(self.JumpLandSequence, 1, 100)
        self:AddAnimationEvent(self.JumpLandSequence, 3, 100)
    end
end

function NPC:InitNextTick()
    -- Auto set NPC class
    if self.IsZBase_SNPC && self:GetNPCClass() == -1 && ZBaseFactionTranslation_Flipped[ZBaseGetFaction(self)] then
        self:SetNPCClass(ZBaseFactionTranslation_Flipped[ZBaseGetFaction(self)])
    end

    -- Init more stuff next tick
    self:CONV_CallNextTick("Init2Ticks")
end

function NPC:Init2Ticks()
    -- FOV and sight dist
    self.FieldOfView = math.cos( (self.SightAngle*(math.pi/180))*0.5 )
    self:SetSaveValue( "m_flFieldOfView", self.FieldOfView )
    self:SetMaxLookDistance(self.ZBase_ExpectedSightDist)

    -- Phys damage scale
    self:Fire("physdamagescale", self.PhysDamageScale)

    -- Initialize capabilities
    self:InitCap()

    -- Set squad to faction if we should
    if !self.DontAutoSetSquad then
        conv.callNextTick(function()
            if IsValid(self) then
                self:SetSquad(self.ZBaseFaction)
            end
        end)
    end
end

-- Set specified internal variables
function NPC:InitInternalVars()
    for varname, var in pairs(self.EInternalVars || {}) do
        self:SetSaveValue(varname, var)
    end
    self.EInternalVars = nil
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
    -- Set rendermode
    self:SetRenderMode(self.RenderMode)

    -- Set submaterials
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
        -- Fixed number || grenades and alts

        self.GrenCount = ZBCVAR.GrenCount:GetInt()
        self.AltCount = ZBCVAR.AltCount:GetInt()
    end
end

function NPC:InitBounds()
    if self.CollisionBounds then
        if self.IsZBase_SNPC then
            -- Workaround: Needs to be called next tick on SNPCs for some reason...
            self:CONV_CallNextTick("SetCollisionBounds", self.CollisionBounds.min, self.CollisionBounds.max)
        else
            self:SetCollisionBounds( self.CollisionBounds.min, self.CollisionBounds.max )
        end

        self:SetSurroundingBounds(self.CollisionBounds.min*1.3, self.CollisionBounds.max*1.3)
        self:CONV_CallNextTick("InitBlockingBounds")
    end

    if self.HullType then
        self:SetHullType(self.HullType)
        self:SetHullSizeNormal()
    end

    if self.UseVPhysics then
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            self:OnInitPhys(phys)
        end

        return
    end
end

function NPC:InitBlockingBounds()
    -- Set up blocking bounds
    local mins, maxs = self:OBBMins(), self:OBBMaxs()
    mins, maxs = Vector(mins.x*1.5, mins.y*1.5, mins.z), Vector(maxs.x*1.5, maxs.y*1.5, maxs.z)
    self.ZBase_BlockingBounds = {mins, maxs}
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
    if self.CanOpenDoors        then self:CapabilitiesAdd(CAP_OPEN_DOORS) end
    if self.CanOpenAutoDoors    then self:CapabilitiesAdd(CAP_AUTO_DOORS) end
    if self.CanUse              then self:CapabilitiesAdd(CAP_USE) end

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

function NPC:ZBaseThink()
    -- Don't think if has EFL_NO_THINK_FUNCTION
    if self:IsEFlagSet(EFL_NO_THINK_FUNCTION) then
        return
    end

    local isAIEnabled = !ai_disabled:GetBool()

    if isAIEnabled then
        local ene = self:GetEnemy()
        local sched = self:GetCurrentSchedule()
        local seq = self:GetSequence()
        local act = self:GetActivity()
        local GP = self:GetGoalPos()
        local moveact = self:OverrideMovementAct()

        -- Enemy visible
        self.EnemyVisible = IsValid(ene) && (self:HasCondition(COND.SEE_ENEMY) || self:Visible(ene))

        -- Slow think, for performance
        if self.NPCNextSlowThink < CurTime() then
            self:AITick_Slow()
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

        -- Sched debug
        if ZBCVAR.ShowSched:GetBool() then
            conv.overlay("Text", function() return {
                                    self:WorldSpaceCenter()+self:GetUp()*50,
                                    "sched: "..tostring(ZBaseSchedDebug(self)),
                                    0.13,} end)
        end

        -- Base regen
        if self.HealthRegenAmount > 0 && self:Health() < self:GetMaxHealth() && self.NextHealthRegen < CurTime() then
            self:SetHealth(math.Clamp(self:Health()+self.HealthRegenAmount, 0, self:GetMaxHealth()))
            self.NextHealthRegen = CurTime()+self.HealthCooldown
        end

        -- Foot steps
        if self.NextFootStepTimer < CurTime() && self:GetNavType()==NAV_GROUND && self:CONV_HasCapability(CAP_MOVE_GROUND) then
            self:FootStepTimer()
        end

        -- Move anim override
        self.MovementOverrideActive = isnumber(moveact) || nil
        if self.MovementOverrideActive then
            self:SetMovementActivity(moveact)
        end
    end

    -- Stuff to make play anim work as intended
    if self.DoingPlayAnim then
        self:InternalDoPlayAnim()
    end

    -- For NPC:PlayAnimation(), SNPC only
    if self.DoingPlayAnim && self.IsZBase_SNPC then
        self:ExecuteWalkFrames()
    end

    -- TODO: Should this really be ran here and not in FrameTick?
    if self.EnableLUAAnimationEvents then
        self:LUAAnimEventThink()
    end

    -- Custom think
    self:CustomThink()

    -- User think function that is only called when thinking is enabled
    if isAIEnabled then
        self:AIThink()
    end
end

function NPC:FrameTick()
    if ai_disabled:GetBool() then return end

    local ene = self:GetEnemy()
    local isMoving = self:IsMoving()

    -- For NPC:PlayAnimation()
    if !self.DoingPlayAnim && (isMoving || self.bControllerMoving) then
        self:DoMoveSpeed()
    end

    -- For NPC:PlayAnimation(), non-scripted
    if self.DoingPlayAnim && !self.IsZBase_SNPC then
        self:ExecuteWalkFrames(0.3)
    end

    -- For NPC:Face()
    if self.ZBase_CurrentFace_bShould then
        if IsValid(self.ZBase_CurrentFace_Ent) then
            -- Ent face
            self.ZBase_CurrentFace_Yaw = ( self.ZBase_CurrentFace_Ent:GetPos()-self:GetPos() ):Angle().yaw
        end

        -- Constant yaw face
        self:ZBaseUpdateYaw(self.ZBase_CurrentFace_Yaw, self.ZBase_CurrentFace_Speed || 15)
    end

    -- User custom tick
    self:CustomFrameTick()
end

--[[
==================================================================================================
            RELATIONSHIPS
==================================================================================================
--]]

function NPC:DecideRelationship( myFaction, ent )
    local theirFaction = ent.ZBaseFaction

    -- Me || the ent has faction neutral, like
    if myFaction == "neutral" || theirFaction=="neutral" then
        self:ZBASE_SetMutualRelationship( ent, D_LI )
        return
    end

    -- My faction is none, hate everybody
    if myFaction == "none" then
        self:ZBASE_SetMutualRelationship( ent, D_HT )
        return
    end

    -- Ent is VJ SNPC
    if ent.IsVJBaseSNPC then
        -- Give VJ SNPC a table of ZBase factions that are equal to its VJ classes

        ent.VJ_ZBaseFactions = {}
        for _, vjclass in pairs(ent.VJ_NPC_Class) do
            if !isstring(vjclass) then continue end

            local vj_to_zbase_trans_faction = ZBaseVJFactionTranslation_Flipped[vjclass]

            if !vj_to_zbase_trans_faction then continue end

            ent.VJ_ZBaseFactions[vj_to_zbase_trans_faction] = true
        end
    end

    if myFaction == theirFaction
    || self.ZBaseFactionsExtra[theirFaction]
    || ( ent.IsZBaseNPC && ent.ZBaseFactionsExtra && ent.ZBaseFactionsExtra[myFaction] )
    || ( ent.IsVJBaseSNPC && ent.VJ_ZBaseFactions[myFaction] ) then
        self:ZBASE_SetMutualRelationship( ent, D_LI )
    else
        self:ZBASE_SetMutualRelationship( ent, D_HT )
    end
end

function NPC:UpdateRelationships()
    -- Set my VJ class
    if ZBaseVJFactionTranslation[self.ZBaseFaction] then
        self.VJ_NPC_Class = {ZBaseVJFactionTranslation[self.ZBaseFaction]}
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
                                           SUPPRESSION AI
==================================================================================================
--]]

function NPC:Weapon_TrySuppress( target )
    if self.ZBASE_IsPlyControlled then return end
    self:AddEntityRelationship(target.ZBase_SuppressionBullseye, D_HT, 0)
    self:UpdateEnemyMemory(target.ZBase_SuppressionBullseye, target:GetPos())
end

function NPC:Weapon_RemoveSuppressionPoint( target )
    SafeRemoveEntity(target.ZBase_SuppressionBullseye)
end

local PlayerHeightVec = Vector(0, 0, 60)
function NPC:Weapon_CreateSuppressionPoint( lastseenpos, target )
    if self.ZBASE_IsPlyControlled then return end

    local pos
    if target:IsPlayer() && target:Crouching() then
        -- Crappy workaround that should work most of the time
        pos = lastseenpos+PlayerHeightVec
    else
        pos = lastseenpos+target:OBBCenter()
    end

    SafeRemoveEntity(target.ZBase_SuppressionBullseye)

    target.ZBase_SuppressionBullseye = ents.Create("npc_bullseye")
    target.ZBase_SuppressionBullseye.Is_ZBase_SuppressionBullseye = true
    target.ZBase_SuppressionBullseye.EntityToSuppress = target
    target.ZBase_SuppressionBullseye:SetPos( pos )
    target.ZBase_SuppressionBullseye:Spawn()
    target.ZBase_SuppressionBullseye:SetModel("models/props_lab/huladoll.mdl")
    target.ZBase_SuppressionBullseye:SetHealth(math.huge)
    target:DeleteOnRemove(target.ZBase_SuppressionBullseye) -- Remove suppression point when target does not exist anymore
    SafeRemoveEntityDelayed(target.ZBase_SuppressionBullseye, 8) -- Remove suppression point after some time

    if developer:GetBool() then
        target.ZBase_SuppressionBullseye:SetNoDraw(false)
        target.ZBase_SuppressionBullseye:SetMaterial("models/wireframe")
    end

    target.ZBase_SuppressionBullseye:SetNotSolid(true)
end

function NPC:Weapon_CanCreateSuppressionPointForEnemy( ene )
    if !ene.ZBase_DontCreateSuppressionPoint then
        return true
    end

    if ene.ZBase_DontCreateSuppressionPoint[self] then
        return false
    end

    return true
end

local minSuppressDist = 350
local minDistFromSuppressPointToEne = 1000^2
function NPC:Weapon_SuppressionThink()
    local ene = self:GetEnemy()

    if !IsValid(ene) then return false end

    -- Don't suppress bullseye that is not visible
    if ene.Is_ZBase_SuppressionBullseye && !self.EnemyVisible then
        return false
    end

    if !self.EnemyVisible
    && self:Weapon_CanCreateSuppressionPointForEnemy( ene )
    && !ene.Is_ZBase_SuppressionBullseye -- Don't create a suppression point for a suppression point...
    then
        if !IsValid(ene.ZBase_SuppressionBullseye) then
            -- Create a new suppression point for this enemy if there is none
            local lastseenpos = self:GetEnemyLastSeenPos(ene)
            if lastseenpos:DistToSqr(ene:GetPos()) < minDistFromSuppressPointToEne then
                self:Weapon_CreateSuppressionPoint( lastseenpos, ene )
            end
        end

        -- Can see enemy's current suppression point, start hating it and make it enemy to us
        if IsValid(ene.ZBase_SuppressionBullseye) then
            self:Weapon_TrySuppress(ene)
        end

        -- Don't allow new suppression points for this enemy until it is seen again
        ene.ZBase_DontCreateSuppressionPoint = ene.ZBase_DontCreateSuppressionPoint || {}
        self:CONV_MapInTable( ene.ZBase_DontCreateSuppressionPoint )

        -- Don't shoot since enemy is not visible
        return false
    end

    if self.EnemyVisible && !ene.Is_ZBase_SuppressionBullseye then
        -- Enemy is visible...

        if ene.ZBase_DontCreateSuppressionPoint then
            ene.ZBase_DontCreateSuppressionPoint[self] = nil -- Allow new suppression points to be created
        end

        -- Remove their suppression point since we know they are no longer there
        self:Weapon_RemoveSuppressionPoint( ene )
    end

    -- Enemy is a suppression point and its NPC/player (the actual enemy) is visible
    -- stop attacking this point and attack the NPC/player instead
    -- TODO: Change to in view cone instead of visible
    if ene.Is_ZBase_SuppressionBullseye
    && ( (IsValid(ene.EntityToSuppress) && self:Visible(ene.EntityToSuppress))
    || self:ZBaseDist(ene, {within=minSuppressDist}) ) then
        self:Weapon_RemoveSuppressionPoint( ene.EntityToSuppress )

        self:UpdateEnemyMemory(ene.EntityToSuppress, ene.EntityToSuppress:GetPos())

        return false -- Don't shoot this time, shoot at the actual enemy next time instead
    end

    return true
end

--[[
==================================================================================================
                                           INTERNAL UTIL
==================================================================================================
--]]

local dynamicInteractionScheds = {
    [SCHED_SCRIPTED_CUSTOM_MOVE] = true,
    [SCHED_SCRIPTED_FACE] = true,
    [SCHED_SCRIPTED_RUN] = true,
    [SCHED_SCRIPTED_WAIT] = true,
    [SCHED_SCRIPTED_WALK] = true
}

function NPC:InDynamicInteraction()
    return dynamicInteractionScheds[self:GetCurrentSchedule()]
end

function NPC:HasZBaseWeapon()
    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then
        return false
    end
    return wep.IsZBaseWeapon
end

-- Checks if weapon is ZBASE melee weapon
-- Not the best check but works for the current case(s)
function NPC:HasMeleeWeapon()
    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then
        return false
    end

    if wep:GetClass() == "weapon_stunstick" then return true end
    if wep:GetClass() == "weapon_crowbar"   then return true end

    return wep.IsZBaseWeapon && wep.NPCIsMeleeWep
end

function NPC:ZBaseUpdateYaw(yaw, speed)
    self.ZBase_DidInternalUpdateYawCall = true
    self:SetIdealYawAndUpdate(yaw, speed)
    self.ZBase_DidInternalUpdateYawCall = false
end

function NPC:Face( face, duration, speed )
    if !face then return end

    local turnSpeed = speed || self:GetInternalVariable("m_fMaxYawSpeed") || 15
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

    if yaw == nil then return end

    if duration && duration > 0 then
        self:CONV_TempVar("ZBase_CurrentFace_bShould", true, duration)
        self:CONV_TempVar("ZBase_CurrentFace_Yaw", yaw, duration)

        if IsValid(face) then
            self:CONV_TempVar("ZBase_CurrentFace_Ent", face, duration)
        end

        self:CONV_TempVar("ZBase_CurrentFace_Speed", turnSpeed, duration)

    elseif !self.ZBase_CurrentFace_Yaw then
        self:ZBaseUpdateYaw(yaw, turnSpeed)

    end
end

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

function NPC:StopFace()
    if self:IsCurrentSchedule(SCHED_TARGET_FACE) then
        self:TaskComplete()
        self:ClearSchedule()
    end

    self:CONV_RemoveTempVar("ZBase_CurrentFace_Ent")
    self:CONV_RemoveTempVar("ZBase_CurrentFace_bShould")
    self:CONV_RemoveTempVar("ZBase_CurrentFace_Yaw")
    self:CONV_RemoveTempVar("ZBase_CurrentFace_Speed")
end

function NPC:CheckHasAimPoseParam()
    for i=0, self:GetNumPoseParameters() - 1 do

        local name, min, max = self:GetPoseParameterName(i), self:GetPoseParameterRange( i )

        if (name == "aim_yaw" || name == "aim_pitch") && (math.abs(min)>0 || math.abs(max)>0) then
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

    if self:IsScripted() then
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
    if self.Dead || self.DoingDeathAnim then return end

    if !anim then return end

    if isGest && !self.IsZBase_SNPC && bMultiplayer then return end -- Don't do gestures on non-scripted NPCs in multiplayer, it seems to be broken

    moreArgs = moreArgs || {}

    local extraData = {}
    extraData.isGesture = isGest -- If true, it will play the animation as a gesture
    extraData.face = forceFace -- Position || entity to constantly face, if set to false, it will face the direction it started the animation in
    extraData.speedMult = playbackRate -- Speed multiplier for the animation
    extraData.duration = duration -- The animation duration
    extraData.faceSpeed = faceSpeed -- Face turn speed
    extraData.noTransitions = moreArgs.freezeForever || noTransitions -- If true, it won't do any transition animations, will be true if this is a "freezeForver animation"
    self:OnPlayAnimation( anim, forceFace==self:GetEnemy() && forceFace!=nil, extraData )

    -- Do anim as gesture if it is one --
    -- Don't do the rest of the code after that --
    if isGest then
        -- Make sure gest is act
        local gest = isstring(anim) &&
        self:GetSequenceActivity(self:LookupSequence(anim)) ||
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
            self:SetLayerPlaybackRate(id, (playbackRate || 1)*0.5 )
        else
            self:SetLayerPlaybackRate(id, (playbackRate || 1) )
        end

        return -- Stop here
    end

    -- Main function --
    local function playAnim()
        -- No animation in dynamic interaction
        if self:InDynamicInteraction() then
            return
        end

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
            duration = (self:SequenceDuration(anim))/(playbackRate || 1)
        elseif isnumber(duration) then
            duration = duration/(playbackRate || 1)
        end

        -- Anim stop timer --
        timer.Create("ZBasePlayAnim"..self:EntIndex(), duration, 1, function()
            if !IsValid(self) then return end

            if moreArgs.freezeForever != true then -- if freezeforever is enabled, never end the animation

                self:InternalStopAnimation(isTransition || noTransitions)
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
            if forceFace == false then
                self:SetMoveYawLocked(true)
            else
                self:Face(forceFace, duration, faceSpeed)
            end
        end

        -- Vars
        self.PlayAnim_PlayBackRate = playbackRate
        self.PlayAnim_SeqName = ( isnumber(anim) && string.lower( self:GetSequenceName(anim) ) ) || string.lower( anim )
        self.PlayAnim_OnFinishFunc = moreArgs.onFinishFunc
        self.PlayAnim_OnFinishArgs = moreArgs.onFinishFuncArgs
        self.DoingPlayAnim = true

    end

    -- Transition

    local forceFrm = moreArgs.forcedTransitionFrom
    forceFrm = ( isstring(forceFrm) && self:LookupSequence(forceFrm) ) || ( isnumber(forceFrm) && self:SelectWeightedSequence(forceFrm) )

    local goalSeq = isstring(anim) && self:LookupSequence(anim) || self:SelectWeightedSequence(anim)
    local transition = self:FindTransitionSequence( forceFrm || self:GetSequence(), goalSeq )
    local transitionAct = self:GetSequenceActivity(transition)

    if forceFrm then
        conv.devPrint("Forced transition from: ", self:GetSequenceName(forceFrm), " to: ", self:GetSequenceName(goalSeq))
    end

    if !noTransitions
    && transition != -1
    && transition != goalSeq then
        -- Recursion
        self:InternalPlayAnimation( transitionAct != -1 && transitionAct || self:GetSequenceName(transition), nil, playbackRate,
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

function NPC:InternalDoPlayAnim()
    local curSeq = string.lower( self:GetCurrentSequenceName() )

    -- Playback rate for the animation
    self:SetPlaybackRate(self.PlayAnim_PlayBackRate || 1)

    -- Stop movement
    self:SetSaveValue("m_flTimeLastMovement", 2)

    -- Failure, stop so we don't do some weird shit when the NPC is still playing an animation
    if isstring(self.PlayAnim_SeqName) 
    && curSeq != self.PlayAnim_SeqName then
        conv.devPrint(Color(255,0,0), "Play anim failure, seq is '", curSeq, "' but should be '", self.PlayAnim_SeqName, "'")
        self:InternalStopAnimation(true)
        self:OnPlayAnimationFailed( self.PlayAnim_SeqName )
    end
end

function NPC:InternalStopAnimation(dontTransitionOut)
    if !self.DoingPlayAnim then return end

    -- Prevent this func from messing up dynamic interactions
    if self:InDynamicInteraction() then
        return
    end

    if !dontTransitionOut then
        -- Out transition --
        local goalSeq = self:SelectWeightedSequence(ACT_IDLE)
        local transition = self:FindTransitionSequence( self:GetSequence(), goalSeq )
        local transitionAct = self:GetSequenceActivity(transition)

        if transition != -1
        && transition != goalSeq then
            -- Recursion
            self:InternalPlayAnimation( transitionAct != -1 && transitionAct || self:GetSequenceName(transition), nil, playbackRate,
            SCHED_SCENE_GENERIC, forceFace, faceSpeed, false, nil, false )
            return -- Stop here
        end

    end

    self:SetActivity(ACT_IDLE)
    self:ExitScriptedSequence() -- what? when did i put this here. probably does something cool.
    self:ClearSchedule()
    self:SetNPCState(self.PreAnimNPCState)
    self:SetMoveYawLocked(false)
    self:StopFace()

    if isfunction(self.PlayAnim_OnFinishFunc) then
        if istable(self.PlayAnim_OnFinishArgs) then self.PlayAnim_OnFinishFunc( self.PlayAnim_OnFinishArgs )
        else self.PlayAnim_OnFinishFunc() end
    end

    self.DoingPlayAnim = nil
    self.PlayAnim_PlayBackRate = nil
    self.PlayAnim_SeqName = nil
    self.PlayAnim_OnFinishFunc = nil
    self.PlayAnim_OnFinishArgs = nil

    timer.Remove("ZBasePlayAnim"..self:EntIndex())
end

function NPC:SequenceGetFrames(seqID, anim)
    local seqInf = self:GetSequenceInfo( seqID )
	local animID = anim && seqInf.anims[ anim ]
	return animID && self:GetAnimInfo( animID ).numframes || -1
end

function NPC:GetGestureSequence()
	local gest
	local lay
	for i = 0, 5 do
		if self:GetLayerSequence( i ) && self:GetLayerSequence( i ) > 0 then
			gest = self:GetLayerSequence( i )
			lay = i
			break
		end
	end
	return gest, lay || false
end

-- For SNPCs and SNPCs ONLY
function NPC:HandleAnimEvent(event, eventTime, cycle, type, options)
    if !self:IsAlive() then return end
    self:SNPCHandleAnimEvent(event, eventTime, cycle, type, options)
end

-- LUA anim events, that is
function NPC:InternalHandleAnimationEvent( seq, ev )
    -- Jump landing footsteps
    if seq == self.JumpLandSequence && ev == 100 then
        self:EmitFootStepSound()
    end

    self:HandleLUAAnimationEvent( seq, ev )
end

function NPC:LUAAnimEventThink()
	if self.ZBaseLuaAnimEvents then
		local seq = self:GetSequenceName( self:GetSequence() )
		if ( self.ZBaseLuaAnimEvents[ seq ] ) then

			if ( self.ZBaseSeqLast != seq ) then self.ZBaseSeqLast = seq; self.ZBaseFrameLast = -1 end
			local frameNew = math.floor( self:GetCycle() * self.ZBaseLuaAnimationFrames[ seq ] )	-- Despite what the wiki says, GetCycle doesn't return the frame, but a float between 0 and 1
			for frame = self.ZBaseFrameLast + 1, frameNew do	-- a loop, just in case the think function is too slow to catch all frame changes
				if ( self.ZBaseLuaAnimEvents[ seq ][ frame ] ) then
					for _, ev in ipairs( self.ZBaseLuaAnimEvents[ seq ][ frame ] ) do
                        self:InternalHandleAnimationEvent( seq, ev )
					end
				end
			end
			self.ZBaseFrameLast = frameNew

		end

		local gest, layer = self:GetGestureSequence()

		if !gest then return end

		gest = self:GetSequenceName( gest )
		if ( self.ZBaseLuaAnimEvents[ gest ] ) then

			if ( self.m_gestSeqLast != gest ) then self.m_gestSeqLast = gest; self.m_gestFrameLast = -1 end
			local gestFrameNew = math.floor( self:GetLayerCycle( layer ) * self.ZBaseLuaAnimationFrames[ gest ] )	-- Despite what the wiki says, GetCycle doesn't return the frame, but a float between 0 and 1
			for gFrame = self.m_gestFrameLast + 1, gestFrameNew do	-- a loop, just in case the think function is too slow to catch all frame changes
				if ( self.ZBaseLuaAnimEvents[ gest ][ gFrame ] ) then
					for _, ev in ipairs( self.ZBaseLuaAnimEvents[ gest ][ gFrame ] ) do
                        self:InternalHandleAnimationEvent( gest, ev )
					end
				end
			end
			self.m_gestFrameLast = gestFrameNew
		end
	end
end

-- Tags: TickSlow, SlowTick, SlowThink, Slow Think
local blockingColTypes = {
    [COLLISION_GROUP_NONE] = true,
    [COLLISION_GROUP_INTERACTIVE_DEBRIS] = true,
    [COLLISION_GROUP_INTERACTIVE] = true,
    [COLLISION_GROUP_VEHICLE] = true,
    [COLLISION_GROUP_WORLD] = true,
}
function NPC:AITick_Slow()
    local squad = self:GetSquad()

    -- Remove squad if faction is 'none'
    if self.ZBaseFaction == "none" && isstring(squad) && squad!="" then
        self:SetSquad("")
    end

    -- Config weapon proficiency
    if self:GetCurrentWeaponProficiency() != self.WeaponProficiency then
        self:SetCurrentWeaponProficiency(self.WeaponProficiency)

        if developer:GetInt() >= 2 then
            debugoverlay.Text(self:GetPos(), "ZBASE NPC's weapon proficiency set to its 'self.WeaponProficiency'", 0.5)
        end
    end

    -- Update current danger
    self:InternalDetectDanger()

    -- Reload if we cannot see enemy and we have no ammo
    if IsValid(self:GetActiveWeapon()) && !self:HasMeleeWeapon() && !self:HasAmmo() && !self.EnemyVisible && !self:IsCurrentSchedule(SCHED_RELOAD) && !self.bControllerBlock then
        self:SetSchedule(SCHED_RELOAD)
        debugoverlay.Text(self:GetPos(), "Doing SCHED_RELOAD because enemy occluded")
    end

    -- -- Reload if dry firing
    if self.bIsDryFiring && !self:IsCurrentSchedule(SCHED_RELOAD) then
        self:SetSchedule(SCHED_RELOAD)
        debugoverlay.Text(self:GetPos(), "Doing SCHED_RELOAD because of dry fire")
    end

    -- Follow player that we should follow
    if self:CanPursueFollowing() then
        self:PursueFollowing()
    end

    -- Stop following if no longer allied
    -- Or any other thing that should cause us to stop following
    if IsValid(self.PlayerToFollow) && ( !self:IsAlly(self.PlayerToFollow) || self.bControllerBlock ) then
        self:StopFollowingCurrentPlayer(true)
    end

    -- Stop doing forced go when we really shouldn't
    if ( self:IsCurrentSchedule(SCHED_FORCED_GO) || self:IsCurrentSchedule(SCHED_FORCED_GO_RUN) )
    && (self.EnemyVisible && self.bStoredInShootDist) then

        -- Doing move fallback
        if ZBaseMoveIsActive(self, "MoveFallback") then
            self:FullReset()
        else
            -- Doing out of shoot range move || doing cover ally move
            local lastpos = self:GetInternalVariable("m_vecLastPosition")
            if lastpos == self.LastCoverHurtAllyPos || lastpos==self.OutOfShootRange_LastPos then
                self:FullReset()
            end
        end

    end

    -- Cheap detection for moving
    self.ZBase_IsMoving = self:IsMoving() || nil

    -- Push blocking entities away
    if self.ZBase_IsMoving && self.BaseMeleeAttack && self.MeleeDamage_AffectProps && !self.bControllerBlock then

        -- Find blocking entities manually since the engine is a bit dumb (my copilot said this lol, based)
        if !self.ShouldNotManualCheckBlockingEnt && self.ZBase_BlockingBounds then
            local mins, maxs = self.ZBase_BlockingBounds[1], self.ZBase_BlockingBounds[2]
            local mypos = self:GetPos()

            for _, ent in ipairs( ents.FindInBox(mypos+mins, mypos+maxs) ) do
                if ent == self then continue end

                if ent:IsSolid() && ent:GetMoveType() == MOVETYPE_VPHYSICS && blockingColTypes[ent:GetCollisionGroup()] then
                    conv.devPrint("Manually found blocking ent ", ent, " ", ent:GetCollisionGroup())
                    self.ZBase_LastBlockingEnt = ent
                    break
                end
            end

            self:CONV_TempVar("ShouldNotManualCheckBlockingEnt", true, 2)
        end

        local blockingEnt = self.ZBase_LastBlockingEnt || self:GetBlockingEntity()

        if IsValid(blockingEnt) then
            self:MultipleMeleeAttacks()
            self:MeleeAttack(blockingEnt)
            self.ZBase_LastBlockingEnt = nil
        end

    end

    -- Some prop doors normally won't open for NPCs
    -- Force open those doors
    if self.ZBase_IsMoving && self:CONV_HasCapability(CAP_OPEN_DOORS) then
        local vel = self:GetMoveVelocity()
        local wspacecenter = self:WorldSpaceCenter()
        for _, ent in ipairs(ents.FindAlongRay(wspacecenter, wspacecenter+vel, vector_origin, vector_origin)) do
            if ent:GetClass() == "prop_door_rotating" then
                ent:Fire("Open")
            end
        end
    end

    -- Make follow if in player squad
    local engineFollow = self.Patch_UseEngineFollow && self:Patch_UseEngineFollow()
    if engineFollow then

        local squad = self:GetSquad()

        if squad == "player_squad" then
            self:StartFollowingPlayer(Entity(1), true, true, true)
        else
            self:StopFollowingCurrentPlayer(true, true)
        end

    end

    -- If we have an engine-based weapon
    -- Replace it with a ZBASE equivalent
    -- so that we get more control over it
    local wep       = self:GetActiveWeapon()
    if IsValid(wep) then
        local wepcls = wep:GetClass()
        if engineWeaponReplacements[wepcls] then
            self:Give(engineWeaponReplacements[wepcls])
        end
    end
end

function NPC:ShouldPreventSetSched( sched )
    -- Forced go will run no matter what
    if sched==SCHED_FORCED_GO then return false end
    if sched==SCHED_FORCED_GO_RUN then return false end

    -- Prevent SetSchedule from being ran if these conditions apply:
    return self.HavingConversation
    || self.DoingPlayAnim
end

-- function NPC:ShouldPreventSetYaw()
--     if self.IsZBaseSNPC && self:IsCurrentZSched("SCHED_ZBASE_COMBAT_FACE") then
--         print("PREVENTING")
--         return true
--     end
--     return false
-- end

function NPC:OnKilledEnt( ent )
    if ent == self:GetEnemy() then
        self:EmitSound_Uninterupted(self.KilledEnemySounds)
    end

    self:CustomOnKilledEnt( ent )
end

function NPC:RangeThreatened( threat )
    if !self:HasEnemyMemory(threat) then return end
    if self.NextRangeThreatened > CurTime() then return end
    if self.Dead || self.DoingDeathAnim then return end

    self:CONV_TempVar("ZBase_InDanger", true, 3)

    self:OnRangeThreatened( threat )

    self.NextRangeThreatened = CurTime()+3
end

local RangeAttackActs = {
    [ACT_RANGE_ATTACK1] = true,
    [ACT_RANGE_ATTACK2] = true,
    [ACT_SPECIAL_ATTACK1] = true,
    [ACT_SPECIAL_ATTACK2] = true,
}
function NPC:NewActivityDetected( act )
    local ene = self:GetEnemy()

    if IsValid(ene) && RangeAttackActs[act] && ene.IsZBaseNPC then
        ene:RangeThreatened(self)
    end

    self:CustomNewActivityDetected( act )
end

function NPC:NewSequenceDetected( seq, seqName )
    local bIsReloadAnim = string.find(self:GetSequenceActivityName(seq), "RELOAD") != nil
    local wep           = self:GetActiveWeapon()

    -- Has ZBase weapon
    -- ZBase weapon reload sound
    -- I cannot think of a better method than this
    if self:HasZBaseWeapon() then
        if IsValid(wep) && bIsReloadAnim then
            -- Reload sound for weapon
            wep:EmitSound(wep.NPCReloadSound)
        end

        -- Our reload has stopped
        -- We are doing some other sequence now
        -- Stop reload sound
        if !bIsReloadAnim then
            wep:StopSound(wep.NPCReloadSound)
        end
    end

    -- Has any weapon
    if IsValid(wep) then
        if bIsReloadAnim then
            -- Weapon reload workaround
            self.bReloadWorkaround = true
            self:CONV_TimerCreate("WeaponReloadWorkaround", self:SequenceDuration(seq)*0.75, 1, function()
                local wep           = self:GetActiveWeapon()

                if IsValid(wep) && wep:Clip1() < wep:GetMaxClip1() then
                    wep:SetClip1(wep:GetMaxClip1())
                    self:ClearCondition(COND.LOW_PRIMARY_AMMO)
                    self:ClearCondition(COND.NO_PRIMARY_AMMO)
                    conv.devPrint(self.Name, " ", self:EntIndex(), " did wep reload workaround")
                end
            end)

            -- Reload announce
            if math.random(1, self.OnReloadSound_Chance) == 1 then
                self:EmitSound_Uninterupted(self.OnReloadSounds)
            end
        end

        if self.bReloadWorkaround && !bIsReloadAnim then
            -- Weapon reload workaround
            -- Don't do it if we aren't reloading anymore
            self:CONV_TimerRemove("WeaponReloadWorkaround")
            self.bReloadWorkaround = nil
        end
    end

    self:CustomNewSequenceDetected( seq, seqName )
end

function NPC:NewSchedDetected( sched, schedName )
    local assumedFailSched =

    ( string.find(schedName, "FAIL")
        || (self.Patch_IsFailSched && self:Patch_IsFailSched(sched))
    )

    && !( self.IsZBase_SNPC && self.SNPCType == ZBASE_SNPCTYPE_FLY ) -- Don't detect failures for flying mfs

    if assumedFailSched then
        if developer:GetInt() >= 2 then
            MsgN("Had schedule failure (", schedName, ")")
        end

        self:OnDetectSchedFail()
    end

    self:CustomNewSchedDetected(sched, self.ZBaseLastESched || -1)
end

function NPC:OnDetectSchedFail()
    if !ZBCVAR.FallbackNav:GetBool() then return end
    if ZBaseMoveIsActive(self, "MoveFallback") then return end

    if developer:GetInt() >= 2 then
        MsgN("Schedule failed, last seen sched was: "..(self.ZBaseLastESchedName || "none"))
    end

    local fallback_MovePos
    local npcState = self:GetNPCState()
    local ene = self:GetEnemy()

    if self.ZBaseLastValidGoalPos && self.ZBaseLastGoalPos_ValidForFallBack then
        fallback_MovePos = self.ZBaseLastValidGoalPos
    else
        if IsValid(ene) then
            local eneLastPos = self:GetEnemyLastSeenPos()
            fallback_MovePos = ( eneLastPos && !eneLastPos:IsZero() && eneLastPos ) || (ene:GetPos())
        else
            -- Not combat || alert, move randomly
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

        if !self.LostEnemyForShortDuration && self.NextAlertSound < CurTime() then
            self:StopTalking(self.IdleSounds)
            self:CancelConversation()

            if !self:NearbyAllySpeaking({"AlertSounds"}) then
                self:EmitSound_Uninterupted(self.AlertSounds)
                self.NextAlertSound = CurTime() + ZBaseRndTblRange(self.AlertSoundCooldown)
                ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown), self, "DoIdleEnemySound")
            end
        end

        self:CONV_TimerRemove("LostEnemySound")

        ZBaseMoveEnd(self, "MoveFallback")
    end

    -- Lost enemy
    if self.LostEnemySounds != ""
    && !IsValid(ene)
    && self.HadPreviousEnemy
    && !self.EnemyDied
    then
        self.LostEnemyForShortDuration = true
        self:CONV_TimerCreate("LostEnemySound", 3, 1, function()
            self:EmitSound_Uninterupted(self.LostEnemySounds)
            self.LostEnemyForShortDuration = nil
        end)
    end

    self:EnemyStatus(ene, self.HadPreviousEnemy)
    self.HadPreviousEnemy = ene && true || false
    self.LastEnemy = ene || self.LastEnemy
end

local UNKNOWN_DAMAGE_DIST = 1000^2
function NPC:AI_OnHurt( dmg, MoreThan0Damage )
    local attacker = dmg:GetAttacker()
    local ene = self:GetEnemy()

    self:CONV_TempVar("ZBase_InDanger", true, 5)
    ZBaseUpdateGuard(self)

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

    local wep = self:GetActiveWeapon()

    if self:HasZBaseWeapon() && !self:HasMeleeWeapon() && !self:HasAmmo()
    && !self:IsCurrentSchedule(SCHED_RELOAD) then
        -- Re
        self:SetSchedule(SCHED_RELOAD)
    elseif !self.DontTakeCoverOnHurt then
        -- Take cover stuff

        local hasEne = IsValid(ene)

        if !hasEne && !self:IsCurrentSchedule(SCHED_TAKE_COVER_FROM_ORIGIN)
        && self:Disposition(attacker) != D_LI
        && self:GetPos():DistToSqr(attacker:GetPos()) >= UNKNOWN_DAMAGE_DIST then
            -- Become alert and try to hide when hurt by unknown source
            self:SetNPCState(NPC_STATE_ALERT)
            self:SetSchedule(SCHED_TAKE_COVER_FROM_ORIGIN)
            self:CONV_TempVar("DontTakeCoverOnHurt", true, math.Rand(6, 8))

        elseif hasEne && IsValid(wep) then
            -- Take cover if armed
            -- Like a cinematic gun fight with the enemy
            self:SetSchedule(SCHED_TAKE_COVER_FROM_ENEMY)
            self:CONV_TempVar("DontTakeCoverOnHurt", true, math.Rand(6, 8))
        end
    end

    -- Become enemy to attacker even if outside sight distance
    -- As long as they are in view
    if !IsValid(ene) && IsValid(attacker) && self.IsInViewCone && self:IsInViewCone(attacker) && self:Visible(attacker)
    && self:Disposition(attacker) == D_HT && !(attacker:IsPlayer() && ai_ignoreplayers:GetBool()) then
        self:SetNPCState(NPC_STATE_COMBAT)
        self:SetEnemy(attacker)
        self:UpdateEnemyMemory(attacker, attacker:GetPos())
    end

    -- Bloody cop's AI implementation
    -- Alerts npcs who saw their ally get hurt of the ally's enemy
    if !self.DontAlertAlliesOnHurt && !ZBase_DontDontAlertAlliesOnHurt then
        self:IterateNearbyAllies(4096, function(npc)
            if ( npc:Disposition( self ) != D_LI || !npc:Visible( self ) ) then return end

            if ( IsValid( self:GetEnemy() ) ) then
                npc:UpdateEnemyMemory( self:GetEnemy(), self:GetPos() )
                -- comment@ bloodycop6385 : let's not assume that SELF was attacked by enemy. ( Rogue Rebel || smth LOL )
                -- comment@ Zippy6666 : what
                -- npc:SetNPCState( NPC_STATE_COMBAT )
                -- npc:AddEntityRelationship( self:GetEnemy(), D_HT )
            end
        end)

        self:CONV_TempVar("DontAlertAlliesOnHurt", true, 4)
        conv.tempCond("ZBase_DontDontAlertAlliesOnHurt", 1)
    end
end

function NPC:OnOwnedEntCreated( ent )
    self:CustomOnOwnedEntCreated( ent )
end

function NPC:OnParentedEntCreated( ent )
    self:CustomOnParentedEntCreated( ent )
end

function NPC:MarkEnemyAsDead( ene, time )
    self:CONV_TempVar("EnemyDied", true, time)
end

function NPC:DoMoveSpeed()
    local mult = self.MoveSpeedMultiplier * ZBCVAR.MoveSpeedMult:GetFloat()

    if !self.DoingPlayAnim then
        self:SetPlaybackRate(mult)
    end

    self:SetSaveValue("m_flTimeLastMovement", -0.1*mult)
end

function NPC:InternalOnReactToSound(ent, pos, loudness)
    if self:GetNPCState()==NPC_STATE_ALERT then
        self:CancelConversation()

        if !self:NearbyAllySpeaking({"HearDangerSounds"}) && self.NextEmitHearDangerSound < CurTime() then
            self:StopTalking()
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

function NPC:StartFollowingPlayer( ply, dontSched, skipChecks, dontReset )
    if self.ZBASE_IsPlyControlled then return end
    if self.PlayerToFollow == ply then return end

    if !skipChecks then
        if !self:IsAlly(ply) then return end
        if self:ZBaseDist(ply, {away=200}) then return end
    end

    self.PlayerToFollow = ply
    self.ZBaseFollow_DontSchedule = dontSched

    net.Start("ZBaseSetFollowHalo")
    net.WriteEntity(self)
    net.WriteString(self.Name)
    net.Send(self.PlayerToFollow)

    if !dontReset then
        self:FullReset()
        self:SetTarget(ply)
        self:SetSchedule(SCHED_TARGET_FACE)
    end

    self:EmitSound_Uninterupted(self.FollowPlayerSounds)

    self:FollowPlayerStatus(self.PlayerToFollow)
end

function NPC:StopFollowingCurrentPlayer( noSound, skipDistCheck )
    if !IsValid(self.PlayerToFollow) then return end

    if !skipDistCheck && self:ZBaseDist(self.PlayerToFollow, {away=200}) then
        return
    end

    if IsValid(self.PlayerToFollow) then
        net.Start("ZBaseRemoveFollowHalo")
        net.WriteEntity(self)
        net.WriteString(self.Name)
        net.Send(self.PlayerToFollow)
    end

    self.PlayerToFollow = NULL
    self.ZBaseFollow_DontSchedule = nil

    if !noSound then
        self:EmitSound_Uninterupted(self.UnfollowPlayerSounds)
    end

    self:FollowPlayerStatus(NULL)
end

function NPC:CanPursueFollowing()
    return IsValid(self.PlayerToFollow)
    && !self.ZBaseFollow_DontSchedule
    && !self.DontUpdatePlayerFollowing
    && self:ZBaseDist(self.PlayerToFollow, {away=200})
    && !self.ZBase_Guard
    && !self.bControllerBlock
end

function NPC:PursueFollowing()
    if !self:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
        self:SetLastPosition(self.PlayerToFollow:GetPos())
        self:SetSchedule(SCHED_FORCED_GO_RUN)
    end

    self:NavSetGoalTarget( self.PlayerToFollow, vector_origin )
    self:CONV_TempVar("DontUpdatePlayerFollowing", true, 0.5)
end

--[[
==================================================================================================
                                           AI PATROL
==================================================================================================
--]]


BEHAVIOUR.Patrol = {MustNotHaveEnemy = true}


local PatrolCvar = GetConVar("zbase_patrol")
local SchedsToReplaceWithPatrol = {
    [SCHED_IDLE_STAND] = true,
    [SCHED_ALERT_STAND] = true,
    [SCHED_ALERT_FACE] = true,
    [SCHED_ALERT_WALK] = true,
}

function BEHAVIOUR.Patrol:ShouldDoBehaviour( self )
    return PatrolCvar:GetBool() && self.CanPatrol && SchedsToReplaceWithPatrol[self:GetCurrentSchedule()]
    && self:GetMoveType() == MOVETYPE_STEP
    && !self.CurrentSchedule -- Not doing any custom SNPC schedule at the moment
end

function BEHAVIOUR.Patrol:Delay(self)
    if self.ZBase_IsMoving || self.DoingPlayAnim then
        return math.random(8, 15)
    end
end

function BEHAVIOUR.Patrol:Run( self )
    local IsAlert = self:GetNPCState() == NPC_STATE_ALERT

    if IsValid(self.PlayerToFollow) then
        self:SetSchedule(SCHED_ALERT_SCAN)
    elseif IsAlert then
        self:SetSchedule(SCHED_PATROL_RUN)
    else
        self:SetSchedule(SCHED_PATROL_WALK)
    end

    ZBaseDelayBehaviour(IsAlert && math.random(3, 6) || math.random(8, 15))
end

--[[
==================================================================================================
                                           AI CALL FOR HELP
==================================================================================================
--]]

-- Call allies outside of squad for help

local callForHelpHint           = SOUND_COMBAT
BEHAVIOUR.FactionCallForHelp    = {}

function BEHAVIOUR.FactionCallForHelp:ShouldDoBehaviour( self )
    if !ZBCVAR.CallForHelp:GetBool() then
        return false
    end

    if self.ZBASE_IsPlyControlled then return end

    local hasCallForHelp = self.AlertAllies || self.CallForHelp
    local callForHelpDist = self.AlertAlliesDistance || self.CallForHelpDistance

    if !hasCallForHelp then
        return false
    end

    return self.ZBaseFaction != "none" && self.ZBaseFaction != "neutral"
end

function BEHAVIOUR.FactionCallForHelp:Run( self )
    local hintDuration = math.Rand(2, 3.5)
    local loudestCallForHelpHint = sound.GetLoudestSoundHint(callForHelpHint, self:GetPos())
    local ene = self:GetEnemy()
    local hasEne = IsValid(ene)

    if !hasEne && istable(loudestCallForHelpHint) && loudestCallForHelpHint.owner != self then
        -- Check if someone calls me for help

        local hintOwn = loudestCallForHelpHint.owner
        local hintOwnCanBeCalledForHelp = hintOwn.CanBeAlertedByAlly || hintOwn.CanBeCalledForHelp

        if IsValid(hintOwn) && hintOwnCanBeCalledForHelp && self:Disposition(hintOwn) == D_LI then
            local hintOwnEne = hintOwn:GetEnemy()

            if IsValid(hintOwnEne) then
                self:UpdateEnemyMemory(hintOwnEne, hintOwnEne:GetPos())
                self:AlertSound()

                conv.overlay("Text", function()
                    local pos = self:GetPos()+self:GetUp()*25
                    return {pos, "Was from SOUND_COMBAT by "..(hintOwn.Name || hintOwn:GetClass()).." ("..hintOwn:EntIndex()..")", 2}
                end)
            end
        end
    elseif hasEne then
        -- Call for help

        local eneLastKnownPos = self:GetEnemyLastKnownPos()

        if isvector(eneLastKnownPos) && !eneLastKnownPos:IsZero() then
            sound.EmitHint(callForHelpHint, eneLastKnownPos, self.AlertAlliesDistance, hintDuration, self)
        end
    end

    ZBaseDelayBehaviour(hintDuration)
end

--[[
==================================================================================================
                                           AI SECONDARY FIRE
==================================================================================================
--]]

ZBaseComballOwner = NULL

BEHAVIOUR.SecondaryFire = {MustHaveVisibleEnemy = true, MustFaceEnemy = true}

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
        if self.Dead || self:GetNPCState() == NPC_STATE_DEAD then return end

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

        local att_num = wep:LookupAttachment("muzzle")
        if att_num == 0 then
            att_num = wep:LookupAttachment("0")
        end
        if att_num then
            local effectdata = EffectData()
            effectdata:SetFlags(5)
            effectdata:SetEntity(wep)
            ZBaseMuzzleFlash(self, 5, att_num)
        end

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

    local att_num = wep:LookupAttachment("muzzle")
    if att_num == 0 then
        att_num = wep:LookupAttachment("0")
    end
    local effectdata = EffectData()
    effectdata:SetFlags(5)
    effectdata:SetEntity(wep)
    ZBaseMuzzleFlash(self, 7, att_num)

    if IsValid(enemy) && enemy.IsZBaseNPC then
        enemy:RangeThreatened( self )
    end
end

function BEHAVIOUR.SecondaryFire:ShouldDoBehaviour( self )
    if !self.CanSecondaryAttack then return false end
    if self.DoingPlayAnim then return false end
    if self.bControllerBlock then return false end

    local wep = self:GetActiveWeapon()

    local wepTbl = wep.EngineCloneClass && SecondaryFireWeapons[ wep.EngineCloneClass ]
    if !wepTbl then return false end

    -- TODO: What check should be here?
    -- if !self:Weapon_WantsToShoot() then return end

    return (self.AltCount > 0 || self.AltCount == -1)
    && self:ZBaseDist( self:GetEnemy(), {within=wepTbl.dist, away=wepTbl.mindist} )
end

function BEHAVIOUR.SecondaryFire:Delay( self )
    if math.random(1, 2) == 1 then
        return math.Rand(4, 6)
    end
end

function BEHAVIOUR.SecondaryFire:Run( self )
    local enemy = self:GetEnemy()
    local wep = self:GetActiveWeapon()

    SecondaryFireWeapons[ wep.EngineCloneClass ]:Func( self, wep, enemy )

    if self.AltCount > 0 && self.AltCount != -1 then
        self.AltCount = self.AltCount - 1
    end

    ZBaseDelayBehaviour(math.Rand(4, 8))
end

-- QOL for dispatching secondary using controller
function NPC:ControllerSecondaryAttack()
    local wep = self:GetActiveWeapon()
    local ene = self:GetEnemy()

    if !IsValid(ene) then return end

    if !SecondaryFireWeapons[ wep.EngineCloneClass ] then return end

    BEHAVIOUR.SecondaryFire:Run( self )
end

--[[
==================================================================================================
                                           AI MELEE ATTACK
==================================================================================================
--]]

BEHAVIOUR.MeleeAttack = {MustHaveEnemy = true}
BEHAVIOUR.PreMeleeAttack = {MustHaveEnemy = true}

-- Don't melee push NPCs with these hulls (fairly large)
local HULL_CANNOT_PUSH = {
    [HULL_LARGE] = true,
    [HULL_LARGE_CENTERED] = true,
    [HULL_MEDIUM_TALL] = true
}

function NPC:TooBusyForMelee()
    return self.DoingPlayAnim || self.bControllerBlock
end

function NPC:CanBeMeleed( ent )
    local mtype = ent:GetMoveType()
    return mtype == MOVETYPE_STEP -- NPC
    || mtype == MOVETYPE_VPHYSICS -- Prop
    || mtype == MOVETYPE_WALK -- Player
    || ent:IsNextBot()
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
        local isFriendlyTowardsEnt = ( (disp==D_LI || disp==D_NU) && bullseyeDisp!=D_HT && bullseyeDisp!=D_FR ) && !self.ZBASE_IsPlyControlled
        local htype = ent:IsNPC() && ent:GetHullType() -- Target hull type

        -- Don't melee push NPCs with these hulls (fairly large)
        local entTooHeavyToPush = (ent:IsNPC() && HULL_CANNOT_PUSH[htype])

        local isProp = (disp == D_NU || entIsUndamagable)

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
            forcevec = self:GetForward()*(tbl.forward || 0) + self:GetUp()*(tbl.up || 0) + self:GetRight()*(tbl.right || 0)
            if tbl.randomness then
                forcevec = forcevec + VectorRand()*tbl.randomness
            end
        end

        -- Push
        if !entTooHeavyToPush && (!isFriendlyTowardsEnt || isProp) then
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

function BEHAVIOUR.MeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end
    if self:GetActiveWeapon().NPCIsMeleeWep then return false end

    local ene = self:GetEnemy()
    if !self.MeleeAttackFaceEnemy && !self:IsFacing(ene) then return false end
    if ene:IsPlayer() && !ene:Alive() then return end

    if self:PreventMeleeAttack() then return false end

    return !self:TooBusyForMelee()
    && self:ZBaseDist(ene, {within=self.MeleeAttackDistance})
end

function BEHAVIOUR.MeleeAttack:Run( self )
    self:MeleeAttack()
    ZBaseDelayBehaviour(self:SequenceDuration() + ZBaseRndTblRange(self.MeleeAttackCooldown))
end

function BEHAVIOUR.PreMeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end
    if self:TooBusyForMelee() then return false end
    return true
end

function BEHAVIOUR.PreMeleeAttack:Run( self )
    self:MultipleMeleeAttacks()
end

--[[
==================================================================================================
                                           AI RANGE ATTACK
==================================================================================================
--]]

BEHAVIOUR.RangeAttack = {MustHaveEnemy = true}

function BEHAVIOUR.RangeAttack:ShouldDoBehaviour( self )
    if !self.BaseRangeAttack then return false end -- Doesn't have range attack
    if self.DoingPlayAnim then return false end
    if self.bControllerBlock then return false end

    -- Don't range attack in mid-air
    if self:GetNavType() == 0
    && self:GetEngineClass() != "npc_manhack"
    && !self:IsOnGround() then return false end

    self:MultipleRangeAttacks()

    if self:PreventRangeAttack() then return false end

    local ene = self:GetEnemy()
    local seeEnemy = self.EnemyVisible -- IsValid(ene) && self:Visible(ene)
    local trgtPos = self:Projectile_TargetPos()

    if self.RangeAttackSuppressEnemy then
        local result = self:Weapon_SuppressionThink()
        if result == false then
            return false
        end
    end
    if !seeEnemy then return false end
    if !self:VisibleVec(trgtPos) then return false end -- Can't see target position
    if !self:ZBaseDist(trgtPos, {away=self.RangeAttackDistance[1], within=self.RangeAttackDistance[2]}) then return false end -- Not in distance

    return true
end

function BEHAVIOUR.RangeAttack:Run( self )
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

BEHAVIOUR.Grenade = {MustHaveEnemy = true}

function BEHAVIOUR.Grenade:ShouldDoBehaviour( self )
    local lastSeenPos = self:GetEnemyLastSeenPos()

    return self.BaseGrenadeAttack
    && !self.DoingPlayAnim
    && !self.bControllerBlock
    && (self.GrenCount == -1 || self.GrenCount > 0)
    && !table.IsEmpty(self.GrenadeAttackAnimations)
    && self:GetNPCState()==NPC_STATE_COMBAT
    && !lastSeenPos:IsZero()
    && self:ZBaseDist(lastSeenPos, {away=400, within=1500})
    && self:VisibleVec(lastSeenPos)
    && !(self.Patch_PreventGrenade && self:Patch_PreventGrenade())
end

function BEHAVIOUR.Grenade:Delay( self )
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

function BEHAVIOUR.Grenade:Run( self )
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
    local isGrenade = IsValid(dangerOwn) && (dangerOwn.IsZBaseGrenade || dangerOwn:GetClass() == "npc_grenade_frag")

    -- Sound
    if self.NPCNextDangerSound < CurTime() then
        self:EmitSound_Uninterupted(isGrenade && self.SeeGrenadeSounds!="" && self.SeeGrenadeSounds || self.SeeDangerSounds)
        self.NPCNextDangerSound = CurTime()+math.Rand(2, 4)
    end

    if isGrenade && self:GetNPCState()==NPC_STATE_IDLE then
        self:SetNPCState(NPC_STATE_ALERT)
    end

    if (Class_ShouldRunRandomOnDanger[self:Classify()] || self.ForceAvoidDanger) && self:GetCurrentSchedule() <= 88 && !self:IsCurrentSchedule(SCHED_RUN_RANDOM) then
        self:SetSchedule(SCHED_RUN_RANDOM)
    end

    self:CancelConversation()
end

function NPC:InDanger()
    return self.LastLoudestSoundHint && self.LastLoudestSoundHint.type == SOUND_DANGER
end

function NPC:InternalDetectDanger()
    if self.bControllerBlock then return end

	local hint = sound.GetLoudestSoundHint(SOUND_DANGER, self:GetPos())
    local IsDangerHint = (istable(hint) && hint.type==SOUND_DANGER)

    if !hint || IsDangerHint then
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

local sndVarToCapTrans = {
    AlertSounds = "[ Alert! ]",
    IdleSounds = "[ Chatter. ]",
    Idle_HasEnemy_Sounds = "[ Chatter. ]",
    DeathSounds = "[ Death! ]",
    PainSounds = "[ Pain! ]",
    KilledEnemySounds = "[ Killed enemy. ]",
    LostEnemySounds = "[ Lost enemy. ]",
    SeeDangerSounds = "[ Danger! ]",
    SeeGrenadeSounds = "[ Grenade! ]",
    AllyDeathSounds = "[ Ally dead. ]",
    OnReloadSounds = "[ Reloading. ]",
    OnGrenadeSounds = "[ Throwing grenade! ]",
    FollowPlayerSounds = "[ Following ally. ]",
    UnfollowPlayerSounds = "[ Stopped following ally. ]",
    Dialogue_Question_Sounds = "[ Conversating. ]",
    Dialogue_Answer_Sounds = "[ Conversating. ]",
    HearDangerSounds = "[ Hear sound. ]",
}
function NPC:OnEmitSound( data )
    if !self.RanInit then return end

    local altered
    local sndVarName = (data.OriginalSoundName && self.SoundVarNames[data.OriginalSoundName]) || nil

    local isVoiceSound = ( isnumber(data.SentenceIndex) || data.Channel == CHAN_VOICE )
    && !self.EmittedSoundFromSentence -- Do not count as voice sound if emitted from sentence

    local currentlySpeakingImportant = isstring(self.IsSpeaking_SoundVar)
    local goingToZBaseSpeak = (sndVarName && isVoiceSound) || false

    -- TODO: What does this do?
    if data.SoundName == "common/null.wav" then
        return false
    end

    -- Don't play engine voice sounds when dying
    if self.DoingDeathAnim && isVoiceSound && !IsEmitSoundCall then
        return false
    end

    -- Check if sound can interrupt important sounds
    local sndCanInterruptImportantSnd =
    (sndVarName=="PainSounds" || sndVarName=="DeathSounds" || sndVarName=="SeeDangerSounds")
    || (self.Patch_CanInterruptImportantVoiceSound && data.OriginalSoundName && self.Patch_CanInterruptImportantVoiceSound[data.OriginalSoundName])

    -- Did not play sound because I was already playing important voice sound
    if isVoiceSound && !sndCanInterruptImportantSnd && currentlySpeakingImportant then
        conv.devPrint(self.Name, " did not play ", sndVarName || data.OriginalSoundName || data.SoundName, ", IsSpeaking_SoundVar was ", self.IsSpeaking_SoundVar)
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

    -- LUA sentences
    local isSentence = string.EndsWith(data.SoundName, ".SS")
    if isSentence then
        local callback = function()
            if !IsValid(self) then return end
            self.IsSpeaking = nil
            self.IsSpeaking_SoundVar = nil
        end

        self:ZBaseEmitScriptedSentence(data.SoundName, self:WorldSpaceCenter(), nil, nil, callback)

        self.IsSpeaking = true
        self.IsSpeaking_SoundVar = sndVarName

        conv.devPrint(self, " emitting sentence: ", data.SoundName)

        return false
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

        return false -- Stop this sound
    elseif value == false then
        return false -- Prevent sound
    end

    if isVoiceSound then
        if !self.EmittedSoundFromSentence then
            -- Some new voice sound wants to interrupt our sentence
            -- Let it do that
            self:ZBaseStopScriptedSentence(true)
        end

        -- Register as speaking
        self.IsSpeaking = true
        self.IsSpeaking_SoundVar = sndVarName

        -- No longer speaking after sound duration
        self.InternalCurrentVoiceSoundDuration = ZBaseSoundDuration(data.SoundName)
        timer.Create("ZBaseStopSpeaking"..self:EntIndex(), self.InternalCurrentVoiceSoundDuration+0.1, 1, function()
            self.IsSpeaking = nil
            self.IsSpeaking_SoundVar = nil
        end)

        -- Misc caption
        local caption = sndVarToCapTrans[sndVarName]
        if sndVarName && caption then
            ZBaseAddCaption(false,self.Name..": "..caption, 2, data.SoundLevel || 75, self:GetPos())
        end
    end

    -- Custom on sound emitted
    self:CustomOnSoundEmitted( data, self.InternalCurrentSoundDuration, sndVarName )

    return altered
end

function NPC:NearbyAllySpeaking( soundList )
    if self.Dead || self.DoingDeathAnim then return false end -- Otherwise they might not do their death sounds

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

function NPC:StopTalking( talkCvar )
    if talkCvar then
        self:StopSound(talkCvar)
    end

    self.IsSpeaking = nil
    self.IsSpeaking_SoundVar = nil
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

BEHAVIOUR.DoIdleSound = {MustNotHaveEnemy = true}

function BEHAVIOUR.DoIdleSound:ShouldDoBehaviour( self )
    if self.IdleSounds == "" then return false end
    if self:GetNPCState() != NPC_STATE_IDLE then return false end
    if self.HavingConversation then return false end

    return true
end

function BEHAVIOUR.DoIdleSound:Delay( self )
    if self:NearbyAllySpeaking({"IdleSounds"}) || math.random(1, self.IdleSound_Chance)==1 then
        return ZBaseRndTblRange(self.IdleSoundCooldown)
    end
end

function BEHAVIOUR.DoIdleSound:Run( self )
    self:EmitSound_Uninterupted(self.IdleSounds)
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSoundCooldown))
end

--[[
==================================================================================================
                                           IDLE ENEMY SOUNDS
==================================================================================================
--]]

BEHAVIOUR.DoIdleEnemySound = {MustHaveEnemy = true}

function BEHAVIOUR.DoIdleEnemySound:ShouldDoBehaviour( self )
    if self.Idle_HasEnemy_Sounds == "" then return false end
    if self:GetNPCState() == NPC_STATE_DEAD then return false end

    return true
end

function BEHAVIOUR.DoIdleEnemySound:Delay( self )
    if self:NearbyAllySpeaking() then
        return ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown)
    end
end

function BEHAVIOUR.DoIdleEnemySound:Run( self )
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

BEHAVIOUR.Dialogue = {MustNotHaveEnemy = true}

function BEHAVIOUR.Dialogue:ShouldDoBehaviour( self )
    if self.Dialogue_Question_Sounds == "" then return false end
    if self:GetNPCState() != NPC_STATE_IDLE then return false end
    if self.HavingConversation then return false end
    if self:IsCurrentSchedule(SCHED_FORCED_GO) || self:IsCurrentSchedule(SCHED_FORCED_GO_RUN)
    || self:IsCurrentSchedule(SCHED_SCENE_GENERIC) then return false end
    return true
end

function BEHAVIOUR.Dialogue:Delay( self )
    if self:NearbyAllySpeaking() || self.HavingConversation || math.random(1, self.IdleSound_Chance)==1 then
        return ZBaseRndTblRange(self.IdleSoundCooldown)
    end
end

function BEHAVIOUR.Dialogue:Run( self )
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

        self.DialogueMate:StopTalking(self.DialogueMate.Dialogue_Question_Sounds)
        self.DialogueMate:StopTalking(self.DialogueMate.Dialogue_Answer_Sounds)

        timer.Remove("DialogueAnswerTimer"..self.DialogueMate:EntIndex())
    end

    self.HavingConversation = nil
    self.DialogueMate = nil
    self:FullReset()

    self:StopTalking(self.Dialogue_Question_Sounds)
    self:StopTalking(self.Dialogue_Answer_Sounds)

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
    if disp==D_LI && !ZBCVAR.FriendlyFire:GetBool() && !self.ZBASE_IsPlyControlled then
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
        if infl:GetClass()=="rpg_missile" || infl:GetClass() == "zb_rocket" ||  infl:GetClass()=="grenade_ar2" then
            -- RPG rocket ~ 50 dmg
            -- SMG Nade ~ 33 dmg
            dmg:ScaleDamage(0.33)
        elseif infl:GetClass() == "crossbow_bolt" then
            dmg:ScaleDamage(0.5) -- Crossbow bolt 50 dmg
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

function NPC:LastDMGINFO()
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
    if (self.CustomBloodParticles || self.CustomBloodDecals) && dmg:IsBulletDamage() then
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
    if self.DoingDeathAnim then
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

    -- Workaround so that combine ball deals dissolve damage.
    -- It does not for some reason when EFL_NO_DISSOLVE
    -- is applied.
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

    if self.Patch_TakeDamage then
        self:Patch_TakeDamage( dmg )
    end

    -- Custom damage
    if !self.CustomTakeDamageDone then
        self:CustomTakeDamage( dmg, HITGROUP_GENERIC )
        self.CustomTakeDamageDone = true
    end

    local goingToDie = self:Health()-dmg:GetDamage() <= 0

    if goingToDie then
        self.IsSpeaking = nil
    end

    -- Prevent engine gib
    if goingToDie && ShouldPreventGib[self:GetEngineClass()] then
        self.ZBasePreDeathDamageType = dmg:GetDamageType()

        if dmg:IsDamageType(DMG_DISSOLVE) || (IsValid(infl) && infl:GetClass()=="prop_combine_ball") then
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
    if !self.DeathAnimStarted
    && !table.IsEmpty(self.DeathAnimations)
    && goingToDie && math.random(1, self.DeathAnimationChance)==1 then
        self:DeathAnimation(dmg)
        return true
    end
end

-- Called last
function NPC:OnPostEntityTakeDamage( dmg )
    local MoreThan0Damage = dmg:GetDamage() > 0

    -- Custom blood
    if (self.CustomBloodParticles || self.CustomBloodDecals) && MoreThan0Damage then
        self:CustomBleed(dmg:GetDamagePosition(), dmg:GetDamageForce():GetNormalized())
    end

    -- Don't do anything if we are dead I guess?
    -- Still bleed though
    if self.Dead then
        return
    end

    self:StoreDMGINFO( dmg ) -- Remember last dmginfo again for accuracy sake

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

    local infl = dmg:GetInflictor()

    -- Return previous damage
    -- If it was altered in an effort of preventing engine gibs
    if self.ZBasePreDeathDamageType then
        dmg:SetDamageType(self.ZBasePreDeathDamageType)
    end

    -- Register as no longer speaking, this will fix death sounds not being played
    self.IsSpeaking = nil
    self.IsSpeaking_SoundVar = nil

    -- Death sound
    if !self.DoingDeathAnim then
        self:EmitSound(self.DeathSounds)
    end

    -- My honest reaction
    self:Death_AlliesReact()

    -- Drop engine weapon, not stoopid vegetable zbase weapon
    local wep = self:GetActiveWeapon()
    if IsValid(wep) && engineWeaponFlipped[wep:GetClass()] then
        self:Give(engineWeaponFlipped[wep:GetClass()])
    end

    -- Item drop
    if ZBCVAR.ItemDrop:GetBool() then
        self:Death_ItemDrop(dmg)
    end

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

    -- Do gib code
    self.ZBase_WasGibbedOnDeath = self:ShouldGib(dmg, hit_gr)

    -- Client || server ragdoll?
    local shouldCLRagdoll = ZBCVAR.ClientRagdolls:GetBool() && !ai_serverragdolls:GetBool()
    && self.HasDeathRagdoll
    self:SetShouldServerRagdoll(!shouldCLRagdoll)

    -- Set my own model to the custom ragdoll model if any
    -- so that my ragdoll has the model
    if self.RagdollModel != "" then
        self:SetModel(self.RagdollModel)
    end

    if shouldCLRagdoll then
        -- If we should client ragdoll, create a fake ragdoll on server first so that
        -- expected server stuff can still happen to the corpse
        local fakeRagdoll = !self.ZBase_WasGibbedOnDeath && self:FakeRagdoll()

        -- Run custom on death for the fake ragdoll
        self:CustomOnDeath(dmg, hit_gr, fakeRagdoll || NULL)

        if IsValid(fakeRagdoll) then
            -- If the server ragdoll is valid (i.e. the fake ragdoll in this case)..

            -- This makes so that the client ragdoll has the desired bodygroups
            for k, v in pairs(fakeRagdoll:GetBodyGroups()) do
                self:SetBodygroup(v.id, fakeRagdoll:GetBodygroup(v.id))
            end

            -- And the desired model
            if fakeRagdoll:GetModel()!=self:GetModel() then
                self:SetModel(fakeRagdoll:GetModel())
            end

            -- And the desired skin
            if fakeRagdoll:GetSkin() != self:GetSkin() then
                self:SetSkin(fakeRagdoll:GetSkin())
            end
        end
    end
end

function NPC:InternalOnAllyDeath()
    -- All nearby allies stop talking
    self:StopTalking(self.IdleSounds)
    self:CancelConversation()
end

function NPC:ImTheNearestAllyAndThisIsMyHonestReaction( deathpos )
    if self.AllyDeathSound_Chance && math.random(1, self.AllyDeathSound_Chance) == 1 then
        timer.Simple(0.5, function()
            if IsValid(self) then
                self:EmitSound_Uninterupted(self.AllyDeathSounds)

                local npcstate = self:GetNPCState()

                if self.AllyDeathSounds != "" && ( npcstate==NPC_STATE_IDLE || npcstate==NPC_STATE_ALERT ) then
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


function NPC:FakeRagdoll()
	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self.RagdollModel == "" && self:GetModel() || self.RagdollModel)
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

-- LEGACY
function NPC:BecomeRagdoll( dmg, hit_gr, keep_corpse )
    error("Tried using legacy ZBase function: 'NPC.BecomeRagdoll'!")
end

-- Create server ragdoll manually with LUA, this may be desired at times
function NPC:MakeShiftRagdoll()
	if !self.HasDeathRagdoll then return end
    if self.ZBase_WasGibbedOnDeath then return end

    local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self.RagdollModel == "" && self:GetModel() || self.RagdollModel)
    rag:SetPos(self:GetPos())
    rag:SetAngles(self:GetAngles())
	rag:SetSkin(self:GetSkin())
	rag:SetColor(self:GetColor())
	rag:SetMaterial(self:GetMaterial())
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

    local dmg = self:LastDMGINFO() -- Get last damage info

    -- Create basic damage info if none was stored
    if !dmg then
        dmg = DamageInfo()
        dmg:SetDamageForce(vector_up)
        dmg:SetDamagePosition(self:GetPos())
        dmg:SetInflictor(self)
        dmg:SetAttacker(self)
        dmg:SetDamageType(DMG_GENERIC)
    end

	local physcount = rag:GetPhysicsObjectCount()
    local dmgpos = dmg:GetDamagePosition()
    local force = self.RagdollApplyForce && (
        dmg:GetDamageForce()*0.02  + self:GetMoveVelocity() + self:GetVelocity()
    )
    local forcemaxnoise = force && force:Length()*0.3
    local closestPhys
    local mindist = math.huge
	for i = 1, physcount - 1 do
		-- Placement
		local physObj = rag:GetPhysicsObjectNum(i)
        local bone = self:TranslatePhysBoneToBone(i)
		local pos, ang = self:GetBonePosition(bone)
        local distsqrFromDmg = pos:DistToSqr(dmg:GetDamagePosition())

        if distsqrFromDmg < mindist then
            mindist = distsqrFromDmg
            closestPhys = physObj
        end

        if !self.RagdollUseAltPositioning then
		    physObj:SetPos( pos )
        end

        if !self.RagdollDontAnglePhysObjects then
	        physObj:SetAngles( ang )
        end

        if force then
            physObj:SetVelocity(force + VectorRand()*forcemaxnoise)
        end
	end

    -- Apply more force to the closest bone to the damage
    if closestPhys && force then
        closestPhys:ApplyForceCenter(force)
    end

	-- Dissolve
    local infl = dmg:GetInflictor()
    local isDissolveDMG = dmg:IsDamageType(DMG_DISSOLVE)
	if isDissolveDMG && self.DissolveRagdoll then
		rag:SetName( "base_ai_ext_rag" .. rag:EntIndex() )

		local dissolve = ents.Create("env_entity_dissolver")
		dissolve:SetKeyValue("target", rag:GetName())
		dissolve:SetKeyValue("dissolvetype", dmg:IsDamageType(DMG_SHOCK) && 2 || 0)
		dissolve:Fire("Dissolve", rag:GetName())
		dissolve:Spawn()
		rag:DeleteOnRemove(dissolve)

        rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end

	-- Ignite
	if self:IsOnFire() then
		rag:Ignite(math.Rand(4,8))
	end

	-- Hook
	hook.Run("CreateEntityRagdoll", self, rag)
end

--[[
==================================================================================================
                                           GIBS
==================================================================================================
--]]

function NPC:InternalCreateGib( model, data )
    data = data || {}

    -- Create
    local entclass = !data.IsRagdoll && "zb_temporary_ent" || "prop_ragdoll"
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

            if data.IsRagdoll && data.SmartPositionRagdoll then
                local bonepos = self:GetBonePosition( self:TranslatePhysBoneToBone(i) )
                phys:SetPos( bonepos )
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
    -- Emitted death sounds, don't emit again on actual death
    self.DeathSounds = ""

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
