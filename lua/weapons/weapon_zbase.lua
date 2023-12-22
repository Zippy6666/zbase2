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
SWEP.Primary.TakeAmmoPerShot = 1 -- Ammo to take for each shot
SWEP.Primary.NumShots = 1 -- Number of bullets per shot
SWEP.Primary.ShellEject = false -- Set to the name of an attachment to enable shell ejection
SWEP.Primary.ShellType = "ShellEject" -- https://wiki.facepunch.com/gmod/Effects


--[[
==================================================================================================
                                    CUSTOMIZABLE FUNCTIONS
==================================================================================================
--]]


function SWEP:Initialize()
	self:SetHoldType( "smg" )
end


function SWEP:OnPrimaryAttack()

    local effectdata = EffectData()
    effectdata:SetFlags(1)
    effectdata:SetEntity(self)
    util.Effect( "MuzzleFlash", effectdata )


	if self.Primary.ShellEject then

		local att = self:GetAttachment(self:LookupAttachment(self.Primary.ShellEject))

		if att then
			local effectdata = EffectData()
			effectdata:SetEntity(self)
			effectdata:SetOrigin(att.Pos)
			effectdata:SetAngles(att.Ang)
			util.Effect( "ShellEject", effectdata )
		end
	
	end

end


function SWEP:PrimaryAttack()
	self:OnPrimaryAttack()


	local bullet = {
		Attacker = self:GetOwner(),
		Inflictor = self,
		Damage = self.PrimaryDamage,
		AmmoType = self.Primary.Ammo,
		Src = self:GetOwner():GetShootPos(),
		Dir = self:GetOwner():GetAimVector(),
		Spread = Vector(self.PrimarySpread, self.PrimarySpread),
		Tracer = 2,
		Num = self.Primary.NumShots,
	}
	self:FireBullets(bullet)


	if self.Primary.TakeAmmoPerShot > 0 then
		self:TakePrimaryAmmo(self.Primary.TakeAmmoPerShot)
	end


	self:EmitSound(self.PrimaryShootSound)
end


--[[
==================================================================================================
                            !!! DON'T USE THE FUNCTIONS BELOW !!!
==================================================================================================
--]]


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