-- Make sure internals and globals are loaded first as such:
include("zbase/toolmenu/cl_internal.lua")
include("zbase/sh_globals_pub.lua")

-- Appearance settings
local SettingFont       = "Trebuchet18"
local DescriptionColor  = Color( 50, 50, 50 )
local DescriptionFont   = "DefaultSmall"
local grey              = Color( 180, 16, 52)
local lightgrey         = Color( 200, 200, 200 )
local posterTab = {
    ['Image']     = "vgui/zbase_menu.jpg",
    ['Size']     = { 375, 375 },
    ['Color']     = color_white,
    ['Scroll']    = 0.2
}

ZBaseAddToolMenu( "ZBASE", "Misc", function(panel)
    panel:ZBase_ToolMenuCustomize( "MISC", color_white, "ChatFont", grey, lightgrey, posterTab  )

    panel:ZBase_ToolMenuAddCategory( "MENU" )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Pop-Up", "zbase_popup" ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "NPC Tab", "zbase_defmenu" ) }, color_black, SettingFont, "NPCs in regular NPC tab too", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Tab Mixin", "zbase_mixmenu" ) }, color_black, SettingFont, "Don't use separate categories in default NPC tab", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Collapse", "zbase_collapse_cat" ) }, color_black, SettingFont, "Collapse ZBase category icons by default", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "No HL2", "zbase_nodefhl2" ) }, color_black, SettingFont, "Don't add retail HL2 NPC 'replicas' to the menu", DescriptionColor, DescriptionFont )
    
    panel:ZBase_ToolMenuAddCategory( "NPC GENERAL" )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Ply Hurt Ally", "zbase_ply_hurt_ally" ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "NPC Hurt Ally", "zbase_friendly_fire" ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Nocollide between NPCs", "zbase_nocollide" ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )

    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Custom Classes", "zbase_custom_class" ) }, color_black, SettingFont, 
    "Give custom class names to ZBase NPCs. Disable this to allow NPC-specific improvement addons, such as improved Combine AI, to affect ZBase NPCs.", 
    DescriptionColor, DescriptionFont )

    panel:ZBase_ToolMenuAddCategory( "RESET" )

    local resetBtn = panel:ZBase_ToolMenuAddItem( { panel:Button( "Reset All Settings" ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )[1]
    resetBtn.DoClick = function()
        for k, v in pairs(ZBCVAR or {}) do
            if !v.Revert then continue end
            if !v.GetFlags then continue end
            if bit.band(v:GetFlags(), FCVAR_REPLICATED) == FCVAR_REPLICATED then continue end
            v:Revert()
        end
        if LocalPlayer():IsSuperAdmin() then
            RunConsoleCommand("zbase_resetsettings")
        end
    end
end)

local cleanupPosterTbl = {
    ['Image']     = "vgui/npcs.png",
    ['Size']     = { 375, 375 },
    ['Color']     = color_white,
    ['Scroll']    = 0.2
}
ZBaseAddToolMenu( "ZBASE", "AI", function(panel)
    panel:ZBase_ToolMenuCustomize( "AI", color_white, "ChatFont", grey, lightgrey, cleanupPosterTbl  )

    panel:ZBase_ToolMenuAddCategory( "STATS" )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Multiply HP", "zbase_hp_mult", 0, 20, 2 ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Multiply DMG", "zbase_dmg_mult", 0, 20, 2 ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Multiply Speed", "zbase_speed_mult", 0.1, 3, 2 ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Nerf", "zbase_nerf") }, color_black, SettingFont, "Nerf NPC AR2 alts, RPGs, crossbow, etc", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Grenades", "zbase_gren_count", -1, 20, 0 ) }, color_black, SettingFont, "-1 = inf", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Alt Fires", "zbase_alt_count", -1, 20, 0 ) }, color_black, SettingFont, "-1 = inf", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Grenade/Alt Rnd", "zbase_gren_alt_rand") }, color_black, SettingFont, "NPCs spawn with 0 to MAX grenades & alts, where the sliders above are MAX", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Sight Dist", "zbase_sightdist", 1, 30000, 0 ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Override", "zbase_sightdist_override") }, color_black, SettingFont, "Override all ZBase NPC sight distances. The distance still may vary due to what weapon the NPC has. Also NPCs ignore this distance if you attack them while you are in their view-cone.", DescriptionColor, DescriptionFont )

    panel:ZBase_ToolMenuAddCategory( "BEHAVIOR" )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Patrol", "zbase_patrol" ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Call Allies", "zbase_callforhelp" ) }, color_black, SettingFont, "Call any ally for help when in danger", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Squad", "zbase_autosquad" ) }, color_black, SettingFont, "Initially spawn with same squad name as faction name", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("+USE Follow", "zbase_followplayers") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Move Aid", "zbase_fallback_nav") }, color_black, SettingFont, "Enable if navigation is poor", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Jump Aid", "zbase_more_jumping") }, color_black, SettingFont, "Enable if navigation is poor", DescriptionColor, DescriptionFont )
