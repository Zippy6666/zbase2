AddCSLuaFile()
---------------------------------------------------------------------------------------=#
hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )
	if swep.IsZBaseWeapon && class!="weapon_zbase" then
		list.Add( "NPCUsableWeapons", { class = class, title = "ZBase - "..swep.PrintName } )
	end
end)
---------------------------------------------------------------------------------------=#