AddCSLuaFile()


-- Variables --


-- General
SWEP.Base = "weapon_base" -- "weapon_zbase"
SWEP.IsZBaseSWEP = true
SWEP.PrintName = "ZBase"
SWEP.Author = "Zippy"
SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" )

-- Bullet
SWEP.Primary.Damage = 5 -- The damage of the bullet
SWEP.Primary.NumBullets = 1 -- Number of bullets per shot
SWEP.Primary.BulletForce = 15 -- Amount of force that the bullet puts on physics

-- Ammo
SWEP.Primary.ClipSize = 30 -- Clip size

-- Sound
SWEP.Primary.ShootSound = "" -- Shoot sound
SWEP.Primary.ShootSoundLevel = 140 -- Shoot sounds level

-- Cooldown
SWEP.Primary.ShootDelay = 1 -- Shoot cooldown in seconds
SWEP.Primary.ShootDelayMax = false -- If set to a number, the shoot cooldown will be a random number between this and "SWEP.Primary.ShootDelay"

-- Burst
SWEP.Primary.Burst = false -- Fire this amount of bullets before doing the "SWEP.Primary.BurstCoolDown", this will ignore "SWEP.Primary.ShootDelayMax", false to disable
SWEP.Primary.BurstMax = false -- If set to a number, the burst will fire a random number of bullets between this and "SWEP.Primary.Burst"
SWEP.Primary.BurstCoolDownMin = 0.3 -- Minimum cooldown between bursts in seconds
SWEP.Primary.BurstCoolDownMax = 0.6 -- Maximum cooldown between bursts in seconds

-- Spread
-- Remember that the spread mostly depends on the SNPCs weapon proficiency
-- This should only be high for shotguns really, or crappy inaccurate weapons
SWEP.Primary.Spread = 0

-- Holdtype
SWEP.HoldType = "smg" -- https://wiki.facepunch.com/gmod/Hold_Types

-- Effects
SWEP.TracerEffectName = nil -- https://wiki.facepunch.com/gmod/Effects
SWEP.TracerChance = 2 -- 1/X
SWEP.ZBase_MuzzleFlashFlag = 1 -- 1 = Normal, 2 = AR2, 2 = Shotgun

--------------------------------------------------------------------------=#


-- Functions that you can change --


--------------------------------------------------------------------------=#
function SWEP:CustomMuzzleFlash()

	local own = self:GetOwner()
	local ang = own.IsZBaseSNPC && own:ZBase_AimVector():Angle() or self:GetAttachment(self:LookupAttachment("muzzle")).Ang

	local data = EffectData()
	data:SetStart(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
	data:SetAngles(ang)
	data:SetEntity(self)
	data:SetFlags(self.ZBase_MuzzleFlashFlag)
	util.Effect("zbase_muzzleflash", data, true, true)


end
--------------------------------------------------------------------------=#


-- DON'T CHANGE/USE ANYTING BELOW THIS LINE!!


--------------------------------------------------------------------------=#
function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

	if SERVER then

		-- Workaround to counter some bugs, such as shoot position for NPCs being weird
		self.bulletprop1 = ents.Create("base_gmodentity")
		self.bulletprop1:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self.bulletprop1:SetPos(self:GetAttachment(self:LookupAttachment("Muzzle")).Pos)
		self.bulletprop1:SetParent(self, self:LookupAttachment("Muzzle"))
		self.bulletprop1:SetSolid(SOLID_NONE)
		self.bulletprop1:AddEFlags(EFL_DONTBLOCKLOS)
		self.bulletprop1:SetNoDraw(true)
		self.bulletprop1:Spawn()
		self.bulletprop1.ZBaseBulletProp = true
		self.bulletprop1.Weapon = self

		self:SetNextBurst()

	end

end
--------------------------------------------------------------------------=#
function SWEP:FireAnimationEvent()
	-- Prevent all animation events
	return true
end
--------------------------------------------------------------------------=#
function SWEP:SetNextBurst()
	self.BurstBulletsFired = 0
	if self.Primary.Burst then
		self.BurstBulletsToFire = self.Primary.BurstMax && math.random(self.Primary.Burst, self.Primary.BurstMax) or self.Primary.Burst
	end
end
--------------------------------------------------------------------------=#
function SWEP:Reload()
end
--------------------------------------------------------------------------=#
function SWEP:CanBePickedUpByNPCs()
	return true
end
--------------------------------------------------------------------------=#
function SWEP:PrimaryAttack()
	local own = self:GetOwner()

	if own.IsZBaseSNPC && !WEAPON_ZBASE_CALL then return end

	-- Bullet
	local bulletDir = IsValid(own) && (own.IsZBaseSNPC && own:ZBase_AimVector() or own:GetAimVector()) or Vector()
	self.bulletprop1:FireBullets({
		Damage = self.Primary.Damage,
		Num = self.Primary.NumBullets,
		Force = self.Primary.BulletForce,
		Dir = bulletDir,
		Spread = Vector( self.Primary.Spread, self.Primary.Spread, 0 ),
		Src = self.bulletprop1:GetPos(),
		Attacker = IsValid(own) && own or self,
		IgnoreEntity = own,
		TracerName = self.TracerEffectName,
		Tracer = self.TracerChance
	})

	-- Sound
	self:EmitSound( self.Primary.ShootSound, self.ShootSoundLevel, math.random(95, 105) )

	-- Muzzleflash
	self:CustomMuzzleFlash()

	-- Logic
    self:TakePrimaryAmmo(1)

	local cooldown = ((self.Primary.ShootDelayMax && !self.Primary.Burst) && math.Rand(self.Primary.ShootDelay, self.Primary.ShootDelayMax)) or self.Primary.ShootDelay

	self.BurstBulletsFired = self.BurstBulletsFired + 1
	if self.BurstBulletsFired == self.BurstBulletsToFire then
		self:SetNextBurst()
		cooldown = math.Rand(self.Primary.BurstCoolDownMin, self.Primary.BurstCoolDownMax)
	end

	self:SetNextPrimaryFire( CurTime() + cooldown )

end
--------------------------------------------------------------------------=#
hook.Add("EntityTakeDamage", "ZBase_FixWeaponStuff", function( ent, dmginfo )

	-- Change inflictor for bullet prop to its owner (the weapon)
	local infl = dmginfo:GetInflictor()
	if infl.ZBaseBulletProp then
		dmginfo:SetInflictor(infl.Weapon)
	end

end)
--------------------------------------------------------------------------=#
function SWEP:GetNPCRestTimes()
	-- Handles the time between bursts
	-- Min rest time in seconds, max rest time in seconds
	return self.Primary.ShootDelay
end
--------------------------------------------------------------------------=#
function SWEP:GetNPCBurstSettings()
	-- Handles the burst settings
	-- Minimum amount of shots, maximum amount of shots, and the delay between each shot
	-- The amount of shots can end up lower than specificed
	return 1, 1, 0
end
--------------------------------------------------------------------------=#
function SWEP:GetNPCBulletSpread( proficiency )
	-- Handles the bullet spread based on the given proficiency
	-- return value is in degrees
	return 0
end
--------------------------------------------------------------------------=#