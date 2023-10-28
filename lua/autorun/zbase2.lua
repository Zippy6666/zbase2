-------------------------------------------------------------------------------------------------------------------------=#
if BRANCH == "x86-64" && SERVER then
    print("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
    print("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
    print("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
    print("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
    print("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
    print("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --")
        
    print("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
    print("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
    print("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")
end   
-------------------------------------------------------------------------------------------------------------------------=#


        -- TODO --
    -- SNPCs (flying snpcs with custom movement system)
    -- More sounds (hear enemy, lost enemy, hear danger, grenade, etc)
    -- More variables and function, and npcs that use said variables and functions
    -- Internal variable system

        -- Future ideas --
    -- Custom NPCs, for example, Ministrider, crabless zombies (just called zombies, normal zombies will be called headcrab zombies)
    -- Very basic weapon base
    -- Recreate more hl2 npcs
    -- Custom blood system, white blood decals for hunters
    -- Player factions


-------------------------------------------------------------------------------------------------------------------------=#

if BRANCH != "x86-64" then
    -------------------------------------------------------------------------------------------------------------------------=#
    if SERVER then
        util.AddNetworkString("ZBaseError")

        hook.Add("PlayerInitialSpawn", "ZBase", function( ply )
            timer.Simple(3, function()
                net.Start("ZBaseError")
                net.Send(ply)
            end)
        end)
    end
    -------------------------------------------------------------------------------------------------------------------------=#
    if CLIENT then
        net.Receive("ZBaseError", function()
            chat.AddText(Color(255, 0, 0), "[ZBase] Fatal ZBase error!")
            chat.AddText(Color(255, 0, 0), "[ZBase] ZBase only works for the 'x86-64' branch of gmod! Current branch: '", BRANCH, "'.")
        end)
    end
    -------------------------------------------------------------------------------------------------------------------------=#
    return
end

-------------------------------------------------------------------------------------------------------------------------=#


AddCSLuaFile("zbase/cl_hooks.lua")

include("zbase/sh_globals.lua")
include("zbase/sh_replace_funcs.lua")

if SERVER then
    include("zbase/sv_behaviour.lua")
    include("zbase/sv_hooks.lua")
end

if CLIENT then
    include("zbase/cl_hooks.lua")
end



-------------------------------------------------------------------------------------------------------------------------=#
local function NPCsInherit()
    for cls, t in pairs(ZBaseNPCs) do
        local ZBase_Inherit = t.Inherit

        for k, v in pairs(ZBaseNPCs[ZBase_Inherit]) do
            if !t[k] then
                t[k] = v
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function NPCReg( name, path )
    if string.StartsWith(name, "npc_") then

        local path = path or ("zbase_npcs/"..name)
        local sh = path.."/shared.lua"
        local cl = path.."/cl_init.lua"
        local sv = path.."/init.lua"


        if file.Exists(sh, "LUA")
        && file.Exists(sv, "LUA")
        && file.Exists(cl, "LUA") then

            -- New NPC
            ZBaseNPCs[name] = {}
            if name == "npc_zbase" then
                ZBaseNPCs[name].Behaviours={}
            end

            -- Files --
            include(sh)
            AddCSLuaFile(sh)
            AddCSLuaFile(cl)

            if SERVER then
                include(sv)

                local bh = path.."/behaviour.lua"
                if file.Exists(bh, "LUA") then
                    include(bh)
                end
            end

            if CLIENT then
                include(cl)
            end
            --------------------------------=#
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function registerNPCs()
    local _, dirs = file.Find("zbase_npcs/*","LUA")

    NPCReg("npc_zbase", "npc_zbase") -- Register base

    -- Register all ZBase NPCs
    for _, v in ipairs(dirs) do
        NPCReg(v)
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function AddNPCsToSpawnMenu()
    -- Add all NPCs to spawnmenu
    for cls, t in pairs( ZBaseNPCs ) do

        local spawnmenuTbl = table.Copy(t)
        if SERVER then
            spawnmenuTbl.KeyValues.parentname = "zbase_"..cls
        end
        spawnmenuTbl.Category = "ZBase - "..t.Category

        list.Set( "NPC", cls, spawnmenuTbl )

    end
end
-------------------------------------------------------------------------------------------------------------------------=#
hook.Add("Initialize", "ZBASE", function()
    NPCsInherit()
    AddNPCsToSpawnMenu()
end)
-------------------------------------------------------------------------------------------------------------------------=#

registerNPCs()
