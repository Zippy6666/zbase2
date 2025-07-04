local NPC = ZBaseNPCs["npc_zbase"]
local cacheGetNearbyAlliesOptimized = {}

-- These are functions that you can call, don't change them

--[[
==================================================================================================
                                           CONTROLLER
==================================================================================================
--]]

-- Adds a new attack/bind that can be triggered via the controller
-- pressFunc and releaseFunc are called respectively when the key is pressed and released
-- attackName should be the name of your attack. Example: "Charge Attack"
function NPC:AddControllerAttack(pressFunc, releaseFunc, attackName)
    self:ZBASE_ControllerAddAttack(pressFunc, releaseFunc, nil, attackName)
end

-- Returns wheter or not the NPC is being controlled by a player
function NPC:IsBeingControlled() 
    return self.ZBASE_IsPlyControlled or false
end

-- Get where the player is aiming
function NPC:ControllerTargetPos() 
    return self:ZBASE_Controller_GetBullseye():GetPos()
end

-- Attack the bullseye entity that follows the players cursor
function NPC:StartAttackBullseye() 
    self:ZBASE_Controller_TargetBullseye(true)
end

-- Stop attacking the bullseye entity that follows the players cursor
function NPC:StopAttackBullseye() 
    self:ZBASE_Controller_TargetBullseye(false)
end

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
    -- extraData.freezeForever - If true, the frozen state of the npc will never end, this should really just be used for the death animation
    -- extraData.onFinishFunc - Function to play when the animation finishes
    -- extraData.onFinishFuncArgs - Table of arguments to pass in onFinishFunc
    -- extraData.forcedTransitionFrom - If set, it will force the animation to transition from this act/seq
-- Returns the provided 'extraData' table or an empty table if none was provided
function NPC:PlayAnimation( anim, faceEnemy, extraData )
    extraData = extraData or {}


    local enemy = self:GetEnemy()
    local face = extraData.face
    or (faceEnemy && IsValid(enemy) && enemy)
    or nil

    if extraData.face == false then
        face = false
    end
        local moreArgs = {
        freezeForever = extraData.freezeForever,
        onFinishFunc = extraData.onFinishFunc,
        onFinishFuncArgs = extraData.onFinishFuncArgs,
        forcedTransitionFrom = extraData.forcedTransitionFrom
    }

    -- Deprecated stuff
    local loop = nil
    local onFinishFunc = nil


    local isTransition = false

    
    local sched = SCHED_SCENE_GENERIC
    self:InternalPlayAnimation(
        anim, extraData.duration, extraData.speedMult,
        sched, face, extraData.faceSpeed, loop, onFinishFunc, extraData.isGesture, isTransition, extraData.noTransitions, moreArgs
    )


    return extraData or {}
end

-- Stops the current NPC:PlayAnimation() animation
function NPC:StopCurrentAnimation()
    self:InternalStopAnimation()
end

-- Check if the NPC is currently busy playing an animation
function NPC:BusyPlayingAnimation()
    return self.DoingPlayAnim
end

-- Check if the NPC is currently doing the death animation
function NPC:DoingDeathAnimation()
    return self.DoingDeathAnim
end

-- Return the name of the sequence the NPC currently is playing
function NPC:GetCurrentSequenceName()
    return self:GetSequenceName(self:GetSequence())
end

-- Return the name of the activity the NPC currently is playing
function NPC:GetCurrentActivityName()
    return self:GetSequenceActivityName(self:GetSequence())
end

-- Add a new animation event for this sequence at the desired frame
-- Use in CustomInitialize
function NPC:AddAnimationEvent(seq, frame, ev)
    if !self.EnableLUAAnimationEvents then return end
    if(!self.ZBaseLuaAnimationFrames[seq]) then
        local seqID = self:LookupSequence( seq )
        if seqID && seqID != -1 then
            local seqFrames = self:SequenceGetFrames( seqID, 1 )
            self.ZBaseLuaAnimationFrames[seq] = seqFrames
        else
            conv.devPrint( Color( 255, 0, 0, 255 ), "LUA animation event ERROR! ", "The sequence '"..seq.."' does not exist!" )
            return
        end
    end

    if frame <= self.ZBaseLuaAnimationFrames[seq] then
        -- conv.devPrint( "LUA animation event created: ", "[ SEQUENCE: " .. seq .. " FRAMES: " .. self.ZBaseLuaAnimationFrames[seq] .. " ] AT" .. " [ FRAME: " .. frame, " EVENT_ID: " .. ev .. " ]" )
    else
        conv.devPrint( Color( 255, 0, 0, 255 ), "LUA animation event ERROR! ", "You've tried to create an animation event at frame [" .. frame .. "] while sequence [" .. seq .. "] has only [" .. self.ZBaseLuaAnimationFrames[seq] .. "] frame/s." )
        return false
    end
 
    self.ZBaseLuaAnimEvents[seq] = self.ZBaseLuaAnimEvents[seq] || {}
    self.ZBaseLuaAnimEvents[seq][frame] = self.ZBaseLuaAnimEvents[seq][frame] || {}

    table.insert( self.ZBaseLuaAnimEvents[seq][frame], ev )	