end)

ZBaseAddToolMenu( "ZBASE", "Replace", function(panel)
    panel:ZBase_ToolMenuCustomize( "REPLACE", color_white, "ChatFont", grey, lightgrey, posterTab  )

    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Menu Replace", "zbase_replace") }, color_black, SettingFont, "Should the default HL2 NPCs be replaced by their ZBase equivalents in the spawn menu? This only works if you have 'NPC Tab' option enabled. You will also need to restart the map for changes to take effect.", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Campaign Replace", "zbase_camp_replace") }, color_black, SettingFont, "Enable the zbase campaign replace system. Replaces retail HL2 NPCs with any desired ZBase NPC.", DescriptionColor, DescriptionFont )
    
    local ReloadButton = panel:ZBase_ToolMenuAddItem( { panel:Button( "Load Campaign Replace File" ) }, color_black, SettingFont, "Loads the 'zbase_campaign_replace.json' file in your data directory with your supplied changes.", DescriptionColor, DescriptionFont )[1]
    function ReloadButton:DoClick()
        net.Start("zbase_camp_replace_reload")
        net.SendToServer()
    end
end)

local cleanupPosterTbl = {
    ['Image']     = "vgui/aftermath.jpg",
    ['Size']     = { 375, 375 },
    ['Color']     = color_white,
    ['Scroll']    = 0.2
}
ZBaseAddToolMenu( "ZBASE", "Cleanup", function(panel)
    panel:ZBase_ToolMenuCustomize( "CLEAN UP", color_white, "ChatFont", grey, lightgrey, cleanupPosterTbl  )

    panel:ZBase_ToolMenuAddCategory( "RAGDOLLS/GIBS" )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Ragdoll Time", "zbase_rag_remove_time", 0, 600, 1 ) }, color_black, SettingFont, "0 = never", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Max Ragdolls", "zbase_rag_max", 1, 200, 0 ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "CL Ragdolls", "zbase_cl_ragdolls") }, color_black, SettingFont, "Use client ragdolls instead, may not always work", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Gib Time", "zbase_gib_remove_time", 0, 600, 1 ) }, color_black, SettingFont, "0 = never", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Max Gibs", "zbase_gib_max", 1, 200, 0 ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    
    panel:ZBase_ToolMenuAddCategory( "ITEMS/WEAPONS" )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Item Drops", "zbase_item_drops") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Dissolve Weapons", "zbase_dissolve_wep") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
end)

local spawnerPosterTbl = {
    ['Image']     = "vgui/spawners.png",
    ['Size']     = { 375, 375 },
    ['Color']     = color_white,
    ['Scroll']    = 0.2
}
ZBaseAddToolMenu( "ZBASE", "Spawner", function(panel)
    panel:ZBase_ToolMenuCustomize( "SPAWNER", color_white, "ChatFont", grey, lightgrey, spawnerPosterTbl )

    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Spawn Cooldown", "zbase_spawner_cooldown", 0, 300, 2 ) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "VisCheck", "zbase_spawner_vis") }, color_black, SettingFont, "Don't spawn NPCs when in sight", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Check MinDist", "zbase_spawner_mindist") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "MinDist", "zbase_spawner_mindist", 0, 20000, 0 ) }, color_black, SettingFont, "Don't spawn this close to player", DescriptionColor, DescriptionFont )
end)

