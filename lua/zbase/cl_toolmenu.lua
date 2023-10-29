------------------------------------------------------------------------------------------=#
local function ZBaseAddMenuCategory( name, func )
    spawnmenu.AddToolMenuOption("Options", "ZBase", name, name, "", "", func)
end
------------------------------------------------------------------------------------------=#
hook.Add("PopulateToolMenu", "ZBASE", function()
    ------------------------------------------------------------------------------------------=#
    ZBaseAddMenuCategory( "General", function( panel )

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

        panel:CheckBox("Replace Default NPCs (Requires restart)", "zbase_replace")
    end)
    ------------------------------------------------------------------------------------------=#
end)
------------------------------------------------------------------------------------------=#

