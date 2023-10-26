AddCSLuaFile()

---------------------------------------------------------------------------------------=#
local function do_method(ent, method_name, ... )
    if !ent[method_name] then return end
    return ent[method_name](ent, ...)
end
---------------------------------------------------------------------------------------=#
local function init( ent, name )
    table.insert(ZBaseNPCInstances, ent)

    local name = string.Right(name, #name-6)
    ent.ZBase_Class = name
    for k, v in pairs(ZBaseNPCs[ent.ZBase_Class]) do
        ent[k] = v
    end

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

                net.Start("ZBaseInitEnt")
                net.WriteEntity(ent)
                net.WriteString(parentname)
                net.Broadcast()
            end

        end)
    end)
    ---------------------------------------------------------------------------------------=#
end
---------------------------------------------------------------------------------------=#
hook.Add("Think", "ZBASE", function()
    for _, v in ipairs(ZBaseNPCInstances) do

        if !IsValid(v) then
            table.RemoveByValue(ZBaseNPCInstances, v)
            return
        end

        do_method(v, "CustomThink")

    end
end)
---------------------------------------------------------------------------------------=#
hook.Add("EntityTakeDamage", "ZBASE", function( ent, dmg )

    if IsZBaseNPC(ent) then
        local r = do_method(ent, "CustomTakeDamage", dmg)
        if r then
            return r
        end
    end

    local attacker = dmg:GetAttacker()
    if IsValid(attacker) && IsZBaseNPC(attacker) then
        local r = do_method(attacker, "DealDamage", ent, dmg)
        if r then
            return r
        end
    end

end)
---------------------------------------------------------------------------------------=#