AddCSLuaFile()

---------------------------------------------------------------------------------------=#
local function do_method(ent, method_name, ... )
    if !ent[method_name] then return end
    return ent[method_name](ent, ...)
end
---------------------------------------------------------------------------------------=#
local function init( ent, name )

    -- Register
    table.insert(ZBaseNPCInstances, ent)


    -- Table "transfer" --
    ent.ZBase_Class = string.Right(name, #name-6)
    ent.ZBase_Inherit = ZBaseNPCs[ent.ZBase_Class].Inherit

        -- Inherit from base
    if ent.ZBase_Class!="npc_zbase" then
        -- for k, v in pairs(ZBaseNPCs[ent.ZBase_Inherit]) do
        --     ent[k] = v
        -- end
        for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
            ent[k] = v
        end
    end

        -- This npc's table
    for k, v in pairs(ZBaseNPCs[ent.ZBase_Class]) do
        ent[k] = v
    end
    ------------------------------------------------------=#


    -- Init stuff --

    ------------------------------------------------------=#

    -- Custom init
    ent:ZBaseInit()
    do_method(ent, "CustomInitialize")

end
---------------------------------------------------------------------------------------=#
if CLIENT then
    net.Receive("ZBaseInitEnt", function()
        init(net.ReadEntity(), net.ReadString())
    end)
end
---------------------------------------------------------------------------------------=#
if SERVER then
    util.AddNetworkString("ZBaseInitEnt")

    ---------------------------------------------------------------------------------------=#
    hook.Add("OnEntityCreated", "ZBASE", function( ent )
        timer.Simple(0, function()

            if !IsValid(ent) then return end

            if IsZBaseNPC(ent) then
                local parentname = ent:GetKeyValues().parentname

                init( ent, parentname )

                -- net.Start("ZBaseInitEnt")
                -- net.WriteEntity(ent)
                -- net.WriteString(parentname)
                -- net.Broadcast()
            end

        end)
    end)
    ---------------------------------------------------------------------------------------=#
end
---------------------------------------------------------------------------------------=#
local ZBaseNextThink = CurTime()
hook.Add("Think", "ZBASE", function()
    if ZBaseNextThink > CurTime() then return end
    for _, v in ipairs(ZBaseNPCInstances) do

        if !IsValid(v) then
            table.RemoveByValue(ZBaseNPCInstances, v)
            return
        end

        do_method(v, "ZBaseThink")
        do_method(v, "CustomThink")

    end

    ZBaseNextThink = CurTime()+0.2
end)
---------------------------------------------------------------------------------------=#
hook.Add("EntityTakeDamage", "ZBASE", function( ent, dmg )

    local attacker = dmg:GetAttacker()
    if IsValid(attacker) && IsZBaseNPC(attacker) then
        local r = do_method(attacker, "DealDamage", ent, dmg)
        if r then
            return r
        end
    end

end)
---------------------------------------------------------------------------------------=#
hook.Add("ScaleNPCDamage", "ZBASE", function( npc, hit_gr, dmg )

    if IsZBaseNPC(npc) then
        local r = do_method(npc, "CustomTakeDamage", dmg, hit_gr)
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
        local r = do_method(ent, "CustomAcceptInput", input, activator, caller, value)
        if r == true then return true end
    end
end)
---------------------------------------------------------------------------------------=#