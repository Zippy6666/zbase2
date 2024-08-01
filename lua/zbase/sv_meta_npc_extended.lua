local NPC = FindMetaTable("NPC")
local Developer = GetConVar("developer")


--[[
======================================================================================================================================================
                                           RELATIONSHIP STUFF
======================================================================================================================================================
--]]


function NPC:ZBASE_SetMutualRelationship( ent, rel )
    local myLastDispToEnt = self:Disposition(ent)


    if myLastDispToEnt == rel then return end -- Relationship unchanged
    if (bit.band(ent:GetFlags(), FL_NOTARGET)==FL_NOTARGET) then return end -- Recipient has notarget


    local relToEnt = rel
    local allowAddRelationship = !(self.IsZBaseNPC && !self:OnBaseSetRel(ent, relToEnt, 0))


    -- Neutral to all else if controlled
    if self.IsZBPlyControlled then
        relToEnt = D_NU
    end

    
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

    if Developer:GetBool() then
        MsgN(self, " ZBASE relationship change to ", ent)
    end

end


--[[
======================================================================================================================================================
                                           Other
======================================================================================================================================================
--]]


ZBase_OldSetSchedule = ZBase_OldSetSchedule or NPC.SetSchedule
ZBase_OldDropWeapon = ZBase_OldDropWeapon or NPC.DropWeapon

function NPC:SetSchedule( sched, ... )
    -- Prevent LUA from setting schedules to ZBase NPCs if we should
    if self.IsZBaseNPC && self:ShouldPreventSetSched( sched ) then
        return
    end

    -- Aerial ZBase NPC
    if self.IsZBase_SNPC && self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialSetSchedule(sched, ...)
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