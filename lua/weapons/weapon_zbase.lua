AddCSLuaFile()

	-- You can use this weapon base for your swep to have better control over how NPCs handle it --



SWEP.PrintName = "ZBase Weapon"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.IsZBaseWeapon = true

SWEP.NPCOnly = true -- Should only NPCs be able to use this weapon?
SWEP.NPCCanPickUp = true -- Can NPCs pick up this weapon from the ground
SWEP.NPCBurstMin = 1 -- Minimum amount of bullets the NPC can fire when firing a burst
SWEP.NPCBurstMax = 1 -- Maximum amount of bullets the NPC can fire when firing a burst
SWEP.NPCFireRate = 1 -- Shoot delay in seconds
SWEP.NPCFireRestTimeMin = 1 -- Minimum amount of time the NPC rests between bursts in seconds
SWEP.NPCFireRestTimeMax = 1 -- Maximum amount of time the NPC rests between bursts in seconds
SWEP.NPCBulletSpreadMult = 1 -- Higher number = worse accuracy
SWEP.NPCReloadSound = "" -- Sound when the NPC reloads the gun



--------------------------------------------------------=#



	-- Don't touch anything below this! --

--------------------------------------------------------=#
hook.Add("PlayerCanPickupWeapon", "ZBASE", function( ply, wep )
	if wep.IsZBaseWeapon && wep.NPCOnly then
		ply:GiveAmmo(wep:GetMaxClip1(), wep:GetPrimaryAmmoType())
		wep:Remove()
		return false
	end
end)
--------------------------------------------------------=#
function SWEP:CanBePickedUpByNPCs()
	return true
end
--------------------------------------------------------=#
function SWEP:GetNPCRestTimes()
	return self.NPCFireRestTimeMin, self.NPCFireRestTimeMax
end
--------------------------------------------------------=#
function SWEP:GetNPCBurstSettings()
	return self.NPCBurstMin, self.NPCBurstMax, self.NPCFireRate
end
--------------------------------------------------------=#
function SWEP:GetNPCBulletSpread( proficiency )
	return (7 - proficiency)*self.NPCBulletSpreadMult
end
--------------------------------------------------------=#