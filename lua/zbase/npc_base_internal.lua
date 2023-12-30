util.AddNetworkString("ZBaseGlowEyes")


--[[
==================================================================================================
                    !! YOU GOT NOTHING TO DO HERE BOYE, GO BACK TO npc_base_init !!
==================================================================================================
--]]



local NPC = ZBaseNPCs["npc_zbase"]
local NPCB = ZBaseNPCs["npc_zbase"].Behaviours



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
        self:SetModel_MaintainBounds(self.SpawnModel)
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
    self.EnemyVisible = false
    self.HadPreviousEnemy = false
    self.InternalDistanceFromGround = self.Fly_DistanceFromGround
    self.LastHitGroup = HITGROUP_GENERIC
    self.SchedDebug = GetConVar("developer"):GetBool() && ZBCVAR.ShowSched:GetBool()
    self.PlayerToFollow = NULL
    self:SetNWBool("IsZBaseNPC", true)
    self:SetNWString("ZBaseName", self.Name)


    -- Rendermode
    self:SetRenderMode(self.RenderMode)


    -- Submaterials
    for k, v in pairs(self.SubMaterials) do
        self:SetSubMaterial(k-1, v)
    end


    -- Collisions/Bounds
    if self.HullType && !self.IsZBase_SNPC then
        self:SetHullType(self.HullType)
    end
    if self.CollisionBounds then
        self:SetCollisionBounds(self.CollisionBounds.min, self.CollisionBounds.max)
        self:SetSurroundingBounds(self.CollisionBounds.min*1.25, self.CollisionBounds.max*1.25)
    end


    -- Set specified internal variables
    self:InitSaveValues()


    -- Tick delay to fix issues
    timer.Simple(0, function()

        if IsValid(self) then
            self:SetBloodColor(self.BloodColor)
        end

    end)


    -- Longer delay to prevent overrides
    timer.Simple(0.1, function()

        if IsValid(self) then
            -- Weapon proficiency
            self:SetCurrentWeaponProficiency(self.WeaponProficiency)
            

            -- Some calls based on attributes
            self:SetCurrentWeaponProficiency(self.WeaponProficiency)
            self:SetBloodColor(self.BloodColor)


            -- FOV and sight dist
            self:SetSaveValue("m_flFieldOfView", math.cos( (self.SightAngle*(math.pi/180))*0.5 ) )
            self:SetMaxLookDistance(self.SightDistance)
        

            -- Phys damage scale
            self:Fire("physdamagescale", self.PhysDamageScale)
        

            -- Set specified internal variables (again just to be sure)
            self:CapabilitiesClear()
            self:InitCap()
        

            -- Capability shit
            self:InitCap()


            if self.ZBaseFaction != "none" then
                self:SetSquad(self.ZBaseFaction)
            end
        end

    end)


    -- On remove
    self:CallOnRemove("ZBaseOnRemove", function() self:OnRemove() end)


    -- Weapon system
    self:ZBWepSys_Init()


    -- Glowing eyes
    self:GlowEyeInit()


    -- Makes behaviour system function
    ZBaseBehaviourInit( self )


    -- Custom init
    self:CustomInitialize()


    -- Debug shit
    if GetConVar("developer"):GetBool() then
        self.ZBaseCurFunc = {}
        self:DebugMyFunctions()
    end
end


