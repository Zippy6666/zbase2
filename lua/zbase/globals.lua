--[[
======================================================================================================================================================
                                           ENUMS
======================================================================================================================================================
--]]


ZBASE_SNPCTYPE_WALK = 1
ZBASE_SNPCTYPE_FLY = 2
ZBASE_SNPCTYPE_STATIONARY = 3
ZBASE_SNPCTYPE_VEHICLE = 4
ZBASE_SNPCTYPE_PHYSICS = 5


ZBASE_CANTREACHENEMY_HIDE = 1
ZBASE_CANTREACHENEMY_FACE = 2


--[[
======================================================================================================================================================
                                           ESSENTIAL FUNCTIONS
======================================================================================================================================================
--]]


function FindZBaseTable(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split-1]
    return ZBaseNPCs[name]
end


function FindZBaseBehaviourTable(debuginfo)
    if SERVER then
        return FindZBaseTable(debuginfo).Behaviours
    end
end


--[[
======================================================================================================================================================
                                           UTIL FUNCTIONS
======================================================================================================================================================
--]]


function ZBaseSetFaction( ent, newFaction )
    ent.ZBaseFaction = newFaction or ent.ZBaseStartFaction

    for _, v in ipairs(ZBaseRelationshipEnts) do
        v:Relationships()
    end
end


--[[
======================================================================================================================================================
                                           CONVINIENT FUNCTIONS
======================================================================================================================================================
--]]


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


function ZBaseBleed( ent, pos, ang )
    if !SERVER then return end
    if !ent.GetBloodColor then return end
    if ent.GetNPCState && ent:GetNPCState()==NPC_STATE_DEAD then return end


    local distFromSelf = ent:GetPos():DistToSqr(pos)
    if distFromSelf > (math.max(ent:OBBMaxs().x, ent:OBBMaxs().z)*1.5)^2 then
        pos = ent:WorldSpaceCenter()+VectorRand()*15
    end


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
        local BloodEffects = {
            [BLOOD_COLOR_RED] = "blood_impact_red_01",
            [BLOOD_COLOR_ANTLION] = "blood_impact_antlion_01",
            [BLOOD_COLOR_ANTLION_WORKER] = "blood_impact_antlion_worker_01",
            [BLOOD_COLOR_GREEN] = "blood_impact_green_01",
            [BLOOD_COLOR_ZOMBIE] = "blood_impact_zombie_01",
            [BLOOD_COLOR_YELLOW] = "blood_impact_yellow_01",
        }
        local effect = BloodEffects[bloodcol]


        if effect then
            ParticleEffect(effect, pos, ang or AngleRand())
        end
    end
end


function ZBaseRndTblRange( tbl )
    return math.Rand(tbl[1], tbl[2])
end