end

--[[
==================================================================================================
                                           MELEE ATTACK
==================================================================================================
--]]

-- Triggers the base melee attack
-- 'forceFaceEnt' - Force the NPC to face this entity while attacking
function NPC:MeleeAttack( forceFaceEnt )
    self.MeleeEntToFace = forceFaceEnt

    -- Animation
    if !table.IsEmpty(self.MeleeAttackAnimations) then
        self:MeleeAnimation()
    end
    
    self.MeleeEntToFace = nil

    -- Damage
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
            if self:GetNPCState()==NPC_STATE_DEAD or self.Dead then return end

            self:InternalMeleeAttackDamage(dmgData)
        end)
    end

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
    local hitEnts = self:InternalMeleeAttackDamage(dmgData)
    return hitEnts
end

--[[
==================================================================================================
                                           RANGE ATTACK
==================================================================================================
--]]

-- Triggers the base range attack
function NPC:RangeAttack()
        -- Animation --
    local animData = {}

    if !table.IsEmpty(self.RangeAttackAnimations) then
        animData = self:RangeAttackAnimation() or {}
    end

    -- Projectile
    if self.RangeProjectile_Delay then
        self.RangeAttackTimerActive = true

        timer.Simple(self.RangeProjectile_Delay, function()

            self.RangeAttackTimerActive = nil
            
            if !IsValid(self) then return end
            if self.Dead or self:GetNPCState()==NPC_STATE_DEAD then return end

            self:RangeAttackProjectile()

        end)
    end

    -- Special face code
    if !table.IsEmpty(self.RangeAttackAnimations) && self.RangeAttackFaceEnemy then
        self.TimeUntilStopFace = (animData.duration or (self:SequenceDuration() + 0.25)) / (animData.speedMult or 1)
        self:Face(self:RangeAttack_IdealFacePos(), self.TimeUntilStopFace, self.RangeAttackTurnSpeed)
    end

    if math.random(1, self.OnRangeSound_Chance) == 1 then
        self:EmitSound_Uninterupted(self.OnRangeSounds)
    end

    self:OnRangeAttack()
end

    -- Returns the ideal position to face while range attacking
