util.AddNetworkString("ZBaseInitEnt")


local ZBaseNextThink = CurTime()





local ZBaseWeaponDMGs = {
    ["weapon_pistol"] = {dmg=5, inflclass="bullet"},
    ["weapon_357"] = {dmg=40, inflclass="bullet"},
    ["weapon_ar2"] = {dmg=8, inflclass="bullet"},
    ["weapon_shotgun"] = {dmg=56, inflclass="bullet"},
    ["weapon_smg1"] = {dmg=4, inflclass="bullet"},
    ["weapon_rpg"] = {dmg=150, inflclass="rpg_missile"},
    ["weapon_crossbow"] = {dmg=100, inflclass="crossbow_bolt"},
}


---------------------------------------------------------------------------------------=#
hook.Add("OnEntityCreated", "ZBASE", function( ent )
    timer.Simple(0, function()
        if !IsValid(ent) then return end

        if IsZBaseNPC(ent) then

            local parentname = ent:GetKeyValues().parentname

            --print(ent, parentname)
            ZBaseInit(ent, parentname)

            -- net.Start("ZBaseInitEnt")
            -- net.WriteEntity(ent)
            -- net.WriteString(parentname)
            -- net.Broadcast()

            -- ZBasePrintInternalVars(ent)

        elseif ent:IsNPC() then

            ent.ZBaseFaction = ZBaseFactionTranslation[ent:Classify()]
            table.insert(ZBase_NonZBaseNPCs, ent)
            ent:CallOnRemove("ZBase_RemoveFromNPCTable", function() table.RemoveByValue(ZBase_NonZBaseNPCs, ent) end)

        end
    end) 
end)
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
    local infl = dmg:GetInflictor()

    if IsValid(attacker.ZBaseComballOwner) then
        dmg:SetAttacker(attacker.ZBaseComballOwner)
        attacker = attacker.ZBaseComballOwner
    end


    -- Don't hurt NPCs in same faction
    if attacker.IsZBaseNPC
    && ent.IsZBaseNPC
    && ent:HasCapability(CAP_FRIENDLY_DMG_IMMUNE)
    && attacker.ZBaseFaction == ent.ZBaseFaction
    && ent.ZBaseFaction != "none" then
        dmg:ScaleDamage(0)
        return true
    end


    if IsValid(attacker) && IsZBaseNPC(attacker) then
        local r = attacker:ZBaseMethod("DealDamage", ent, dmg)
        if r then
            return r
        end

        -- Proper damage values for hl2 weapons
        local wep = attacker:GetActiveWeapon()

        if IsValid(infl) && IsValid(wep) then
            local dmgTbl = ZBaseWeaponDMGs[wep:GetClass()]

            if dmgTbl
            && ( (dmgTbl.inflclass=="bullet"&&dmg:IsBulletDamage()) or (dmgTbl.inflclass == infl:GetClass()) ) then
                local dmgFinal = dmgTbl.dmg

                if dmg:IsDamageType(DMG_BUCKSHOT) then
                    if attacker:WithinDistance(ent, 200) then
                        dmgFinal = math.random(40, 56)
                    elseif attacker:WithinDistance(ent, 400) then
                        dmgFinal = math.random(16, 40)
                    else
                        dmgFinal = math.random(8, 16)
                    end
                end

                dmg:SetDamage(dmgFinal)
            end
        end
        ----------------------------------------------=#
    end
end)
---------------------------------------------------------------------------------------=#
hook.Add("ScaleNPCDamage", "ZBASE", function( npc, hit_gr, dmg )
    if !npc.IsZBaseNPC then return end

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