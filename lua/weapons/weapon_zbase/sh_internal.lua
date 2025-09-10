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
	self.InitialHoldType = self:GetHoldType()
	self:Init()
end

function SWEP:OwnerChanged()
	-- Store bullet spread vector
	self.BulletSpread = Vector(self.PrimarySpread, self.PrimarySpread)

	-- Due to my whoopsies and daisies
	-- this workaround is now needed for the
	-- weapon base to function as intended lol
	self.Primary.ClipSize = self.Primary.DefaultClip

	if SERVER then
		local own = self:GetOwner()

		self:CONV_TimerRemove("MeleeWepInstructAI") -- Remove this timer if it exists

		-- SET holdtype
		conv.callNextTick(function()
			if !IsValid(self) || !IsValid(own) then return end

			if own:IsNPC() then
				own:ZBASE_SetHoldType(self, self.NPCHoldType)
			else
				self:SetHoldType(self.InitialHoldType)
			end
		end)

		-- Create a timer that updates the AI of the NPC owner
		-- with behavior for melee weapons
		if own:IsNPC() && self.NPCIsMeleeWep then
			self:CONV_TimerCreate("MeleeWepInstructAI", 0.5, 0, function()
				-- Remove timer if owner went NULL
				if !IsValid(own) then
					self:CONV_TimerRemove("MeleeWepInstructAI")
					return
				end

				self:MeleeInstructAI( own )
			end)
		end
	end
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

-- Get the bullet position with the specified offset
-- Or nil if it could not determine one
function SWEP:GetBulletOffsetPos()
	local own = self:GetOwner()
	if !IsValid(own) then return end

	local boneid = own:LookupBone(self.CustomWorldModel.Bone) -- Right Hand
	if !boneid then return end

	local matrix = own:GetBoneMatrix(boneid)
	if !matrix then return end

	return LocalToWorld(self.Primary.BulletPos.Offset, self.Primary.BulletPos.AngOffset, 
						matrix:GetTranslation(), matrix:GetAngles())
end

function SWEP:PrimaryAttack()
	local own = self:GetOwner()

	if !IsValid(own) then return end

	if own:IsNPC() && self.NPCIsMeleeWep then return end

	-- No ammo
	-- *click*
	if !self:CanPrimaryAttack() then
		-- Notify owner we are dryfiring
		if IsValid(own)  then
			own:CONV_TempVar("bIsDryFiring", true, 0.2)
		end

		return 
	end

	-- Owner is NPC
	if own:IsNPC() then
		-- ..and default primary has not been prevented
		if self:NPCPrimaryAttack() != true then
			-- Do default primary for NPC

			-- Owner || a temporary ent, if we want to adjust the offset
			-- Will fire the bullet
			local bulletDispatcherEnt = own
			local src = own:GetShootPos() -- Bullet start position

			-- Check should use manual positioning
			if self.Primary.BulletPos.ShouldUse == true then
				local offsetpos = self:GetBulletOffsetPos()
				
				-- Got an offset...
				if offsetpos then
					-- Change bullet dispatcher to a temporary ent with the offset position
					bulletDispatcherEnt = ents.Create("zb_temporary_ent")
					bulletDispatcherEnt.ShouldRemain = true
					bulletDispatcherEnt:SetPos(offsetpos)
					bulletDispatcherEnt:SetNoDraw(true)
					-- bulletDispatcherEnt:SetModel("models/props_junk/garbage_coffeemug001a.mdl")
					-- bulletDispatcherEnt:SetMaterial("models/wireframe")
					bulletDispatcherEnt:Spawn()
					SafeRemoveEntityDelayed(bulletDispatcherEnt, 1)
					
					-- Change src to the offset position
					src = offsetpos

					debugoverlay.Axis(src, angle_zero, 20, 2, true)
					debugoverlay.Text(src+vector_up*10, "Bullet start position", 2, false)
				end
			end
			
			local bullet = {
				Attacker = own,
				Inflictor = self,
				Damage = self.PrimaryDamage,
				AmmoType = self.Primary.Ammo,
				Src = src,
				Dir = own:GetAimVector(),
				Spread = self.BulletSpread,
				Tracer = self.Primary.TracerChance,
				TracerName = self.Primary.TracerName,
				Num = self.Primary.NumShots,
			}
			bulletDispatcherEnt:FireBullets(bullet)

			self:NPCShootEffects()
			self:EmitSound(self.PrimaryShootSound)
			self:TakePrimaryAmmo(self.Primary.TakeAmmoPerShot)

			-- Give developer chance to catch ZBase NPC shooting
			if own.IsZBaseNPC then
				own:OnFireWeapon()
			end
		end

	-- Owner is player and default primary has not been prevented
	elseif own:IsPlayer() && self:OnPrimaryAttack() != true then
		-- Default primary logic for players here
		-- None for now
	end
