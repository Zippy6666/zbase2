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


        -- Ideas --
    -- Fix dumbass seach bar

    -- More sounds
        -- LostEnemySounds
        -- ReloadSounds
        -- SeeDangerSounds
        -- HearDangerSounds
        -- AllyDeathSounds

    -- Ministrider
        -- Based on hunter
        -- Armor that deflects bullets

    -- Mortar synth
        -- Based on scanner

    -- Crab synth
        -- Based on antlion guard

    -- Some kind of SNPC
        -- Uses custom schedule system

    -- Crabless zombies (just called zombies, normal zombies will be called headcrab zombies)

    -- Custom blood system
        --White blood decals for hunters

    -- Any kind of general npc improvement
        -- Extended jumping?
        -- Hearing system

    -- Aerial base (maybe)


        -- Finally --
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
    include("zbase/sh_hooks.lua")

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

        local ZBaseSpawnMenuTbl = {
            Name=t.Name,
            Category=t.Category,
            Class = t.Class,
            Weapons = t.Weapons,
            KeyValues = table.Copy(t.KeyValues),
        }
        if SERVER then
            if !ZBaseSpawnMenuTbl.KeyValues then ZBaseSpawnMenuTbl.KeyValues = {} end
            ZBaseSpawnMenuTbl.KeyValues.parentname = "zbase_"..cls
            ZBaseSpawnMenuTbl.KeyValues.spawnflags = bit.bor(ZBaseSpawnMenuTbl.KeyValues.spawnflags or 0, 256) -- Long Visibility/Shoot
        end

        ZBaseSpawnMenuNPCList[cls] = ZBaseSpawnMenuTbl -- Add to zbase menu

         -- Add to regular spawn menu
        local SpawnMenuTable = table.Copy(ZBaseSpawnMenuTbl)
        SpawnMenuTable.Category = "ZBase - "..ZBaseSpawnMenuTbl.Category

        if !file.Exists( "materials/entities/" .. cls .. ".png", "GAME" ) then
            SpawnMenuTable.IconOverride = "entities/zbase.png"
        end

        list.Set("NPC", cls, SpawnMenuTable)
        ----------------------------------------------------------=#

        local replaceTargetTbl = list.Get("NPC")[t.Replace]
        if ZBaseCvar_Replace:GetBool() && t.Replace && replaceTargetTbl then
            -- Replace default spawn menu npcs

            local replaceTable = table.Copy(SpawnMenuTable)
            replaceTable.Category = replaceTargetTbl.Category

            -- Replace image if available (otherwise it will just use monke)
            if file.Exists( "materials/entities/" .. cls .. ".png", "GAME" ) then
                replaceTable.IconOverride = "materials/entities/" .. cls .. ".png"
            end
    
            list.Set( "NPC", t.Replace, replaceTable )
        end

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