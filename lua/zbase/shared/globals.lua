AddCSLuaFile()


-- game.AddDecal( "ZBaseSynthBlood", {
--     "decals/zsynthblood1",
--     -- "decals/zsynthblood2",
--     -- "decals/zsynthblood3",
--     -- "decals/zsynthblood4",
--     -- "decals/zsynthblood5",
--     -- "decals/zsynthblood6",
-- } )


ZBASE_SNPCTYPE_WALK = 1
ZBASE_SNPCTYPE_FLY = 2
ZBASE_SNPCTYPE_STATIONARY = 3
ZBASE_SNPCTYPE_VEHICLE = 4
ZBASE_SNPCTYPE_PHYSICS = 5


ZBASE_CANTREACHENEMY_HIDE = 1
ZBASE_CANTREACHENEMY_FACE = 2


if !ZBaseNPCs then
    ZBaseNPCs = {}
    ZBaseNPCInstances = {}
    ZBaseNPCInstances_NonScripted = {}
    ZBaseBehaviourTimerFuncs = {}
    ZBase_NonZBaseNPCs = {}
    ZBaseSpawnMenuNPCList = {}
    ZBaseSpeakingSquads = {}
end


if SERVER then
    ZBaseForbiddenFaceScheds = {
        [SCHED_ALERT_FACE]	= true,
        [SCHED_ALERT_FACE_BESTSOUND]	= true,
        [SCHED_COMBAT_FACE] 	= true,
        [SCHED_FEAR_FACE] 	= true,	
        [SCHED_SCRIPTED_FACE] 	= true,	
        [SCHED_TARGET_FACE]	= true,
    }
end


ZBase_EmitSoundCall = false
ZBase_DontSpeakOverThisSound = false
ZBaseComballOwner = NULL


local BloodEffects = {
    [BLOOD_COLOR_RED] = "blood_impact_red_01",
    [BLOOD_COLOR_ANTLION] = "blood_impact_antlion_01",
    [BLOOD_COLOR_ANTLION_WORKER] = "blood_impact_antlion_worker_01",
    [BLOOD_COLOR_GREEN] = "blood_impact_green_01",
    [BLOOD_COLOR_ZOMBIE] = "blood_impact_zombie_01",
    [BLOOD_COLOR_YELLOW] = "blood_impact_yellow_01",
}


-------------------------------------------------------------------------------------------------------------------------=#
-- Quickly adds a soundscript with voice like features
function ZBaseCreateVoiceSounds( name, tbl )
    sound.Add( {
        name = name,
        channel = CHAN_VOICE,
        volume = 0.5,
        level = 90,
        pitch = {95, 105},
        sound = tbl,
    } )
end
-------------------------------------------------------------------------------------------------------------------------=#
-- Blood effect from an NPC
function ZBaseBleed( ent, pos, ang )
    if !ent.GetBloodColor then return end
    if ent.GetNPCState && ent:GetNPCState()==NPC_STATE_DEAD then return end

    local bloodcol = ent:GetBloodColor()

    if bloodcol==BLOOD_COLOR_MECH then
        local spark = ents.Create("env_spark")
        spark:SetKeyValue("spawnflags", 256)
        spark:SetKeyValue("TrailLength", 1)
        spark:SetKeyValue("Magnitude", 1)
        spark:SetPos(pos)
        spark:SetAngles(ang && -ang or AngleRand())
        spark:Spawn()
        spark:Activate()
        spark:Fire("SparkOnce")
        SafeRemoveEntityDelayed(spark, 0.1)
    else
        local effect = BloodEffects[bloodcol]

        if effect then
            ParticleEffect(effect, pos, ang or AngleRand())
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
function ZBaseEnhancementNPCClass(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split]
    local split2 = string.Split(name, ".")
    return split2[1]
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
function ZBasePrintInternalVars(ent)
    print("---", ent, "internal vars", "---")
    for k in pairs(ent:GetSaveTable( true )) do
        print(k)
    end
    print("----------------------------------------")
end
---------------------------------------------------------------------------------------------------------------------=#
function ZBaseRndTblRange( tbl )
    return math.Rand(tbl[1], tbl[2])
end
---------------------------------------------------------------------------------------------------------------------=#
function ZBaseListFactions( _, ply )
    if SERVER then
        local factions = {none=true, neutral=true, ally=true}

        for k, v in pairs(ZBaseNPCs) do
            if v.ZBaseStartFaction then
                factions[v.ZBaseStartFaction] = true
            end
        end

        net.Start("ZBaseListFactions")
        net.WriteTable(factions)
        net.Send(ply)
    end

    if CLIENT then
        net.Start("ZBase_GetFactionsFromServer")
        net.SendToServer()
    end
end
---------------------------------------------------------------------------------------------------------------------=#
if SERVER then
    util.AddNetworkString("ZBaseListFactions")
    util.AddNetworkString("ZBase_GetFactionsFromServer")
    net.Receive("ZBase_GetFactionsFromServer", ZBaseListFactions)
end
---------------------------------------------------------------------------------------------------------------------=#