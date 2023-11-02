------------------------------------------------------------------------------------------=#
local function ZBaseAddMenuCategory( name, func )
    spawnmenu.AddToolMenuOption("Options", "ZBase", name, name, "", "", function(panel)
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
        func(panel)
    end)
end
------------------------------------------------------------------------------------------=#
hook.Add("PopulateToolMenu", "ZBASE", function()

    ZBaseAddMenuCategory( "General", function( panel )
        panel:CheckBox("Replace Default NPCs", "zbase_replace")
        panel:Help("Replace the default HL2 NPCs with ZBase ones in the spawn menu? Requires restart.")
        panel:CheckBox("Player HL2 Weapon Damage", "zbase_hl2_wep_damage")
        panel:Help("Should ZBase NPC's HL2 weapons have the same damage values as players?")
    end)

end)
------------------------------------------------------------------------------------------=#

