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
end


function SWEP:PrimaryAttack()
end


function SWEP:GetNPCRestTimes()
    local RangeSeqDuration = self:SequenceDuration(self:SelectWeightedSequence(ACT_RANGE_ATTACK1))
    return RangeSeqDuration, RangeSeqDuration
end


function SWEP:GetNPCBurstSettings()
    return 1, 1
end


function SWEP:GetNPCBulletSpread( proficiency )
    return 0
end