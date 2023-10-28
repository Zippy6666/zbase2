util.AddNetworkString("ZBaseInitEnt")


local ZBaseNextThink = CurTime()


---------------------------------------------------------------------------------------=#
hook.Add("OnEntityCreated", "ZBASE", function( ent ) timer.Simple(0, function()
    if !IsValid(ent) then return end

    if IsZBaseNPC(ent) then

        local parentname = ent:GetKeyValues().parentname

        --print(ent, parentname)
        ZBaseInit(ent, parentname)

        -- net.Start("ZBaseInitEnt")
        -- net.WriteEntity(ent)
        -- net.WriteString(parentname)
        -- net.Broadcast()

    elseif ent:IsNPC() then

        ent.ZBaseFaction = ZBaseFactionTranslation[ent:Classify()]
        table.insert(ZBase_NonZBaseNPCs, ent)
        ent:CallOnRemove("ZBase_RemoveFromNPCTable", function() table.RemoveByValue(ZBase_NonZBaseNPCs, ent) end)

    end
end) end)
---------------------------------------------------------------------------------------=#
hook.Add("Think", "ZBASE", function()
    if ZBaseNextThink > CurTime() then return end

    for _, v in ipairs(ZBaseNPCInstances) do

        if !IsValid(v) then
            table.RemoveByValue(ZBaseNPCInstances, v)
            return
        end

        v:ZBaseMethod("ZBaseThink")
        v:ZBaseMethod("CustomThink")

    end

    ZBaseNextThink = CurTime()+0.2
end)
---------------------------------------------------------------------------------------=#
hook.Add("EntityTakeDamage", "ZBASE", function( ent, dmg )
    local attacker = dmg:GetAttacker()

    if IsValid(attacker) && IsZBaseNPC(attacker) then
        local r = attacker:ZBaseMethod("DealDamage", ent, dmg)
        if r then
            return r
        end
    end
end)
---------------------------------------------------------------------------------------=#
hook.Add("ScaleNPCDamage", "ZBASE", function( npc, hit_gr, dmg )
    if !npc.IsZBaseNPC then return end

    if npc:HasCapability(CAP_FRIENDLY_DMG_IMMUNE) then
        local attacker = dmg:GetAttacker()

        if IsValid(attacker)
        && attacker.ZBaseFaction == npc.ZBaseFaction
        && npc.ZBaseFaction != "none" then
            dmg:ScaleDamage(0)
            print("sus")
            return
        end
    end

    local r = npc:ZBaseMethod("CustomTakeDamage", dmg, hit_gr)
    if r then
        return r
    end

    if npc.HasArmor[hit_gr] then
        local r = npc:ZBaseMethod("HitArmor", dmg, hit_gr)
        if r then
            return r
        end
    end
end)
---------------------------------------------------------------------------------------=#
hook.Add("EntityEmitSound", "ZBASE", function( data )

    -- Mute voice
    if !ZBase_EmitSoundCall
    && SERVER
    && data.Entity.IsZBaseNPC
    && data.Entity.MuteDefaultVoice
    && (data.SoundName == "invalid.wav" or data.Channel == CHAN_VOICE) then
        return false
    end

end)
---------------------------------------------------------------------------------------=#
hook.Add("AcceptInput", "ZBASE", function( ent, input, activator, caller, value )
    if ent.IsZBaseNPC then
        local r = ent:ZBaseMethod("CustomAcceptInput", input, activator, caller, value)
        if r == true then return true end
    end
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerSpawn", "PlayerSpawn", function( ply )
    ply.ZBaseFaction = "ally"
end)
---------------------------------------------------------------------------------------------------------------------=#