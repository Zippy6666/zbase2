local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {}
NPC.StartHealth = 50
NPC.CanPatrol = true

NPC.MuteDefaultVoice = true -- Mute all voice sounds normally emitted by this NPC
NPC.UseCustomSounds = true -- Should the NPC be able to use custom sounds?

NPC.AlertSounds = "ZBase.Alert"
NPC.IdleSounds = "ZBase.Idle"
NPC.IdleSounds_HasEnemy = "ZBase.IdleEnemy"
NPC.PainSounds = "ZBase.Pain"
NPC.DeathSounds = "ZBase.Death"

---------------------------------------------------------------------------------------------------------------------=#
    -- Accept input, return true to prevent --
function NPC:CustomAcceptInput( input, activator, caller, value )

    if input == "PullGrenade" then
        PrintMessage(HUD_PRINTTALK, "ALLAHU AKBAR")
    end

end
---------------------------------------------------------------------------------------------------------------------=#
    -- On NPC hurt --
function NPC:CustomTakeDamage( dmginfo, HitGroup )

    if HitGroup == HITGROUP_CHEST then
        if math.random(1, 4) == 1 then
            dmginfo:ScaleDamage(0.5)
        else
            local spark = ents.Create("env_spark")
            spark:SetKeyValue("spawnflags", 256)
            spark:SetKeyValue("TrailLength", 1)
            spark:SetKeyValue("Magnitude", 1)
            spark:SetPos(dmginfo:GetDamagePosition())
            spark:SetAngles(-dmginfo:GetDamageForce():Angle())
            spark:Spawn()
            spark:Activate()
            spark:Fire("SparkOnce")
            SafeRemoveEntityDelayed(spark, 0.1)
            self:EmitSound("ZBase.Ricochet")
            dmginfo:ScaleDamage(0)
        end
    end

end
---------------------------------------------------------------------------------------------------------------------=#