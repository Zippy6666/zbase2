util.AddNetworkString("ZBaseGlowEyes")


--[[
==================================================================================================
                    !! YOU GOT NOTHING TO DO HERE BOYE, GO BACK TO npc_base_init !!
==================================================================================================
--]]

local NPC = ZBaseNPCs["npc_zbase"]
local NPCB = ZBaseNPCs["npc_zbase"].Behaviours



local function ListConditions(npc, dur)
    dur = dur or 0.13
	
	if(!IsValid(npc)) then return end

    local cond_count = 0
	
	for c = 0, 100 do
	
		if(npc:HasCondition(c)) then
		
			-- MsgN(npc:ConditionName(c))
            debugoverlay.Text(npc:GetPos()+npc:GetUp()*cond_count*10+npc:GetRight()*40, npc:ConditionName(c), dur)
			
            cond_count = cond_count + 1

		end
		
	end
	
end


local Developer = GetConVar("developer")
local function ZBaseDOverlay( funcname, argsFunc )
    if !Developer:GetBool() then return end
    local args = argsFunc()
    debugoverlay[funcname](unpack(args))
end


--[[
==================================================================================================
                                           INIT BRUV
==================================================================================================
--]]


    -- Called before spawn if it can, otherwise just before ZBaseInit
function NPC:BeforeSpawn( NPCData )
    
    self.AllowedCustomEScheds = {}
    self.ProhibitCustomEScheds = false


    -- Needed for some NPCs to allow them to spawn with weapons
    self:CapabilitiesAdd(CAP_USE_WEAPONS)
    

    self.BeforeSpawnDone = true

end


function NPC:ZBaseInit()

    -- "Before spawn"
    if !self.BeforeSpawnDone then
        self:BeforeSpawn()
    end


    -- Set model
    if self.SpawnModel && self.SpawnModel != self:GetModel() then

        local mins, maxs = self:GetCollisionBounds() -- Default collision bounds, not affected by base

        -- Set model but maintain bounds and don't enter tpose
        self:SetModel(self.SpawnModel)
        self:SetCollisionBounds(mins, maxs)
        self:ResetIdealActivity(ACT_IDLE)

    end


    -- Set health
    self:SetMaxHealth(self.StartHealth*ZBCVAR.HPMult:GetFloat())
    self:SetHealth(self.StartHealth*ZBCVAR.HPMult:GetFloat())


    -- Vars
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
    self.InternalDistanceFromGround = self.Fly_DistanceFromGround
    self.ZBLastHitGr = HITGROUP_GENERIC
    self.PlayerToFollow = NULL
    self.GuardSpot = self:GetPos()
    self:InitGrenades()
    self:SetNWBool("IsZBaseNPC", true)
    self:SetNWString("ZBaseName", self.Name)
    self:SetNWString("NPCName", self.NPCName)
    self:AddEFlags(EFL_NO_DISSOLVE)


    -- Rendermode
    self:SetRenderMode(self.RenderMode)


    -- Forces npcs with "target" keyvalue to walk
    self:Fire("wake") 


    -- Submaterials
    for k, v in pairs(self.SubMaterials) do
        self:SetSubMaterial(k-1, v)
    end


    -- Collisions and shit
    self:InitBounds()


    -- Set specified internal variables
    for varname, var in pairs(self.EInternalVars or {}) do
        self:SetSaveValue(varname, var)
    end


    if !self.DontAutoSetSquad then
        self:SetSquad("zbase") -- Basic squad, will be replaced with faction later
    end


    self:CallNextTick("InitNextTick")


    -- On remove
    self:CallOnRemove("ZBaseOnRemove", function()
        self:InternalOnRemove()
        self:OnRemove()
    end)


    -- Weapon system
    self:ZBWepSys_Init()


    -- Glowing eyes
    self:GlowEyeInit()


    -- Makes behaviour system function
    ZBaseBehaviourInit( self )


    -- Custom init
    self:CustomInitialize()
end


function NPC:InitNextTick()
    -- Blood color
    self:SetBloodColor(self.BloodColor)

    -- Auto set npc class
    if self.IsZBase_SNPC && self:GetNPCClass() == -1 && ZBaseFactionTranslation_Flipped[ZBaseGetFaction(self)] then
        self:SetNPCClass(ZBaseFactionTranslation_Flipped[ZBaseGetFaction(self)])
    end

    self:CallNextTick("Init2Ticks")
end


function NPC:Init2Ticks()
    -- Weapon proficiency
    self:SetCurrentWeaponProficiency(self.WeaponProficiency)


    -- Some calls based on attributes
    self:SetCurrentWeaponProficiency(self.WeaponProficiency)
    self:SetBloodColor(self.BloodColor)


    -- FOV and sight dist
    self.FieldOfView = math.cos( (self.SightAngle*(math.pi/180))*0.5 )
    self:SetSaveValue( "m_flFieldOfView", self.FieldOfView )
    self:SetMaxLookDistance(self.SightDistance)


    -- Phys damage scale
    self:Fire("physdamagescale", self.PhysDamageScale)


    -- Set specified internal variables (again just to be sure)
    self:CapabilitiesClear()
    self:InitCap()


    -- Set squad name to faction name
    if !self.DontAutoSetSquad
    && self.ZBaseFaction != "none" then
        self:SetSquad(self.ZBaseFaction)
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

    
    -- Basics
    self:CapabilitiesAdd(CAP_SKIP_NAV_GROUND_CHECK)
    self:CapabilitiesAdd(CAP_USE_SHOT_REGULATOR)
    self:CapabilitiesAdd(CAP_DUCK)
    self:CapabilitiesAdd(CAP_MOVE_SHOOT)
    self:CapabilitiesAdd(CAP_SQUAD)
    self:CapabilitiesAdd(CAP_USE_WEAPONS)
    self:CapabilitiesAdd(CAP_FRIENDLY_DMG_IMMUNE)


    -- Door/button stuff
    if self.CanOpenDoors then
        self:CapabilitiesAdd(CAP_OPEN_DOORS)
    end
    if self.CanOpenAutoDoors then
        self:CapabilitiesAdd(CAP_AUTO_DOORS)
    end
    if self.CanPushButtons then
        self:CapabilitiesAdd(CAP_USE)
    end


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
    if self:SelectWeightedSequence(ACT_RANGE_ATTACK1) != -1 && self:GetClass() != "npc_antlion" then
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
	if self.SNPCType == ZBASE_SNPCTYPE_FLY then
		self:SetNavType(NAV_FLY)
    else
        self:CapabilitiesAdd(CAP_MOVE_GROUND)
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


