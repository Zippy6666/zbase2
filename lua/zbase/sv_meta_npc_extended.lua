local NPC = FindMetaTable("NPC")
local ENT = FindMetaTable("Entity")

--[[
======================================================================================================================================================
                                           RELATIONSHIP STUFF
======================================================================================================================================================
--]]


local VJ_Translation = {
    ["CLASS_COMBINE"] = "combine",
    ["CLASS_ZOMBIE"] = "zombie",
    ["CLASS_ANTLION"] = "antlion",
    ["CLASS_PLAYER_ALLY"] = "ally",
    ["CLASS_XEN"] = "xen",
    ["CLASS_UNITED_STATES"] = "hecu",
    ["CLASS_BLACKOPS"] = "blackops",
    ["CLASS_RACE_X"] = "racex",
    ["CLASS_AIDEN"] = "clonecop"
}


local VJ_Translation_Flipped = {
    ["combine"] = "CLASS_COMBINE",
    ["zombie"] = "CLASS_ZOMBIE",
    ["antlion"] = "CLASS_ANTLION",
    ["ally"] = "CLASS_PLAYER_ALLY",
    ["xen"] = "CLASS_XEN",
    ["hecu"] = "CLASS_UNITED_STATES",
    ["blackops"] = "CLASS_BLACKOPS",
    ["racex"] = "CLASS_RACE_X",
    ["clonecop"] = "CLASS_AIDEN"
}


function NPC:ZBaseSetMutualRel( ent, relToEnt )
    
    if !IsValid(ent) then return end


    local relToMe = relToEnt
    if self.IsZBPlyControlled && self.ZBControlTarget == ent then
        -- Always hate control target if controlled
        relToEnt = D_HT
        print("hate control target")
    elseif self.IsZBPlyControlled then
        -- Neutral to all else if controlled
        relToEnt = D_NU
        print("neutral to", ent)
    end


    -- Set relationship to recipient
    local prohibitRel = (self.IsZBaseNPC && !self:OnBaseSetRel(ent, relToEnt, 99))
    if !prohibitRel then

        self:AddEntityRelationship(ent, relToEnt, 99)
    
        -- Recipient's bullseye relationship, allows snpcs of the same class to hate each other
        if ent.IsZBase_SNPC && ent:GetClass()==self:GetClass() && IsValid(ent.Bullseye) then
            self:AddEntityRelationship(ent.Bullseye, relToEnt, 99)
        end

    end


    -- If recipient is not a zbase npc, make the recipient feel the same way about us
    -- Unless we have notarget
    if !ent.IsZBaseNPC && ent:IsNPC() && !(bit.band(self:GetFlags(), FL_NOTARGET)==FL_NOTARGET) then

        -- Recipient keep hating its enemies
        -- Workaround for non-zbase NPCs ignoring players (and maybe other npcs potentially)
        for _, ene in ipairs(ent:GetKnownEnemies()) do
            if ene == self then continue end
            ent:AddEntityRelationship(ene, D_HT, 99)
        end

        ent:AddEntityRelationship(self, relToMe, 99)

    end

end


function NPC:ZBaseVJFriendly( ent )
    if !ent.IsVJBaseSNPC then return false end

    for _, v in ipairs(ent.VJ_NPC_Class) do
        if VJ_Translation[v] == self.ZBaseFaction then return true end
    end

    return false
end


function NPC:ZBaseDecideRelationship( ent )
    local myFaction = self.ZBaseFaction
    local theirFaction = ent.ZBaseFaction


    -- Me or the ent has faction neutral, like
    if myFaction == "neutral" or theirFaction=="neutral" then
        self:ZBaseSetMutualRel( ent, D_LI )
        return
    end


    -- My faction is none, hate everybody
    if myFaction == "none" then
        self:ZBaseSetMutualRel( ent, D_HT )
        return
    end


    -- Are their factions the same?
    if myFaction == theirFaction or self:ZBaseVJFriendly( ent ) then
        self:ZBaseSetMutualRel( ent, D_LI )
    else
        self:ZBaseSetMutualRel( ent, D_HT )
    end
end


function NPC:ZBaseUpdateRelationships()
    if !self.IsZBaseNPC then return end

    -- Set my VJ class
    if VJ_Translation_Flipped[self.ZBaseFaction] then
        self.VJ_NPC_Class = {VJ_Translation_Flipped[self.ZBaseFaction]}
    end

    -- Update relationships between all NPCs
    for _, v in ipairs(ZBaseRelationshipEnts) do
        if v != self then self:ZBaseDecideRelationship(v) end
    end

    -- Update relationships with players
    for _, v in player.Iterator() do
        self:ZBaseDecideRelationship(v)
    end
end


--[[
======================================================================================================================================================
                                           SCHEDULE STUFF
======================================================================================================================================================
--]]


ZBase_OldSetSchedule = ZBase_OldSetSchedule or NPC.SetSchedule


function NPC:SetSchedule( sched )
    if self.IsZBaseNPC && self:ShouldPreventSetSched( sched ) then
        return
    end


    if self.IsZBase_SNPC && self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialSetSchedule(sched)
    end


    return ZBase_OldSetSchedule(self, sched)
end