function NPC:InitSaveValues()

    -- Set all save values that its table has (m_typeSomething)
    for k, v in pairs(self:GetTable()) do

        if string.StartWith(k, "m_") then
            self:SetSaveValue(k, v)
        end

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


    -- Aim pose parameters
    if self:CheckHasAimPoseParam() then
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


        for _, ply in pairs(player.GetAll()) do
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

    local ene = self:GetEnemy()
    local sched = self:GetCurrentSchedule()
    local seq = self:GetSequence()
    local act = self:GetActivity()


    -- Enemy visible
    self.EnemyVisible = IsValid(ene) && (self:HasCondition(COND.SEE_ENEMY) or self:Visible(ene))


    -- Slow think, for performance
    if self.NPCNextSlowThink < CurTime() then
        self:DoSlowThink()
        self.NPCNextSlowThink = CurTime()+0.4
    end


    -- NPC think (not SNPC)
    if !self.IsZBase_SNPC then
        self:AITick_NonScripted()
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

        self:NewESchedDetected( sched, name )
        
        self.ZBaseLastESched = sched
        self.ZBaseLastESchedName = name

    end


    -- Stuff to make play anim work as intended
    if self.DoingPlayAnim then
        self:DoPlayAnim()
    end


    -- Handle danger
    if self.LastLoudestSoundHint then
        self:HandleDanger()
    end


    -- Sched debug
    if self.SchedDebug then
        local sched = ZBaseSchedDebug(self)
        if sched then
            debugoverlay.Text(self:WorldSpaceCenter(), "sched: "..sched..", state: "..StrNPCStates[self:GetNPCState()], 0.13)
        end
    end


    -- Base regen
    if self.HealthRegenAmount > 0 && self:Health() < self:GetMaxHealth() && self.NextHealthRegen < CurTime() then
        self:SetHealth(math.Clamp(self:Health()+self.HealthRegenAmount, 0, self:GetMaxHealth()))
        self.NextHealthRegen = CurTime()+self.HealthCooldown
    end


    if !GetConVar("ai_disabled"):GetBool() && self.NextFootStepTimer < CurTime() && self:GetNavType()==NAV_GROUND then
        self:FootStepTimer()
    end


    self:SetConditionalActivities()


    self:ZBWepSys_Think()


    self:CustomThink()
end


function NPC:DoSlowThink()

    -- Remove squad if faction is 'none'
    if self.ZBaseFaction == "none" && self:SquadName()!="" then
        self:SetSquad("")
    end


    self:AITick_Slow()

end


--[[
==================================================================================================
                                           WEAPON SYSTEM
==================================================================================================
--]]


NPCB.ZBWepSys_ChangeActs = {}


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
}



local HoldTypeActCheck = {
    ["pistol"] = ACT_RANGE_ATTACK_PISTOL,
    ["smg"] = ACT_RANGE_ATTACK_SMG1,
    ["ar2"] = ACT_RANGE_ATTACK_AR2,
    ["shotgun"] =ACT_RANGE_ATTACK_SHOTGUN,
    ["rpg"] = ACT_RANGE_ATTACK_RPG,
    ["passive"] = ACT_IDLE,
}


local ActCrouchTranslate = {
    [ACT_RANGE_ATTACK_PISTOL] = ACT_RANGE_ATTACK_PISTOL_LOW,
    [ACT_RANGE_ATTACK_SMG1] = ACT_RANGE_ATTACK_SMG1_LOW,
    [ACT_RANGE_ATTACK_AR2] = ACT_RANGE_ATTACK_AR2_LOW,
    [ACT_RANGE_ATTACK_SHOTGUN] =ACT_RANGE_ATTACK_SHOTGUN_LOW,
}


function NPC:ZBWepSys_Init()

    self.ZBWepSys_Inventory = {}


    self.ZBWepSys_CurShootAct = self.WeaponFire_Activities[1] or ACT_RUN_AIM
    self.ZBWepSys_CurMoveShootAct = self.WeaponFire_MoveActivities[1] or ACT_RUN_AIM


    self.ZBWepSys_MoveActSet = false

    
    self.ZBWepSys_NextBurst = CurTime()
    self.ZBWepSys_NextShoot = CurTime()

end


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


    zbasewep:SetClip1( zbasewep.Primary.DefaultClip )


    zbasewep.IsEngineClone = true
    zbasewep.EngineCloneMaxClip = zbasewep.Primary.DefaultClip
    zbasewep.EngineCloneClass = engineClass
end


function NPC:ZBWepSys_SetActiveWeapon( class )

    if !self.ZBWepSys_Inventory[class] then return end


    local WepData = self.ZBWepSys_Inventory[class]


    timer.Simple(0.1, function()

        if IsValid(self) then

            local Weapon = self:Give( WepData.isScripted && class or "weapon_zbase" )
            Weapon.FromZBaseInventory = true


            if !WepData.isScripted then
                
                Weapon:SetNWString("ZBaseNPCWorldModel", WepData.model)
                self:ZBWepSys_EngineCloneAttrs( Weapon, class )

            end


            if Weapon.NPCHoldType then
                self:ZBWepSys_SetHoldType( Weapon, Weapon.NPCHoldType )
            end
        
        end

    end)