local fxPosterTbl = {
    ['Image']     = "vgui/fx.png",
    ['Size']     = { 375, 375 },
    ['Color']     = color_white,
    ['Scroll']    = 0.2
}
ZBaseAddToolMenu( "ZBASE", "Effects", function(panel)
    panel:ZBase_ToolMenuCustomize( "FX", color_white, "ChatFont", grey, lightgrey, fxPosterTbl  )

    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("SV Glowing Eyes", "zbase_sv_glowing_eyes") }, color_black, SettingFont, "Network eye sprites globally", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("CL Glowing Eyes (Client)", "zbase_glowing_eyes") }, color_black, SettingFont, "Render eye sprites on client", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Armor Spark", "zbase_armor_sparks") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Follow Halo", "zbase_follow_halo") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:NumSlider("Light Quality", "zbase_muzzle_light", 0, 2, 0) }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )

    local mFlashesBox = panel:ZBase_ToolMenuAddItem( { panel:ComboBox("Muzzle Flashes", "zbase_muzztyle") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )[1]
    mFlashesBox:AddChoice("hl2")
    mFlashesBox:AddChoice("black_mesa")
    mFlashesBox:AddChoice("mmod")
    mFlashesBox:ChooseOption(ZBCVAR.Muzzle:GetString())

    local ar2FlashesBox = panel:ZBase_ToolMenuAddItem( { panel:ComboBox("AR2 Flashes", "zbase_mar2tyle") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )[1]
    ar2FlashesBox:AddChoice("hl2")
    ar2FlashesBox:AddChoice("mmod")
    ar2FlashesBox:ChooseOption(ZBCVAR.AR2Muzzle:GetString())
end)

ZBaseAddToolMenu( "ZBASE", "Dev", function(panel)
    panel:ZBase_ToolMenuCustomize( "DEV", color_white, "ChatFont", grey, lightgrey, posterTab  )

    local gitlink = panel:ZBase_ToolMenuAddItem( { panel:TextEntry("ZBase Github") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )[1]
    gitlink:SetValue("https://github.com/Zippy6666/zbase2")

    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Show Aerial Navigator", "zbase_show_navigator") }, color_black, SettingFont, "Show the 'ghost NPC' that Helps the aerial NPCs navigate.", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Show NPC Schedule", "zbase_show_sched") }, color_black, SettingFont, "Show what schedule the NPC is currently doing.", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "ZBase Reload Spawnmenu", "zbase_reload_spawnmenu") }, color_black, SettingFont, "Should 'zbase_reload' also reload the spawn menu?", DescriptionColor, DescriptionFont )

    local ReloadButton = panel:ZBase_ToolMenuAddItem( { panel:Button( "Reload ZBase" ) }, color_black, SettingFont, "Runs 'zbase_reload' which can be necessary if your NPCs aren't updating properly on save.", DescriptionColor, DescriptionFont )[1]
    function ReloadButton:DoClick()
        net.Start("ZBaseReload")
        net.SendToServer()
    end
end)

ZBaseAddToolMenu( "DEF. NPCs", "Zombie", function(panel)
    panel:ZBase_ToolMenuCustomize( "ZOMBIE", color_white, "ChatFont", grey, lightgrey, posterTab  )

    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Headcrabs", "zbase_zombie_headcrabs") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Red Blood", "zbase_zombie_red_blood") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
end)

ZBaseAddToolMenu( "DEF. NPCs", "Combine", function(panel)
    panel:ZBase_ToolMenuCustomize( "COMBINE", color_white, "ChatFont", grey, lightgrey, posterTab  )

    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Metrocop Glow Eyes", "zbase_metrocop_glow_eyes") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Metrocop Arrest", "zbase_metrocop_arrest") }, color_black, SettingFont, "Metrocops will 'arrest' enemies, instead of attacking immediately. They need to be in a squad in order for it to work.", DescriptionColor, DescriptionFont )
end)

ZBaseAddToolMenu( "DEF. NPCs", "Citizen", function(panel)
    panel:ZBase_ToolMenuCustomize( "CITIZEN", color_white, "ChatFont", grey, lightgrey, posterTab  )

    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Give Ammo", "zbase_reb_ammo") }, color_black, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox("Rock Throw", "zbase_cit_rocks") }, color_black, SettingFont, "For any unarmed citizen, refugee, rebel, or similiar", DescriptionColor, DescriptionFont )
end)