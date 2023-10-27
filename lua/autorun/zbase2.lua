-------------------------------------------------------------------------------------------------------------------------=#

    -- ███████╗██████╗░░█████╗░░██████╗███████╗ --
    -- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --
    -- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --
    -- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --
    -- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --
    -- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --


                                                    -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --
                                                    -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --
                                                    -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --

-------------------------------------------------------------------------------------------------------------------------=#

    -- TODO --
    -- Comments
    -- Figure out what to do next

-------------------------------------------------------------------------------------------------------------------------=#

if !ZBaseNPCs then
    ZBaseNPCs = {}
    ZBaseNPCInstances = {}
end

include("zbase/globals.lua")
include("zbase/hooks.lua")


-------------------------------------------------------------------------------------------------------------------------=#
local function include_npc_files()
    -- Include all npc files
    
    local _, dirs = file.Find("zbase_npcs/*","LUA")

    for k, v in ipairs(dirs) do
        if string.StartsWith(v, "npc_") then
            local sh = "zbase_npcs/"..v.."/shared.lua"
            local cl = "zbase_npcs/"..v.."/cl_init.lua"
            local sv = "zbase_npcs/"..v.."/init.lua"
            
            if file.Exists(sh, "LUA") && file.Exists(sv, "LUA") && file.Exists(cl, "LUA") then

                -- Register
                ZBaseNPCs[v] = {}
                include(sh)
                AddCSLuaFile(sh)
                AddCSLuaFile(cl)
                if SERVER then include(sv) end
                if CLIENT then include(cl) end

            end
        end
    end

end
-------------------------------------------------------------------------------------------------------------------------=#
local function addNPCs()
    -- Add all NPCs to spawnmenu
    for cls, t in pairs(ZBaseNPCs) do

        if t.KeyValues then
            t.KeyValues.parentname = "zbase_"..cls
        else
            t.KeyValues = {parentname = "zbase_"..cls}
        end

        list.Set( "NPC", cls, t )

    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function updateActiveNPCs()
    for _, ent in ipairs(ZBaseNPCInstances) do
        for k, v in pairs(ZBaseNPCs[ent.ZBase_Class]) do
            ent[k] = v
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#


include_npc_files()
addNPCs()
updateActiveNPCs()