end


function NPC:ZBWepSys_StoreInInventory( wep )

    self.ZBWepSys_Inventory[wep:GetClass()] = {model=wep:GetModel(), isScripted=wep:IsScripted()}

    wep:Remove()

end


function NPC:ZBNWepSys_NewNumShots()
    local ShotsMin, ShotsMax = self:GetActiveWeapon():ZBaseGetNPCBurstSettings()
    local RndShots = math.random(ShotsMin, ShotsMax)

    return RndShots
end


function NPC:ZBWepSys_Shoot()
    
    self.ZBWepSys_AllowShoot = true
    self:GetActiveWeapon():PrimaryAttack()
    self.ZBWepSys_AllowShoot = false


    self.ZBWepSys_ShotsLeft = self.ZBWepSys_ShotsLeft && (self.ZBWepSys_ShotsLeft - 1) or self:ZBNWepSys_NewNumShots()-1


    if self.ZBWepSys_ShotsLeft <= 0 then

        local RestTimeMin, RestTimeMax = self:GetActiveWeapon():GetNPCRestTimes()
        local RndRest = math.Rand(RestTimeMin, RestTimeMax)


        self.ZBWepSys_NextBurst = CurTime()+RndRest
        self.ZBWepSys_ShotsLeft = nil

    end


    local _, _, cooldown = self:GetActiveWeapon():ZBaseGetNPCBurstSettings()
    self.ZBWepSys_NextShoot = CurTime()+cooldown

end


function NPC:ZBWepSys_WantsToShot()

    -- Enemy valid and visible
    return self.EnemyVisible

    -- Not playing an animation from PlayAnimation
    && !self.DoingPlayAnim

    -- Enemy is within shoot distance
    && self:ZBaseDist(self:GetEnemy(), {within=self.MaxShootDistance, away=self.MinShootDistance})

    -- Conditions
    && self:HasCondition(COND.WEAPON_HAS_LOS) && self:HasCondition(COND.CAN_RANGE_ATTACK1) && !self:HasCondition(COND.WEAPON_BLOCKED_BY_FRIEND)

end


function NPC:ZBWepSys_CanFireWeapon()

    -- Ready to fire
    return self:ZBWepSys_WantsToShot()

    && self.ZBWepSys_NextShoot < CurTime()

    -- Volley has started
    && self.ZBWepSys_NextBurst < CurTime()


end


    -- Translates the activity and sets it if it is available, otherwise it does nothing
    -- Returns the translated activity if it was ran, otherwise false
function NPC:ZBWepSys_SetAct_Translated( act, func, ... )
    func = func or self.SetActivity


    local TranslatedAct = self:Weapon_TranslateActivity(act)


    if self:SelectWeightedSequence( TranslatedAct ) != -1 then

        func( self, TranslatedAct, ... )
        return TranslatedAct

    end


    return false

end


function NPCB.ZBWepSys_ChangeActs:ShouldDoBehaviour( self )
    return self:ZBWepSys_WantsToShot()
end


function NPCB.ZBWepSys_ChangeActs:Run( self )

    -- Randomize shoot act every now and then
    self.ZBWepSys_CurMoveShootAct = table.Random(self.WeaponFire_MoveActivities)
    self.ZBWepSys_CurShootAct = table.Random(self.WeaponFire_Activities)

    ZBaseDelayBehaviour(math.Rand(3, 9))

end


function NPC:ZBWepSys_ShootAnim(arguments)

    self.ZBWepSys_AllowRange1Translate = true


    local ActToTranslate = self.ZBWepSys_CurShootAct
    local Moving = self:IsMoving()


    if !Moving then
        local DesiredAct = self:ZBWepSys_SetAct_Translated( ActToTranslate, self.ResetIdealActivity )
        

        if DesiredAct then

            -- Start anim from the start
            self:ResetSequenceInfo()
            self:SetCycle(0)
            self:ResetSequence( self:SelectWeightedSequence(DesiredAct) )

        end
    end


    -- Gesture
    if !Moving && self.WeaponFire_DoGesture then

        -- While standing
        self:ZBWepSys_SetAct_Translated(table.Random(self.WeaponFire_Gestures), self.PlayAnimation, false, {isGesture=true} )

    elseif Moving && self.WeaponFire_DoGesture_Moving then

        -- While moving
        self:ZBWepSys_SetAct_Translated(table.Random(self.WeaponFire_Gestures), self.PlayAnimation, false, {isGesture=true} )

    end


    self.ZBWepSys_AllowRange1Translate = false

