AddCSLuaFile()


SWEP.Base = "weapon_base"
SWEP.IsZBaseWeapon = true
SWEP.PrintName = "weapon_zbase_internal"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.NPCSpawnable = false -- Add to NPC weapon list


--[[
==================================================================================================
                            INIT/THINK
==================================================================================================
--]]


function SWEP:Initialize()

	self:Init()
	
end


	-- Called when the SWEP should set up its Data Tables.
function SWEP:SetupDataTables()
end


	-- Called when the swep thinks. This hook won't be called during the deploy animation and when using Weapon:DefaultReload.
	-- Works only in players hands. Doesn't work in NPCs hands. Despite being a predicted hook, this hook is called clientside in single player,
	-- however it will not be recognized as a predicted hook to Player:GetCurrentCommand.
	-- This hook will be called before Player movement is processed on the client, and after on the server.
	-- This will not be run during deploy animations after a serverside-only deploy. This usually happens after picking up and dropping an object with +use.
function SWEP:Think()
end


--[[
==================================================================================================
                            PRIMARY ATTACK
==================================================================================================
--]]



function SWEP:PrimaryAttack()

	local own = self:GetOwner()
	local CanAttack = self:CanPrimaryAttack()


	if own.IsZBaseNPC && !own.ZBWepSys_AllowShoot then return end


	if own:IsPlayer() && self:OnPrimaryAttack()!=true && CanAttack then

		-- idk xd

	elseif own:IsNPC() && self:NPCPrimaryAttack()!=true && CanAttack then


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


		self:ShootEffects()

	end

end


--[[
==================================================================================================
                            SECONDARY
==================================================================================================
--]]


function SWEP:SecondaryAttack()
end


--[[
==================================================================================================
                            EFFECTS
==================================================================================================
--]]


-- A convenience function to create shoot effects.
function SWEP:ShootEffects()
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
	self:EmitSound(self.PrimaryShootSound)
end


-- Called so the weapon can override the impact effects it makes.
function SWEP:DoImpactEffect( tr, damageType )
end


--[[
==================================================================================================
                            OPTIONS I GUESS IDK
==================================================================================================
--]]


-- Sets the hold type of the weapon. This must be called on both the server and the client to work properly.
-- NOTE: You should avoid calling this function and call Weapon:SetHoldType now.
function SWEP:SetWeaponHoldType( name )
end


-- Should this weapon be dropped when its owner dies? This only works if the player has Player:ShouldDropWeapon set to true.
function SWEP:ShouldDropOnDie()
end


--[[
==================================================================================================
                            EVENT TYPE SHIT
==================================================================================================
--]]


	-- Called when another entity fires an event to this entity.
function SWEP:AcceptInput( inputName, activator, called, data )
end


	-- Called before firing animation events, such as muzzle flashes or shell ejections.
	-- This will only be called serverside for 3000-range events, and clientside for 5000-range and other events.
function SWEP:FireAnimationEvent( pos, ang, event, options, source )
end


	-- Called when the engine sets a value for this scripted weapon.
	-- See GM:EntityKeyValue for a hook that works for all entities. See ENTITY:KeyValue for an hook that works for scripted entities.
function SWEP:KeyValue( key, value )
end


	-- Called when the weapon entity is reloaded from a Source Engine save (not the Sandbox saves or dupes)
	-- or on a changelevel (for example Half-Life 2 campaign level transitions)
function SWEP:OnRestore()
end


	-- Called when weapon is dropped or picked up by a new player.
	-- This can be called clientside for all players on the server if the weapon has no owner and is picked up. See also WEAPON:OnDrop.
function SWEP:OwnerChanged()
end


	-- Called whenever the weapons Lua script is reloaded.
function SWEP:OnReloaded()
end


--[[
==================================================================================================
                            NPC Stuff
==================================================================================================
--]]


function SWEP:CanBePickedUpByNPCs()
	return self.NPCCanBePickedUp
end


function SWEP:GetNPCRestTimes()
	return self.NPCFireRestTimeMin, self.NPCFireRestTimeMax
end


function SWEP:ZBaseGetNPCBurstSettings()
	return self.NPCBurstMin, self.NPCBurstMax, self.NPCFireRate
end


function SWEP:GetNPCBurstSettings()
	
	local own = self:GetOwner()

	if IsValid(own) && own.IsZBaseNPC then
		return 0, 0, math.huge
	else
		return self.NPCBurstMin, self.NPCBurstMax, self.NPCFireRate
	end

end


function SWEP:GetNPCBulletSpread( proficiency )
	return (7 - proficiency)*self.NPCBulletSpreadMult
end


	-- This hook is for NPCs, you return what they should try to do with it.
function SWEP:GetCapabilities()
end


--[[
==================================================================================================
                            NPC Stuff: Activity Translate
==================================================================================================
--]]


function SWEP:TranslateActivity( act )

	local CustomAct = self:CustomTranslateActivity( act )
	if CustomAct != nil then
		return CustomAct
	end


	local own = self:GetOwner()


	if own.ZBWepSys_ActivityTranslate && own.ZBWepSys_ActivityTranslate[act] then
		return own.ZBWepSys_ActivityTranslate[act]
	end


	if own:IsNPC() then

		if self.ActivityTranslateAI[ act ] then
			return self.ActivityTranslateAI[ act ]
		end

		return -1

	end


	if self.ActivityTranslate[ act ] != nil then

		return self.ActivityTranslate[ act ]

	end


	return -1

end


--[[
==================================================================================================
                            CLIENT
==================================================================================================
--]]


if CLIENT then


	function SWEP:DrawWorldModel()

		local own = self:GetOwner()


		if IsValid(own) && own:GetNWBool("IsZBaseNPC") then

			if IsValid(self.NPCWorldModelOverride) then

				if !self.NPCWorldModelOverride.SetupDone then

					self.NPCWorldModelOverride:SetNoDraw(true)
					self.NPCWorldModelOverride:AddEffects(EF_BONEMERGE)
					self.NPCWorldModelOverride.SetupDone = true

				end


				self.NPCWorldModelOverride:SetParent(own)
				self.NPCWorldModelOverride:DrawModel()

			else

				local modelname = self:GetNWString("ZBaseNPCWorldModel", nil)


				if modelname then

					self.NPCWorldModelOverride = ClientsideModel( modelname )

					
				end
			
			end

		end

	end



	-- Called when we are about to draw the translucent world model.
	function SWEP:DrawWorldModelTranslucent( flags )
	end


end


--[[
==================================================================================================
                            Removal
==================================================================================================
--]]


function SWEP:OnRemove()

	if IsValid(self.NPCWorldModelOverride) then
		self.NPCWorldModelOverride:Remove()
	end


	self:CustomOnRemove()

end


































































































