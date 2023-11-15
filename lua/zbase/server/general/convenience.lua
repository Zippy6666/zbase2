-------------------------------------------------------------------------------------=#


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
-------------------------------------------------------------------------------------=#


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
-------------------------------------------------------------------------------------=#