end



function NPC:ZBWepSys_FireWeaponThink()

    local Moving = self:IsMoving()


    if self:ZBWepSys_CanFireWeapon() then

        if Moving && !self.ZBWepSys_MoveActSet then

            -- Movement act
            self:ZBWepSys_SetAct_Translated( self.ZBWepSys_CurMoveShootAct, self.SetMovementActivity )
            self.ZBWepSys_MoveActSet = true
            debugoverlay.Text(self:GetPos(), "shoot move act set", 3)


        end

        -- Press trigger, recoil anim
        self:ZBWepSys_Shoot()
        self:ZBWepSys_ShootAnim()

    end


    if !Moving then
        self.ZBWepSys_MoveActSet = false
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
    if !IsValid(Weapon) then return end


    local WeaponCls = Weapon:GetClass()
    

    if !Weapon.FromZBaseInventory then

        self:ZBWepSys_StoreInInventory( Weapon )
        self:ZBWepSys_SetActiveWeapon( WeaponCls )
        return

    end


    if Weapon.IsZBaseWeapon then


        if Weapon.NPCIsMeleeWep then

            self:ZBWepSys_MeleeThink()

        else
    
            self:ZBWepSys_FireWeaponThink()

        end

    end

end


--[[
==================================================================================================
                                           INTERNAL UTIL
==================================================================================================
--]]



function NPC:SetModel_MaintainBounds(model)

    local mins, maxs = self:GetCollisionBounds()

    self:SetModel(model)
    self:SetCollisionBounds(mins, maxs)
    self:ResetIdealActivity(ACT_IDLE)

end



-- Make the NPC face certain directions
-- 'face' - A position or an entity to face, or a  representing the yaw.
-- 'duration' - Face duration, if not set, you can run the function in think for example
-- 'speed' - Turn speed, if not set, it will be the default turn speed
function NPC:Face( face, duration, speed )

    local function turn( yaw )
        if GetConVar("ai_disabled"):GetBool() then return end
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


function NPC:ZBaseFuncPrint()
    MsgN(self, ":", self.ZBaseCurFunc.name, "(", self.ZBaseCurFunc.args, ")")
end


function NPC:DebugMyFunctions()
    for VarName, VarValue in pairs(self:GetTable()) do
        if VarName == "ZBaseFuncPrint" then continue end
        

        if isfunction(VarValue) then
            local func = VarValue

            self[VarName] = function(me, ...)
                self.ZBaseCurFunc = {name=VarName, args=...}
                return func(me, ...)
            end
        end

    end
end


--[[
==================================================================================================
                                           ANIMATION
==================================================================================================
--]]


function NPC:InternalPlayAnimation(anim,duration,playbackRate,sched,forceFace,faceSpeed,loop,onFinishFunc,isGest,isTransition,noTransitions)
    if GetConVar("ai_disabled"):GetBool() then return end
    if !anim then return end



    if isGest && !self.IsZBase_SNPC && ZBaseIsMP then return end -- Don't do gestures on non-scripted NPCs in multiplayer, it seems to be broken




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


        self.PlayAnim_PlayBackRate = playbackRate
        self.PlayAnim_Seq = anim
        self.DoingPlayAnim = true


        -- Walkframe for non-scripted NPCs
        if !self.IsZBase_SNPC then

            local TimerName = "ZBaseWalkFrames"..self:EntIndex()


            timer.Create(TimerName, 0, 0, function()

                if !IsValid(self) or !self.DoingPlayAnim then
                    timer.Remove(TimerName)
                    return
                end
    
                self:AutoMovement(self:GetAnimTimeInterval()*0.3)

            end)

        end
        
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

    -- Playback rate for the animation
    self:SetPlaybackRate(self.PlayAnim_PlayBackRate or 1)


    -- Stop movement
    self:SetSaveValue("m_flTimeLastMovement", 2)


    -- Walkframes for SNPCs
    if self.IsZBase_SNPC then
        self:AutoMovement( self:GetAnimTimeInterval() )
    end

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


