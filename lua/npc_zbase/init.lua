local NPC = FindZBaseTable(debug.getinfo(1,'S'))



-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {}


NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.SightDistance = 7000 -- Sight distance
NPC.StartHealth = 100 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour


NPC.ZBaseFaction = "menace" -- Any string, all ZBase NPCs with this faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion"



    -- Functions you can change --

---------------------------------------------------------------------------------------------------------------------=#
    -- Called when the NPC is created --
function NPC:CustomInitialize() end
---------------------------------------------------------------------------------------------------------------------=#
    -- Called every tick --
function NPC:CustomThink() end
---------------------------------------------------------------------------------------------------------------------=#
    -- On NPC hurt, dmginfo:ScaleDamage(0) to prevent damage --
function NPC:CustomTakeDamage( dmginfo, HitGroup ) end
---------------------------------------------------------------------------------------------------------------------=#
    -- Called when the NPC hurts an entity, return true to prevent damage --
function NPC:DealDamage( victimEnt, dmginfo ) end
---------------------------------------------------------------------------------------------------------------------=#






    -- DON'T TOUCH ANYTHING BELOW HERE --


local factionTranslation = {
-- Combine
[CLASS_COMBINE] = "combine",
[CLASS_COMBINE_GUNSHIP] = "combine",
[CLASS_MANHACK] = "combine",
[CLASS_METROPOLICE] = "combine",
[CLASS_MILITARY] = "combine",
[CLASS_SCANNER] = "combine",
[CLASS_STALKER] = "combine",
[CLASS_PROTOSNIPER] = "combine",
[CLASS_COMBINE_HUNTER] = "combine",

-- Player ally
[CLASS_HACKED_ROLLERMINE] = "ally",
[CLASS_HUMAN_PASSIVE] = "ally",
[CLASS_VORTIGAUNT] = "ally",
[CLASS_PLAYER] = "ally",
[CLASS_PLAYER_ALLY] = "ally",
[CLASS_PLAYER_ALLY_VITAL] = "ally",
[CLASS_CITIZEN_PASSIVE] = "ally",
[CLASS_CITIZEN_REBEL] = "ally",

-- Xen
[CLASS_BARNACLE] = "xen",
[CLASS_ALIEN_MILITARY] = "xen",
[CLASS_ALIEN_MONSTER] = "xen",
[CLASS_ALIEN_PREDATOR] = "xen",

-- Hecu
[CLASS_MACHINE] = "hecu",
[CLASS_HUMAN_MILITARY] = "hecu",

-- Zombie
[CLASS_HEADCRAB] = "zombie",
[CLASS_ZOMBIE] = "zombie",
[CLASS_ALIEN_PREY] = "zombie",

-- Antlion
[CLASS_ANTLION] = "antlion",
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

---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseInit()

    -- Model
    if !table.IsEmpty(self.Models) then
        self:SetModel(table.Random(self.Models))
    end

    self:SetMaxHealth(self.StartHealth)
    self:SetHealth(self.StartHealth)
    self:SetMaxLookDistance(self.SightDistance)
    self:SetCurrentWeaponProficiency(self.WeaponProficiency)

    ZBaseBehaviourInit( self )

    -- Better position
    self:SetPos(self:GetPos()+Vector(0, 0, 20))

end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SetRelationship( ent, rel )
    self:AddEntityRelationship(ent, rel, 99)
    if ent:IsNPC() then
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
    if self.ZBaseFaction == ent.ZBaseFaction or self:ZBase_VJFriendly( ent ) then
        self:SetRelationship( ent, D_LI )
    else
        self:SetRelationship( ent, D_HT )
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:Relationships()

    if VJ_Translation_Flipped[self.ZBaseFaction] then
        self.VJ_NPC_Class = {VJ_Translation_Flipped[self.ZBaseFaction]}
    end

    for _, v in ipairs(ZBASE_NPC_TABLE) do
        if v != self then self:Relationship(v) end
    end

    for _, v in ipairs(player.GetAll()) do
        self:Relationship(v)
    end

end
---------------------------------------------------------------------------------------------------------------------=#
if !ZBASE_NPC_TABLE then ZBASE_NPC_TABLE = {} end
hook.Add("OnEntityCreated", "ZBase_EntityCreated_Relationships", function( ent )
    if ent:IsNPC() then

        ent.ZBaseFaction = factionTranslation[ent:Classify()]
        table.insert(ZBASE_NPC_TABLE, ent)

        ent:CallOnRemove("ZBase_RemoveFromNPCTable", function() table.RemoveByValue(ZBASE_NPC_TABLE, ent) end)

    end
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerSpawn", "PlayerSpawn", function( ply )
    ply.ZBaseFaction = "ally"
    print(ply.ZBaseFaction)
end)
---------------------------------------------------------------------------------------------------------------------=#