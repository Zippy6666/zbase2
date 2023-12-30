AddCSLuaFile()


--[[
==================================================================================================
                    !! YOU GOT NOTHING TO DO HERE BOYE, GO BACK TO SHARED !!
==================================================================================================
--]]



SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = true -- Add to NPC weapon list


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

	self:CustomSetupDataTables()

end


	-- Called when the swep thinks. This hook won't be called during the deploy animation and when using Weapon:DefaultReload.
	-- Works only in players hands. Doesn't work in NPCs hands. Despite being a predicted hook, this hook is called clientside in single player,
	-- however it will not be recognized as a predicted hook to Player:GetCurrentCommand.
	-- This hook will be called before Player movement is processed on the client, and after on the server.
	-- This will not be run during deploy animations after a serverside-only deploy. This usually happens after picking up and dropping an object with +use.
function SWEP:Think()

	self:CustomThink()

end


--[[
==================================================================================================
                            PRIMARY ATTACK
==================================================================================================
--]]



function SWEP:PrimaryAttack()

	local own = self:GetOwner()
	local CanAttack = self:CanPrimaryAttack()


	if own.IsZBaseNPC && !own.ZBWepSys_AllowShoot then return end -- muy imporante


	if own:IsPlayer() && self:OnPrimaryAttack()!=true && CanAttack then

		-- idk xd

	elseif own:IsNPC() && self:NPCPrimaryAttack()!=true && CanAttack && !self.NPCIsMeleeWep then


		local bullet = {
			Attacker = self:GetOwner(),
			Inflictor = self,
			Damage = self.PrimaryDamage,
			AmmoType = self.Primary.Ammo,
			Src = self:GetOwner():GetShootPos(),
			Dir = self:GetOwner():GetAimVector(),
			Spread = Vector(self.PrimarySpread, self.PrimarySpread),
			Tracer = self.Primary.TracerChance,
			TracerName = self.Primary.TracerName,
			Num = self.Primary.NumShots,
		}
		self:FireBullets(bullet)


		if self.Primary.TakeAmmoPerShot > 0 then
			-- self:TakePrimaryAmmo(self.Primary.TakeAmmoPerShot)
		end


		self:ShootEffects()
	

		-- Sound
		self:EmitSound(self.PrimaryShootSound)

	end

end


--[[
==================================================================================================
                            SECONDARY
==================================================================================================
--]]


function SWEP:SecondaryAttack()
	self:CustomSecondaryAttack()
end


--[[
==================================================================================================
                            EFFECTS
==================================================================================================
--]]


-- A convenience function to create shoot effects.
function SWEP:ShootEffects()

	-- Custom
	local r = self:CustomShootEffects()
	if r == true then
		return
	end


	local modelname = self:GetNWString("ZBaseNPCWorldModel", nil)
	local CustomModel = modelname!=nil && modelname!=""
	local EffectEnt = CustomModel && ents.Create("base_gmodentity") or self
	local own = self:GetOwner()


	-- Model override effect fix, create temporary a new ent with the same model
	if CustomModel && IsValid(EffectEnt) && IsValid(own) then
		EffectEnt:SetModel(modelname)
		EffectEnt:SetPos(own:GetPos())
		EffectEnt:SetParent(own)
		EffectEnt:AddEffects(EF_BONEMERGE)
		EffectEnt:Spawn()
	end


	-- Muzzle flash
	if self.Primary.MuzzleFlash then
		local effectdata = EffectData()
		effectdata:SetFlags(self.Primary.MuzzleFlashFlags)
		effectdata:SetEntity(EffectEnt)
		util.Effect( "MuzzleFlash", effectdata, true, true )
	end
	

	-- Shell eject
	if self.Primary.ShellEject then

		local att = EffectEnt:GetAttachment(EffectEnt:LookupAttachment(self.Primary.ShellEject))

		if att then
			local effectdata = EffectData()
			effectdata:SetEntity(EffectEnt)
			effectdata:SetOrigin(att.Pos)
			effectdata:SetAngles(att.Ang+self.Primary.ShellAngOffset)
			util.Effect( self.Primary.ShellType, effectdata, true, true )
		end
	
	end


	if CustomModel then
		EffectEnt:SetNoDraw(true)
		SafeRemoveEntityDelayed(EffectEnt, 0.5)
	end

end


-- Called so the weapon can override the impact effects it makes.
function SWEP:DoImpactEffect( tr, damageType )

	local r = self:CustomDoImpactEffect( tr, damageType )
	if r == true then
		return
	end

end


--[[
==================================================================================================
                            OPTIONS I GUESS IDK
==================================================================================================
--]]


-- Should this weapon be dropped when its owner dies? This only works if the player has Player:ShouldDropWeapon set to true.
function SWEP:ShouldDropOnDie()

	local r = self:CustomShouldDropOnDie()
	if r != nil then
		return r
	end

end


--[[
==================================================================================================
                            EVENT TYPE SHIT
==================================================================================================
--]]


	-- Called when another entity fires an event to this entity.
function SWEP:AcceptInput( inputName, activator, called, data )

	local r = self:CustomAcceptInput( inputName, activator, called, data )
	if r != nil then
		return r
	end