function NPC:SetConditionalActivities()
    
    if self:IsCurrentSchedule(SCHED_TAKE_COVER_FROM_ENEMY) && self:SelectWeightedSequence(ACT_RUN_PROTECTED) != -1 then
        self:SetMovementActivity(ACT_RUN_PROTECTED)
    end

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
    if GetConVar("ai_disabled"):GetBool() then return end


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
    local EneLastKnownPos = self:GetEnemyLastKnownPos()
    if IsValid(ene) && !self.EnemyVisible && CurTime()-self:GetEnemyLastTimeSeen() >= 5 then
        self:MarkEnemyAsEluded()

        if self.GotoEneLastKnownPosWhenEluded && self:ShouldChase() then
            self:ForceGotoLastKnownPos()
        end

        debugoverlay.Text(self:GetPos(), "marked current enemy as eluded", 2)
    end


    -- Last known pos debug
    debugoverlay.Text(EneLastKnownPos+Vector(0, 0, 100), self.Name.."["..self:EntIndex().."] last known enemy pos", 0.3)
    debugoverlay.Cross(EneLastKnownPos, 40, 0.3, Color( 255, 0, 0 ))


    -- NPC_STATE
    if IsCombat then
        -- Reset stop alert if in combat
        self.NextStopAlert = nil


        if IsValid(ene) then
            self.DoEnemyLostSoundWhenLost = true
            self.GotoEneLastKnownPosWhenEluded = true
        end
    end

    if IsAlert && !self.NextStopAlert then
        self.NextStopAlert = CurTime()+math.Rand(15, 25)
    end


    if IsAlert && self.NextStopAlert && self.NextStopAlert < CurTime() then
        self:SetNPCState(NPC_STATE_IDLE)
        self.NextStopAlert = nil
    end


    -- Keep following players
    if IsValid(self.PlayerToFollow) && !GetConVar("ai_ignoreplayers"):GetBool()
    && self:ZBaseDist(self.PlayerToFollow, {away=300}) then
        local pos = self.PlayerToFollow:GetPos()
        local NavigatorEnt = (IsValid(self.Navigator) && self.Navigator) or self


        NavigatorEnt:SetLastPosition(pos)
        NavigatorEnt:NavSetGoalTarget(self.PlayerToFollow, (self:GetPos()-pos):GetNormalized()*125)


        if !NavigatorEnt:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
            self:SetSchedule(SCHED_FORCED_GO_RUN)
        end
    end


    if IsValid(self.PlayerToFollow) && !self:IsAlly(self.PlayerToFollow) then
        self:StopFollowingCurrentPlayer(true)
    end
end


function NPC:AITick_NonScripted()
    if GetConVar("ai_disabled"):GetBool() then return end


    local ene = self:GetEnemy()



    if self.ProhibitCustomEScheds then

        local state = self:GetNPCState()
        local sched = self:GetCurrentSchedule()


        if sched > 88 && !self.AllowedCustomEScheds[sched] then

            self.Debug_ProhibitedCusESched = sched

            self:SetSchedule( (state==NPC_STATE_ALERT && SCHED_ALERT_STAND) or (state==NPC_STATE_COMBAT && SCHED_COMBAT_FACE)
            or SCHED_IDLE_STAND )

        end

    end

    

    -- Reload now if hiding spot is too far away
    if (self:IsCurrentSchedule(SCHED_HIDE_AND_RELOAD)
    or ( self:GetClass()=="npc_combine_s" && self:IsCurrentSchedule(ZBaseESchedID("SCHED_COMBINE_HIDE_AND_RELOAD")) ) )
    && self:ZBaseDist(self:GetGoalPos(), {away=1000}) then
        self:SetSchedule(SCHED_RELOAD)
    end


    -- Sees enemy, but shouldn't chase it, take cover from it instead
    if self.EnemyVisible && !self:ShouldChase() && !self:IsCurrentSchedule(SCHED_TAKE_COVER_FROM_ENEMY) && !self:CurrentlyFollowingPlayer() then
        self:SetSchedule(SCHED_TAKE_COVER_FROM_ENEMY)
    end
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


