-------------------------------------------------------------------------------------------------------------------------=#
if BRANCH == "x86-64" then
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
    -- A few NPCs that need special functions and shit (custom schedule system for snpcs)

        -- Future ideas --
    -- Ministrider (with armor that reflects bullets)
    -- Crab synth snpc?
    -- Crabless zombies (just called zombies, normal zombies will be called headcrab zombies)
    -- Custom blood system, white blood decals for hunters
    -- Player factions + faction tool
    -- Any kind of general npc improvement
    -- Very basic weapon base?
    -- Hearing system?
    -- Aerial base

    -- Finally
    -- Make more user friendly with comments and shit, dummy git
    -- Make sure everything works

-------------------------------------------------------------------------------------------------------------------------=#

if BRANCH != "x86-64" && BRANCH != "dev" then
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
            chat.AddText(Color(255, 0, 0), "[ZBase] Fatal error!")
            chat.AddText(Color(255, 0, 0), "[ZBase] ZBase only works for the 'x86-64' and 'dev' branch of gmod! Current branch: '", BRANCH, "'.")
        end)
    end
    -------------------------------------------------------------------------------------------------------------------------=#
    return
end

-------------------------------------------------------------------------------------------------------------------------=#
local function IncludeFiles()
    AddCSLuaFile("zbase/cl_hooks.lua")
    AddCSLuaFile("zbase/cl_spawnmenu.lua")
    AddCSLuaFile("zbase/cl_toolmenu.lua")

    include("zbase/sh_globals.lua")
    include("zbase/sh_replace_funcs.lua")

    if SERVER then
        include("zbase/sv_behaviour.lua")
        include("zbase/sv_hooks.lua")
    end

    if CLIENT then
        include("zbase/cl_hooks.lua")
        include("zbase/cl_spawnmenu.lua")
        include("zbase/cl_toolmenu.lua")
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function NPCsInherit()
    for cls, t in pairs(ZBaseNPCs) do
        local ZBase_Inherit = t.Inherit

        if ZBase_Inherit
        && ZBaseNPCs[ZBase_Inherit] then
            for k, v in pairs(ZBaseNPCs[ZBase_Inherit]) do
                if !t[k] then 
                    t[k] = v
                end
            end
        end
    
        for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
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
        && file.Exists(sv, "LUA") then

            -- New NPC
            ZBaseNPCs[name] = {}
            if name == "npc_zbase" then
                ZBaseNPCs[name].Behaviours={}
            end

            -- Files --
            include(sh)
            AddCSLuaFile(sh)

            if file.Exists(cl, "LUA") then
                AddCSLuaFile(cl)
            end

            if SERVER then
                include(sv)

                if name == "npc_zbase" then
                    local base = path.."/base.lua"
                    local util = path.."/util.lua"
                    include(base)
                    include(util)
                end

                local bh = path.."/behaviour.lua"
                if file.Exists(bh, "LUA") then
                    include(bh)
                end
            end

            if file.Exists(cl, "LUA") && CLIENT then
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
    for cls, t in pairs( ZBaseNPCs ) do

        local spawnmenuTbl = {
            Name=t.Name,
            Category=t.Category,
            Class = t.Class,
            Weapons = t.Weapons,
            KeyValues = table.Copy(t.KeyValues),
        }
        if SERVER then
            if !spawnmenuTbl.KeyValues then spawnmenuTbl.KeyValues = {} end
            spawnmenuTbl.KeyValues.parentname = "zbase_"..cls
        end


        -- Add to regular spawn menu
        local npcTable = table.Copy(spawnmenuTbl)
        npcTable.Category = "ZBase"
        list.Set( "NPC", cls, npcTable )
        if !file.Exists( "materials/entities/" .. cls .. ".png", "GAME" ) then
            npcTable.IconOverride = "entities/zbase.png"
        end


        -- Replace default spawn menu npcs
        local replaceTargetTbl = list.Get("NPC")[t.Replace]
        if ZBaseCvar_Replace:GetBool() && t.Replace && replaceTargetTbl then

            local replaceTable = table.Copy(npcTable)
            replaceTable.Category = replaceTargetTbl.Category

            if file.Exists( "materials/entities/" .. cls .. ".png", "GAME" ) then
                replaceTable.IconOverride = "materials/entities/" .. cls .. ".png"
            end
    
            list.Set( "NPC", t.Replace, replaceTable )
        end

        -- Add to zbase menu
        ZBaseSpawnMenuNPCList[cls] = spawnmenuTbl

    end
end
-------------------------------------------------------------------------------------------------------------------------=#
hook.Add("Initialize", "ZBASE", function()
    NPCsInherit()
    AddNPCsToSpawnMenu()
    ZBaseInitialized = true
end)
-------------------------------------------------------------------------------------------------------------------------=#

IncludeFiles()
registerNPCs()

if ZBaseInitialized then
    NPCsInherit()
    AddNPCsToSpawnMenu()
end