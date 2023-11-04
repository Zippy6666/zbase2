hook.Add("InitPostEntity", "ZBaseReplaceFuncsClient", function()
	local spawnmenu_reload = concommand.GetTable()["spawnmenu_reload"]


	--------------------------------------------------------------------=#
	concommand.Add("spawnmenu_reload", function(...)
        ZBase_JustReloadedSpawnmenu = true

		spawnmenu_reload(...)

        timer.Simple(0.5, function()
            ZBase_JustReloadedSpawnmenu = false 
        end)
	end)
	--------------------------------------------------------------------=#
end)