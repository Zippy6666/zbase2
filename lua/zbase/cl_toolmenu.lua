------------------------------------------------------------------------------------------=#
local function ZBaseAddMenuCategory( name, func )

    spawnmenu.AddToolMenuOption("Configure ZBase", "Base", name, name, "", "", function(panel)
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
        panel:ControlHelp("")
        panel:ControlHelp("-- "..string.upper(name).." --")
        func(panel)
    end)

end
------------------------------------------------------------------------------------------=#
hook.Add("PopulateToolMenu", "ZBASE", function()
    spawnmenu.AddToolTab( "Configure ZBase", "ZBase", "entities/zippy.png" )


    ZBaseAddMenuCategory("NPC General", function( panel )
        panel:CheckBox("Glowing Eyes (Server)", "zbase_sv_glowing_eyes")
        panel:Help("Give NPCs glowing eyes on spawn if the NPC's model has any.")

        panel:CheckBox("Glowing Eyes (Client)", "zbase_glowing_eyes")
        panel:Help("Render glowing eyes if any are available.")

        panel:NumSlider( "Health Multiplier", "zbase_hp_mult", 0, 20, 2 )
        panel:Help("Multiply ZBase NPCs' health by this number.")
        panel:NumSlider( "Damage Multiplier", "zbase_dmg_mult", 0, 20, 2 )
        panel:Help("Multiply ZBase NPCs' damage by this number.")

        panel:CheckBox( "Patrol", "zbase_patrol" )
        panel:Help("Enable base patrol system.")

        panel:CheckBox( "Hurt Allies", "zbase_ply_hurt_ally" )
        panel:Help("Allow players to hurt their allies.")

        panel:CheckBox("Zombie Headcrabs", "zbase_zombie_headcrabs")
        panel:Help("Should the default ZBase zombies spawn with headcrabs?")
        panel:CheckBox("Zombie Red Blood", "zbase_zombie_red_blood")
        panel:Help("Should the default ZBase zombies spawn with red blood?")
    end)


    ZBaseAddMenuCategory("Aftermath", function( panel )
        panel:NumSlider( "Ragdoll Remove Time", "zbase_rag_remove_time", 0, 600, 1 )
        panel:Help("Time until ragdolls are removed, 0 = never. If keep corpses is enabled, this is ignored.")
        panel:NumSlider( "Max Ragdolls", "zbase_rag_max", 1, 200, 0 )
        panel:Help("Max ragdolls, if there is one too many, the oldest ragdoll will be removed. If keep corpses is enabled, this is ignored.")

        panel:NumSlider( "Gib Remove Time", "zbase_gib_remove_time", 0, 600, 1 )
        panel:Help("Time until gibs are removed, 0 = never. Not affected by keep corpses.")
        panel:NumSlider( "Max Gibs", "zbase_gib_max", 1, 200, 0 )
        panel:Help("Max gibs, if there is one too many, the oldest gib will be removed. Not affected by keep corpses.")
    end)


    ZBaseAddMenuCategory("Weapons", function( panel )
        panel:CheckBox("Random Weapon", "zbase_randwep")
        panel:Help("Should ZBase NPCs spawn with a random zbase weapon? Only works when they are spawned from the zbase tab at the moment!")

        -- panel:TextEntry("Rand Wep Blacklist", "zbase_randwep_blacklist")
        -- panel:Help("ZBase weapons that are not allowed in the random list.")
    
        panel:TextEntry("Rand Wep Blacklist", "zbase_randwep_blacklist_npc")
        panel:Help("ZBase NPCs that should not have their weapons randomized, separate with spaces.")
    end)


    ZBaseAddMenuCategory("Options", function( panel )

        panel:CheckBox( "Start Message", "zbase_start_msg")
        panel:Help("Allow warning/message boxes when joining the game.")

        panel:CheckBox( "Precache NPCs", "zbase_precache")
        panel:Help("Precache NPCs, will lead to a smoother experience at the expense of longer load times.")
    
        panel:CheckBox("Default Spawn Menu", "zbase_defmenu")
        panel:Help("Should ZBase NPCs be added to the regular NPC menu too?")

        panel:CheckBox("Replace in NPC Menu", "zbase_replace")
        panel:Help("Should the default HL2 NPCs be replaced by their ZBase equivalents in the spawn menu?")

    end)


    ZBaseAddMenuCategory("Developer", function( panel )


        local gitlink = panel:TextEntry("ZBase Github")
        gitlink:SetValue("https://github.com/Zippy6666/zbase2")


        -- panel:CheckBox( "Developer", "developer")
        -- panel:Help("Sets 'developer' to '1'.")


        panel:CheckBox( "Show Aerial Navigator", "zbase_show_navigator")
        panel:Help("Show the 'ghost NPC' that helps the aerial NPCs navigate.")


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
end)
------------------------------------------------------------------------------------------=#

