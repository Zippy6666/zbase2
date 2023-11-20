-------------------------------------------------------------------------------------------------------------------------=#
if !ZBaseInitialized then
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
if CLIENT then
    net.Receive("ZBaseReload", function()
        include("autorun/zbase2.lua")
    end)
else
    util.AddNetworkString("ZBaseReload")
end
-------------------------------------------------------------------------------------------------------------------------=#
concommand.Add("zbase_reload", function( ply )
    if ply:IsSuperAdmin() then
        include("autorun/zbase2.lua")
        net.Start("ZBaseReload")
        net.Broadcast()
    end
end)
-------------------------------------------------------------------------------------------------------------------------=#
local function IncludeFiles()
    AddCSLuaFile("zbase/client/spawnmenu.lua")
    AddCSLuaFile("zbase/client/toolmenu.lua")
    AddCSLuaFile("zbase/client/hooks.lua")

    include("zbase/shared/globals.lua")
    include("zbase/shared/hooks.lua")
    include("zbase/shared/sounds.lua")
    

    if SERVER then
        include("zbase/server/general/behaviour.lua")
        include("zbase/server/general/hooks.lua")
        include("zbase/server/general/spawn_npc.lua")
        include("zbase/server/general/scheds.lua")
        include("zbase/server/general/relationship.lua")
        include("zbase/server/decals.lua")

        local files = file.Find("zbase/server/npc_enhancements/*","LUA")
        local enhPath = "zbase/server/npc_enhancements/"

        for _, v in ipairs(files) do
            include(enhPath..v)
        end
    end

    if CLIENT then
        include("zbase/client/spawnmenu.lua")
        include("zbase/client/toolmenu.lua")
        include("zbase/client/hooks.lua")
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function NPCsInherit()
    for cls, t in pairs(ZBaseNPCs) do
        local ZBase_Inherit = t.Inherit

        if ZBase_Inherit
        && ZBaseNPCs[ZBase_Inherit] then
            for k, v in pairs(ZBaseNPCs[ZBase_Inherit]) do
                if t[k] == nil then 
                    -- print(cls, "ZBase_Inherit", k, v)
                    t[k] = v
                end
            end
        end
    
        for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
            if t[k] == nil then
                -- print(cls, "npc_zbase", k, v)
                t[k] = v
            end
        end

        if SERVER then
            local path = "zbase_npcs/"..cls
            local bh = path.."/behaviour.lua"
            if file.Exists(bh, "LUA") then
                include(bh)
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function RegBase()
    ZBaseNPCs["npc_zbase"] = {}

    local npcpath = "zbase/npcs/npc_zbase/"

    AddCSLuaFile(npcpath.."shared.lua")
    AddCSLuaFile(npcpath.."cl_init.lua")

    if SERVER then
        include("zbase/server/npc_base/core.lua")
        include("zbase/server/npc_base/util.lua")
        include(npcpath.."init.lua")


        ZBaseNPCs["npc_zbase"].Behaviours = {}


        local files = file.Find("zbase/server/npc_base/behaviours/*","LUA")
        local behaviourPath = "zbase/server/npc_base/behaviours/"

        for _, v in ipairs(files) do
            include(behaviourPath..v)
        end


        -- Get names of sound variables
        ZBaseNPCs["npc_zbase"].SoundVarNames = {}
        for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
            if string.EndsWith(k, "Sounds") then
                table.insert(ZBaseNPCs["npc_zbase"].SoundVarNames, k)
            end
        end
    end

    include(npcpath.."shared.lua")

    if CLIENT then
        include(npcpath.."cl_init.lua")
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function NPCReg( name )
    if string.StartsWith(name, "npc_") && name != "npc_zbase" then
        local path = "zbase/npcs/"..name.."/"
        local sh = path.."shared.lua"
        local cl = path.."cl_init.lua"
        local sv = path.."init.lua"

        if file.Exists(sh, "LUA")
        && file.Exists(sv, "LUA") then
            ZBaseNPCs[name] = {}

            include(sh)
            AddCSLuaFile(sh)

            if file.Exists(cl, "LUA") then
                AddCSLuaFile(cl)
            end

            if SERVER then
                include(sv)
            end

            if file.Exists(cl, "LUA") && CLIENT then
                include(cl)
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function registerNPCs()
    local _, dirs = file.Find("zbase/npcs/*","LUA")

    RegBase() -- Register base

    -- Register all ZBase NPCs
    for _, v in ipairs(dirs) do
        NPCReg(v)
    end

    -- PrintTable(ZBaseNPCs)
end
-------------------------------------------------------------------------------------------------------------------------=#
local function AddNPCsToSpawnMenu()
    for cls, t in pairs( ZBaseNPCs ) do
        local ZBaseSpawnMenuTbl = {
            Name=t.Name,
            Category=t.Category,
            Class = t.Class,
            Weapons = t.Weapons,
            Models = t.Models,
            KeyValues = table.Copy(t.KeyValues),
            OnFloor = t.OnFloor,
            OnCeiling = t.OnCeiling,
            NoDrop = t.NoDrop,
            Offset = t.Offset or (t.SNPCType == ZBASE_SNPCTYPE_FLY && t.Fly_DistanceFromGround),
            Rotate = t.Rotate,
            Skins = t.Skins,
            AdminOnly = t.AdminOnly,
            SpawnFlagTbl = t.SpawnFlagTbl,
            TotalSpawnFlags = t.TotalSpawnFlags,
            OnDuplicated = t.OnDuplicated,
            BodyGroups = BodyGroups,
            StartHealth = t.StartHealth,
        }


        ZBaseSpawnMenuNPCList[cls] = ZBaseSpawnMenuTbl -- Add to zbase menu
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
hook.Add("Initialize", "ZBASE", function()
    NPCsInherit()
    AddNPCsToSpawnMenu()
    ZBaseInitialized = true
end)
-------------------------------------------------------------------------------------------------------------------------=#


if ZBaseInitialized then
    table.Empty( ZBaseNPCs )
    table.Empty( ZBaseSpawnMenuNPCList )
    
    IncludeFiles()
    registerNPCs()

    NPCsInherit()
    AddNPCsToSpawnMenu()

    MsgN("ZBase Reloaded!")
else

    IncludeFiles()
    registerNPCs()

end