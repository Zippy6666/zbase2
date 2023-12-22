AddCSLuaFile()


--[[
==================================================================================================
                                           GENERAL
==================================================================================================
--]]


SWEP.PrintName = "ZBase Handler"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" )


--[[
==================================================================================================
                            	FUNCS
==================================================================================================
--]]


function SWEP:Initialize()
	self:SetHoldType( "smg" )
end


function SWEP:PrimaryAttack()
end


function SWEP:CanBePickedUpByNPCs()
	return true
end


function SWEP:GetNPCRestTimes()
	return self.NPCFireRestTimeMin, self.NPCFireRestTimeMax
end


function SWEP:GetNPCBurstSettings()
	return self.NPCBurstMin, self.NPCBurstMax, self.NPCFireRate
end


function SWEP:GetNPCBulletSpread( proficiency )
	return (7 - proficiency)*self.NPCBulletSpreadMult
end