function NPC:ForceGotoLastKnownPos()
    self:SetLastPosition(self:GetEnemyLastKnownPos())
    self:SetSchedule(SCHED_FORCED_GO_RUN)
    self.GotoEneLastKnownPosWhenEluded = false

    debugoverlay.Text(self:GetPos(), "going to last known pos", 2)
end



function NPC:ShouldChase()
    if self.NoWeapon_Scared && !IsValid(self:GetActiveWeapon()) then return false end
    if self:CurrentlyFollowingPlayer() then return false end

    return true
end


function NPC:ShouldPreventSetSched( sched )
    -- Prevent SetSchedule from being ran if these conditions apply:


    if sched==SCHED_FORCED_GO then return false end


    return self.HavingConversation
    or self.DoingPlayAnim
end


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


function NPC:RangeThreatened( threat )
    if !self:HasEnemyMemory(threat) then return end
    if self.NextRangeThreatened > CurTime() then return end


    debugoverlay.Text(self:GetPos(), "threatened")
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

    if string.find(self:GetSequenceActivityName(seq), "RELOAD") then

        
        local wep = self:GetActiveWeapon()


        -- Reload weapon sounds:
        if IsValid(wep) then

            if wep.IsZBaseWeapon && wep.NPCReloadSound != "" then

                wep:EmitSound(wep.NPCReloadSound)

            end


            if math.random(1, self.OnReloadSound_Chance) == 1 then
                self:EmitSound_Uninterupted(self.OnReloadSounds)
            end

        end

    end

    
    self:CustomNewSequenceDetected( seq, seqName )

end


function NPC:NewESchedDetected( sched, schedName )

    -- Shit reload workaround
    -- local wep = self:GetActiveWeapon()
    -- if wep.IsEngineClone && string.find(self.ZBaseLastESchedName, "RELOAD") then

    --     wep:SetClip1( wep.EngineCloneMaxClip )

    -- end

end


function NPC:DoNewEnemy()
    local ene = self:GetEnemy()


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


    self:EnemyStatus(ene, self.HadPreviousEnemy)
    self.HadPreviousEnemy = ene && true or false
end


function NPC:HasCapability( cap )
    return bit.band(self:CapabilitiesGet(), cap)==cap
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
    if self.MoveSpeedMultiplier==0 then return end

    local TimeLastMovement = self:GetInternalVariable("m_flTimeLastMovement")

    self:SetPlaybackRate(self.MoveSpeedMultiplier)
    self:SetSaveValue("m_flTimeLastMovement", TimeLastMovement*self.MoveSpeedMultiplier)
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


--[[
==================================================================================================
                                           AI FOLLOW PLAYER
==================================================================================================
--]]


function NPC:CanStartFollowPlayers()
    return self.CanFollowPlayers && !GetConVar("ai_ignoreplayers"):GetBool() && !IsValid(self.PlayerToFollow)
    && self.SNPCType != ZBASE_SNPCTYPE_STATIONARY
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

    self:SetTarget(ply)
    self:SetSchedule(SCHED_TARGET_FACE)

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


