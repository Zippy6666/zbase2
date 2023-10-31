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

        local own = ent:GetOwner()

        if IsValid(own) && own.IsZBaseNPC then
            own:OnOwnedEntCreated( ent )
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

        v:ZBaseThink()
        v:CustomThink()

    end

    ZBaseNextThink = CurTime()+0.2
end)
---------------------------------------------------------------------------------------=#
hook.Add("EntityTakeDamage", "ZBASE", function( ent, dmg )

    if ent.IsZBaseNPC then
        ent:OnHurt(dmg)
    end


    local attacker = dmg:GetAttacker()
    local infl = dmg:GetInflictor()


    -- if IsValid(attacker) then
    --     ent.ZBaseLastAttacker = attacker
    -- end

    if IsValid(attacker.ZBaseComballOwner) then

        dmg:SetAttacker(attacker.ZBaseComballOwner)

        if ent:GetClass() == "npc_hunter" or ent:GetClass() == "npc_strider" then

            attacker:Fire("Explode")

            if attacker.ZBaseComballOwner.ZBaseFaction != ent.ZBaseFaction
            or attacker.ZBaseComballOwner.ZBaseFaction == "none" then
                local dmg2 = DamageInfo()
                dmg2:SetDamage(ent:GetClass() == "npc_strider" && 100 or 1000)
                dmg2:SetDamageType(DMG_DISSOLVE)
                dmg2:SetAttacker(dmg:GetAttacker())
                ent:TakeDamageInfo(dmg2)
            end

        end

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
    
        local r = attacker:DealDamage(ent, dmg)
        if r then
            return r
        end

        -- Proper damage values for hl2 weapons
        if ZBaseCvar_HL2WepDMG:GetBool() then
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
        end

    end
end)
---------------------------------------------------------------------------------------=#
hook.Add("ScaleNPCDamage", "ZBASE", function( npc, hit_gr, dmg )
    if !npc.IsZBaseNPC then return end

    local r = npc:CustomTakeDamage(dmg, hit_gr)
    if r then
        return r
    end

    if npc.HasArmor[hit_gr] then
        local r = npc:HitArmor(dmg, hit_gr)
        if r then
            return r
        end
    end
end)
---------------------------------------------------------------------------------------=#
local SoundIndexes = {}
local ShuffledSoundTables = {}
---------------------------------------------------------------------------------------=#
local function RestartSoundCycle( sndTbl, data )
    SoundIndexes[data.OriginalSoundName] = 1

    local shuffle = table.Copy(sndTbl.sound)
    table.Shuffle(shuffle)
    ShuffledSoundTables[data.OriginalSoundName] = shuffle

    -- print("-----------------", data.OriginalSoundName, "-----------------")
    -- PrintTable(ShuffledSoundTables[data.OriginalSoundName])
    -- print("--------------------------------------------------")
end
---------------------------------------------------------------------------------------=#
hook.Add("EntityEmitSound", "ZBASE", function( data )

    if !IsValid(data.Entity) then return end

    
    if data.Entity.IsZBaseNPC then
        local altered = false


        -- Mute default "engine" voice
        if !ZBase_EmitSoundCall
        && SERVER
        && data.Entity.MuteDefaultVoice
        && (data.SoundName == "invalid.wav" or data.Channel == CHAN_VOICE) then
            return false
        end


            -- Avoid sound repitition --
        local sndTbl = sound.GetProperties(data.OriginalSoundName)

        if istable(sndTbl.sound) && table.Count(sndTbl.sound) > 1 then
            if !SoundIndexes[data.OriginalSoundName] then
                RestartSoundCycle(sndTbl, data)
            else
                if SoundIndexes[data.OriginalSoundName] == table.Count(sndTbl.sound) then
                    RestartSoundCycle(sndTbl, data)
                else
                    SoundIndexes[data.OriginalSoundName] = SoundIndexes[data.OriginalSoundName] + 1
                end
            end

            local snds = ShuffledSoundTables[data.OriginalSoundName]
            data.SoundName = snds[SoundIndexes[data.OriginalSoundName]]
            altered = true

            --print(SoundIndexes[data.OriginalSoundName], data.SoundName)
        end
        -----------------------------------------------=#


        -- "OnEmitSound"
        local r = data.Entity:OnEmitSound(data)
        if isstring(r) then
            data.Entity:EmitSound(r)
            return false
        elseif r == false then
            return false
        end


        if altered then
            return true
        end
    end

end)
---------------------------------------------------------------------------------------=#
hook.Add("AcceptInput", "ZBASE", function( ent, input, activator, caller, value )
    if ent.IsZBaseNPC then
        local r = ent:CustomAcceptInput(input, activator, caller, value)
        if r == true then return true end
    end
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerSpawn", "ZBASE", function( ply )
    ply.ZBaseFaction = "ally"
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerDeath", "ZBASE", function( ply, _, attacker )
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( ply )
    end
end)
---------------------------------------------------------------------------------------------------------------------=#