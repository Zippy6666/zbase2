--[[
======================================================================================================================================================
                                           NETWORK
======================================================================================================================================================
--]]


if SERVER then

    util.AddNetworkString("ZBaseListFactions")
    util.AddNetworkString("ZBase_GetFactionsFromServer")
    util.AddNetworkString("ZBaseError")
    util.AddNetworkString("ZBaseReloadServer")
    util.AddNetworkString("ZBaseReloadClient")


    net.Receive("ZBase_GetFactionsFromServer", function(_, ply)
        ZBaseListFactions(_, ply)
    end)

end


if CLIENT then

    net.Receive("ZBaseError", function()
        chat.AddText(Color(255, 0, 0), "[ZBase] Fatal error!")
        chat.AddText(Color(255, 0, 0), "[ZBase] ZBase only works for the 'x86-64' and 'dev' branch of gmod! Current branch: '", BRANCH, "'.")
    end)

end


--[[
======================================================================================================================================================
                                           WELCOME MESSAGE OR SOMETHING IDK
======================================================================================================================================================
--]]


if !ZBaseInitialized then
    MsgN("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
    MsgN("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
    MsgN("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
    MsgN("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
    MsgN("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
    MsgN("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --") 
    MsgN("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
    MsgN("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
    MsgN("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")
end   


--[[
======================================================================================================================================================
                                           BRANCH
======================================================================================================================================================
--]]


if SERVER && !string.StartsWith(BRANCH, "x86") && BRANCH != "dev" then

    hook.Add("PlayerInitialSpawn", "ZBase", function( ply )

        timer.Simple(3, function()
            net.Start("ZBaseError")
            net.Send(ply)
        end)
        
    end)

    return

end


--[[
======================================================================================================================================================
                                           ZBASE_RELOAD
======================================================================================================================================================
--]]


if CLIENT then
    net.Receive("ZBaseReloadClient", function()
        include("autorun/zbase.lua")
    end)
end


if SERVER then
    net.Receive("ZBaseReloadServer", function( _, ply)
        if !ply:IsSuperAdmin() then return end
        concommand.Run(ply, "zbase_reload")
    end)
end


concommand.Add("zbase_reload", function( ply )
    if ply:IsSuperAdmin() then
        include("autorun/zbase.lua")
        net.Start("ZBaseReloadClient")
        net.Broadcast()
    end
end)


--[[
======================================================================================================================================================
                                           PARTICLES
======================================================================================================================================================
--]]


game.AddParticles("particles/zbase_blood_impact.pcf")

game.AddParticles("particles/striderbuster.pcf")
game.AddParticles("particles/mortarsynth_fx.pcf")

PrecacheParticleSystem("blood_impact_zbase_green")
PrecacheParticleSystem("blood_impact_zbase_black")
PrecacheParticleSystem("blood_impact_zbase_blue")
PrecacheParticleSystem("striderbuster_break")
PrecacheParticleSystem("striderbuster_break_shell")


--[[
======================================================================================================================================================
                                           DECALS
======================================================================================================================================================
--]]


game.AddDecal("ZBaseBloodBlack", {
    "decals/zbase_blood_black/blood1",
    "decals/zbase_blood_black/blood2",
    "decals/zbase_blood_black/blood3",
    "decals/zbase_blood_black/blood4",
    "decals/zbase_blood_black/blood5",
    "decals/zbase_blood_black/blood6",
})

game.AddDecal("ZBaseBloodSynth", {
    "decals/zbase_blood_synth/blood1",
    "decals/zbase_blood_synth/blood2",
    "decals/zbase_blood_synth/blood3",
    "decals/zbase_blood_synth/blood4",
    "decals/zbase_blood_synth/blood5",
    "decals/zbase_blood_synth/blood6",
})

game.AddDecal("ZBaseBloodRed", {
    "decals/zbase_blood_red/blood1",
    "decals/zbase_blood_red/blood2",
    "decals/zbase_blood_red/blood3",
    "decals/zbase_blood_red/blood4",
    "decals/zbase_blood_red/blood5",
    "decals/zbase_blood_red/blood6",
})

game.AddDecal("ZBaseBloodGreen", {
    "decals/zbase_blood_green/blood1",
    "decals/zbase_blood_green/blood2",
    "decals/zbase_blood_green/blood3",
    "decals/zbase_blood_green/blood4",
    "decals/zbase_blood_green/blood5",
    "decals/zbase_blood_green/blood6",
})

game.AddDecal("ZBaseBloodBlue", {
    "decals/zbase_blood_blue/blood1",
    "decals/zbase_blood_blue/blood2",
    "decals/zbase_blood_blue/blood3",
    "decals/zbase_blood_blue/blood4",
    "decals/zbase_blood_blue/blood5",
    "decals/zbase_blood_blue/blood6",
})



--[[
======================================================================================================================================================
                                           SOUNDS
======================================================================================================================================================
--]]


sound.Add( {
	name = "ZBase.Melee1",
	channel = CHAN_AUTO,
	volume = 0.6,
	level = 75,
	pitch = {95, 105},
	sound = {
        "npc/fast_zombie/claw_strike1.wav",
		"npc/fast_zombie/claw_strike2.wav",
		"npc/fast_zombie/claw_strike3.wav",
    }
} )

sound.Add( {
	name = "ZBase.Melee2",
	channel = CHAN_AUTO,
	volume = 0.6,
	level = 75,
	pitch = {95, 105},
	sound = {
        "physics/body/body_medium_impact_hard1.wav",
		"physics/body/body_medium_impact_hard2.wav",
		"physics/body/body_medium_impact_hard3.wav",
        "physics/body/body_medium_impact_hard4.wav",
		"physics/body/body_medium_impact_hard5.wav",
		"physics/body/body_medium_impact_hard6.wav",
    }
} )

sound.Add( {
	name = "ZBase.Ricochet",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 75,
	pitch = {90, 110},
	sound = {
        "weapons/fx/rics/ric1.wav",
        "weapons/fx/rics/ric2.wav",
        "weapons/fx/rics/ric3.wav",
        "weapons/fx/rics/ric4.wav",
        "weapons/fx/rics/ric5.wav"
    }
} )


sound.Add({
    name = "ZBase.Step",
	channel = CHAN_AUTO,
	volume = 0.7,
	level = 80,
	pitch = {90, 110},
	sound = {
        "npc/footsteps/hardboot_generic1.wav",
        "npc/footsteps/hardboot_generic2.wav",
        "npc/footsteps/hardboot_generic3.wav",
        "npc/footsteps/hardboot_generic4.wav",
        "npc/footsteps/hardboot_generic5.wav",
        "npc/footsteps/hardboot_generic6.wav",
        "npc/footsteps/hardboot_generic8.wav",
    },
})


--[[
======================================================================================================================================================
                                           ESSENTIAL GLOBALS
======================================================================================================================================================
--]]



ZBaseNPCs = {}
ZBaseSpawnMenuNPCList = {}
ZBaseEnhancementTable = {}
ZBaseDynSplatterInstalled = file.Exists("dynsplatter", "LUA")



ZBaseNPCInstances = ZBaseNPCInstances or {}
ZBaseNPCInstances_NonScripted = ZBaseNPCInstances_NonScripted or {}
ZBaseBehaviourTimerFuncs = ZBaseBehaviourTimerFuncs or {}



function ZBaseEnhancementNPCClass(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split]
    local split2 = string.Split(name, ".")
    return split2[1]
end


function ZBaseListFactions( _, ply )

    if SERVER then
        local factions = {none=true, neutral=true, ally=true}

        for k, v in pairs(ZBaseNPCs) do
            if v.ZBaseStartFaction then
                factions[v.ZBaseStartFaction] = true
            end
        end

        net.Start("ZBaseListFactions")
        net.WriteTable(factions)
        net.Send(ply)
    end

    if CLIENT then
        net.Start("ZBase_GetFactionsFromServer")
        net.SendToServer()
    end

end


--[[
======================================================================================================================================================
                                           INCLUDES
======================================================================================================================================================
--]]


local function IncludeFiles()

    include("zbase/sh_globals_pri.lua")
    include("zbase/sh_globals_pub.lua")
    include("zbase/sh_hooks.lua")
    include("zbase/sh_cvars.lua")


    if SERVER then

        include("zbase/sv_schedules.lua")
        include("zbase/sv_meta_npc_extended.lua")
        include("zbase/sv_behaviour_system.lua")
        include("zbase/sv_spawnnpc.lua")
        include("zbase/sv_enginewep_translation.lua")

        
        -- Include NPC enhancement files
        local files = file.Find("zbase/npc_enhancements/*","LUA")
        local enhPath = "zbase/npc_enhancements/"
        for _, v in ipairs(files) do
            include(enhPath..v)
        end

    end


    if CLIENT then
        include("zbase/cl_spawnmenu.lua")
        include("zbase/cl_toolmenu.lua")
    end

end


local function AddCSLuaFiles()
    AddCSLuaFile("zbase/sh_cvars.lua")
    AddCSLuaFile("zbase/sh_globals_pri.lua")
    AddCSLuaFile("zbase/sh_globals_pub.lua")
    AddCSLuaFile("zbase/sh_override_functions.lua")
    AddCSLuaFile("zbase/sh_hooks.lua")

    AddCSLuaFile("zbase/cl_spawnmenu.lua")
    AddCSLuaFile("zbase/cl_toolmenu.lua")

    AddCSLuaFile("zbase/npc_base_shared.lua")


    -- Add zbase entity files
    local _, dirs = file.Find("zbase/entities/*","LUA")
    for _, v in ipairs(dirs) do
        AddCSLuaFile("zbase/entities/"..v.."/shared.lua")
    end
end


--[[
======================================================================================================================================================
                                           REGISTER THE BLOODY NPC BASE
                                           ADD NPCS TO SPAWNMENU
======================================================================================================================================================
--]]


local function UpdateLiveNPCs()
    for _, npc in ipairs(ZBaseNPCInstances) do
        local MyUpdatedTable = ZBaseNPCs[npc.NPCName]
        local MyOldTable = npc:GetTable()

        for attr, val in pairs(MyUpdatedTable) do
            MyOldTable[attr] = val
        end
    end
end


-- Idk bout this tbh
-- help
local function NPCsInherit()
    for cls, t in pairs(ZBaseNPCs) do


        if SERVER then
            if !t.Behaviours then t.Behaviours = {} end

            local path = "zbase/entities/"..cls
            local bh = path.."/behaviour.lua"
            if file.Exists(bh, "LUA") then
                include(bh)
            end
        end


        local function RecursiveInherit( inherit_class )

            if !ZBaseNPCs[inherit_class] then return end -- Tried inheriting from nonexistant npc


            for k, v in pairs(ZBaseNPCs[inherit_class]) do
                if t[k] == nil then
                    t[k] = istable(v) && table.Copy(v) or v
                elseif istable(v) && istable(t[k]) then
                    table.Inherit(t[k], v)
                    t[k].BaseClass = nil -- lol fuk u
                    PrintTable(t[k])
                end
            end


            local new_inherit_class = ZBaseNPCs[inherit_class].Inherit
            if !(new_inherit_class == "npc_zbase" && inherit_class == "npc_zbase") then
                RecursiveInherit( new_inherit_class )
            end

        end


        RecursiveInherit( t.Inherit )





    end
end


local function RegBase()
    ZBaseNPCs["npc_zbase"] = {}
    ZBaseNPCs["npc_zbase"].Behaviours = {}
    ZBaseNPCs["npc_zbase"].IsZBaseNPC = true


    local NPCBasePrefix = "zbase/npc_base_"


    include(NPCBasePrefix.."shared.lua")


    if SERVER then
        include(NPCBasePrefix.."internal.lua")
        include(NPCBasePrefix.."util.lua")
        include(NPCBasePrefix.."init.lua")


        -- Get names of sound variables
        ZBaseNPCs["npc_zbase"].SoundVarNames = {}
        for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
            if string.EndsWith(k, "Sounds") then
                table.insert(ZBaseNPCs["npc_zbase"].SoundVarNames, k)
            end
        end
    end
end


local function NPCReg( name )
    if name != "npc_zbase" then
        local path = "zbase/entities/"..name.."/"
        local sh = path.."shared.lua"
        local cl = path.."cl_init.lua"
        local sv = path.."init.lua"
        

        if file.Exists(sh, "LUA")
        && (CLIENT or file.Exists(sv, "LUA")) then
            ZBaseNPCs[name] = {}

            include(sh)

            if SERVER then
                include(sv)
            end

            if file.Exists(cl, "LUA") && CLIENT then
                include(cl)
            end
        end
    end
end


local function registerNPCs()
    local _, dirs = file.Find("zbase/entities/*","LUA")

    RegBase() -- Register base

    -- Register all ZBase NPCs
    for _, v in ipairs(dirs) do
        NPCReg(v)
    end
end


local function AddNPCsToSpawnMenu()
    for cls, t in pairs( ZBaseNPCs ) do
        if t.Category == false then continue end -- Don't add to menu


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
            Material = t.Material,
        }


        -- Gender studies xd idk
        if t.Class=="npc_citizen" && (t.Gender == ZBASE_MALE or t.Gender == ZBASE_FEMALE) then
            table.insert(ZBaseSpawnMenuTbl.SpawnFlagTbl, t.Gender)
        end


        ZBaseSpawnMenuNPCList[cls] = ZBaseSpawnMenuTbl -- Add to zbase menu
    end
end


hook.Add("Initialize", "ZBASE", function()
    NPCsInherit()
    AddNPCsToSpawnMenu()
    ZBaseInitialized = true
end)


if ZBaseInitialized then

    IncludeFiles()

    registerNPCs()
    NPCsInherit()
    AddNPCsToSpawnMenu()
    UpdateLiveNPCs()


    if CLIENT && ZBCVAR.ReloadSpawnMenu:GetBool() then
        concommand.Run(LocalPlayer(), "spawnmenu_reload")
    end


    MsgN("ZBase Reloaded!")

else

    AddCSLuaFiles()
    IncludeFiles()
    registerNPCs()

end