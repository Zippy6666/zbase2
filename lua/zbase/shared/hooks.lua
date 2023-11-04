AddCSLuaFile()

-------------------------------------------------------------------------------------------------------------=#
hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )
	if swep.IsZBaseWeapon && class!="weapon_zbase" then
		list.Add( "NPCUsableWeapons", { class = class, title = "ZBase - "..swep.PrintName } )
	end
end)
-------------------------------------------------------------------------------------------------------------=#
hook.Add("InitPostEntity", "ZBaseFuckAroundAndFindOut", function()
	local listGet = list.Get

	----------------------------------------------------------------------------------------------=#
	function list:Get()
		if self == "NPC" then
			-- Add ZBase NPCs to NPC list

			local ZBaseTableAdd = {}
			for k, v in pairs(ZBaseSpawnMenuNPCList) do
				local ZBaseNPC = table.Copy(v)

				ZBaseNPC.Category = "ZBase"
				ZBaseNPC.KeyValues = {parentname=k}
				ZBaseTableAdd[k] = ZBaseNPC
			end

			local t = table.Merge(listGet(self), ZBaseTableAdd)

			-- PrintTable(ZBaseTableAdd)
			return t
		end

		return listGet(self)
	end
	----------------------------------------------------------------------------------------------=#
end)
---------------------------------------------------------------------------------------=#