local NPC = FindMetaTable("NPC")
local NPC_ZBASE = ZBaseNPCs["npc_zbase"]
local Developer = GetConVar("developer")
local isFacingFunc
ZBase_OldSetSchedule = ZBase_OldSetSchedule or NPC.SetSchedule
ZBase_OldDropWeapon = ZBase_OldDropWeapon or NPC.DropWeapon

--[[
======================================================================================================================================================
                                           ANIMATION
======================================================================================================================================================
--]]

function NPC:ZBASE_SimpleAnimation(anim)
    self.DoingPlayAnim = true

    self:SetSchedule(SCHED_SCENE_GENERIC)

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

    -- Exit the animation after SequenceDuration
    self:CONV_TimerCreate("ZBASE_SimpleAnimation_Exit", self:SequenceDuration(), 1, function()
        self:SetNPCState(self.PreAnimNPCState)
        self.DoingPlayAnim = false
        self:ClearSchedule()
    end)
end

--[[
======================================================================================================================================================
                                           WEAPON HANDLING
======================================================================================================================================================
--]]

-- https://wiki.facepunch.com/gmod/Hold_Types
local holdTypeFallBack = {
    ["pistol"] 		= "revolver",
    ["smg"] 		= "ar2",
    ["grenade"] 	= "passive",
    ["ar2"] 		= "shotgun",	
    ["shotgun"] 	= "ar2",	
    ["rpg"] 		= "ar2",	
    ["physgun"] 	= "shotgun",	
    ["crossbow"] 	= "shotgun",	
    ["melee"] 		= "passive",	
    ["slam"] 		= "passive",	
    ["fist"] 		= "passive",	
    ["melee2"] 		= "passive",	
    ["knife"] 		= "passive",	
    ["duel"] 		= "pistol",	
    ["camera"] 		= "revolver",
    ["magic"] 		= "passive", 
    ["revolver"] 	= "pistol", 
    ["passive"] 	= "normal"
}

local holdTypeACTCheck = {
    ["pistol"] 	= ACT_RANGE_ATTACK_PISTOL,
    ["smg"] 	= ACT_RANGE_ATTACK_SMG1,
    ["ar2"] 	= ACT_RANGE_ATTACK_AR2,
    ["shotgun"] = ACT_RANGE_ATTACK_SHOTGUN,
    ["rpg"] 	= ACT_RANGE_ATTACK_RPG,
    ["passive"] = ACT_IDLE
}

-- Set hold type, use fallbacks if npc does not have supporting anims
-- Priority:
-- Original -> Fallback -> "smg" -> "normal"
function NPC:ZBASE_SetHoldType( wep, startHoldT, isFallBack, lastFallBack, isFail )
    if !isFail && (!holdTypeACTCheck[startHoldT] or self:SelectWeightedSequence(holdTypeACTCheck[startHoldT]) == -1) then
        -- Doesn't support this hold type

        if lastFallBack then
            -- "normal"
            self:ZBASE_SetHoldType( wep, "normal", false, false, true )
            return
        elseif isFallBack then
            -- "smg"
            self:ZBASE_SetHoldType( wep, "smg", false, true )
            return
        else
            -- Fallback
            self:ZBASE_SetHoldType( wep, holdTypeFallBack[startHoldT], true )
            return
        end
    end

    wep:SetHoldType(startHoldT)

    -- Make sure animations get updated
    
    self:TaskComplete()
    self:ClearSchedule()
    self:ResetIdealActivity(ACT_IDLE)
end

--[[
======================================================================================================================================================
                                           UTILS
======================================================================================================================================================
--]]

function NPC:ZBASE_IsFacing(...)
    isFacingFunc = isFacingFunc or ZBaseNPCs["npc_zbase"].IsFacing
    return isFacingFunc(self, ...)
end

-- Mainly useful for ZBase NPCs that are HL2 NPCs but have a custom class name
-- so that we can retrieve its actual engine class name
function NPC:GetEngineClass()
    if CLIENT then
        ZBASE_SkipClassNameWrapper = true
        local cls = self:GetClass()
        ZBASE_SkipClassNameWrapper = false
        
        return cls
    end

    return self.EngineClass
