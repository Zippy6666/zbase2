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
elseif SERVER && !file.Exists("convenience/adam.lua", "LUA") then
    -- Conv lib not on on server, send message to clients
    hook.Add("PlayerInitialSpawn", "convenienceerrormsg", function( ply )
        local sendstr = 'MissingConvMsg()'
        ply:SendLua(sendstr)
    end)
    hook.Add("PlayerInitialSpawn", "convenienceerrormsg_zbase", function( ply )
        local sendstr = 'chat.AddText(Color(255, 0, 0), "WARNING: ZBase may not work as intended on the server without the CONV library!") '
        sendstr = sendstr..'chat.AddText(Color(255, 0, 0), "Get it at: https://steamcommunity.com/sharedfiles/filedetails/?id=3146473253")'
        ply:SendLua(sendstr)
    end)
end


--[[
======================================================================================================================================================
                                           WELCOME MESSAGE OR SOMETHING IDK
======================================================================================================================================================
--]]


ZBaseInstalled = ZBaseInstalled
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


ZBase_RegisterHandler = {}
ZBaseNPCs = {}
ZBaseSpawnMenuNPCList = {}
ZBasePatchTable = {}
ZBaseDynSplatterInstalled = file.Exists("dynsplatter", "LUA")
ZBaseIsMP = !game.SinglePlayer()



ZBaseNPCInstances = ZBaseNPCInstances or {}
ZBaseNPCInstances_NonScripted = ZBaseNPCInstances_NonScripted or {}
ZBaseBehaviourTimerFuncs = ZBaseBehaviourTimerFuncs or {}


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
    include("zbase/sh_controller.lua")
    include("zbase/sh_properties.lua")


    if SERVER then

        include("zbase/sv_schedules.lua")
        include("zbase/sv_meta_npc_extended.lua")
        include("zbase/sv_behaviour_system.lua")
        include("zbase/sv_spawnnpc.lua")
        include("zbase/sv_enginewep_translation.lua")
        include("zbase/sv_replacer.lua")

        
        -- Include NPC enhancement files
        local files = file.Find("zbase/npc_patches/*","LUA")
        local enhPath = "zbase/npc_patches/"
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
    AddCSLuaFile("zbase/sh_controller.lua")
    AddCSLuaFile("zbase/sh_properties.lua")

    AddCSLuaFile("zbase/cl_spawnmenu.lua")
    AddCSLuaFile("zbase/cl_toolmenu.lua")

    AddCSLuaFile("zbase/npc_base_shared.lua")


    -- Add zbase entity files
    local _, dirs = file.Find("zbase/entities/*","LUA")
    for _, v in ipairs(dirs) do
        AddCSLuaFile("zbase/entities/"..v.."/shared.lua")
    end
end


AddCSLuaFiles()
IncludeFiles()


--[[
======================================================================================================================================================
                                           REGISTER THE BLOODY BASE AND NPCS
                                           ADD TO SPAWNMENU
======================================================================================================================================================
--]]





function ZBase_RegisterHandler:UpdateLiveNPCs()
    for _, npc in ipairs(ZBaseNPCInstances) do
        local MyUpdatedTable = ZBaseNPCs[npc.NPCName]
        local MyOldTable = npc:GetTable()

        for attr, val in pairs(MyUpdatedTable) do
            MyOldTable[attr] = val
        end
    end
end



function ZBase_RegisterHandler:NPCsInherit(NPCTablesToInheritFrom)

    -- Keep da prints boye


    local New_NPCTablesToInheritFrom = {}

    for CurInheritClass, CurInheritTable in pairs(NPCTablesToInheritFrom) do

        -- MsgN("\n------------- CurInheritClass=", CurInheritClass, "-------------")


        for NPCClass, NPCTable in pairs(ZBaseNPCs) do

            if NPCClass == "npc_zbase" then continue end -- Don't do shit to the base


            if NPCTable.Inherit == CurInheritClass then

                -- MsgN(NPCClass, " inheriting from ", CurInheritClass, "...")


                table.Inherit(NPCTable, CurInheritTable)
                table.Inherit(NPCTable.Behaviours, CurInheritTable.Behaviours)

                NPCTable.BaseClass = nil
                NPCTable.Behaviours.BaseClass = nil


                New_NPCTablesToInheritFrom[NPCClass] = NPCTable

            end

        end


        -- MsgN("---------------------------------------------------------\n")

    end


    -- for InheritClass in pairs(New_NPCTablesToInheritFrom) do
    --      MsgN(InheritClass, " has inherited from its parents, and can now be inherited from by other npc tables")
    -- end


    if !table.IsEmpty(New_NPCTablesToInheritFrom) then
        self:NPCsInherit(New_NPCTablesToInheritFrom)
    end

