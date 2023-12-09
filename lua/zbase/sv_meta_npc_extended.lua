local NPC = FindMetaTable("NPC")


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
}


local VJ_Translation_Flipped = {
    ["combine"] = "CLASS_COMBINE",
    ["zombie"] = "CLASS_ZOMBIE",
    ["antlion"] = "CLASS_ANTLION",
    ["ally"] = "CLASS_PLAYER_ALLY",
}


function NPC:SetRelationship( ent, rel )
    self:AddEntityRelationship(ent, rel, 99)

    if ent.IsZBase_SNPC && ent:GetClass()==self:GetClass() && IsValid(ent.Bullseye) then
        self:AddEntityRelationship(ent.Bullseye, rel, 99)
    end

    if !ent.IsZBaseNPC && ent:IsNPC() then
        ent:AddEntityRelationship(self, rel, 99)
    end
end


function NPC:ZBase_VJFriendly( ent )
    if !ent.IsVJBaseSNPC then return false end

    for _, v in ipairs(ent.VJ_NPC_Class) do
        if VJ_Translation[v] == self.ZBaseFaction then return true end
    end

    return false
end


function NPC:Relationship( ent )
    -- Me or the ent has faction neutral, like
    local myFaction = self.ZBaseFaction
    local theirFaction = ent.ZBaseFaction

    if myFaction == "neutral" or theirFaction=="neutral" then
        self:SetRelationship( ent, D_LI )
        return
    end

    -- My faction is none, hate everybody
    if myFaction == "none" then
        self:SetRelationship( ent, D_HT )
        return
    end

    -- Are their factions the same?
    if myFaction == theirFaction or self:ZBase_VJFriendly( ent ) then
        self:SetRelationship( ent, D_LI )
    else
        self:SetRelationship( ent, D_HT )
    end
end


function NPC:Relationships()
    if !self.IsZBaseNPC then return end

    -- Set my VJ class
    if VJ_Translation_Flipped[self.ZBaseFaction] then
        self.VJ_NPC_Class = {VJ_Translation_Flipped[self.ZBaseFaction]}
    end

    -- Update relationships between all NPCs
    for _, v in ipairs(ZBaseRelationshipEnts) do
        if v != self then self:Relationship(v) end
    end

    -- Update relationships with players
    for _, v in ipairs(player.GetAll()) do
        self:Relationship(v)
    end
end