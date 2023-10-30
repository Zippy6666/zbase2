AddCSLuaFile()

ZBaseCvar_Replace = CreateConVar("zbase_replace", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
ZBaseCvar_HL2WepDMG = CreateConVar("zbase_hl2_wep_damage", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))

if !ZBaseNPCs then
    ZBaseNPCs = {}
    ZBaseNPCInstances = {}
    ZBaseBehaviourTimerFuncs = {}
    ZBase_NonZBaseNPCs = {}
    ZBaseSpawnMenuNPCList = {}
end

if SERVER then
    ZBaseFactionTranslation = {
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
end


ZBase_EmitSoundCall = false
ZBaseComballOwner = NULL

-------------------------------------------------------------------------------------------------------------------------=#
function ZBaseInit(ent, name)
    table.insert(ZBaseNPCInstances, ent)

    -- Table "transfer" --
    ent.ZBase_Class = string.Right(name, #name-6)
    ent.ZBase_Inherit = ZBaseNPCs[ent.ZBase_Class].Inherit
    
        -- Inherit from base
    for k, v in pairs( ZBaseNPCs["npc_zbase"] ) do
        ent[k] = v
    end

        -- Inherit from self.Inherit NPC
    for k, v in pairs( ZBaseNPCs[ent.ZBase_Inherit] ) do
        ent[k] = v
        -- print("ent.ZBase_Inherit:"..ent.ZBase_Inherit, k, v)
    end

        -- This npc's table
    for k, v in pairs(ZBaseNPCs[ent.ZBase_Class]) do
        ent[k] = v
        -- print(k=="BeforeEmitSound")
    end

    ent:ZBaseInit(ZBaseNPCs[ent.ZBase_Class])
end
-------------------------------------------------------------------------------------------------------------------------=#
function IsZBaseNPC(ent)
    if SERVER then
        local parentname = ent:GetKeyValues().parentname
        return string.StartWith(parentname, "zbase_")
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
function FindZBaseTable(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split-1]
    return ZBaseNPCs[name]
end
-------------------------------------------------------------------------------------------------------------------------=#
function FindZBaseBehaviourTable(debuginfo)
    if SERVER then
        return FindZBaseTable(debuginfo).Behaviours
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
-- List an entity's internal variables
function ZBasePrintInternalVars(ent)
    print("---", ent, "internal vars", "---")
    for k in pairs(ent:GetSaveTable( true )) do
        print(k)
    end
    print("----------------------------------------")
end
-------------------------------------------------------------------------------------------------------------------------=#
-- Quickly adds a soundscript with voice like features
function ZBaseCreateVoiceSounds( name, tbl )
    sound.Add( {
        name = name,
        channel = CHAN_VOICE,
        volume = 0.8,
        level = 90,
        pitch = {95, 105},
        sound = tbl,
    } )
end
---------------------------------------------------------------------------------------------------------------------=#
-- Pretty straight forward if you look at the code
function ZBaseRndTblRange( tbl )
    return math.Rand(tbl[1], tbl[2])
end
---------------------------------------------------------------------------------------------------------------------=#