end


	-- Called before firing animation events, such as muzzle flashes or shell ejections.
	-- This will only be called serverside for 3000-range events, and clientside for 5000-range and other events.
function SWEP:FireAnimationEvent( pos, ang, event, options, source )

	local r = self:CustomFireAnimationEvent( pos, ang, event, options, source )
	if r != nil then
		return r
	end

end


	-- Called when the engine sets a value for this scripted weapon.
	-- See GM:EntityKeyValue for a hook that works for all entities. See ENTITY:KeyValue for an hook that works for scripted entities.
function SWEP:KeyValue( key, value )

	local r = self:CustomKeyValue( key, value )
	if r != nil then
		return r
	end

end


	-- Called when the weapon entity is reloaded from a Source Engine save (not the Sandbox saves or dupes)
	-- or on a changelevel (for example Half-Life 2 campaign level transitions)
function SWEP:OnRestore()
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
	if self.NPCIsMeleeWep then
		return bit.bor( CAP_WEAPON_MELEE_ATTACK1, CAP_INNATE_MELEE_ATTACK1 )
	else
		return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 )
	end
end


--[[
==================================================================================================
                            NPC Stuff: Melee Weapon
==================================================================================================
--]]


function SWEP:CanTakeMeleeWepDmg( ent )
    local mtype = ent:GetMoveType()
    return mtype == MOVETYPE_STEP -- NPC
    or mtype == MOVETYPE_VPHYSICS -- Prop
    or mtype == MOVETYPE_WALK -- Player
end


function SWEP:NPCMeleeWeaponDamage(dmgData)
	local own = self:GetOwner()


	if !IsValid(own) then return end


    local ownerpos = own:WorldSpaceCenter()
    local soundEmitted = false
    local hurtEnts = {}


    for _, ent in ipairs(ents.FindInSphere(ownerpos, self.NPCMeleeWep_DamageDist)) do
        if ent == own then continue end
        if own.GetNPCState && own:GetNPCState() == NPC_STATE_DEAD then continue end
        if !own:Visible(ent) then continue end


		local disp = own:Disposition(ent)
        local entpos = ent:WorldSpaceCenter()
        local undamagable = (ent:Health()==0 && ent:GetMaxHealth()==0)


        -- Angle check
        if self.NPCMeleeWep_DamageAngle != 360 then
            local yawDiff = math.abs( own:WorldToLocalAngles( (entpos-ownerpos):Angle() ).Yaw )*2
            if self.NPCMeleeWep_DamageAngle < yawDiff then continue end
        end


        if !self:CanTakeMeleeWepDmg(ent) then
            continue
        end


        -- Damage
        if !undamagable && disp != D_LI then
            local dmg = DamageInfo()
            dmg:SetAttacker(own)
            dmg:SetInflictor(self)
            dmg:SetDamage(ZBaseRndTblRange(self.NPCMeleeWep_Damage))
            dmg:SetDamageType(self.NPCMeleeWep_DamageType)
            ent:TakeDamageInfo(dmg)
        end
    

        -- Sound
        if !soundEmitted && disp != D_NU then
            ent:EmitSound(self.NPCMeleeWep_HitSound)
            soundEmitted = true
        end

        table.insert(hurtEnts, ent)
    end


	self:OnNPCMeleeWeaponDamage( hurtEnts )


    return hurtEnts
end


--[[
==================================================================================================
                            NPC Stuff: Activity Translate
==================================================================================================
--]]


function SWEP:TranslateActivity( act )
	local own = self:GetOwner()


	-- ZBase
	if own.IsZBaseNPC then

		
		if self:SelectWeightedSequence(act) == -1 then

			-- Temporary fix for combines, might do advanced system later
			if act==ACT_WALK_PISTOL then
				return ACT_WALK_AIM_RIFLE
			elseif act==ACT_RUN_PISTOL then
				return ACT_RUN_AIM_RIFLE
			end

		end

	

		if act == ACT_RANGE_ATTACK1 && !own.ZBWepSys_AllowRange1Translate then

			return ACT_IDLE

		end

	end


	-- Custom
	local r = self:CustomTranslateActivity( act )
	if r != nil then
		return r
	end



	-- NPC
	if own:IsNPC() then

		if self.ActivityTranslateAI[ act ] then
			return self.ActivityTranslateAI[ act ]
		end

		return -1

	end


	-- Player
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


	function SWEP:DrawWorldModel( flags )

		local r = self:CustomDrawWorldModel( flags )
		if r != nil then
			return
		end



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


				self:DrawModel()
			
			end
	
		else

			self:DrawModel()

		end

	end



	-- Called when we are about to draw the translucent world model.
	function SWEP:DrawWorldModelTranslucent( flags )

		local r = self:CustomDrawWorldModelTranslucent( flags )
		if r != nil then
			return
		end

	end


end


--[[
==================================================================================================
                            Removal
==================================================================================================
--]]


function SWEP:OnRemove()

	self:CustomOnRemove()


	if IsValid(self.NPCWorldModelOverride) then
		self.NPCWorldModelOverride:Remove()
	end

end


































































































