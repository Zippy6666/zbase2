-- CVARS --
CreateConVar("zbase_max_ragdolls", "20", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
CreateConVar("zbase_ragdoll_remove_time", "0", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
--------------------------------------------------------------------------------=#

if !ZBASE_NPC_WEAPONS then
    ZBASE_NPC_WEAPONS = {}
end

--------------------------------------------------------------------------------=#
function ZBASE_TBL( tbl )
    local function returnTbl()
        return tbl
    end
    return returnTbl
end
--------------------------------------------------------------------------------=#

--------------------------------------------------------------------------------=#
if SERVER then

    local factionTranslation = {
        -- Combine
        [CLASS_COMBINE] = "CLASS_COMBINE",
        [CLASS_COMBINE_GUNSHIP] = "CLASS_COMBINE",
        [CLASS_MANHACK] = "CLASS_COMBINE",
        [CLASS_METROPOLICE] = "CLASS_COMBINE",
        [CLASS_MILITARY] = "CLASS_COMBINE",
        [CLASS_SCANNER] = "CLASS_COMBINE",
        [CLASS_STALKER] = "CLASS_COMBINE",
        [CLASS_PROTOSNIPER] = "CLASS_COMBINE",
        [CLASS_COMBINE_HUNTER] = "CLASS_COMBINE",

        -- Player ally
        [CLASS_HACKED_ROLLERMINE] = "CLASS_PLAYER_ALLY",
        [CLASS_HUMAN_PASSIVE] = "CLASS_PLAYER_ALLY",
        [CLASS_VORTIGAUNT] = "CLASS_PLAYER_ALLY",
        [CLASS_PLAYER] = "CLASS_PLAYER_ALLY",
        [CLASS_PLAYER_ALLY] = "CLASS_PLAYER_ALLY",
        [CLASS_PLAYER_ALLY_VITAL] = "CLASS_PLAYER_ALLY",
        [CLASS_CITIZEN_PASSIVE] = "CLASS_PLAYER_ALLY",
        [CLASS_CITIZEN_REBEL] = "CLASS_PLAYER_ALLY",

        -- Xen
        [CLASS_BARNACLE] = "CLASS_XEN",
        [CLASS_ALIEN_MILITARY] = "CLASS_XEN",
        [CLASS_ALIEN_MONSTER] = "CLASS_XEN",
        [CLASS_ALIEN_PREDATOR] = "CLASS_XEN",

        -- Hecu
        [CLASS_MACHINE] = "CLASS_HECU",
        [CLASS_HUMAN_MILITARY] = "CLASS_HECU",

        -- Zombie
        [CLASS_HEADCRAB] = "CLASS_ZOMBIE",
        [CLASS_ZOMBIE] = "CLASS_ZOMBIE",
        [CLASS_ALIEN_PREY] = "CLASS_ZOMBIE",

        -- Antlion
        [CLASS_ANTLION] = "CLASS_ANTLION",
    }

    -- A table that should hold all NPCs except VJ Base ones
    if !ZBASE_NPC_TABLE then ZBASE_NPC_TABLE = {} end

    --------------------------------------------------------------------------------=#
    function ZBASE_HAS_FACTION( ent, faction )

        if faction == ent.ZBase_Factions() then return true end

        if istable(ent.ZBase_Factions()) then
            for _, f in ipairs(ent.ZBase_Factions()) do
                if f == faction then return true end
            end
        end

        return false
    
    end
    --------------------------------------------------------------------------------=#

    --------------------------------------------------------------------------------=#
    hook.Add("OnEntityCreated", "ZBase_EntityCreated_Relationships", function( ent )

        -- Give normal NPCs ZBase factions:
        if ent:IsNPC() && !ent.IsVJBaseSNPC && !ent.IsZBaseSNPC then
            local function faction() return factionTranslation[ent:Classify()] end
            ent.ZBase_Factions = faction
        end

        if ent:IsNPC() && !ent.IsVJBaseSNPC then
            table.insert(ZBASE_NPC_TABLE, ent)
            ent:CallOnRemove("ZBase_RemoveFromNPCTable", function() table.RemoveByValue(ZBASE_NPC_TABLE, ent) end)
        end

    end)
    --------------------------------------------------------------------------------=#

end
--------------------------------------------------------------------------------=#

-- Add all ZBase SNPCs to the spawnmenu --
hook.Add("PreRegisterSENT", "ZBaseAddSNPCs", function( ENT, class )
    if ENT.IsZBaseSNPC && class != "npc_zbase" then
        list.Set("NPC", class, {
            Name = ENT.PrintName,
            Class = class,
            Category = ENT.Category,
            Weapons = ZBASE_NPC_WEAPONS[class],
        })
    end
end)
--------------------------------------------------------------------------------=#

-- Add all ZBase SNPCs to the spawnmenu --
hook.Add("PreRegisterSWEP", "ZBaseAddNPCWeapons", function( SWEP, class )

    if SWEP.IsZBaseSWEP && class != "weapons_zbase" then
        list.Set("NPCUsableWeapons", { class = class, title = SWEP.PrintName, category = "ZBase" } )
    end

end)
--------------------------------------------------------------------------------=#

-- Menu --
if CLIENT then
    hook.Add("PopulateToolMenu", "PopulateToolMenu_ZBase", function() spawnmenu.AddToolMenuOption("ZBase", "SNPC Settings", "Ragdolls", "Ragdolls", "", "", function(panel)

        panel:Help("These settings only apply when keep corpses is turned off!")

        panel:NumSlider("Ragdoll Lifetime", "zbase_ragdoll_remove_time", 0, 300, 0)
        panel:ControlHelp("Ragdoll lifetime in seconds, 0 = Infinite")

        panel:NumSlider("Max Ragdolls", "zbase_max_ragdolls", 0, 200, 0)
        panel:ControlHelp("Remove old ragdolls if there are more than this amount")

    end) end)
end
--------------------------------------------------------------------------------=#