local AIDisabled = GetConVar("ai_disabled")


function NPC:ZBaseThink()

    -- Don't think if has EFL_NO_THINK_FUNCTION
    if bit.band(self:GetFlags(), EFL_NO_THINK_FUNCTION )==EFL_NO_THINK_FUNCTION then
        return
    end


    local isAIEnabled = !AIDisabled:GetBool()
    local ene = self:GetEnemy()
    local sched = self:GetCurrentSchedule()
    local seq = self:GetSequence()
    local act = self:GetActivity()



    if isAIEnabled then
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
            
            self.ZBaseLastESched = sched
            self.ZBaseLastESchedName = name

        end


        -- Handle danger
        if self.LastLoudestSoundHint then
            self:HandleDanger()
        end


        -- Sched and state debug
        if ZBCVAR.ShowSched:GetBool() then

            ZBaseDOverlay( "Text", function()

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
        if self.NextFootStepTimer < CurTime() && self:GetNavType()==NAV_GROUND then
            self:FootStepTimer()
        end


        -- Move anim override
        self.LastMoveActOverride = self:OverrideMovementAct()
        self.MovementOverrideActive = isnumber(self.LastMoveActOverride)
        if self.MovementOverrideActive then
            self:SetMovementActivity(self.LastMoveActOverride)
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


    -- Controller
    if self.IsZBPlyControlled then
        self:ControllerThink()
    end


    -- Custom think
    self:CustomThink()


end


function NPC:DoSlowThink()

    -- Remove squad if faction is 'none'
    if self.ZBaseFaction == "none" && self:SquadName()!="" then
        self:SetSquad("")
    end


    self:AITick_Slow()

end


function NPC:FrameTick()

    local isAIEnabled = !AIDisabled:GetBool()

    -- Move speed changer
    if isAIEnabled && self.MoveSpeedMultiplier != 1 && !self.DoingPlayAnim && self:IsMoving() then
        self:DoMoveSpeed()
    end

    if self.DoingPlayAnim && !self.IsZBase_SNPC then
        self:ExecuteWalkFrames(0.3)
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

    -- Reload ZBase weapon (ZBase weapon only for now)
    -- local wep = self:GetActiveWeapon()
    -- if key==IN_RELOAD && IsValid(wep) && wep.IsZBaseWeapon && !self:IsCurrentSchedule(SCHED_RELOAD) && self.ZBWepSys_PrimaryAmmo < wep.Primary.DefaultClip then
    --     print("test")
    --     self:SetSchedule(SCHED_RELOAD)
    -- end

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


-- https://wiki.facepunch.com/gmod/Hold_Types
local HoldTypeFallback = {
    ["pistol"] = "revolver",	-- One hand grasp used for pistols
    ["smg"] = "ar2",	-- Used for two-handed weapons such as the SMG1 ( rifles with a grip )
    ["grenade"] = "passive",	-- Used for grenade, similar to melee
    ["ar2"] = "shotgun",	-- Used for two-handed weapons such as the AR2 ( rifles without a grip )
    ["shotgun"] = "ar2",	-- Used for weapons such as shotguns
    ["rpg"] = "ar2",	-- Used for weapons that rest on your shoulder, such as RPG
    ["physgun"] = "shotgun",	-- Used for the gravity and physics guns
    ["crossbow"] = "shotgun",	-- Used for weapons such as crossbows, very similar to shotgun
    ["melee"] = "passive",	-- Hand raised above head, used for crowbar
    ["slam"] = "passive",	-- Used for weapons such as SLAM/explosives/c4
    ["fist"] = "passive",	-- Hands up punching hold type
    ["melee2"] = "passive",	-- Two-handed sword
    ["knife"] = "passive",	-- Bent over stabbing hold type
    ["duel"] = "pistol",	-- Dual pistols hold type
    ["camera"] = "revolver",	-- Holds the weapon in front of your face as a camera
    ["magic"] = "passive", -- Use your power of will to move objects. One hand in front of you, one hand to your head
    ["revolver"] = "pistol", -- wo hand pistol holdtype, revolver reload animation.
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


function NPC:ZBWepSys_Init()

    self.ZBWepSys_Inventory = {}

    
    self.ZBWepSys_NextBurst = CurTime()
    self.ZBWepSys_NextShoot = CurTime()


    self.ZBWepSys_InShootDist = false


    local wep = self:GetActiveWeapon()
    if IsValid(wep) && !wep:IsScripted() then
        wep:SetNoDraw(true)
    end

end


function NPC:ZBWepSys_HasPlayerModel()
    local SubModels = self:GetSubModels()
    return istable(SubModels) && SubModels[1] && SubModels[1].name && SubModels[1].name=="models/m_anm.mdl"
end


function NPC:ZBWepSys_Reload()

    -- On reload weapon


    local wep = self:GetActiveWeapon()


    -- Weapon reload sound
    if wep.IsZBaseWeapon && wep.NPCReloadSound != "" then
        wep:EmitSound(wep.NPCReloadSound)
    end


    -- Refill ammo
    timer.Create("ZBaseReloadWeapon"..self:EntIndex(), self:SequenceDuration()*0.7 / self:GetPlaybackRate(), 1, function()

        if !IsValid(self) or !IsValid(self:GetActiveWeapon()) then return end

        local CurrentStrAct = self:GetSequenceActivityName( self:GetSequence() )
        local StillReloading = string.find(CurrentStrAct, "RELOAD") != nil


        if StillReloading then

            self.ZBWepSys_PrimaryAmmo = self:GetActiveWeapon().Primary.DefaultClip

            self:ClearCondition(COND.LOW_PRIMARY_AMMO)
            self:ClearCondition(COND.LOW_PRIMARY_AMMO)

        end

    end)

end


function NPC:ZBWepSys_SetHoldType( wep, startHoldT, isFallBack, lastFallBack, isFail )

    -- Do simple setholdtype for player models
    if self:ZBWepSys_HasPlayerModel() then
        wep:SetHoldType(startHoldT)
        return
    end



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
function NPC:ZBWepSys_SetActiveWeapon( class )

    if !self.ZBWepSys_Inventory[class] then return end


    local WepData = self.ZBWepSys_Inventory[class]


    local Weapon = self:Give( WepData.isScripted && class or "weapon_zbase" )
    Weapon.FromZBaseInventory = true
    -- Weapon:SetRenderMode(RENDERMODE_TRANSCOLOR)
    -- Weapon:SetColor(barely_visible)


    if !WepData.isScripted then
        
        Weapon:SetNWString("ZBaseNPCWorldModel", WepData.model)
        self:ZBWepSys_EngineCloneAttrs( Weapon, class )

    end


    if Weapon.NPCHoldType then
        self:ZBWepSys_SetHoldType( Weapon, Weapon.NPCHoldType )
    end


    if Weapon.IsZBaseWeapon then
        self.ZBWepSys_PrimaryAmmo = Weapon.Primary.DefaultClip
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
    

    self.ZBWepSys_ShotsLeft = self.ZBWepSys_ShotsLeft && (self.ZBWepSys_ShotsLeft - 1) or self:ZBNWepSys_NewNumShots()-1


    if self.ZBWepSys_ShotsLeft <= 0 then

        local RestTimeMin, RestTimeMax = wep:GetNPCRestTimes()
        local RndRest = math.Rand(RestTimeMin, RestTimeMax)


        self.ZBWepSys_NextBurst = CurTime()+RndRest
        self.ZBWepSys_ShotsLeft = nil

    end


    local _, _, cooldown = wep:ZBaseGetNPCBurstSettings()
    self.ZBWepSys_NextShoot = CurTime()+cooldown

end


    -- WIP
function NPC:ZBWepSys_ControllerWantsToShoot()
    return false
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


function NPC:ZBWepSys_AIWantsToShoot()
    local ene = self:GetEnemy()


    -- Enemy valid and visible
    return self.EnemyVisible

    -- Enemy is within shoot distance
    && self.ZBWepSys_InShootDist

    -- Weapon LOS COND
    && self:HasCondition(COND.WEAPON_HAS_LOS)

    -- Facing enemy
    && self:IsFacing(ene)

    -- Take turns firing
    && !(  ZBCVAR.MaxNPCsShootPly:GetBool() && ene:IsPlayer() && istable(ene.AttackingZBaseNPCs) && self:ZBWepSys_TooManyAttacking(ene)  )
end


function NPC:ZBWepSys_WantsToShoot()

    local ShootSchedBlacklist = {
        [SCHED_RELOAD] = true,
        [SCHED_HIDE_AND_RELOAD] = true,
        [SCHED_NPC_FREEZE] = true,
        [ZBaseESchedID("SCHED_COMBINE_HIDE_AND_RELOAD")] = true,
        [ZBaseESchedID("SCHED_METROPOLICE_WARN_AND_ARREST_ENEMY")] = true,
    }


    return !self.DoingPlayAnim

    && (self:ZBWepSys_AIWantsToShoot() or self:ZBWepSys_ControllerWantsToShoot())

    -- Not in illegal sched
    && !ShootSchedBlacklist[ self:GetCurrentSchedule() ]

    -- Should fire wep check, should be last
    && self:ShouldFireWeapon()

end


function NPC:ZBWepSys_CanFireWeapon()

    -- Ready to fire
    return self:ZBWepSys_WantsToShoot()

    && self:ZBWepSys_HasShootAnim()

    && self.ZBWepSys_NextShoot < CurTime()

    -- Volley has started
    && self.ZBWepSys_NextBurst < CurTime()

    && !self.ComballAttacking

end


local strNeedles = {
    "RIFLE",
    "PISTOL",
    "SHOTGUN",
    "RANGE_ATTACK",
}
function NPC:ZBWepSys_HasShootAnim()
    local strMoveAct = self:GetSequenceActivityName(self:GetMovementSequence())
    local strAct = self:GetSequenceActivityName(self:GetSequence())

    for _, needle in ipairs(strNeedles) do
        if string.find(strAct, needle) or string.find(strMoveAct, needle) then
            return true
        end
    end

    return false
end


-- function NPC:ZBWepSys_ForceShootStance()
--     ZBaseDOverlay("Text", function()
--         return {self:GetShootPos(), "Force shoot stance", 0.13}
--     end)

--     if self:IsMoving() && !self.MovementOverrideActive then
--         self:SetMovementActivity(ACT_RUN_AIM)
--     else
--         self:SetActivity(ACT_RANGE_ATTACK1)
--     end
-- end


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

        local lastpos = ene:GetPos()+ene:GetForward()*ene:OBBMaxs().x*3
        self:SetLastPosition(lastpos)
        self:SetSchedule(OutOfShootRangeSched)
        self.NextOutOfShootRangeSched = CurTime()+3

        ZBaseDOverlay("Text", function()
            local pos = self:GetPos()
            return {pos, "Doing base out of shoot range behaviour.", 2}
        end)

        ZBaseDOverlay("Cross", function()
            return {lastpos, 30, 2, Color(0, 255, 0)}
        end)

    end


    -- Here is where the fun begins
    if self:ZBWepSys_CanFireWeapon() then

        -- Check ammo, and apply COND_
        if self.ZBWepSys_PrimaryAmmo <= 0 then

            -- No ammo

            self.ZBWepSys_AllowShoot = false

            if !self:HasCondition(COND.NO_PRIMARY_AMMO) then
                self:SetCondition(COND.NO_PRIMARY_AMMO)
            end

        elseif self.ZBWepSys_PrimaryAmmo <= wep.Primary.DefaultClip*0.25 then

            -- Low ammo

            self.ZBWepSys_AllowShoot = true

            if !self:HasCondition(COND.LOW_PRIMARY_AMMO) then
                self:SetCondition(COND.LOW_PRIMARY_AMMO)
            end

        else

            -- Reset COND_
            if self:HasCondition(COND.NO_PRIMARY_AMMO) then
                self:ClearCondition(COND.NO_PRIMARY_AMMO)
            end
            if self:HasCondition(COND.LOW_PRIMARY_AMMO) then
                self:ClearCondition(COND.LOW_PRIMARY_AMMO)
            end


            -- Has ammo
            self.ZBWepSys_AllowShoot = true

        end


        -- Should shoot
        if self.ZBWepSys_AllowShoot then

            -- Shoot
            self:ZBWepSys_Shoot()


            -- Force shoot stance if NPC doesn't do any
            -- if !self:ZBWepSys_HasShootAnim() then
            --     self:ZBWepSys_ForceShootStance()
            -- end
        

            -- Pose parameters for snpc
            -- if self.IsZBase_SNPC && self:HasCapability(CAP_AIM_GUN) then

            --     local aimAng = self:GetAimVector():Angle()
            --     local ideal_poseparam_ang = self:WorldToLocalAngles(aimAng)
            --     local x, y = ideal_poseparam_ang.x, ideal_poseparam_ang.y

            --     self:SetPoseParameter("aim_pitch", x)
            --     self:SetPoseParameter("aim_yaw", y)

            -- end


            -- Make sure yaw is precise when standing and shooting
            if !self:IsMoving() then
                self:SetIdealYawAndUpdate((ene:WorldSpaceCenter() - self:GetShootPos()):Angle().yaw, -2)
            end


            self:OnFireWeapon()


            -- Reset var
            self.ZBWepSys_AllowShoot = false

        end

    end

end



function NPC:ZBWepSys_MeleeThink()

    local ene = self:GetEnemy()

    if IsValid(ene) then

        if !self.DoingPlayAnim && self:ZBaseDist(ene, {within=ZBaseRoughRadius(ene)}) then

            self:Weapon_MeleeAnim()


            timer.Simple(self.MeleeWeaponAnimations_TimeUntilDamage, function()
                if IsValid(self) then
                    self:GetActiveWeapon():NPCMeleeWeaponDamage()
                end
            end)

        end
    

        if !self:IsMoving() && !self:IsCurrentSchedule(SCHED_TARGET_CHASE) then

            self:SetTarget(ene)
            self:SetSchedule(SCHED_TARGET_CHASE)

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
            ZBaseDOverlay("Line", function()
                local center = self:WorldSpaceCenter()
                return {center, center+self:GetForward()*maxShootDist, 2, Color(255, 196, 0)}
            end)

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


    -- OLD and should probably be rewritten...
    -- Make the NPC face certain directions
    -- 'face' - A position or an entity to face, or a  representing the yaw.
    -- 'duration' - Face duration, if not set, you can run the function in think for example
    -- 'speed' - Turn speed, if not set, it will be the default turn speed
function NPC:Face( face, duration, speed )

    local function turn( yaw )
        if self:IsMoving() then return end


        local sched = self:GetCurrentSchedule()
        if sched > 88 then return end
    

        local ForbiddenScheds = {
            [SCHED_ALERT_FACE]	= true,
            [SCHED_ALERT_FACE_BESTSOUND]	= true,
            [SCHED_COMBAT_FACE] 	= true,
            [SCHED_FEAR_FACE] 	= true,	
            [SCHED_SCRIPTED_FACE] 	= true,	
            [SCHED_TARGET_FACE]	= true,
            [SCHED_RANGE_ATTACK1] = true,
        }


        if ForbiddenScheds[sched] then return end
        

        local turnSpeed = speed or self:GetInternalVariable("m_fMaxYawSpeed") or 15
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

        timer.Remove("ZBaseFace"..self:EntIndex())
        faceFunc()

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


function NPC:FullReset()
    self:TaskComplete()
    self:ClearGoal()
    self:ClearSchedule()
    self:StopMoving()
    self:SetMoveVelocity(vector_origin)

    if self.IsZBase_SNPC then
        self:AerialResetNav()
        self:ScheduleFinished()
    end
end


function NPC:HasCapability( cap )
    return bit.band(self:CapabilitiesGet(), cap)==cap
end


--[[
==================================================================================================
                                           ANIMATION
==================================================================================================
--]]


function NPC:InternalPlayAnimation(anim, duration, playbackRate, sched, forceFace, faceSpeed, loop, onFinishFunc, isGest, isTransition, noTransitions, moreArgs)
    if self.Dead or self.DoingDeathAnim then return end
    if !anim then return end



    if isGest && !self.IsZBase_SNPC && ZBaseIsMP then return end -- Don't do gestures on non-scripted NPCs in multiplayer, it seems to be broken


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
    --------------------------------------=#


    -- Main function --
    local function playAnim()
        local lastEne = self:GetEnemy() -- Store enemy


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
        if !duration then
            duration = (self:SequenceDuration(anim)*0.9)/(playbackRate or self.MoveSpeedMultiplier or 1)
        elseif isnumber(duration) then
            duration = duration/(playbackRate or self.MoveSpeedMultiplier or 1)
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


            -- Update enemy memory, since the frozen state makes it forget
            -- if IsValid(lastEne) then
            --     self:UpdateEnemyMemory( lastEne, self:GetEnemyLastSeenPos() )
            -- end

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
    self:SetMoveYawLocked(false)


    self.DoingPlayAnim = false
    self.PlayAnim_Face = nil
    self.PlayAnim_FaceSpeed = nil
    self.PlayAnim_PlayBackRate = nil
    self.PlayAnim_Seq = nil


    timer.Remove("ZBasePlayAnim"..self:EntIndex())
    timer.Remove("ZBaseFace"..self:EntIndex())
    timer.Remove("ZBaseForceWalkFrames"..self:EntIndex())
end


function NPC:HandleAnimEvent(event, eventTime, cycle, type, options)       
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
    local ene = self:GetEnemy()
    local IsAlert = self:GetNPCState() == NPC_STATE_ALERT
    local IsCombat = self:GetNPCState() == NPC_STATE_COMBAT


    -- Flying SNPCs should get closer to the ground during melee --
    if self.IsZBase_SNPC
    && self.BaseMeleeAttack
    && self.SNPCType == ZBASE_SNPCTYPE_FLY
    && self.Fly_DistanceFromGround_IgnoreWhenMelee
    && IsValid(ene)
    && self:ZBaseDist(ene, {within=self.MeleeAttackDistance*1.75}) then
        self.InternalDistanceFromGround = ene:WorldSpaceCenter():Distance(ene:GetPos())
    else
        self.InternalDistanceFromGround = self.Fly_DistanceFromGround
    end
    ---------------------------------------------------------------=#


    -- Update current danger
    self:InternalDetectDanger()



    -- Loose enemy
    if IsValid(ene) && !self.EnemyVisible && CurTime()-self:GetEnemyLastTimeSeen() >= self.TimeUntilLooseEnemy then

        ZBaseDOverlay("Text", function()
            local pos = self:GetPos()
            return {pos, "Marked "..tostring(ene).. " eluded.", 2}
        end)

        self:MarkEnemyAsEluded()
    
    end



    -- In combat
    if IsCombat then

        -- Reset stop alert if in combat
        self.NextStopAlert = nil


        if IsValid(ene) then
            self.DoEnemyLostSoundWhenLost = true
            self.GotoEneLastKnownPosWhenEluded = true
        end

    end


    -- Is alert, start timer
    if IsAlert && !self.NextStopAlert then
        self.NextStopAlert = CurTime()+self.TimeUntilExitAlert
    end


    -- Stop alert timer out, back to idle
    if IsAlert && self.NextStopAlert && self.NextStopAlert < CurTime() then
        self:SetNPCState(NPC_STATE_IDLE)
        self.NextStopAlert = nil
        ZBaseDOverlay("Text", function()
            local pos = self:GetPos()
            return {pos, "Alert time elapsed, switching to NPC_STATE_IDLE", 2}
        end)
    end


    -- Follow player that we should follow
    if self:CanPursueFollowing() then
        self:PursueFollowing()
    end

    -- Stop following if no longer allied
    if IsValid(self.PlayerToFollow) && !self:IsAlly(self.PlayerToFollow) then
        self:StopFollowingCurrentPlayer(true)
    end

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


    self:OnRangeThreatened(threat)


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

    if self:GetActiveWeapon().IsZBaseWeapon && string.find(self:GetSequenceActivityName(seq), "RELOAD") != nil then

        -- Reload announce sound
        if math.random(1, self.OnReloadSound_Chance) == 1 then
            self:EmitSound_Uninterupted(self.OnReloadSounds)
        end


        self:ZBWepSys_Reload()

    end

    self:CustomNewSequenceDetected( seq, seqName )

end


function NPC:NewSchedDetected( sched, schedName )
    self:CustomNewSchedDetected(sched, self.ZBaseLastESched or -1)
end


function NPC:DoNewEnemy()

    local ene = self:GetEnemy()


    ZBaseDOverlay("Text", function()
        local pos = self:WorldSpaceCenter()
        return {pos, "DoNewEnemy:  "..tostring(ene), 2}
    end)

    if IsValid(ene) then
        -- New enemy
        -- Do alert sound
        
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
    if !IsValid(ene) && self.HadPreviousEnemy && !self.EnemyDied && !self:NearbyAllySpeaking({"LostEnemySounds"}) then

        self:LostEnemySound()
        self:EmitSound_Uninterupted(self.LostEnemySounds)
        self.DoEnemyLostSoundWhenLost = false

    end


    self:EnemyStatus(ene, self.HadPreviousEnemy)
    self.HadPreviousEnemy = ene && true or false

end


function NPC:OnOwnedEntCreated( ent )
    ent.LastOwnerZBaseFaction = self.ZBaseFaction
    self:CustomOnOwnedEntCreated( ent )
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


function NPC:DoMoveSpeed()
    self:SetPlaybackRate(self.MoveSpeedMultiplier)
    self:SetSaveValue("m_flTimeLastMovement", -0.1*self.MoveSpeedMultiplier)
end


function NPC:OnReactToSound(ent, pos, loudness)
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

        ZBaseDOverlay("Sphere", function()
            return {newDest, 25, 3, Color(0, 0, 255)}
        end)

        ZBaseDOverlay("Text", function()
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


    self.PlayerToFollow = ply


    net.Start("ZBaseSetFollowHalo")
    net.WriteEntity(self)
    net.Send(self.PlayerToFollow)

    -- self:SetTarget(ply)
    -- self:SetSchedule(SCHED_TARGET_FACE)

    self:EmitSound_Uninterupted(self.FollowPlayerSounds)


    self:FollowPlayerStatus(self.PlayerToFollow)
end


function NPC:StopFollowingCurrentPlayer( noSound )
    net.Start("ZBaseRemoveFollowHalo")
    net.WriteEntity(self)
    net.Send(self.PlayerToFollow)

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
    return PatrolCvar:GetBool() && self.CanPatrol && SchedsToReplaceWithPatrol[self:GetCurrentSchedule()] && self:GetMoveType() == MOVETYPE_STEP
end


function NPCB.Patrol:Delay(self)
    if self:IsMoving() or self.DoingPlayAnim then
        return math.random(8, 15)
    end
end


function NPCB.Patrol:Run( self )
    local IsAlert = self:GetNPCState() == NPC_STATE_ALERT


    if IsValid(self.PlayerToFollow) && !self:IsMoving() then

        self:SetSchedule(SCHED_ALERT_SCAN)

        ZBaseDOverlay("Text", function()
            return {self:GetPos(), "SCHED_ALERT_SCAN as patrol.", 2}
        end)

    elseif IsAlert then

        self:SetSchedule(SCHED_PATROL_RUN)
    
        ZBaseDOverlay("Text", function()
            return {self:GetPos(), "Alert patrol.", 2}
        end)

    else

        self:SetSchedule(SCHED_PATROL_WALK)
    
        ZBaseDOverlay("Text", function()
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
    return self.CallForHelp && self.CallForHelpDistance > 0
    && self.ZBaseFaction != "none" && self.ZBaseFaction != "neutral"
    && ZBCVAR.CallForHelp:GetBool()
end


function NPCB.FactionCallForHelp:Run( self )
    local ally = self:GetNearestAlly(self.CallForHelpDistance)
    local ene = self:GetEnemy()

    if IsValid(ally) && ally:IsNPC() && ally.CanBeCalledForHelp && !IsValid(ally:GetEnemy()) && !ally:HasEnemyEluded(ene)
    && self:GetSquad()!=ally:GetSquad() then

        ally:UpdateEnemyMemory(ene, self:GetEnemyLastSeenPos())
        ally:AlertSound()

        ZBaseDOverlay("Text", function()
            local pos = self:GetPos()+self:GetUp()*25
            return {pos, "Was called by ally.", 2}
        end)

        self:OnCallForHelp(ally)

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
        if ent == self then continue end
        if ent.GetNPCState && ent:GetNPCState() == NPC_STATE_DEAD then continue end

        local disp = self:Disposition(ent)
        if (!dmgData.affectProps && disp == D_NU) then continue end

        if !self:Visible(ent) then continue end


        local entpos = ent:WorldSpaceCenter()
        local undamagable = (ent:Health()==0 && ent:GetMaxHealth()==0)
        local forcevec = self:GetForward()*100


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
        if ((!self:IsAlly(ent)) or (self:IsAlly(ent) && self:Disposition(ent) == D_HT )) then
            local phys = ent:GetPhysicsObject()

            if IsValid(phys) then
                phys:SetVelocity(forcevec)
            end

            ent:SetVelocity(forcevec)
        end


        -- Damage
        if !undamagable && ((!self:IsAlly(ent)) or (self:IsAlly(ent) && self:Disposition(ent) == D_HT)) then
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
        if disp == D_NU or undamagable && !soundPropEmitted then -- Prop probably
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
    && (self.GrenCount == -1 or self.GrenCount > 0)
    && !table.IsEmpty(self.GrenadeAttackAnimations)
    && !lastSeenPos:IsZero()
    && self:ZBaseDist(lastSeenPos, {away=400, within=1500})
    && !self.DoingPlayAnim
end


function NPCB.Grenade:Delay( self )
    local should_throw_visible = self.EnemyVisible && math.random(1, self.ThrowGrenadeChance_Visible)==1
    local should_throw_occluded = !self.EnemyVisible && math.random(1, self.ThrowGrenadeChance_Occluded)==1

    if !should_throw_visible && !should_throw_occluded then
        return ZBaseRndTblRange(self.GrenadeCoolDown)
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
ZBaseSpeakingSquads = {}


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


    -- Mute default "engine" voice when we should
    if !ZBase_EmitSoundCall
    && (self.MuteDefaultVoice or self:NearbyAllySpeaking() or self.IsSpeaking)
    && (data.SoundName == "invalid.wav" or data.Channel == CHAN_VOICE or self.DoingDeathAnim) then
        return false
    end


    -- Mute default sounds
    if !ZBase_EmitSoundCall && self.MuteAllDefaultSoundEmittions then
        return false
    end


    -- Avoid sound repitition
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
    local value = self:BeforeEmitSound( data, sndVarName )
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


    -- Garbage variable
    if sndVarName then
        self.InternalCurrentSoundDuration = SoundDuration(data.SoundName)
    end


    -- CustomOnSoundEmitted
    self:CustomOnSoundEmitted( data, SoundDuration(data.SoundName), sndVarName )


    -- Determine that if we are speaking
    if data.Channel == CHAN_VOICE && data.SoundName != "common/null.wav" then
        self.IsSpeaking = true
        self.IsSpeaking_SoundVar = sndVarName

        timer.Create("ZBaseStopSpeaking"..self:EntIndex(), SoundDuration(data.SoundName), 1, function()
            if IsValid(self) then
                self.IsSpeaking = false
            end
        end)
    end


    if altered then
        return true
    end
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

        -- Face the recipient
        self:FullReset()
        self:SetTarget(ally)
        self:SetSchedule(SCHED_TARGET_FACE)

        -- Set vars for me
        self.HavingConversation = true
        self.DialogueMate = ally

        -- Recipient faces me
        ally:FullReset()
        ally:SetTarget(self)
        ally:SetSchedule(SCHED_TARGET_FACE)

        -- Set vars for recipient
        ally.HavingConversation = true
        ally.DialogueMate = self
    

        ZBaseDOverlay("Text", function()
            local pos = self:WorldSpaceCenter()
            return {pos, "*Question*", self.InternalCurrentSoundDuration}
        end)


        -- ResetTimer
        timer.Create("DialogueAnswer"..ally:EntIndex(), self.InternalCurrentSoundDuration+0.4, 1, function()


            if IsValid(ally) then

                -- Recipient answers me
                ally:EmitSound_Uninterupted(ally.Dialogue_Answer_Sounds)


                ZBaseDOverlay("Text", function()
                    local pos = ally:WorldSpaceCenter()
                    return {pos, "*Answer*", ally.InternalCurrentSoundDuration}
                end)


                -- Reset recipient from dialogue state
                timer.Simple(ally.InternalCurrentSoundDuration, function()
                    if !IsValid(ally) then return end
                    ally:CancelConversation()
                end)

                -- Not sure if this does anything of value
                ZBaseDelayBehaviour( ZBaseRndTblRange(ally.IdleSoundCooldown), ally, "Dialogue" )

            end

            if IsValid(self) then

                -- Reset from dialogue state
                timer.Simple(ally.InternalCurrentSoundDuration or 0, function()
                    if !IsValid(self) then return end
                    self:CancelConversation()
                end)

            end
        end)


        DialogueExtraCoolDown = self.InternalCurrentSoundDuration+0.2


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
                                           DEAL DAMAGE
==================================================================================================
--]]

local attackingResetDelay = 1.5 -- Time until a zbase npc is not considered to attack a player, after hurting them
function NPC:DealDamage( dmg, ent )

    local infl = dmg:GetInflictor()
    local disp = self:Disposition(ent)

    -- Friendly fire immune
    if ent.GetCapabilities && bit.band(ent:GetCapabilities(), CAP_FRIENDLY_DMG_IMMUNE)==CAP_FRIENDLY_DMG_IMMUNE && self:Disposition(ent)==D_LI then
        dmg:ScaleDamage(0)
        return true
    end

    -- Cannot suicide
    if self==ent then
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
    
        end

    end


    -- Decide how many ZBase NPCs are attacking this player
    if ent:IsPlayer() then
        -- How many ZBase NPCs are attacking this player

        local ply = ent
        ply.AttackingZBaseNPCs = ply.AttackingZBaseNPCs or {}
        ply.AttackingZBaseNPCs[self]=true


        ply:ConvTimer("RemoveFromAttackingZBaseNPCs"..self:EntIndex(), attackingResetDelay, function()
            -- No longer considered to be attacking
            if ply.AttackingZBaseNPCs[self] then
                ply.AttackingZBaseNPCs[self] = nil
            end
        end)

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


function NPC:ApplyZBaseDamageScale(dmg)
    if self.HasZBScaledDamage then return end
    self.HasZBScaledDamage = true

    if ( self.DamageScaling[dmg:GetDamageType()] ) then
        dmg:ScaleDamage(self.DamageScaling[dmg:GetDamageType()])
    end
end


function NPC:StoreDMGINFO( dmg )

    -- bruh
    local ammotype = dmg:GetAmmoType()
    local attacker = dmg:GetAttacker()
    local basedmg = dmg:GetBaseDamage()
    local damage = dmg:GetDamage()
    local dmgbonus = dmg:GetDamageBonus()
    local dmgcustom = dmg:GetDamageCustom()
    local dmgforce = dmg:GetDamageForce()
    local dmgtype = dmg:GetDamageType()
    local dmgpos = dmg:GetDamagePosition()
    local infl = dmg:GetInflictor()
    local maxdmg = dmg:GetMaxDamage()
    local reportedpos = dmg:GetReportedPosition()

    self.LastDMGINFOTbl = {
        ammotype = ammotype,
        attacker = attacker,
        basedmg = basedmg,
        damage = damage,
        dmgbonus = dmgbonus,
        dmgcustom = dmgcustom,
        dmgforce = dmgforce,
        dmgtype = dmgtype,
        dmgpos = dmgpos,
        infl = infl,
        maxdmg = maxdmg,
        reportedpos = reportedpos,
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
    lastdmginfo:SetBaseDamage(self.LastDMGINFOTbl.basedmg)
    lastdmginfo:SetDamage(self.LastDMGINFOTbl.damage)
    lastdmginfo:SetDamageBonus(self.LastDMGINFOTbl.dmgbonus)
    lastdmginfo:SetDamageCustom(self.LastDMGINFOTbl.dmgcustom)
    lastdmginfo:SetDamageForce(self.LastDMGINFOTbl.dmgforce)
    lastdmginfo:SetDamageType(self.LastDMGINFOTbl.dmgtype)
    lastdmginfo:SetDamagePosition(self.LastDMGINFOTbl.dmgpos)
    lastdmginfo:SetMaxDamage(self.LastDMGINFOTbl.maxdmg)
    lastdmginfo:SetReportedPosition(self.LastDMGINFOTbl.reportedpos)

    
    return lastdmginfo

end


    -- Called first
local isSinglePlayer = game.SinglePlayer()
function NPC:OnScaleDamage( dmg, hit_gr )
    local infl = dmg:GetInflictor()
    local attacker = dmg:GetAttacker()

    -- Players not hurting allies
    if !ZBCVAR.PlayerHurtAllies:GetBool() && attacker:IsPlayer() && self:IsAlly(attacker) then

        -- Hacky way to not apply decals from bullets
        -- if isSinglePlayer then
        --     local last_rendermode = self:GetRenderMode() 
        --     self:SetRenderMode(RENDERMODE_TRANSALPHA)
        --     self:CallNextTick("SetRenderMode", last_rendermode)
        -- end

        dmg:ScaleDamage(0)
        return
    end


    -- Remember stuff
    self.ZBLastHitGr = hit_gr
    self:StoreDMGINFO( dmg )

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


    -- Players not hurting allies
    if !ZBCVAR.PlayerHurtAllies:GetBool() && attacker:IsPlayer() && self:IsAlly(attacker) then
        dmg:ScaleDamage(0)
        return true
    end


    -- In "stationary mode" zbase npcs cannot hurt each other
    if ZBCVAR.Static:GetBool() && attacker.IsZBaseNPC then
        dmg:ScaleDamage(0)
        return true
    end


    -- Remember last dmginfo
    self:StoreDMGINFO( dmg )
    self.LastDamageWasBullet = dmg:IsBulletDamage()


    self:ApplyZBaseDamageScale(dmg)


    -- Custom damage
    if !self.CustomTakeDamageDone then
        self:CustomTakeDamage( dmg, HITGROUP_GENERIC )
        self.CustomTakeDamageDone = true
    end


    local boutaDie = self:Health()-dmg:GetDamage() <= 0 -- mf bouta fng die lmfao


    if boutaDie then
        -- the brawn jameee
        self.IsSpeaking = false
    end


    if boutaDie && ShouldPreventGib[self:GetClass()] then
        if dmg:IsDamageType(DMG_DISSOLVE) or (IsValid(infl) && infl:GetClass()=="prop_combine_ball") then
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
    self:StoreDMGINFO( dmg )


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
        local anim = self:GetFlinchAnimation(dmg, self.ZBLastHitGr)


        if self:OnFlinch(dmg, self.ZBLastHitGr, anim) != false then
            self:FlinchAnimation(anim)
            self.NextFlinch = CurTime()+ZBaseRndTblRange(self.FlinchCooldown)
        end
    end


    self.HasZBScaledDamage = false
    self.CustomTakeDamageDone = false
end



function NPC:OnBulletHit(BulletEnt, tr, dmginfo, bulletData)
    -- Players not hurting allies
    if IsValid(BulletEnt) && !ZBCVAR.PlayerHurtAllies:GetBool() && BulletEnt:IsPlayer() && self:IsAlly(BulletEnt) then
        return
    end


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
            Attacker = Entity(0),
            Inflictor = Entity(0),
            Damage = math.random(1, 3),
            IgnoreEntity = self,
        })

        ent:Remove()

        ZBaseReflectedBullet = false
    end


    self:CustomOnBulletHit(BulletEnt, tr, bulletData)
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
    self.IsSpeaking = false


    -- Death sound
    if !self.DoingDeathAnim then
        self:EmitSound(self.DeathSounds)
    end


    -- My honest reaction
    self:Death_AlliesReact()
    

    -- Gib or ragdoll
    local Gibbed = self:ShouldGib(dmg, hit_gr)
    local rag


    -- Become ragdoll if we should
    if !Gibbed && !dmg:IsDamageType(DMG_REMOVENORAGDOLL) then
        local Ragdoll = self:BecomeRagdoll(dmg, hit_gr, self:GetShouldServerRagdoll())
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
        self:Death_ItemDrop()
    end


    -- Custom on death
    self:CustomOnDeath( dmg, hit_gr, rag )


    -- No stoopid ragdoll pls
    self:SetShouldServerRagdoll(false)


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
    self:Remove()


end



function NPC:Death_AlliesReact()

    local ally = self:GetNearestAlly(600)
    local deathpos = self:GetPos()


    if IsValid(ally) && ally:Visible(self) && ally.AllyDeathSound_Chance && math.random(1, ally.AllyDeathSound_Chance) == 1 then

        timer.Simple(0.5, function()

            if IsValid(ally) then

                ally:EmitSound_Uninterupted(ally.AllyDeathSounds)

                if ally.AllyDeathSounds != "" && ally:GetNPCState()==NPC_STATE_IDLE then
                    ally:FullReset()
                    ally:Face(deathpos, ally.InternalCurrentSoundDuration)
                end
            
            end

        end)

    end

end


function NPC:Death_ItemDrop()

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

            
            if math.random(1, dropData.chance)==1 then
                local drop = ents.Create(dropData.cls)
                drop:SetPos(self:WorldSpaceCenter())
                drop:SetAngles(AngleRand())
                drop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                drop:Spawn()
                SafeRemoveEntityDelayed(drop, 120)

                DropsDone = DropsDone+1
            end
        end

    end


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


    local CopyPosEnt = IsValid(self.ActiveRagdoll) && self.ActiveRagdoll or self


	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self:GetModel())
    rag:SetPos(CopyPosEnt:GetPos())
    rag:SetAngles(CopyPosEnt:GetAngles())
	rag:SetSkin(self:GetSkin())
	rag:SetColor(self:GetColor())
	rag:SetMaterial(self:GetMaterial())
    rag.IsZBaseRag = true
	rag:Spawn()

    local infl = dmg:GetInflictor()


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


	local physcount = rag:GetPhysicsObjectCount()
    local dmgpos = dmg:GetDamagePosition()
    local force = self.RagdollApplyForce && dmg:GetDamageForce()*0.02
	for i = 0, physcount - 1 do

		-- Placement
		local physObj = rag:GetPhysicsObjectNum(i)
		local pos, ang = CopyPosEnt:GetBonePosition(CopyPosEnt:TranslatePhysBoneToBone(i))

        if !self.RagdollUseAltPositioning then
		    physObj:SetPos( pos )
        end

	    physObj:SetAngles( ang )


        if force then
            physObj:SetVelocity(force)
        end

	end

	-- Hook
	hook.Run("CreateEntityRagdoll", self, rag)


    -- Damage type tester
    -- for i = 0, 30 do
    --     MsgN(2^i, dmg:IsDamageType(2^i))
    -- end


	-- Dissolve
	if dmg:IsDamageType(DMG_DISSOLVE) or (IsValid(infl) && infl:GetClass()=="prop_combine_ball") then
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

    return rag
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


    -- Phys stuff
    local phys = Gib:GetPhysicsObject()
    if IsValid(phys) then
        
        phys:Wake()

        local LastDMGInfo = self:LastDMGINFO()

        if LastDMGInfo then
            local ForceDir = LastDMGInfo:GetDamageForce()/(math.Clamp(phys:GetMass(), 40, 10000))
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


    -- Dissolve if we should
    -- if dmg:IsDamageType(DMG_DISSOLVE) then
    --     self:SetName("zbase_dissolving_npc"..self:EntIndex())
    --     local dissolve = ents.Create("env_entity_dissolver")
    --     dissolve:SetKeyValue("target", self:GetName())
    --     dissolve:SetKeyValue("dissolvetype", dmg:IsDamageType(DMG_SHOCK) && 2 or 0)
    --     dissolve:Fire("Dissolve", self:GetName())
    --     dissolve:Spawn()
    --     self:DeleteOnRemove(dissolve)
    -- end

end



function NPC:InternalOnRemove()
    for _, ply in player.Iterator() do
        if IsValid(ply) && istable(ply.AttackingZBaseNPCs) then
            ply.AttackingZBaseNPCs[self]=nil
        end
    end
end