end

function SWEP:TakePrimaryAmmo( num )
	local own = self:GetOwner()

	-- Doesn't use clips
	if self.Weapon:Clip1() <= 0 then 
		own:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
		return
	end

	self:SetClip1( self:Clip1() - num )	
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

function SWEP:WorldMFlash(effectEnt)
	local effectEnt = self

	if self:ShouldDrawFakeModel() then
		effectEnt = self.customWModel -- Client only variable

		-- Only emit effect on client if has fake model
		if SERVER || !IsValid(effectEnt) then
			if SERVER then
				-- Still, emit light on server
				local iFlags = self.Primary.MuzzleFlashFlags
				local col = iFlags==5 && "75 175 255" || "255 125 25"
				ZBaseMuzzleLight( self:GetPos(), 1.5, 256, col )

			end
			
			return 
		end
	end

	if self.Primary.MuzzleFlashPos.ShouldUse then
		if math.random(1, self.Primary.MuzzleFlashChance)==1 then
			local ofs = 	self.Primary.MuzzleFlashPos.Offset
			local angof = 	self.Primary.MuzzleFlashPos.AngOffset

			ZBaseMuzzleFlashAtPos(
				effectEnt:GetPos()+effectEnt:GetForward()*ofs.x+effectEnt:GetRight()*ofs.y+effectEnt:GetUp()*ofs.z, 
				effectEnt:GetAngles()+angof,
				self.Primary.MuzzleFlashFlags, effectEnt
			)
		end

	else
		local att_num = effectEnt:LookupAttachment("muzzle")
		if att_num == 0 then
			att_num = effectEnt:LookupAttachment("0")
		end

		if math.random(1, self.Primary.MuzzleFlashChance)==1 && att_num != 0 then
			ZBaseMuzzleFlash(effectEnt, self.Primary.MuzzleFlashFlags, att_num)
		end

	end
end

function SWEP:WorldShellEject()
	local effectEnt = self

	if self:ShouldDrawFakeModel() then
		effectEnt = self.customWModel -- Client only variable

		-- Only emit effect on client if has fake model
		if SERVER || !IsValid(effectEnt) then return end
	end

	local att = self:GetAttachment(self:LookupAttachment(self.Primary.ShellEject))

	if att then
		-- Attachment found
		local effectdata = EffectData()
		effectdata:SetEntity(effectEnt)
		effectdata:SetOrigin(att.Pos)
		effectdata:SetAngles(att.Ang+self.Primary.ShellAngOffset)
		util.Effect( self.Primary.ShellType, effectdata, true, rf )
	else
		-- No attachment
		local effectdata = EffectData()
		effectdata:SetEntity(effectEnt)
		effectdata:SetOrigin(effectEnt:GetPos())
		effectdata:SetAngles(effectEnt:GetAngles())
		util.Effect( self.Primary.ShellType, effectdata, true, rf )
	end
end

function SWEP:MainEffects()
	-- Muzzle flash
	if self.Primary.MuzzleFlash then
		self:WorldMFlash(effectEnt)
	end

	-- Shell eject
	if self.Primary.ShellEject then
		self:WorldShellEject(effectEnt)
	end
end

function SWEP:NPCShootEffects()
	local own = self:GetOwner()
	if !IsValid(own) then return end 
	
	-- Custom
	local r = self:CustomShootEffects()
	if r == true then
		return
	end

	if self:ShouldDrawFakeModel() then
		net.Start("ZBASE_MuzzleFlash")
		net.WriteEntity(self)
		net.SendPVS(self:GetPos())
	end

	self:MainEffects()
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

-- Called before firing animation events, such as muzzle flashes || shell ejections.
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

-- Called when the weapon entity is reloaded from a Source Engine save (not the Sandbox saves || dupes)
-- || on a changelevel (for example Half-Life 2 campaign level transitions)
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
	return self.NPCBurstMin, self.NPCBurstMax, self.NPCFireRate
end

function SWEP:GetNPCBulletSpread( proficiency )
	return (7 - proficiency)*self.NPCBulletSpreadMult
end

-- This hook is for NPCs, you return what they should try to do with it.
function SWEP:GetCapabilities()
	if self.NPCIsMeleeWep then
		return CAP_WEAPON_MELEE_ATTACK1
	else
		return CAP_WEAPON_RANGE_ATTACK1
	end
end

--[[
==================================================================================================
                            NPC Stuff: Melee Weapon
==================================================================================================
--]]

function SWEP:CanTakeMeleeWepDmg( ent )
    local mtype = ent:GetMoveType()
    return mtype == MOVETYPE_STEP 	-- NPC
    || mtype == MOVETYPE_VPHYSICS 	-- Prop
    || mtype == MOVETYPE_WALK 		-- Player
	|| ent:IsNextBot()
