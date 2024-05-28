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

        panel:ControlHelp("")
        panel:ControlHelp("-- "..string.upper(name).." --")
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

    ZBaseAddMenuCategory("A - General", function( panel )

        panel:CheckBox( "Logo", "zbase_enable_logo")
        panel:ControlHelp("Enable the ASCII-style ZBase logo in the tool menu. Requires the spawnmenu to be reloaded.")

        panel:CheckBox( "Start Message", "zbase_start_msg")
        panel:ControlHelp("Allow warning/message boxes when joining the game.")

        panel:CheckBox( "Precache NPCs", "zbase_precache")
        panel:ControlHelp("Precache NPCs, will lead to a smoother experience at the expense of longer load times.")
    
        panel:CheckBox("Glowing Eyes (Server)", "zbase_sv_glowing_eyes")
        panel:ControlHelp("Give NPCs glowing eyes on spawn if the NPC's model has any.")

        panel:CheckBox("Glowing Eyes (Client)", "zbase_glowing_eyes")
        panel:ControlHelp("Render glowing eyes if any are available.")

        panel:CheckBox("Default Spawn Menu", "zbase_defmenu")
        panel:ControlHelp("Should ZBase NPCs be added to the regular NPC menu too?")

    end)

    --[[
    ==================================================================================================
                                            AI
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("B - AI", function( panel )
        panel:CheckBox( "Patrol", "zbase_patrol" )
        panel:ControlHelp("Enable base patrol system.")
    
        panel:CheckBox( "Hurt Allies", "zbase_ply_hurt_ally" )
        panel:ControlHelp("Allow players to hurt their allies.")
    
        panel:NumSlider( "Health Multiplier", "zbase_hp_mult", 0, 20, 2 )
        panel:ControlHelp("Multiply ZBase NPCs' health by this number.")
        panel:NumSlider( "Damage Multiplier", "zbase_dmg_mult", 0, 20, 2 )
        panel:ControlHelp("Multiply ZBase NPCs' damage by this number.")
    

        panel:NumSlider( "Grenades", "zbase_gren_count", -1, 20, 0 )
        panel:ControlHelp("How many grenades should they be able to carry? -1 = infinite.")
        panel:NumSlider( "Secondary Attacks", "zbase_alt_count", -1, 20, 0 )
        panel:ControlHelp("How many alt-fire attacks should they be able to do? -1 = infinite.")
        panel:CheckBox("Grenade/Secondary Random", "zbase_gren_alt_rand")
        panel:ControlHelp("If enabled, ZBase NPCs will spawn with anywhere from 0 to the max value of grenades and alt-fire attacks, where the sliders above act as the max value.")
    
        panel:CheckBox( "Call for Help", "zbase_callforhelp" )
        panel:ControlHelp("Enable base call for help system. Lets NPCs call allies outside of its squad for help.")


        panel:CheckBox("Follow Players", "zbase_followplayers")
        panel:ControlHelp("If enabled, ZBase NPCs will follow allied players when the use key is pressed on them.")

        panel:NumSlider("Max NPCs Firing [WIP]", "zbase_max_npcs_shoot_ply", 0, 10, 0)
        panel:ControlHelp("Maximum amount of NPCs that can shoot at a single player at once. 0 = infinite.")

        panel:CheckBox( "Static Mode", "zbase_static" )
        panel:ControlHelp("Makes NPCs hold down the spot they spawned on. Also makes so that NPCs cannot hurt each other. This can be better for a PVE campaign-like experience.")
    end)

    --[[
    ==================================================================================================
                                            REPLACER
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("C - Replacer", function( panel )
        panel:CheckBox("Replace in NPC Menu", "zbase_replace")
        panel:ControlHelp("Should the default HL2 NPCs be replaced by their ZBase equivalents in the spawn menu?")

        panel:CheckBox("Campaign Replace", "zbase_camp_replace")
        panel:ControlHelp("Enable the zbase campaign replace system. Replaces retail HL2 NPCs with any desired ZBase NPC.")
    
        local ReloadButton = vgui.Create("DButton", panel)
        ReloadButton:Dock(TOP)
        ReloadButton:DockMargin(5, 25, 5, 0)
        ReloadButton:SetText("Load Campaign Replace File")
        function ReloadButton:DoClick()
            net.Start("zbase_camp_replace_reload")
            net.SendToServer()
        end
        panel:ControlHelp("Loads the 'zbase_campaign_replace.json' file in your data directory with your supplied changes.")

    end)


    --[[
    ==================================================================================================
                                            AFTERMATH
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("D - Aftermath", function( panel )
        panel:NumSlider( "Ragdoll Remove Time", "zbase_rag_remove_time", 0, 600, 1 )
        panel:ControlHelp("Time until ragdolls are removed, 0 = never. If keep corpses is enabled, this is ignored.")
        panel:NumSlider( "Max Ragdolls", "zbase_rag_max", 1, 200, 0 )
        panel:ControlHelp("Max ragdolls, if there is one too many, the oldest ragdoll will be removed. If keep corpses is enabled, this is ignored.")

        panel:NumSlider( "Gib Remove Time", "zbase_gib_remove_time", 0, 600, 1 )
        panel:ControlHelp("Time until gibs are removed, 0 = never. Not affected by keep corpses.")
        panel:NumSlider( "Max Gibs", "zbase_gib_max", 1, 200, 0 )
        panel:ControlHelp("Max gibs, if there is one too many, the oldest gib will be removed. Not affected by keep corpses.")

        panel:CheckBox( "Item Drops", "zbase_item_drops")
        panel:ControlHelp("Should NPCs drop items?")

        panel:CheckBox( "Dissolve Weapons", "zbase_dissolve_wep")
        panel:ControlHelp("Should the NPC's weapons dissolve?")
        
    end)

    --[[
    ==================================================================================================
                                            WEAPONS
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("E - Weapons", function( panel )

        panel:CheckBox("Random Weapon", "zbase_randwep")
        panel:ControlHelp("Should ZBase NPCs spawn with a random zbase weapon? Only works when they are spawned from the zbase tab at the moment!")

        panel:TextEntry("Rand Wep Blacklist", "zbase_randwep_blacklist_npc")
        panel:ControlHelp("ZBase NPCs that should not have their weapons randomized, separate with spaces.")

        panel:CheckBox("Nerf Powerful Weapons", "zbase_nerf")
        panel:ControlHelp("Powerful weapons like ar2 energy balls and rpgs will have a more reasonable amount of damage towards players.")

    end)

    --[[
    ==================================================================================================
                                            DEVELOPER
    ==================================================================================================
    --]]

    ZBaseAddMenuCategory("F - Developer", function( panel )

        local gitlink = panel:TextEntry("ZBase Github")
        gitlink:SetValue("https://github.com/Zippy6666/zbase2")


        panel:CheckBox( "Show Aerial Navigator", "zbase_show_navigator")
        panel:ControlHelp("Show the 'ghost NPC' that ControlHelps the aerial NPCs navigate.")


        panel:CheckBox( "Show NPC Schedule", "zbase_show_sched")
        panel:ControlHelp("Show what schedule the NPC is currently doing.")


        panel:CheckBox( "ZBase Reload Spawnmenu", "zbase_reload_spawnmenu")
        panel:ControlHelp("Should 'zbase_reload' also reload the spawn menu?")


        local ReloadButton = vgui.Create("DButton", panel)
        ReloadButton:Dock(TOP)
        ReloadButton:DockMargin(5, 25, 5, 0)
        ReloadButton:SetText("Reload NPCs")
        function ReloadButton:DoClick()
            net.Start("ZBaseReload")
            net.SendToServer()
        end
        panel:ControlHelp("Runs 'zbase_reload' which can be necessary if your NPCs aren't updating properly on save.")

    end)

    --[[
    ==================================================================================================
                                            ZOMBIES
    ==================================================================================================
    --]]
    
    ZBaseAddMenuCategory("Zombies", function( panel )

        panel:CheckBox("Zombie Headcrabs", "zbase_zombie_headcrabs")
        panel:ControlHelp("Should the zombies spawn with headcrabs?")
    
        panel:CheckBox("Zombie Red Blood", "zbase_zombie_red_blood")
        panel:ControlHelp("Should the zombies spawn with red blood?")

    end, "Default NPCs")
end)



