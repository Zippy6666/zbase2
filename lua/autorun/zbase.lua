ZBaseInstalled = true

--[[
======================================================================================================================================================
                                           CONV CHECK
============================================= =========================================================================================================
--]]

if CLIENT then
    function MissingConvMsg()
        local frame = vgui.Create("DFrame")
        frame:SetSize(300, 125)
        frame:SetTitle("Missing Library!")
        frame:Center()
        frame:MakePopup()

        local text = vgui.Create("DLabel", frame)
        text:SetText("This server does not have the CONV library installed, some addons may function incorrectly. Click the link below to get it:")
        text:Dock(TOP)
        text:SetWrap(true)  -- Enable text wrapping for long messages
        text:SetAutoStretchVertical(true)  -- Allow the text label to stretch vertically
        text:SetFont("BudgetLabel")

        local label = vgui.Create("DLabelURL", frame)
        label:SetText("CONV Library")
        label:SetURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3146473253")
        label:Dock(BOTTOM)
        label:SetContentAlignment(5)  -- 5 corresponds to center alignment
    end

elseif SERVER && ( !file.Exists("convenience/adam.lua", "LUA") && !conv ) then
    -- Conv lib not on on server, send message to clients
    hook.Add("PlayerInitialSpawn", "convenienceerrormsg", function( ply )
        local sendstr = 'MissingConvMsg()'
        ply:SendLua(sendstr)
    end)

    -- This second hook is needed so that the ZBASE message isn't overwritten
    hook.Add("PlayerInitialSpawn", "convenienceerrormsg_zbase", function( ply )
        local sendstr = 'chat.AddText(Color(255, 0, 0), "WARNING: ZBase WILL not work as intended without the CONV library!") '
        sendstr = sendstr..'chat.AddText(Color(255, 0, 0), "Get it at: https://steamcommunity.com/sharedfiles/filedetails/?id=3146473253")'
        ply:SendLua(sendstr)
    end)

    return -- CONV not on server so return...

end

--[[
======================================================================================================================================================
                                           WELCOME MESSAGE OR SOMETHING IDK
======================================================================================================================================================
--]]

