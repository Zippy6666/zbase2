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
end

--[[
======================================================================================================================================================
                                           UTILS
======================================================================================================================================================
--]]

function NPC:ZBASE_IsFacing(...)
    isFacingFunc = isFacingFunc or ZBaseNPCs["npc_zbase"].IsFacing
    isFacingFunc(self, ...)
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

    -- Player using pill pack, don't do relationship operation, let parakeet's pill pack do that instead
    if ent:IsPlayer() && IsValid(ent.pk_pill_ent) then
        return
    end

    if myLastDispToEnt == relToEnt then return end -- Relationship unchanged, don't do any relationship operations
    
    -- Set relationship to recipient
    if allowAddRelationship then

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