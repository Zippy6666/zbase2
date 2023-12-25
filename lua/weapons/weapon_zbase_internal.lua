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
                            Init/Think
==================================================================================================
--]]


function SWEP:Initialize()

	self:Init()
	
end


--[[
==================================================================================================
                            Primary Attack
==================================================================================================
--]]



function SWEP:PrimaryAttack()

	local own = self:GetOwner()
	local CanAttack = self:CanPrimaryAttack()


	if own.IsZBaseNPC && !own.ZBWepSys_AllowShoot then return end


	if own:IsPlayer() && self:OnPrimaryAttack()!=true && CanAttack then

		-- idk xd

	elseif own:IsNPC() && self:NPCPrimaryAttack()!=true && CanAttack then
	
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
                            Removal
==================================================================================================
--]]


function SWEP:OnRemove()

	if IsValid(self.NPCWorldModelOverride) then
		self.NPCWorldModelOverride:Remove()
	end


	self:CustomOnRemove()

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


end