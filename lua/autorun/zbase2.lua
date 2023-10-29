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
    -- Separate spawnmenu tab + options tab + logo
    -- More variables, sounds (hear enemy, lost enemy, hear danger, grenade, etc), internal variables, and functions, and npcs and snpcs that use said variables and functions + Make more user friendly, dummy git

        -- Future ideas --
    -- Custom schedule system for snpcs
    -- Ministrider
    -- Crabless zombies (just called zombies, normal zombies will be called headcrab zombies)
    -- Elite metro police with head armor and custom sounds and custom gun
    -- Recreate more hl2 npcs + replace feature
    -- Custom blood system, white blood decals for hunters
    -- Player factions + faction tool
    -- Any kind of general npc improvement
    -- Very basic weapon base?
    -- Hearing system?
    -- Aerial base

-------------------------------------------------------------------------------------------------------------------------=#

-- if BRANCH != "x86-64" then
--     -------------------------------------------------------------------------------------------------------------------------=#
--     if SERVER then
--         util.AddNetworkString("ZBaseError")

--         hook.Add("PlayerInitialSpawn", "ZBase", function( ply )
--             timer.Simple(3, function()
--                 net.Start("ZBaseError")
--                 net.Send(ply)
--             end)
--         end)
--     end
--     -------------------------------------------------------------------------------------------------------------------------=#
--     if CLIENT then
--         net.Receive("ZBaseError", function()
--             chat.AddText(Color(255, 0, 0), "[ZBase] Fatal ZBase error!")
--             chat.AddText(Color(255, 0, 0), "[ZBase] ZBase only works for the 'x86-64' branch of gmod! Current branch: '", BRANCH, "'.")
--         end)
--     end
--     -------------------------------------------------------------------------------------------------------------------------=#
--     return
-- end



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

        -- local spawnmenuTbl = table.Copy(t)
        -- if SERVER then
        --     spawnmenuTbl.KeyValues.parentname = "zbase_"..cls
        -- end
        -- spawnmenuTbl.Category = "ZBase - "..t.Category

        local spawnmenuTbl = {
            Name=t.Name,
            Category=t.Category,
            Class = t.Class,
            Weapons = t.Weapons,
            KeyValues = table.Copy(t.KeyValues),
        }
        if SERVER then
            spawnmenuTbl.KeyValues.parentname = "zbase_"..cls
        end

        -- list.Set( "NPC", cls, spawnmenuTbl )
        ZBaseSpawnMenuNPCList[cls] = spawnmenuTbl

    end
end
-------------------------------------------------------------------------------------------------------------------------=#
hook.Add("Initialize", "ZBASE", function()
    NPCsInherit()
    AddNPCsToSpawnMenu()
end)
-------------------------------------------------------------------------------------------------------------------------=#

IncludeFiles()
registerNPCs()