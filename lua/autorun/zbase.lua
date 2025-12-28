ZBaseInstalled = true

--[[=========================== CONV MESSAGE START ===========================]]--
MissingConvMsg2 = CLIENT && function()

    Derma_Query(
        "This server does not have Zippy's Library installed, addons will function incorrectly!",

        "ZIPPY'S LIBRARY MISSING!",
        
        "Get Zippy's Library",

        function()
            gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3146473253")
        end,

        "Close"
    )

end || nil

hook.Add("PlayerInitialSpawn", "MissingConvMsg2", function( ply )

    if file.Exists("autorun/conv.lua", "LUA") then return end

    local sendstr = 'MissingConvMsg2()'
    ply:SendLua(sendstr)

end)
--[[============================ CONV MESSAGE END ============================]]--

if SERVER then
    ZBaseDidConsoleLogo = ZBaseDidConsoleLogo
    || MsgN("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
    || MsgN("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
    || MsgN("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
    || MsgN("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
    || MsgN("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
    || MsgN("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --")
    || MsgN("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
    || MsgN("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
    || MsgN("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")
    || true
end

--[[
======================================================================================================================================================
                                           NETWORK
======================================================================================================================================================
--]]

if SERVER then
    util.AddNetworkString("ZBaseListFactions")
    util.AddNetworkString("ZBase_GetFactionsFromServer")
    util.AddNetworkString("ZBaseClientReload")
    util.AddNetworkString("ZBaseReload")
    util.AddNetworkString("ZBaseUpdateSpawnMenuFactionDropDown")

    net.Receive("ZBase_GetFactionsFromServer", function(_, ply)
        if ply.UpdatedFactionListRecently then return end
        ZBaseListFactions(_, ply)
        ply:CONV_TempVar("UpdatedFactionListRecently", true, 2)
    end)
end

if CLIENT then
    net.Receive("ZBaseClientReload", function()
        ZBase_RegisterHandler:Reload()
    end)
end

--[[
======================================================================================================================================================
                                           PARTICLES
======================================================================================================================================================
--]]

game.AddParticles("particles/zbase/zbase_blood_impact.pcf")
game.AddParticles("particles/zbase/hl2mmod_muzzleflashes_npc.pcf")
game.AddParticles("particles/zbase/weapon_mp5_bmbs.pcf")
game.AddParticles("particles/zbase/weapon_shotgun.pcf")

game.AddParticles("particles/striderbuster.pcf")
game.AddParticles("particles/mortarsynth_fx.pcf")

PrecacheParticleSystem("blood_impact_zbase_green")
PrecacheParticleSystem("blood_impact_zbase_black")
PrecacheParticleSystem("blood_impact_zbase_blue")
PrecacheParticleSystem("blood_impact_zbase_synth")
PrecacheParticleSystem("striderbuster_break")
PrecacheParticleSystem("striderbuster_break_shell")

PrecacheParticleSystem("hl2mmod_muzzleflash_npc_ar2")
PrecacheParticleSystem("hl2mmod_muzzleflash_npc_pistol")
PrecacheParticleSystem("hl2mmod_muzzleflash_npc_shotgun")

PrecacheParticleSystem("world_weapon_mp5_muzzleflash_bmb")
PrecacheParticleSystem("world_weapon_shotgun_muzzleflash")

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
                                           INCLUDES
======================================================================================================================================================
--]]

-- If not already ran, run now
include("autorun/conv.lua")

AddCSLuaFile("zbase/sh_globals_pri.lua")
AddCSLuaFile("zbase/sh_globals_pub.lua")
AddCSLuaFile("zbase/sh_override_functions.lua")
include("zbase/sh_globals_pri.lua")
include("zbase/sh_globals_pub.lua")

conv.includeDir(
    "zbase", 
    -- These require special procedures so they are skipped
    {"sh_override_functions", "npc_patches", "entities", "npc_base", "sh_globals_"} 
)

if SERVER then
    -- Include NPC patch files
    local files = file.Find("zbase/npc_patches/*","LUA")
    local enhPath = "zbase/npc_patches/"
    for _, v in ipairs(files) do
        include(enhPath..v)
    end

    -- Add shared files of all ZBase npcs to clients when they join
    local _, dirs = file.Find("zbase/entities/*","LUA")
    for _, v in ipairs(dirs) do
        AddCSLuaFile("zbase/entities/"..v.."/shared.lua")
    end
end

--[[
======================================================================================================================================================
                                           REGISTER / ADD TO SPAWN MENU FUNCS
======================================================================================================================================================
--]]

function ZBase_RegisterHandler:NPCsInherit(NPCTablesToInheritFrom)
    local New_NPCTablesToInheritFrom = {}

    for CurInheritClass, CurInheritTable in pairs(NPCTablesToInheritFrom) do
        for NPCClass, NPCTable in pairs(ZBaseNPCs) do
            if NPCClass == "npc_zbase" then continue end -- Don't do shit to the base

            if NPCTable.Inherit == CurInheritClass then
                local explicitAuthor = NPCTable.Author

                table.Inherit(NPCTable, CurInheritTable)
                table.Inherit(NPCTable.Behaviours, CurInheritTable.Behaviours)

                if explicitAuthor == nil then
                    NPCTable.Author = "An addon creator."
                end

                NPCTable.BaseClass = nil
                NPCTable.Behaviours.BaseClass = nil

                New_NPCTablesToInheritFrom[NPCClass] = NPCTable
            end
        end
    end

    if !table.IsEmpty(New_NPCTablesToInheritFrom) then
        self:NPCsInherit(New_NPCTablesToInheritFrom)
    end
end

function ZBase_RegisterHandler:RegBase()
    ZBaseNPCs["npc_zbase"] = {}
    ZBaseNPCs["npc_zbase"].Behaviours = {}
    ZBaseNPCs["npc_zbase"].IsZBaseNPC = true

    local NPCBasePrefix = "zbase/npc_base/"

    if SERVER && !ZBase_AddedBaseLuaFilesToClient then
        AddCSLuaFile(NPCBasePrefix.."sh_sentence.lua")
        AddCSLuaFile(NPCBasePrefix.."shared.lua")
        AddCSLuaFile(NPCBasePrefix.."sh_classname.lua")
        ZBase_AddedBaseLuaFilesToClient = true
    end

    include(NPCBasePrefix.."sh_sentence.lua")
    include(NPCBasePrefix.."shared.lua")
    include(NPCBasePrefix.."sh_classname.lua")

    if SERVER then
        include(NPCBasePrefix.."sv_internal.lua")
        include(NPCBasePrefix.."sv_backwards.lua")
        include(NPCBasePrefix.."sv_util.lua")
        include(NPCBasePrefix.."init.lua")
    end
end

function ZBase_RegisterHandler:NPCReg( name )
    if name != "npc_zbase" then
        local path = "zbase/entities/"..name.."/"
        local sh = path.."shared.lua"
        local cl = path.."cl_init.lua"
        local sv = path.."init.lua"

        if file.Exists(sh, "LUA") && (CLIENT || file.Exists(sv, "LUA")) then
            ZBaseNPCs[name] = {}
            ZBaseNPCs[name].Behaviours = {}

            include(sh)

            if CLIENT then
                language.Add(name, ZBaseNPCs[name].Name)
            end

            if SERVER then
                include(sv)

                local bh = path.."behaviour.lua"
                if file.Exists(bh, "LUA") then
                    include(bh)
                end

                -- Store internal vars
                ZBaseNPCs[name].EInternalVars = {}
                for varname, var in pairs(ZBaseNPCs[name]) do
                    if string.StartWith(varname, "m_") then
                        ZBaseNPCs[name].EInternalVars[varname] = var
                    end
                end

                -- Make dupable if using custom class
                duplicator.RegisterEntityClass(name, function(ply, _)
                    return duplicator.GenericDuplicatorFunction(ply, {})
                end)
            end

            if file.Exists(cl, "LUA") && CLIENT then
                include(cl)
            end
        end
    end
end

function ZBase_RegisterHandler:RegNPCs()
    -- Empty NPC register
    table.Empty(ZBaseNPCs)

    -- Register base
    self:RegBase()

    -- Register all ZBase NPCs
    local _, dirs = file.Find("zbase/entities/*","LUA")
    for _, v in ipairs(dirs) do
        self:NPCReg(v)
    end
end

local retail_hl2_mfs = {
    ["zb_antlion"]                  = true,
    ["zb_combine_soldier"]          = true,
    ["zb_zombine"]                  = true,
    ["zb_fastzombie"]               = true,
    ["zb_stalker"]                  = true,
    ["zb_kleiner"]                  = true,
    ["zb_zombie"]                   = true,
    ["zb_human_rebel"]              = true,
    ["zb_human_refugee"]            = true,
    ["zb_human_medic"]              = true,
    ["zb_human_civilian"]           = true,
    ["zb_human_rebel_f"]              = true,
    ["zb_human_refugee_f"]            = true,
    ["zb_human_medic_f"]              = true,
    ["zb_human_civilian_f"]           = true,
    ["zb_poisonzombie"]             = true,
    ["zb_metropolice"]              = true,
    ["zb_combine_elite"]            = true,
    ["zb_combine_nova_prospekt"]    = true,
    ["zb_hunter"]                   = true,
    ["zb_vortigaunt"]               = true,
    ["zb_odessa"]                   = true,
    ["zb_magnusson"]                = true,
    ["zb_dog"]                      = true,
    ["zb_uriah"]                    = true,
    ["zb_manhack"]                  = true
}
function ZBase_RegisterHandler:AddNPCsToSpawnMenu()
    for cls, t in pairs( ZBaseNPCs ) do
        if t.Category == false then continue end -- Don't add to menu if category is false
        if cls == "npc_zbase" then continue end -- Don't add base to menu
        
        -- Don't add retail hl2 npc "replicas" if not desired
        if ZBCVAR.NoDefHL2:GetBool() && retail_hl2_mfs[cls] then 
            continue 
        end

        local RegularSpawnMenuCat
        local split = string.Split(t.Category, ": ")    
        if #split == 2 then
            RegularSpawnMenuCat = split[2]
        else
            RegularSpawnMenuCat = t.Category
        end

        -- Add to NPC tab in spawn menu
        list.Set("NPC", cls, {
            Name        = t.Name,
            Category        = RegularSpawnMenuCat,
            ZBaseCategory   = t.Category,
            Class       = cls,
            ZBaseEngineClass = t.Class,
            Weapons     = t.Weapons,
            Offset      = t.Offset || (t.SNPCType == ZBASE_SNPCTYPE_FLY && t.Fly_DistanceFromGround),
            OnFloor     = t.OnFloor,
            OnCeiling   = t.OnCeiling,
            NoDrop      = t.NoDrop,
            Rotate      = t.Rotate,
            AdminOnly   = t.AdminOnly,
            Author      = t.Author,
            IconOverride= t.IconOverride,
        })
    end
end

function ZBase_RegisterHandler:Reload()
    self:RegNPCs()
    self:NPCsInherit({npc_zbase=ZBaseNPCs["npc_zbase"]})
    self:AddNPCsToSpawnMenu()

    if SERVER && ZBCVAR.ReloadSpawnMenu:GetBool() then
        RunConsoleCommand("spawnmenu_reload")
    end
end

function ZBase_RegisterHandler:Load()
    self:RegNPCs()
    self:NPCsInherit({npc_zbase=ZBaseNPCs["npc_zbase"]})
    self:AddNPCsToSpawnMenu()
end

function ZBase_RegisterHandler:NetworkedReload()
    ZBase_RegisterHandler:Reload()

    net.Start("ZBaseClientReload")
    net.Broadcast()
end

concommand.Add("zbase_reload", function( ply )
    if !ply:IsSuperAdmin() then return end

    ZBase_RegisterHandler:NetworkedReload()
    conv.devPrint(Color(0, 255, 200), "ZBase reloaded!")
end)

if SERVER then
    net.Receive("ZBaseReload", function( len, ply )
        if !ply:IsSuperAdmin() then return end
        RunConsoleCommand("zbase_reload")
    end)
end

--[[
======================================================================================================================================================
                                           REGISTER THE BLOODY BASE AND NPCS
                                           ADD TO SPAWNMENU
======================================================================================================================================================
--]]

ZBase_RegisterHandler:Load()

if SERVER then
    conv.devPrint(Color(0, 255, 200), "ZBase autorun complete!")
end