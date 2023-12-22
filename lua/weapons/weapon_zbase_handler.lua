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


-- IMPORTANT: Set this to true in your base
-- Note that your SWEP will be added to the NPC weapon menu automatically if you do
SWEP.IsZBaseWeapon = true


--[[
==================================================================================================
                                           NPC HANDLING
==================================================================================================
--]]



SWEP.NPCOnly = true -- Should only NPCs be able to use this weapon?
SWEP.NPCCanPickUp = true -- Can NPCs pick up this weapon from the ground
SWEP.NPCBurstMin = 1 -- Minimum amount of bullets the NPC can fire when firing a burst
SWEP.NPCBurstMax = 1 -- Maximum amount of bullets the NPC can fire when firing a burst
SWEP.NPCFireRate = 1 -- Shoot delay in seconds
SWEP.NPCFireRestTimeMin = 1 -- Minimum amount of time the NPC rests between bursts in seconds
SWEP.NPCFireRestTimeMax = 1 -- Maximum amount of time the NPC rests between bursts in seconds
SWEP.NPCBulletSpreadMult = 1 -- Higher number = worse accuracy
SWEP.NPCReloadSound = "" -- Sound when the NPC reloads the gun
SWEP.NPCShootDistanceMult = 1 -- Multiply the NPCs shoot distance by this number with this weapon


--[[
==================================================================================================
                                           BASIC PRIMARY ATTACK
==================================================================================================
--]]


SWEP.PrimaryShootSound = "Weapon_SMG1.NPC_Single" -- Shoot sound
SWEP.PrimarySpread = 0.02 -- Spread
SWEP.PrimaryDamage = 3 -- Damage
SWEP.Primary.DefaultClip = 30 -- Clipsize for NPCs
SWEP.Primary.Ammo = "SMG1" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types



--[[
==================================================================================================
                                    CUSTOMIZABLE FUNCTIONS
==================================================================================================
--]]


function SWEP:Initialize()
	self:SetHoldType( "smg" )
    self:SetNoDraw(true)
end


function SWEP:PrimaryAttack()
end


--[[
==================================================================================================
                            !!! DON'T USE THE FUNCTIONS BELOW !!!
==================================================================================================
--]]


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