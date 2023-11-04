AddCSLuaFile()

-------------------------------------------------------------------------------------------------------------=#
hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )
	if swep.IsZBaseWeapon && class!="weapon_zbase" then
		list.Add( "NPCUsableWeapons", { class = class, title = "ZBase - "..swep.PrintName } )
	end
end)
-------------------------------------------------------------------------------------------------------------=#
hook.Add("InitPostEntity", "ZBaseReplaceFuncs", function() timer.Simple(0.5, function()
	local listGet = list.Get


	----------------------------------------------------------------------------------------------=#
	function list:Get()
		if self == "NPC" then
			-- Add ZBase NPCs to NPC list

			local ZBaseTableAdd = {}
			for k, v in pairs(ZBaseSpawnMenuNPCList) do
				local ZBaseNPC = table.Copy(v)

				ZBaseNPC.Category = "ZBase"
				ZBaseTableAdd[k] = ZBaseNPC
			end

			-- local t = table.Merge(listGet(self), table.Copy(ZBaseSpawnMenuNPCList))

			PrintTable(ZBaseTableAdd)
			return ZBaseTableAdd
		end

		return listGet(self)
	end
	----------------------------------------------------------------------------------------------=#
end) end)
---------------------------------------------------------------------------------------=#