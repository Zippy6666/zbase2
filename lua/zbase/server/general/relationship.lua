local NPC = FindMetaTable("NPC")
if !ZBaseRelationshipEnts then ZBaseRelationshipEnts = {} end


ZBaseFactionTranslation = {
    [CLASS_COMBINE] = "combine",
    [CLASS_COMBINE_GUNSHIP] = "combine",
    [CLASS_MANHACK] = "combine",
    [CLASS_METROPOLICE] = "combine",
    [CLASS_MILITARY] = "combine",
    [CLASS_SCANNER] = "combine",
    [CLASS_STALKER] = "combine",
    [CLASS_PROTOSNIPER] = "combine",
    [CLASS_COMBINE_HUNTER] = "combine",

    [CLASS_HACKED_ROLLERMINE] = "ally",
    [CLASS_HUMAN_PASSIVE] = "ally",
    [CLASS_VORTIGAUNT] = "ally",
    [CLASS_PLAYER] = "ally",
    [CLASS_PLAYER_ALLY] = "ally",
    [CLASS_PLAYER_ALLY_VITAL] = "ally",
    [CLASS_CITIZEN_PASSIVE] = "ally",
    [CLASS_CITIZEN_REBEL] = "ally",

    [CLASS_BARNACLE] = "xen",
    [CLASS_ALIEN_MILITARY] = "xen",
    [CLASS_ALIEN_MONSTER] = "xen",
    [CLASS_ALIEN_PREDATOR] = "xen",

    [CLASS_MACHINE] = "hecu",
    [CLASS_HUMAN_MILITARY] = "hecu",

    [CLASS_HEADCRAB] = "zombie",
    [CLASS_ZOMBIE] = "zombie",
    [CLASS_ALIEN_PREY] = "zombie",

    [CLASS_ANTLION] = "antlion",

    [CLASS_EARTH_FAUNA] = "neutral",
}


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


util.AddNetworkString("ZBasePlayerFactionSwitch")
util.AddNetworkString("ZBaseNPCFactionOverrideSwitch")


---------------------------------------------------------------------------------------------------------------------=#
net.Receive("ZBasePlayerFactionSwitch", function( _, ply )
    local faction = net.ReadString()
    ply.ZBaseFaction = faction

    for _, v in ipairs(ZBaseRelationshipEnts) do
        v:Relationships()
    end
end)
---------------------------------------------------------------------------------------------------------------------=#
net.Receive("ZBaseNPCFactionOverrideSwitch", function( _, ply )
    local faction = net.ReadString()
    
    if faction == "No Override" then
        ply.ZBaseNPCFactionOverride = nil
    else
        ply.ZBaseNPCFactionOverride = faction
    end
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("OnEntityCreated", "ZBaseFactions", function( ent ) timer.Simple(0, function()
    if !IsValid(ent) then return end

    if ent:IsNPC() && ent:GetClass() != "npc_bullseye" && !ent.IsZBaseNavigator then
        local faction = ZBaseFactionTranslation[ent:Classify()]

        
        table.insert(ZBaseRelationshipEnts, ent)
        ent:CallOnRemove("ZBaseRelationshipEntsRemove", function() table.RemoveByValue(ZBaseRelationshipEnts, ent) end)


        ent:SetZBaseFaction(!ent.IsZBaseNPC && faction)
    end
end) end)
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SetZBaseFaction(newFaction)
    self.ZBaseFaction = newFaction or self.ZBaseStartFaction

    for _, v in ipairs(ZBaseRelationshipEnts) do
        v:Relationships()
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SetRelationship( ent, rel )
    self:AddEntityRelationship(ent, rel, 99)

    if ent.IsZBase_SNPC && ent:GetClass()==self:GetClass() && IsValid(ent.Bullseye) then
        self:AddEntityRelationship(ent.Bullseye, rel, 99)
    end

    if !ent.IsZBaseNPC && ent:IsNPC() then
        ent:AddEntityRelationship(self, rel, 99)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBase_VJFriendly( ent )
    if !ent.IsVJBaseSNPC then return false end

    for _, v in ipairs(ent.VJ_NPC_Class) do
        if VJ_Translation[v] == self.ZBaseFaction then return true end
    end

    return false
end
---------------------------------------------------------------------------------------------------------------------=#
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
---------------------------------------------------------------------------------------------------------------------=#
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
---------------------------------------------------------------------------------------------------------------------=#