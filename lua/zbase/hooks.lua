AddCSLuaFile()

---------------------------------------------------------------------------------------=#
local function do_method(ent, method_name)
    if ent[method_name] then
        ent[method_name](ent)
    end
end
---------------------------------------------------------------------------------------=#
local function init( ent, name )
    table.insert(ZBaseNPCInstances, ent)

    local name = string.Right(name, #name-6)
    for k, v in pairs(ZBaseNPCs[name]) do
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

            local parentname = ent:GetKeyValues().parentname
            if string.StartWith(parentname, "zbase_") then

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