--[[
==================================================================================================
                                           AI PATROL
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
    local IsAlert = self:GetNPCState() == NPC_STATE_ALERT
    local Chase = self:ShouldChase()


    if IsValid(self.PlayerToFollow) then

        self:SetSchedule(SCHED_ALERT_SCAN)

    elseif IsAlert && self:ZBaseDist(self:GetEnemyLastKnownPos(), {away=200}) && self.GotoEneLastKnownPosWhenEluded && Chase then

        self:ForceGotoLastKnownPos()

    elseif IsAlert && Chase then

        self:SetSchedule(SCHED_PATROL_RUN)


        -- Enemy was lost at this point
        if self.DoEnemyLostSoundWhenLost && !self.EnemyDied then
            self:LostEnemySound()
            self:EmitSound_Uninterupted(self.LostEnemySounds)
            self.DoEnemyLostSoundWhenLost = false
            debugoverlay.Text(self:GetPos(), "enemy lost", 2)
        end

    else

        self:SetSchedule(SCHED_PATROL_WALK)

    end

    
    ZBaseDelayBehaviour(IsAlert && math.random(3, 6) or math.random(8, 15))
end


--[[
==================================================================================================
                                           AI CALL FOR HELP
==================================================================================================
--]]


NPCB.FactionCallForHelp = {
    MustHaveEnemy = true,
}


function NPCB.FactionCallForHelp:ShouldDoBehaviour( self )
    return self.CallForHelp && self.CallForHelpDistance > 0
    && self.ZBaseFaction != "none" && self.ZBaseFaction != "neutral"
end


function NPCB.FactionCallForHelp:Run( self )
    local ally = self:GetNearestAlly(self.CallForHelpDistance)


    local ene = self:GetEnemy()


    if IsValid(ally) && ally:IsNPC() && !IsValid(ally:GetEnemy()) && !ally:HasEnemyEluded(ene) then
        ally:UpdateEnemyMemory(ene, self:GetEnemyLastSeenPos())
        ally:AlertSound()
        self:OnCallForHelp(ally)
    end


    ZBaseDelayBehaviour(math.Rand(2, 3.5))
end


--[[
==================================================================================================
                                           AI SECONDARY FIRE
==================================================================================================
--]]


    // Kinda old, will probably be redone with the new weapon system


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


        wep:EmitSound("Weapon_IRifle.Single")


        self:ZBWepSys_SetAct_Translated(ACT_GESTURE_RANGE_ATTACK1, self.PlayAnimation, false, {isGesture=true} )

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

    wep:EmitSound("Weapon_AR2.Double")

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


    if !IsValid(wep) then return false end


    local wepTbl = wep.EngineCloneClass && SecondaryFireWeapons[ wep.EngineCloneClass ]
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

    SecondaryFireWeapons[ wep.EngineCloneClass ]:Func( self, wep, enemy )


    self:ZBWepSys_SetAct_Translated(ACT_GESTURE_RANGE_ATTACK1, self.PlayAnimation, false, {isGesture=true} )


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
    return self.BaseGrenadeAttack
    && !table.IsEmpty(self.GrenadeAttackAnimations)
    && self:ZBaseDist(self:GetEnemyLastSeenPos(), {away=400, within=1500})
end


function NPCB.Grenade:Delay( self )
    local should_throw_visible = self.EnemyVisible && math.random(1, self.ThrowGrenadeChance_Visible)==1
    local should_throw_occluded = !self.EnemyVisible && math.random(1, self.ThrowGrenadeChance_Occluded)==1


    if !should_throw_visible && !should_throw_occluded then
        return ZBaseRndTblRange(self.GrenadeCoolDown)
    end
end


function NPCB.Grenade:Run( self )
    local ene = self:GetEnemy()


    if self.EnemyVisible then
        -- Throw grenade at enemy now
        self:ThrowGrenade()
    else
        -- Enemy not seen yet, try approaching and doing grenade attack later


        self:SetLastPosition(self:GetEnemyLastSeenPos())
        self:SetSchedule(SCHED_FORCED_GO_RUN)


        local TimerName = "GrenadeThrowTimer"..self:EntIndex()
        timer.Create(TimerName, 1, 8, function()
            if !IsValid(self) or !self:IsCurrentSchedule(SCHED_FORCED_GO_RUN)
            or self:ZBaseDist(self:GetEnemyLastSeenPos(), {within=400})
            or self:GetEnemyLastSeenPos()==self.LastGrenadeTargetPos -- Don't target the same position again
            then
                timer.Remove(TimerName)
                return
            end

            local TargetPos = self:GetEnemyLastSeenPos()
            if self:VisibleVec(TargetPos) then
                self:ThrowGrenade()
                self.LastGrenadeTargetPos = TargetPos
                timer.Remove(TimerName)
            end

        end)
    end


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


    if (Class_ShouldRunRandomOnDanger[self:Classify()] or self.ForceAvoidDanger) && self:GetCurrentSchedule() <= 88 && !self:IsCurrentSchedule(SCHED_RUN_RANDOM) then
        self:SetSchedule(SCHED_RUN_RANDOM)
    end


    if isGrenade && self:GetNPCState()==NPC_STATE_IDLE then
        self:SetNPCState(NPC_STATE_ALERT)
    end


    -- RUN BOYE
    self:SetMovementActivity(ACT_RUN)


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
    && (data.SoundName == "invalid.wav" or data.Channel == CHAN_VOICE) then
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
    if self.Dead then return false end -- Otherwise they might not do their death sounds


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
    local ally = self:GetNearestAlly(350)
    if !IsValid(ally) then return end


    local extraBehaviourDelay = 0


    -- Ally is zbase NPC:
    if ally.IsZBaseNPC && !IsValid(ally:GetEnemy()) && !ally.HavingConversation && self:Visible(ally)
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
    
    -- Ally is player:
    elseif ally:IsPlayer() && !GetConVar("ai_ignoreplayers"):GetBool() then
        self:EmitSound_Uninterupted(self.Dialogue_Question_Sounds)
        self:SetTarget(ally)
        self:SetSchedule(SCHED_TARGET_FACE)
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


    -- Remember stuff
    self.LastHitGroup = dmg, hit_gr
    self.LastDMGINFO = dmg


    -- Don't get hurt by NPCs in the same faction
    if (self:IsAlly(attacker)) && !(ZBCVAR.PlayerHurtAllies:GetBool() && attacker:IsPlayer()) then
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


    if (self:IsAlly(attacker) or attacker.LastOwnerZBaseFaction==self.ZBaseFaction or (infl.IsZBaseDMGInfl && attacker==self))
    && !(ZBCVAR.PlayerHurtAllies:GetBool() && attacker:IsPlayer()) then
        dmg:ScaleDamage(0)
        return true
    end


    -- Remember last dmginfo
    self.LastDMGINFO = dmg
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
        local anim = self:GetFlinchAnimation(dmg, self.LastHitGroup)


        if self:OnFlinch(dmg, self.LastHitGroup, anim) != false then
            self:FlinchAnimation(anim)
            self.NextFlinch = CurTime()+ZBaseRndTblRange(self.FlinchCooldown)
        end
    end


    self.HasZBScaledDamage = false
    self.CustomTakeDamageDone = false
end



function NPC:OnBulletHit(BulletEnt, tr, dmginfo, bulletData)
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
    self:SetNPCState(NPC_STATE_DEAD)
    self:SetNoDraw(true)
    self:CapabilitiesClear()
    self:SetCollisionBounds(Vector(), Vector())


    self.IsSpeaking = false


    -- Stop sounds
    for _, v in ipairs(self.SoundVarNames) do
        if !isstring(v) then continue end
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


    -- Gib or ragdoll
    local Gibbed = self:ShouldGib(dmg, hit_gr)
    local rag
    if !Gibbed then
        rag = self:BecomeRagdoll(dmg, hit_gr, self:GetShouldServerRagdoll())
    end


    self:CustomOnDeath( dmg, hit_gr, rag )


    local wep = self:GetActiveWeapon()
    if IsValid(wep) && wep.EngineCloneClass then
        -- Drop weapon
        self:Give(wep.EngineCloneClass)
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
    if self.RagdollApplyForce then

        local force = dmg:GetDamageForce()/(totMass/120)

        if self.LastDamageWasBullet then
            ragPhys:SetVelocity(force*0.1)
        else
            ragPhys:SetVelocity(force)
        end

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
                effectdata:SetMagnitude( 1.2 )
                effectdata:SetRadius( colData.Speed/20 )
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

        if self.LastDMGINFO then
            local ForceDir = self.LastDMGINFO:GetDamageForce()/(math.Clamp(phys:GetMass(), 40, 10000))
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


    self:DeathAnimation_Animation()

    self:SetHealth(1)
    self:AddFlags(FL_NOTARGET)
    self:CapabilitiesClear()


    timer.Simple(self.DeathAnimationDuration/self.DeathAnimationSpeed, function()
        if !IsValid(self) then return end

        self.DeathAnim_Finished = true

        if self.IsZBase_SNPC then
            self:Die(newDMGinfo)
        else
            GAMEMODE:OnNPCKilled(self, IsValid(lastDMGinfo.att) && lastDMGinfo.att or self, IsValid(lastDMGinfo.inf) && lastDMGinfo.inf or self)
        end
    end)
end