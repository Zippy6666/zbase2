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
    -- Inheritance
    -- Action system
    -- Next?

-------------------------------------------------------------------------------------------------------------------------=#

if !ZBaseNPCs then
    ZBaseNPCs = {}
    ZBaseNPCInstances = {}
end

include("zbase/sh_globals.lua")
include("zbase/sh_hooks.lua")

if SERVER then
    include("zbase/sv_action_system.lua")
end

-------------------------------------------------------------------------------------------------------------------------=#
local function NPCReg( name, path )
    if string.StartsWith(name, "npc_") then

        local path = path or ("zbase_npcs/"..name)
        local sh = path.."/shared.lua"
        local cl = path.."/cl_init.lua"
        local sv = path.."/init.lua"

        -- local function inherit( t )
        --     if name == "npc_zbase" then return true end

        --     local inh = path.."/inherit.lua"

        --     include(inh)
        --     AddCSLuaFile(inh)

        --     local ZBase_Inherit = t.Inherit

        --     if ZBaseNPCs[ZBase_Inherit] then
        --         for k, v in pairs(ZBaseNPCs[ZBase_Inherit]) do
        --             t[k] = v
        --         end
        --         return true
        --     end

        --     return false
        -- end

        if file.Exists(sh, "LUA")
        && file.Exists(sv, "LUA")
        && file.Exists(cl, "LUA") then

            ZBaseNPCs[name] = {}

            -- local inhSuccess = inherit(ZBaseNPCs[name])
            -- print(name, "inhSuccess", inhSuccess)

            if name != "npc_zbase" then
                for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
                    ZBaseNPCs[name][k] = v
                end
            end

            include(sh)
            AddCSLuaFile(sh)
            AddCSLuaFile(cl)
            if SERVER then include(sv) end
            if CLIENT then include(cl) end

        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function registerNPCs()
    local _, dirs = file.Find("zbase_npcs/*","LUA")

    NPCReg("npc_zbase", "zbase/npc_zbase") -- Register base

    -- Register all ZBase NPCs
    for _, v in ipairs(dirs) do
        NPCReg(v)
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

        if SERVER && GetConVar("developer"):GetBool() then
            print("---------------------", cls, "---------------------")
            PrintTable(t)
            print("------------------------------------------------------------")
        end

        list.Set( "NPC", cls, t )

    end
end
-------------------------------------------------------------------------------------------------------------------------=#


registerNPCs()
addNPCs()


