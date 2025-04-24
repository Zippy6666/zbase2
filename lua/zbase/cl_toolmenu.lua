local enableZBaseLogo = CreateClientConVar("zbase_enable_logo", "0", true, false)

local function ZBaseAddMenuCategory( name, func, cat )
    spawnmenu.AddToolMenuOption("ZBase", cat or "ZBase", name, name, "", "", function(panel)
        if enableZBaseLogo:GetBool() then
            panel:ControlHelp("")
            panel:ControlHelp("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
            panel:ControlHelp("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
            panel:ControlHelp("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
            panel:ControlHelp("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
            panel:ControlHelp("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
            panel:ControlHelp("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --")
            panel:ControlHelp("")
            panel:ControlHelp("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
            panel:ControlHelp("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
            panel:ControlHelp("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")
        end

        func(panel)
    end)

end

hook.Add("PopulateToolMenu", "ZBASE", function()
    spawnmenu.AddToolTab( "ZBase", "ZBase", "entities/zippy.png" )

    --[[
    ==================================================================================================
                                            GENERAL
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("Misc", function( panel )
        panel:CheckBox("Pop-Up", "zbase_popup")

        panel:CheckBox( "Logo", "zbase_enable_logo")
        panel:Help("ASCII-style 'ZBASE' logo in menu, requires spawn menu reload")

        panel:CheckBox("NPC Tab", "zbase_defmenu")
        panel:Help("NPCs in regular NPC tab too")

        panel:CheckBox( "Ply Hurt Ally", "zbase_ply_hurt_ally" )
        panel:CheckBox( "NPC Hurt Ally", "zbase_friendly_fire" )

        panel:CheckBox( "NPC Nocollide", "zbase_nocollide" )
        panel:Help("Nocollide between NPCs")

        local resetBtn = panel:Button("Reset All Settings")
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

    --[[
    ==================================================================================================
                                            AI
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("AI", function( panel )
        panel:NumSlider( "HP Mul", "zbase_hp_mult", 0, 20, 2 )
        panel:NumSlider( "DMG Mul", "zbase_dmg_mult", 0, 20, 2 )

        panel:CheckBox("Nerf", "zbase_nerf")
        panel:Help("Nerf NPC AR2 alts, RPGs, crossbow, etc")

        panel:NumSlider( "Grenades", "zbase_gren_count", -1, 20, 0 )
        panel:Help("'-1' = inf")

        panel:NumSlider( "Alt Fires", "zbase_alt_count", -1, 20, 0 )
        panel:Help("'-1' = inf")

        panel:CheckBox("Grenade/Alt Rnd", "zbase_gren_alt_rand")
        panel:Help("NPCs spawn with 0 to MAX grenades & alts, where the sliders above are MAX")

        panel:NumSlider("Max Shooters", "zbase_max_npcs_shoot_ply", 0, 10, 0)
        panel:Help("Max NPCs that can shoot at a single player, '0' = infinite")
    
        panel:CheckBox( "Patrol", "zbase_patrol" )

        panel:CheckBox( "Call Allies", "zbase_callforhelp" )
        panel:Help("Call any ally for help when in danger")

        panel:CheckBox( "Squad", "zbase_autosquad" )
        panel:Help("Initially spawn with same squad name as faction name")

        panel:CheckBox("+USE Follow", "zbase_followplayers")
 
        panel:CheckBox("Move Aid", "zbase_fallback_nav")
        panel:Help("Enable if navigation is poor")
        
        panel:CheckBox("Jump Aid", "zbase_more_jumping")
        panel:Help("Enable if navigation is poor")

        panel:NumSlider( "Sight Dist", "zbase_sightdist", 1, 30000, 0 )

        panel:CheckBox("Override", "zbase_sightdist_override")
        panel:Help("Override all ZBase NPC sight distances")
    end)

    --[[
    ==================================================================================================
                                            REPLACER
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("Replace", function( panel )
        panel:CheckBox("Menu Replace", "zbase_replace")
        panel:Help("Should the default HL2 NPCs be replaced by their ZBase equivalents in the spawn menu? This only works if you have 'NPC Tab' option enabled. You will also need to restart the map for changes to take effect.")

        panel:CheckBox("Campaign Replace", "zbase_camp_replace")
        panel:Help("Enable the zbase campaign replace system. Replaces retail HL2 NPCs with any desired ZBase NPC.")
    
        local ReloadButton = vgui.Create("DButton", panel)
        ReloadButton:Dock(TOP)
        ReloadButton:DockMargin(5, 25, 5, 0)
        ReloadButton:SetText("Load Campaign Replace File")
        function ReloadButton:DoClick()
            net.Start("zbase_camp_replace_reload")
            net.SendToServer()
        end
        panel:Help("Loads the 'zbase_campaign_replace.json' file in your data directory with your supplied changes.")
    end)

    --[[
    ==================================================================================================
                                            AFTERMATH
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("Cleanup", function( panel )
        panel:NumSlider( "Ragdoll Time", "zbase_rag_remove_time", 0, 600, 1 )
        panel:Help("'0' = never")
        panel:NumSlider( "Max Ragdolls", "zbase_rag_max", 1, 200, 0 )

        panel:CheckBox( "CL Ragdolls", "zbase_cl_ragdolls")
        panel:Help("Use client ragdolls instead, may not always work")

        panel:NumSlider( "Gib Time", "zbase_gib_remove_time", 0, 600, 1 )
        panel:Help("'0' = never")

        panel:NumSlider( "Max Gibs", "zbase_gib_max", 1, 200, 0 )

        panel:CheckBox( "Item Drops", "zbase_item_drops")
        panel:CheckBox( "Dissolve Weapons", "zbase_dissolve_wep")
    end)

    --[[
    ==================================================================================================
                                            SPAWNERS
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("Spawner", function( panel )
        panel:NumSlider( "Spawn Cooldown", "zbase_spawner_cooldown", 0, 300, 2 )

        panel:CheckBox( "VisCheck", "zbase_spawner_vis")
        panel:Help("Don't spawn NPCs when in sight")

        panel:CheckBox( "Check MinDist", "zbase_spawner_mindist")

        panel:NumSlider( "MinDist", "zbase_spawner_mindist", 0, 20000, 0 )
        panel:Help("Don't spawn this close to player")
    end)

    --[[
    ==================================================================================================
                                            EFFECTS
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("Effects", function( panel )
        panel:CheckBox("SV Glowing Eyes", "zbase_sv_glowing_eyes")
        panel:Help("Network eye sprites globally")

        panel:CheckBox("CL Glowing Eyes (Client)", "zbase_glowing_eyes")
        panel:Help("Render eye sprites on client")

        panel:CheckBox("Armor Spark", "zbase_armor_sparks")
        panel:CheckBox("Follow Halo", "zbase_follow_halo")

        panel:NumSlider("Light Quality", "zbase_muzzle_light", 0, 2, 0)

        local mFlashesBox = panel:ComboBox("Muzzle Flashes", "zbase_muzztyle")
        mFlashesBox:AddChoice("hl2")
        mFlashesBox:AddChoice("black_mesa")
        mFlashesBox:AddChoice("mmod")
        mFlashesBox:ChooseOption(ZBCVAR.Muzzle:GetString())

        local ar2FlashesBox = panel:ComboBox("AR2 Flashes", "zbase_mar2tyle")
        ar2FlashesBox:AddChoice("hl2")
        ar2FlashesBox:AddChoice("mmod")
        ar2FlashesBox:ChooseOption(ZBCVAR.AR2Muzzle:GetString())
    end)

    --[[
    ==================================================================================================
                                            DEVELOPER
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("Dev", function( panel )
        local gitlink = panel:TextEntry("ZBase Github")
        gitlink:SetValue("https://github.com/Zippy6666/zbase2")

        panel:CheckBox( "Show Aerial Navigator", "zbase_show_navigator")
        panel:Help("Show the 'ghost NPC' that Helps the aerial NPCs navigate.")

        panel:CheckBox( "Show NPC Schedule", "zbase_show_sched")
        panel:Help("Show what schedule the NPC is currently doing.")

        panel:CheckBox( "ZBase Reload Spawnmenu", "zbase_reload_spawnmenu")
        panel:Help("Should 'zbase_reload' also reload the spawn menu?")

        local ReloadButton = vgui.Create("DButton", panel)
        ReloadButton:Dock(TOP)
        ReloadButton:DockMargin(5, 25, 5, 0)
        ReloadButton:SetText("Reload NPCs")
        function ReloadButton:DoClick()
            net.Start("ZBaseReload")
            net.SendToServer()
        end
        panel:Help("Runs 'zbase_reload' which can be necessary if your NPCs aren't updating properly on save.")
    end)

    --[[
    ==================================================================================================
                                            ZOMBIES
    ==================================================================================================
    --]]
    
    ZBaseAddMenuCategory("Zombies", function( panel )
        panel:CheckBox("Headcrabs", "zbase_zombie_headcrabs")
        panel:CheckBox("Red Blood", "zbase_zombie_red_blood")
    end, "NPCs")

    --[[
    ==================================================================================================
                                            COMBINE
    ==================================================================================================
    --]]
    
    ZBaseAddMenuCategory("Combine", function( panel )
        panel:CheckBox("Metrocop Glow Eyes", "zbase_metrocop_glow_eyes")
        panel:CheckBox("Metrocop Arrest", "zbase_metrocop_arrest")
        panel:Help("Metrocops will 'arrest' enemies, instead of attacking immediately")
    end, "NPCs")

    --[[
    ==================================================================================================
                                            CITIZEN
    ==================================================================================================
    --]]
    
    ZBaseAddMenuCategory("Citizens", function( panel )
        panel:CheckBox("Give Ammo", "zbase_reb_ammo")
        panel:CheckBox("Rock Throw", "zbase_cit_rocks")
        panel:Help("For any unarmed citizen, refugee, rebel, or similiar")
    end, "NPCs")
end)