function NPC:RangeAttack_IdealFacePos()
    local ene = self:GetEnemy()
    local pos = IsValid(ene) && self.EnemyVisible && ene:WorldSpaceCenter() or self:Projectile_TargetPos()
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
    self:ZBWepSys_SuppressionThink()
    return ( ene && self.EnemyVisible && ene:WorldSpaceCenter() ) or self:Projectile_SpawnPos()+self:GetForward()*400
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

    if self.GrenCount > 0 && self.GrenCount != -1 then
        self.GrenCount = self.GrenCount - 1
    end

    timer.Simple(self.GrenadeReleaseTime, function()
        if !IsValid(self) or self.Dead then return end

        local grencls = ( istable(self.GrenadeEntityClass) && self.GrenadeEntityClass[math.random(1, #self.GrenadeEntityClass)] )
        or self.GrenadeEntityClass
        
        local grenade = ents.Create(grencls)
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

        self:OnGrenadeSpawned(grenade)
    end)
end

--[[
==================================================================================================
                                           WEAPON STUFF
==================================================================================================
--]]

function NPC:HasAmmo()
    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then return false end

    return wep:Clip1() > 0
end

--[[
==================================================================================================
                                    UTILITIES / CONVENIENCE
==================================================================================================
--]]

-- Give zombie NPCs headcrabs
function NPC:Zombie_GiveHeadCrabs()
    self:SetSaveValue("m_fIsHeadless", false)
    self:SetBodygroup(1, 1)

    if self:GetEngineClass()=="npc_poisonzombie" then
        self:SetSaveValue("m_nCrabCount", 3)
        self:SetSaveValue("m_bCrabs", {true, true, true})

        for i = 2, 4 do
            self:SetBodygroup(i, 1)
        end
    end
end

-- Emit a foot step sound, should idealy be used instead of regular emit sound code
-- Uses self.FootStepSounds
function NPC:EmitFootStepSound()
    local stepent = ents.Create("zb_temporary_ent")
    stepent.ShouldRemain = true

    stepent:SetNoDraw(true)
    stepent:SetPos(self:GetPos())
    stepent:SetOwner(self)
    stepent:Spawn()
    stepent.IsZBaseStepEnt = true

    stepent:EmitSound(self.FootStepSounds)
    SafeRemoveEntityDelayed(stepent, 1)
end

-- Just like Entity:EmitSound(), except it will prevent certain sounds from playing over it
function NPC:EmitSound_Uninterupted( ... )
    ZBase_DontSpeakOverThisSound = true
    self:EmitSound(...)
    ZBase_DontSpeakOverThisSound = false
end

-- Returns the name of the NPC's squad
function NPC:SquadName()
    return self:GetKeyValues().squadname
end

-- Is this NPC even alive at all?
function NPC:IsAlive()
    return !(self.Dead or self.DoingDeathAnim or self:GetNPCState() == NPC_STATE_DEAD)
end

--[[
==================================================================================================
                                    AI / CALCULATIONS / CHECKS
==================================================================================================
--]]

-- Essentially just a classic ent:Visible() check
-- But maybe better performance idk
function NPC:SeeEne()
    return self.EnemyVisible
end

-- Essentially just a classic npc:IsMoving() check
-- But maybe better performance idk
function NPC:IsMoving_Cheap()
    return self.ZBase_IsMoving or self.bControllerMoving
end

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

-- Check if an entity is allied with the NPC
function NPC:IsAlly( ent )
    if !IsValid(ent) then return false end
    if ent==self then return false end
    if self.ZBaseFaction == "none" then return false end

    return ent.ZBaseFaction == self.ZBaseFaction
end

-- Same as below but uses a box and is probably more optimized
-- Only detects ZBase NPCs
function NPC:GetNearbyAlliesOptimized( lenght )
    local allies = {}

    if !cacheGetNearbyAlliesOptimized[lenght] then
        local halflenght = lenght*0.5
        local vec = Vector(halflenght, halflenght, halflenght)
        cacheGetNearbyAlliesOptimized[lenght] = vec
    end

    local vec_add = cacheGetNearbyAlliesOptimized[lenght]

    local mypos = self:GetPos()
    local amt = 0
    for k, v in ipairs(ents.FindInBox(mypos-vec_add, mypos+vec_add)) do

        amt = k
        
        if v == self then continue end
        if !v.IsZBaseNPC then continue end

        if self:IsAlly(v) then
            table.insert(allies, v)
        end

    end

    return allies
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

-- Same as below but uses a box and should be more optimized
-- Only returns ZBase NPCs
function NPC:GetNearestAllyOptimized( lenght )
    local mindist
    local ally

    for _, v in ipairs(self:GetNearbyAlliesOptimized(lenght)) do
        local dist = self:GetPos():DistToSqr(v:GetPos())

        if !mindist or dist < mindist then
            mindist = dist
            ally = v
        end
    end

    return ally
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

-- Get the velocity vector of a moving target
function NPC:GetMovingTargetVel( trgt )
    if !IsValid(trgt) then
        return vector_origin
    end

    if trgt:IsNPC() then
        return trgt:GetMoveVelocity()
    end

    return trgt:GetVelocity()
end

--[[
==================================================================================================
                                           DEATH / GIB STUFF
==================================================================================================
--]]

-- Kills the NPC (no death animation)
-- 'dmginfo' - Damage info, not required
function NPC:InduceDeath( dmginfo )
    dmginfo = dmginfo or DamageInfo()
    
    -- Death anim workaround
    if self.DoingDeathAnim then
        -- Mark us as not doing death animation
        -- Allows damage to happen, etc..
        self.DoingDeathAnim = false

        -- Stop playing the animation to reset our state
        -- so we can die
        self:InternalStopAnimation()
    end

    local cls = self:GetClass()
    local attacker = dmginfo:GetAttacker()

    if cls == "npc_combinedropship" or cls == "npc_helicopter" or cls == "npc_combinegunship" then
        hook.Run("OnNPCKilled", self, attacker, game.GetWorld())
    end

    if cls == "npc_combinedropship" then
        self:Remove()
        return
    end

    self:CONV_CallNextTick(function()
        local dmginfo2 = DamageInfo()
        dmginfo2:SetDamage(math.huge)
        dmginfo2:SetAttacker(conv.thisEntOrWorld(attacker))
        dmginfo2:SetInflictor(conv.thisEntOrWorld(attacker))
        dmginfo2:SetDamageForce(Vector(1,1,1))
        dmginfo2:SetDamagePosition(self:WorldSpaceCenter())
        dmginfo2:SetDamageType(DMG_BLAST)

        if cls=="npc_helicopter" then
            dmginfo2:SetDamageType(DMG_AIRBOAT)
        end

        self:TakeDamageInfo(dmginfo2)
    end)
end

-- Creates a gib entity with the given model
-- Returns the gib so that you can do whatever you want with it after creation
-- 'model' - The model to use
-- 'data' (table)
    -- 'data.offset' - Vector position offset relative to itself
    -- 'data.DontBleed' - If true, the gib will not have blood effects
    -- 'IsRagdoll' - If true, spawn gib as ragdoll
    -- 'SmartPositionRagdoll' - If true, position the ragdoll like the NPC
function NPC:CreateGib( model, data )
    return self:InternalCreateGib( model, data )
end