end


function ZBase_RegisterHandler:RegBase()

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

    -- Replace default fellers
    local zbase_replacements = {
        ["zb_human_civilian"] = "npc_citizen",
        ["zb_antlion"] = "npc_antlion",
        ["zb_combine_soldier"] = "npc_combine_s",
        ["zb_zombine"] = "npc_zombine",
        ["zb_fastzombie"] = "npc_fastzombie",
        ["zb_human_medic"] = "Medic",
        ["zb_stalker"] = "npc_stalker",
        ["zb_kleiner"] = "npc_kleiner",
        ["zb_zombie"] = "npc_zombie",
        ["zb_human_rebel"] = "Rebel",
        ["zb_poisonzombie"] = "npc_poisonzombie",
        ["zb_metropolice"] = "npc_metropolice",
        ["zb_combine_elite"] = "CombineElite",
        ["zb_combine_nova_prospekt"] = "CombinePrison",
        ["zb_hunter"] = "npc_hunter",
        ["zb_vortigaunt"] = "npc_vortigaunt",
        ["zb_human_refugee"] = "Refugee",
        ["zb_odessa"]     = "npc_odessa",
    }


    for cls, t in pairs( ZBaseNPCs ) do
        if t.Category == false then continue end -- Don't add to menu
        if cls == "npc_zbase" then continue end -- Don't add base to menu


        -- ZBase spawn menu tab
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
            local split = isstring(cat) && string.Split(cat, ": ") -- Split away prefixes such as "HL2:"
            local newcat = istable(split) && #split >= 2 && split[2]
            local kvs = RegularSpawnMenuTable.KeyValues
            if kvs then
                kvs["parentname"] = cls
            end


            local sFlags = RegularSpawnMenuTable.TotalSpawnFlags or SpawnFlagTblToBit()
    

            RegularSpawnMenuTable.TotalSpawnFlags = sFlags
            RegularSpawnMenuTable.Category = newcat or cat

            local clsname = "zbase_"..cls
            if ZBCVAR.Replace:GetBool() && zbase_replacements[cls] then
                clsname = zbase_replacements[cls]
            end

            list.Set("NPC", clsname, RegularSpawnMenuTable) -- Add to regular spawn menu
        end
    end
end


function ZBase_RegisterHandler:Reload()

    self:RegNPCs()
    self:NPCsInherit({npc_zbase=ZBaseNPCs["npc_zbase"]})
    self:AddNPCsToSpawnMenu()
    -- self:UpdateLiveNPCs()


    if SERVER && ZBCVAR.ReloadSpawnMenu:GetBool() then
        RunConsoleCommand("spawnmenu_reload")
    end


    MsgN("ZBase reloaded base and NPCs!", CLIENT && "("..tostring(LocalPlayer())..")" or "(SERVER)")

end


function ZBase_RegisterHandler:Load()

    self:RegNPCs()
    self:NPCsInherit({npc_zbase=ZBaseNPCs["npc_zbase"]})
    self:AddNPCsToSpawnMenu()


    MsgN("ZBase registered base and NPCs!", CLIENT && "(CLIENT)" or "(SERVER)")

end


function ZBase_RegisterHandler:NetworkedReload()

    ZBase_RegisterHandler:Reload()

    net.Start("ZBaseClientReload")
    net.Broadcast()

end


concommand.Add("zbase_reload", function(ply)

    ZBase_RegisterHandler:NetworkedReload()

end)


ZBase_RegisterHandler:Load()


MsgN("ZBase autorun complete!")