end

--[[
======================================================================================================================================================
                                           RELATIONSHIP STUFF
======================================================================================================================================================
--]]

function NPC:ZBASE_SetMutualRelationship( ent, rel )
    if !IsValid(ent) then return end

    local myLastDispToEnt = self:Disposition(ent)

    local relToEnt = rel
    local allowAddRelationship = !(self.IsZBaseNPC && !self:OnBaseSetRel(ent, relToEnt, 0))

    -- I am being controlled by a player
    -- and I am a ZBase NPC
    if self.IsZBaseNPC && self.ZBASE_IsPlyControlled && ent != self.ZBASE_ControlBullseye then
        -- I like everyone who is not my target bullseye
        -- they don't have to like me back though...
        relToEnt = D_LI
        conv.devPrint(self, " likes ", ent, " since not its bullseye")
    end

    -- ent is player using pill pack, don't do relationship operation, let parakeet's pill pack do that instead
    if ent:IsPlayer() && IsValid(ent.pk_pill_ent) then
        return
    end

    if myLastDispToEnt == relToEnt then return end -- Relationship unchanged, don't do any relationship operations

    -- Set relationship to recipient
    if allowAddRelationship  then

        self:AddEntityRelationship(ent, relToEnt, 0)

        -- Recipient's bullseye relationship, allows snpcs of the same class to hate each other
        if ent.IsZBase_SNPC && ent:GetClass()==self:GetClass() && IsValid(ent.Bullseye) then
            self:AddEntityRelationship(ent.Bullseye, relToEnt, 0)
        end

    end

    -- If recipient is not a ZBase npc, make the recipient feel the same way about us (Unless we have notarget)
    local isRegularNPC = !ent.IsZBaseNPC && ent:IsNPC()
    if isRegularNPC then
        local meHasNoTarget = (bit.band(self:GetFlags(), FL_NOTARGET)==FL_NOTARGET)
        local entRelToMe = rel

        if !hasNoTarget then
            ent:AddEntityRelationship(self, entRelToMe, 0)
        end
    end

end

--[[
======================================================================================================================================================
                                           Wrapper funcs
======================================================================================================================================================
--]]

function NPC:SetSchedule( sched, ... )
    -- Prevent LUA from setting schedules to ZBase NPCs if we should
    if self.IsZBaseNPC && self:ShouldPreventSetSched( sched ) then
        return
    end

    -- Usual drop weapon
    return ZBase_OldSetSchedule(self, sched, ...)
end

function NPC:DropWeapon( wep, ... )
    -- Fix zbase npcs not dropping engine weapons
    if self.IsZBaseNPC then
        wep = wep or self:GetActiveWeapon()

        if wep.IsEngineClone then
            local newWep = self:Give(wep.EngineCloneClass)
            local val = ZBase_OldDropWeapon( self, newWep, ...)

            wep:Remove()

            return val
        end
    end

    -- Usual drop weapon
    return ZBase_OldDropWeapon(self, wep, ...)
end

-- Ideal yaw and update - wrapper
-- NPC.SetIdealYawAndUpdate = conv.wrapFunc("ZBASE_UpdateYaw", NPC.SetIdealYawAndUpdate, function(self, yaw, speed)
    -- Is ZBase NPC...
    -- if self.IsZBaseNPC then
    --     if self:ShouldPreventSetYaw() then
            -- Prevent set yaw if we should
        --     return false
        -- end
    
        --     if !self.ZBase_DidInternalUpdateYawCall && self.ZBase_CurrentFace_bShould then
            -- Stop ZBase face function
            -- The developer of the NPC clearly wants it to face somewhere else
            -- Don't fight them
    --         self:StopFace()
    --         conv.devPrint("Stopped ZBase face")
    --     end
    -- end

    -- Don't alter anything for other NPCs
-- end)