if SERVER then
    ZBaseDidConsoleLogo = ZBaseDidConsoleLogo
    or MsgN("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
    or MsgN("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
    or MsgN("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
    or MsgN("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
    or MsgN("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
    or MsgN("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --")
    or MsgN("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
    or MsgN("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
    or MsgN("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")
    or true
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
        ZBaseListFactions(_, ply)
    end)

    net.Receive("ZBaseReload", function()
        ZBase_RegisterHandler:NetworkedReload()
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
                                           SET SPAWN MENU CATEGORY ICONS
======================================================================================================================================================
--]]

list.Set("ContentCategoryIcons", "HL2: Humans + Resistance",    "games/16/hl2.png")
list.Set("ContentCategoryIcons", "HL2: Combine",                "games/16/hl2.png")
list.Set("ContentCategoryIcons", "HL2: Zombies + Enemy Aliens",  "games/16/hl2.png")

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

        if file.Exists(sh, "LUA") && (CLIENT or file.Exists(sv, "LUA")) then
            ZBaseNPCs[name] = {}
            ZBaseNPCs[name].Behaviours = {}

            include(sh)

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

function ZBase_RegisterHandler:AddNPCsToSpawnMenu()
    for cls, t in pairs( ZBaseNPCs ) do
        if t.Category == false then continue end -- Don't add to menu
        if cls == "npc_zbase" then continue end -- Don't add base to menu

        -- ZBase spawn menu tab
        local ZBaseSpawnMenuTbl = {
            Name=t.Name,
            Category=t.Category,
            Class = t.Class,
            SpawnMenuZBaseClass = cls,
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
            Author=t.Author,
            IconOverride = "entities/"..cls..".png",
        }
        ZBaseSpawnMenuNPCList[cls] = ZBaseSpawnMenuTbl -- Add to zbase menu

        -- Regular npc spawn menu
        if ZBCVAR.DefaultMenu:GetBool() then
            local function SpawnFlagTblToBit()
                local bt = 0

                for _, flag in ipairs(t.SpawnFlagTbl or {}) do
                    bt = bit.bor(bt, flag)
                end

                return bt
            end

            local RegularSpawnMenuTable = table.Copy(ZBaseSpawnMenuTbl)
            local cat = RegularSpawnMenuTable.Category
            local kvs = RegularSpawnMenuTable.KeyValues
            if kvs then
                kvs["parentname"] = cls
            end

            local sFlags = RegularSpawnMenuTable.TotalSpawnFlags or SpawnFlagTblToBit()

            RegularSpawnMenuTable.TotalSpawnFlags = sFlags

            -- Mix with regular NPCs, or don't
            if ZBCVAR.MenuMixin:GetBool() then
                local split = string.Split(cat, ": ")
                
                if #split == 2 then
                    RegularSpawnMenuTable.Category = split[2]
                else
                    RegularSpawnMenuTable.Category = cat
                end
            else
                RegularSpawnMenuTable.Category = cat
            end

            local clsname = "zbase_"..cls
            if ZBASE_MENU_REPLACEMENTS[cls] then
                if ZBCVAR.MenuMixin:GetBool() then
                    RegularSpawnMenuTable.Name = RegularSpawnMenuTable.Name.." (ZBase)"
                end

                if ZBCVAR.Replace:GetBool() then
                    clsname = ZBASE_MENU_REPLACEMENTS[cls]
                end
            end

            list.Set("NPC", clsname, RegularSpawnMenuTable) -- Add to regular spawn menu
        end
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

--[[
======================================================================================================================================================
                                           AUTO RELOAD BECAUSE I BROKE LUA REFRESH XD
                                           IVAN VLADIMIR CONFIRMS
======================================================================================================================================================
--]]

if SERVER then
    concommand.Add("zbase_reload", function(ply)
        ZBase_RegisterHandler:NetworkedReload()
        conv.devPrint(Color(0, 255, 200), "ZBase reloaded!")
    end)

    local function FetchFilenamesForAddonsInDevelopment()
        local root = "addons/"
        local filenames = {}

        -- ZBase installed as legacy addon
        if file.Find("zbase/npc_base_internal.lua", "GAME") then
            table.insert(filenames, "zbase/npc_base/sv_internal.lua")
            table.insert(filenames, "zbase/npc_base/init.lua")
            table.insert(filenames, "zbase/npc_base/shared.lua")
            table.insert(filenames, "zbase/npc_base/sv_util.lua")
            table.insert(filenames, "zbase/npc_base/sh_sentence.lua")

            local files = file.Find("zbase/npc_patches/*", "LUA")
            for _, f in ipairs(files) do
                table.insert(filenames, "zbase/npc_patches/"..f)
            end
        end

        local _, dirs = file.Find(root.."*", "GAME")

        for k, v in ipairs(dirs) do
            local checkpath = root..v.."/lua/zbase/entities/"

            if file.Exists(checkpath, "GAME") then
                local _, zbase_folder_names = file.Find(checkpath.."*", "GAME")

                for _, zbase_folder_name in ipairs(zbase_folder_names) do
                    if file.Exists( "zbase/entities/"..zbase_folder_name.."/init.lua", "LUA" ) then
                        table.insert(filenames, "zbase/entities/"..zbase_folder_name.."/init.lua")
                    end

                    if file.Exists("zbase/entities/"..zbase_folder_name.."/shared.lua", "LUA") then
                        table.insert(filenames, "zbase/entities/"..zbase_folder_name.."/shared.lua")
                    end

                    if file.Exists("zbase/entities/"..zbase_folder_name.."/behaviour.lua", "LUA") then
                        table.insert(filenames, "zbase/entities/"..zbase_folder_name.."/behaviour.lua")
                    end
                end
            end
        end

        return filenames
    end

    concommand.Add("zbase_update_autorefresh", function()
        ZBaseFilesToAutorefresh = FetchFilenamesForAddonsInDevelopment()
    end)

    local function AutoRefreshFunc()
        ZBaseFilesToAutorefresh = ZBaseFilesToAutorefresh or FetchFilenamesForAddonsInDevelopment()

        for _, fname in ipairs(ZBaseFilesToAutorefresh) do
            local time = file.Time(fname, "LUA")

            if ZBaseLastSavedFileTimeRegistry[fname] && ZBaseLastSavedFileTimeRegistry[fname] != time then
                conv.devPrint(Color(0, 255, 200), "ZBase detected change in '", fname, "', doing autorefresh!")
                RunConsoleCommand("zbase_reload")
                table.Empty(ZBaseLastSavedFileTimeRegistry)
                break
            end

            ZBaseLastSavedFileTimeRegistry[fname] = time
        end
    end

    local developer = GetConVar("developer")
    timer.Create("ZBaseAutoRefresh_Base (set developer to 0 if performance is impacted too much!)", 4, 0, function()
        if !developer:GetBool() then return end
        pcall(AutoRefreshFunc)
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