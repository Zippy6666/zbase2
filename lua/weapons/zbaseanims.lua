AddCSLuaFile()


	-- You can use this weapon base for your swep to have better control over how NPCs handle it --
	-- SWEP.Base = "weapon_zbase"


--[[
==================================================================================================
                                           GENERAL
==================================================================================================
--]]


SWEP.PrintName = "ZBase Weapon"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" )



function SWEP:Initialize()
	self:SetHoldType( "smg" )
    self:SetNoDraw(true)
end


function SWEP:PrimaryAttack()
end



function SWEP:CanBePickedUpByNPCs()
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