end

-- Melee AI for NPC (own)
function SWEP:MeleeInstructAI( own )
	local ene = own:GetEnemy()
	local validEne = IsValid(ene)

	-- Must have valid enemy
	if !validEne then
		return
	end

	-- Chase enemy
	if !own:IsCurrentSchedule(SCHED_CHASE_ENEMY) then
		own:SetSchedule(SCHED_CHASE_ENEMY)
	end
	
	local ownPos = own:GetPos()
	local enePos = ene:GetPos()
	local meleeAttackDistSqr = (self.NPCMeleeWep_DamageDist*0.85)^2 -- Distance at which we initiate a swing
	local distToSqr = ownPos:DistToSqr(enePos)

	-- Swing when within distance and not playing anim currently
	if distToSqr < meleeAttackDistSqr && !own.DoingPlayAnim then
		local timeUntilMeleeStrike = own.MeleeWeaponAnimations_TimeUntilDamage || 0.5

		-- Do anim
		if own.IsZBaseNPC then
			own:Weapon_MeleeAnim()
		else
			own:ZBASE_SimpleAnimation(ACT_MELEE_ATTACK_SWING)
		end

		-- Do damage
		own:CONV_TimerCreate("MeleeWeaponDamage", timeUntilMeleeStrike, 1, function()
			self:NPCMeleeWeaponDamage()
		end)
	end
end

function SWEP:NPCMeleeWeaponDamage()
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
            dmg:SetDamageForce(own:GetForward()*100)
            dmg:SetDamagePosition(ent:WorldSpaceAABB())
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
		-- Activity translate override
		local override = self.ZBase_ActTranslateOverride[act]
		if isnumber(override) then
			return override
		end
	end

	-- Custom
	local r = self:CustomTranslateActivity( act )
	if r != nil then
		return r
	end

	-- NPC
	if own:IsNPC() then
		local holdType = self:GetHoldType()
		local state = own:GetNPCState()
		local shouldMeleeRun = state==NPC_STATE_ALERT || state==NPC_STATE_COMBAT || IsValid(own.PlayerToFollow)
		local sched = own:GetCurrentSchedule()
		local ene = own:GetEnemy()
		local validEne = IsValid(ene)

		-- Melee weapon activities
		if holdType=="passive" || holdType=="melee" || holdType=="melee2" then
			if own:IsMoving() && own:GetNavType() == NAV_GROUND then
				return ( shouldMeleeRun && ACT_RUN ) || ACT_WALK
			elseif act == ACT_IDLE_PISTOL || act == ACT_IDLE_RELAXED then
				return ACT_IDLE
			elseif act == ACT_IDLE_ANGRY_PISTOL || act == ACT_IDLE_ANGRY then
				return ACT_IDLE_ANGRY_MELEE
			end

			-- Return -1 lol idk why
			-- or return at least so other shit does not run
			return -1
		end

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
                            MODEL DRAWING
==================================================================================================
--]]

function SWEP:ShouldDrawFakeModel()
	local own = self:GetOwner()
	return IsValid(own) && self.CustomWorldModel.Active
end

if CLIENT then
	function SWEP:DrawFakeModel()
		local own = self:GetOwner()

		if self:ShouldDrawFakeModel() then
			if self.customWModel == nil then
				-- New custom view model
				self.customWModel = ClientsideModel(self.WorldModel)
				self.customWModel:SetNoDraw(true)
			else
				-- Specify a good position
				local offsetVec = self.CustomWorldModel.Offset
				local offsetAng = self.CustomWorldModel.AngOffset
				
				local boneid = own:LookupBone(self.CustomWorldModel.Bone) -- Right Hand
				if !boneid then return end

				local matrix = own:GetBoneMatrix(boneid)
				if !matrix then return end

				local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

				self.customWModel:SetPos(newPos)
				self.customWModel:SetAngles(newAng)
				self.customWModel:SetupBones()
				self.customWModel:DrawModel()
				self:DrawShadow(false)
			end
		elseif self.customWModel != nil then
			self.customWModel:Remove()
			self.customWModel = nil
		end
	end

	function SWEP:DrawWorldModel( flags )
		self:DrawFakeModel()

		local r = self:CustomDrawWorldModel( flags )
		if r != nil then
			return
		end

		if !self:ShouldDrawFakeModel() then
			self:DrawModel()
		end
	end

	-- Called when we are about to draw the translucent world model.
	function SWEP:DrawWorldModelTranslucent( flags )
		self:DrawFakeModel()

		local r = self:CustomDrawWorldModelTranslucent( flags )
		if r != nil then
			return
		end

		if !self:ShouldDrawFakeModel() then
			self:DrawModel()
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
end