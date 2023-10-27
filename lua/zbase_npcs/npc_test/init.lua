local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/barney.mdl", "models/mossman.mdl", "models/alyx.mdl", "models/eli.mdl"}
NPC.StartHealth = 70
NPC.CanPatrol = true


---------------------------------------------------------------------------------------------------------------------=#
    -- Called every tick --
function NPC:CustomThink()

end
---------------------------------------------------------------------------------------------------------------------=#
    -- On NPC hurt --
function NPC:CustomTakeDamage( dmginfo, HitGroup )

    if self:GetModel() == "models/barney.mdl" && HitGroup == HITGROUP_CHEST then
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