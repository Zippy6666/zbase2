-------------------------------------------------------------------------------------------------------------------------=#
print("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
print("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
print("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
print("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
print("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
print("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --")
    
print("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
print("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
print("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")            
-------------------------------------------------------------------------------------------------------------------------=#

        -- TODO --
    -- Recreate hl2 npcs
    -- Next?

        -- Ideas --
    -- Hearing system
    -- Squad system
    -- Hl2 weapons deal correct damage + secondary fire + improve crossbow + other improvements maybe
    -- SNPCs
    -- COND_ for behaviours
    -- Custom NPCs, for example, Ministrider, crabless zombies (just called zombies, normal zombies will be called headcrab zombies)
    -- Custom blood system, white blood decals for hunters
    -- More sounds (hear enemy, lost enemy, hear danger, grenade, etc)

-------------------------------------------------------------------------------------------------------------------------=#



-- Includes --
include("zbase/sh_globals.lua")
include("zbase/sh_hooks.lua")
include("zbase/sh_replace_funcs.lua")
if SERVER then
    include("zbase/sv_behaviour.lua")
end


if CLIENT then
    -- spawnmenu.AddCreationTab( "ZBase", function(...)
    --     print(...)
    --     return vgui.Create("DCheckBox")
    -- end)

    spawnmenu.AddContentType( "ZBase", function( ... ) print(...) end)
end


 
-- Sounds --
sound.Add( {
	name = "ZBase.Ricochet",
	channel = CHAN_BODY,
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

            ZBaseNPCs[name] = {Behaviours={}}

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
local function addNPCs()
    -- Add all NPCs to spawnmenu
    for cls, t in pairs(ZBaseNPCs) do
        if cls == "npc_zbase" then continue end

        if t.KeyValues then
            t.KeyValues.parentname = "zbase_"..cls
        else
            t.KeyValues = {parentname = "zbase_"..cls}
        end

        t.Category = "ZBase - "..t.Category

        -- if SERVER && GetConVar("developer"):GetBool() then
        --     print("---------------------", cls, "---------------------")
        --     PrintTable(t)
        --     print("------------------------------------------------------------")
        -- end

        list.Set( "NPC", cls, t )

    end
end
-------------------------------------------------------------------------------------------------------------------------=#

registerNPCs()
addNPCs()


