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

        panel:Help("")
        panel:Help("-- "..string.upper(name).." --")
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

    ZBaseAddMenuCategory("A: General", function( panel )
        panel:CheckBox("Pop-Up", "zbase_popup")
        panel:Help("Show the pop-up when joining the game.")

        panel:CheckBox( "Logo", "zbase_enable_logo")
        panel:Help("Enable the ASCII-style ZBase logo in the tool menu. Requires the spawnmenu to be reloaded.")

        panel:CheckBox("Glowing Eyes (Server)", "zbase_sv_glowing_eyes")
        panel:Help("Give NPCs glowing eyes on spawn if the NPC's model has any.")

        panel:CheckBox("Glowing Eyes (Client)", "zbase_glowing_eyes")
        panel:Help("Render glowing eyes if any are available.")

        panel:CheckBox("Default Spawn Menu", "zbase_defmenu")
        panel:Help("Should ZBase NPCs be added to the regular NPC menu too?")

        panel:CheckBox( "Player Friendly Fire", "zbase_ply_hurt_ally" )
        panel:Help("Allow players to hurt their allies.")

        panel:CheckBox( "NPC Friendly Fire", "zbase_friendly_fire" )
        panel:Help("Allow NPCs to hurt their allies.")

        panel:CheckBox( "NPC Nocollide", "zbase_nocollide" )
        panel:Help("NPCs will not collide with eachother (COLLISION_GROUP_NPC_SCRIPTED).")
        
        panel:CheckBox( "Client Ragdolls", "zbase_cl_ragdolls")
        panel:Help("Should ZBase ragdolls be clientside? This will ignore 'Ragdoll Remove Time' and 'Max Ragdolls' in the aftermath section. Does not work perfectly with all NPCs.")

        panel:CheckBox("Armor Sparks", "zbase_armor_sparks")
        panel:Help("Should armor hits cause sparks?")

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

    ZBaseAddMenuCategory("B: AI", function( panel )
        panel:NumSlider( "Health Multiplier", "zbase_hp_mult", 0, 20, 2 )
        panel:Help("Multiply ZBase NPCs' health by this number.")
        panel:NumSlider( "Damage Multiplier", "zbase_dmg_mult", 0, 20, 2 )
        panel:Help("Multiply ZBase NPCs' damage by this number.")
    
        panel:NumSlider( "Grenades", "zbase_gren_count", -1, 20, 0 )
        panel:Help("How many grenades should they be able to carry? -1 = infinite.")
        panel:NumSlider( "Secondary Attacks", "zbase_alt_count", -1, 20, 0 )
        panel:Help("How many alt-fire attacks should they be able to do? -1 = infinite.")
        panel:CheckBox("Grenade/Secondary Random", "zbase_gren_alt_rand")
        panel:Help("If enabled, ZBase NPCs will spawn with anywhere from 0 to the max value of grenades and alt-fire attacks, where the sliders above act as the max value.")
    
        panel:CheckBox( "Patrol", "zbase_patrol" )
        panel:Help("Enable base patrol system.")

        panel:CheckBox( "Call for Help", "zbase_callforhelp" )
        panel:Help("Enable base call for help system. Lets NPCs call allies outside of its squad for help.")

        panel:CheckBox( "Set Squad", "zbase_autosquad" )
        panel:Help("Puts the NPC in a squad with the same name as its faction on spawn.")

        panel:CheckBox("Follow Players", "zbase_followplayers")
        panel:Help("If enabled, ZBase NPCs will follow allied players when the use key is pressed on them.")

        panel:CheckBox("Fallback Navigation", "zbase_fallback_nav")
        panel:Help("Should the NPC use a custom lua way of moving whenever it can't move by normal means? It's best to leave this off if the map you are on is well noded.")
        
        panel:CheckBox("More Jumping", "zbase_more_jumping")
        panel:Help("NPCs will jump when they cannot reach a certain waypoint. Requires 'Fallback Navigation' to be on.")

        panel:NumSlider( "Sight Distance", "zbase_sightdist", 1, 30000, 0 )
        panel:Help("Default ZBase NPC sight distance.")

        panel:CheckBox("Override Sight Distance", "zbase_sightdist_override")
        panel:Help("Should the sight distance slider apply to all ZBase NPCs regardless of unique sight distance?")
    end)

    --[[
    ==================================================================================================
                                            REPLACER
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("C: Replacer", function( panel )
        panel:CheckBox("Replace in NPC Menu", "zbase_replace")
        panel:Help("Should the default HL2 NPCs be replaced by their ZBase equivalents in the spawn menu?")

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

    ZBaseAddMenuCategory("D: Aftermath", function( panel )

        panel:NumSlider( "Ragdoll Remove Time", "zbase_rag_remove_time", 0, 600, 1 )
        panel:Help("Time until ragdolls are removed, 0 = never. If keep corpses is enabled, this is ignored.")
        panel:NumSlider( "Max Ragdolls", "zbase_rag_max", 1, 200, 0 )
        panel:Help("Max ragdolls, if there is one too many, the oldest ragdoll will be removed. If keep corpses is enabled, this is ignored.")

        panel:NumSlider( "Gib Remove Time", "zbase_gib_remove_time", 0, 600, 1 )
        panel:Help("Time until gibs are removed, 0 = never. Not affected by keep corpses.")
        panel:NumSlider( "Max Gibs", "zbase_gib_max", 1, 200, 0 )
        panel:Help("Max gibs, if there is one too many, the oldest gib will be removed. Not affected by keep corpses.")

        panel:CheckBox( "Item Drops", "zbase_item_drops")
        panel:Help("Should NPCs drop items?")

        panel:CheckBox( "Dissolve Weapons", "zbase_dissolve_wep")
        panel:Help("Should the NPC's weapons dissolve?")
        
    end)

    --[[
    ==================================================================================================
                                            WEAPONS
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("E: Spawners", function( panel )

        panel:NumSlider( "Cooldown", "zbase_spawner_cooldown", 0, 300, 2 )
        panel:Help("How long does it take until a spawner can spawn again?")

        panel:CheckBox( "VisCheck", "zbase_spawner_vis")
        panel:Help("Check if any player can see the spawner before spawning. If so, skip spawning this time.")

        panel:CheckBox( "Check MinDist", "zbase_spawner_mindist")

        panel:NumSlider( "MinDist", "zbase_spawner_mindist", 0, 20000, 0 )
        panel:Help("The minumim distance away from any player the spawner has to be in order to spawn. If any player is closer than this distance, skip spawning this time.")

    end)

    --[[
    ==================================================================================================
                                            WEAPONS
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("F: Weapons", function( panel )

        panel:TextEntry("Rand Wep NPC Blacklist", "zbase_randwep_blacklist_npc")
        panel:Help("ZBase NPCs that should not have their weapons randomized, separate with spaces.")
    
        panel:TextEntry("Rand Wep Blacklist", "zbase_randwep_blacklist_wep")
        panel:Help("ZBase weapons that should be blacklisted, separate with spaces.")
        
        panel:NumSlider("Max NPCs Firing", "zbase_max_npcs_shoot_ply", 0, 10, 0)
        panel:Help("Maximum amount of NPCs that can shoot at a single player at once. 0 = infinite.")

        panel:CheckBox("Nerf Powerful Weapons", "zbase_nerf")
        panel:Help("Powerful weapons like ar2 energy balls and rpgs will have a more reasonable amount of damage towards players.")

        panel:CheckBox("Dynamic Light", "zbase_muzzle_light")
        panel:Help("Should weapons emit dynamic light?")

        panel:CheckBox("Quality Flashes", "zbase_mmod_muzzle")
        panel:Help("Use muzzle flash effects from HL2 MMOD?")
    end)

    --[[
    ==================================================================================================
                                            DEVELOPER
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("G: Developer", function( panel )

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

        panel:CheckBox("Zombie Headcrabs", "zbase_zombie_headcrabs")
        panel:Help("Should the zombies spawn with headcrabs?")
    
        panel:CheckBox("Zombie Red Blood", "zbase_zombie_red_blood")
        panel:Help("Should the zombies spawn with red blood?")

    end, "Default NPCs")

    --[[
    ==================================================================================================
                                            COMBINE
    ==================================================================================================
    --]]
    
    ZBaseAddMenuCategory("Combine", function( panel )

        panel:CheckBox("Metro Cop Glowing Eyes", "zbase_metrocop_glow_eyes")
        panel:Help("Should metrocops eyes glow?")

    end, "Default NPCs")
end)



