AddCSLuaFile()


--[[
==================================================================================================
                                           GENERAL
==================================================================================================
--]]


SWEP.PrintName = "ZBase Animations"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.WorldModel = Model( "models/error.mdl" )



function SWEP:Initialize()
	self:SetHoldType( "smg" )
    self.Duration = 1
end


function SWEP:PrimaryAttack()
end


function SWEP:GetNPCRestTimes()
    return self.Duration, self.Duration
end


function SWEP:GetNPCBurstSettings()
    return 1, 1
end


function SWEP:GetNPCBulletSpread( proficiency )
    return 0
end