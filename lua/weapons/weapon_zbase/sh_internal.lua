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
	self.BulletSpread = Vector(self.PrimarySpread, self.PrimarySpread)
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
	if !IsValid(own) then return end
	
	local CanAttack = self:CanPrimaryAttack()

	if own.IsZBaseNPC && !own.ZBWepSys_AllowShoot then return end -- muy imporante

	if own:IsNPC() && self:NPCPrimaryAttack()!=true && CanAttack && !self.NPCIsMeleeWep then

		local bullet = {
			Attacker = own,
			Inflictor = self,
			Damage = self.PrimaryDamage,
			AmmoType = self.Primary.Ammo,
			Src = own:GetShootPos(),
			Dir = own:GetAimVector(),
			Spread = self.BulletSpread,
			Tracer = self.Primary.TracerChance,
			TracerName = self.Primary.TracerName,
			Num = self.Primary.NumShots,
		}
		own:FireBullets(bullet)

		if !self.IsZBaseNPC && self.Primary.TakeAmmoPerShot > 0 then
			self:TakePrimaryAmmo(self.Primary.TakeAmmoPerShot)
		end

		self:NPCShootEffects()
	
		-- Sound
		self:EmitSound(self.PrimaryShootSound)

	elseif own:IsPlayer() && self:OnPrimaryAttack()!=true && CanAttack then
	end
end

function SWEP:TakePrimaryAmmo( num )
	local own = self:GetOwner()

	-- Doesn't use clips
	if !own.IsZBaseNPC && self.Weapon:Clip1() <= 0 then 
	
		if self:Ammo1() <= 0 then return end


		own:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
		return

	end
	
	if own.IsZBaseNPC then

		own.ZBWepSys_PrimaryAmmo = own.ZBWepSys_PrimaryAmmo - num
		
	else

		self.Weapon:SetClip1( self.Weapon:Clip1() - num )	

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

function SWEP:NPCShootEffects()
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
		self:DeleteOnRemove(EffectEnt)
	end

	-- Muzzle flash
	local att_num = EffectEnt:LookupAttachment("muzzle")
	if IsValid(EffectEnt) && self.Primary.MuzzleFlash && math.random(1, self.Primary.MuzzleFlashChance)==1 && att_num != 0 then

		if ZBCVAR.MMODMuzzle:GetBool() then
			local particle = (self.Primary.MuzzleFlashFlags == 1 && "hl2mmod_muzzleflash_npc_pistol")
			or (self.Primary.MuzzleFlashFlags == 5 && "hl2mmod_muzzleflash_npc_ar2")
			or (self.Primary.MuzzleFlashFlags == 7 && "hl2mmod_muzzleflash_npc_shotgun")
			if particle then ParticleEffectAttach( particle, PATTACH_POINT_FOLLOW, EffectEnt, att_num ) end
		else
			local effectdata = EffectData()
			effectdata:SetFlags(self.Primary.MuzzleFlashFlags)
			effectdata:SetEntity(EffectEnt)
			util.Effect( "MuzzleFlash", effectdata, true, true )
		end

		if ZBCVAR.MuzzleLight:GetBool() then
			local att = EffectEnt:GetAttachment(att_num)
			local col = self.Primary.MuzzleFlashFlags==5 && "75 175 255" or "255 175 75"

			ZBaseMuzzleLight( att.Pos, .5, 256, col )
		end
	end
	
	-- Shell eject
	if self.Primary.ShellEject then

		local att = EffectEnt:GetAttachment(EffectEnt:LookupAttachment(self.Primary.ShellEject))

		if att then
			local effectdata = EffectData()
			effectdata:SetEntity(EffectEnt)
			effectdata:SetOrigin(att.Pos)
			effectdata:SetAngles(att.Ang+self.Primary.ShellAngOffset)
			util.Effect( self.Primary.ShellType, effectdata, true, rf )
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
	
	-- local own = self:GetOwner()

	-- if IsValid(own) && own.IsZBaseNPC then
	-- 	return 0, 0, math.huge
	-- else
	-- 	return self.NPCBurstMin, self.NPCBurstMax, self.NPCFireRate
	-- end

	return self.NPCBurstMin, self.NPCBurstMax, self.NPCFireRate

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
	or ent:IsNextBot() -- Bextbit
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

		local returnValue = own:ZBWepSys_TranslateAct(act, self.ActivityTranslateAI)
		if isnumber(returnValue) then
			return returnValue
		end

		-- Melee weapon activities
		local holdType = self:GetHoldType()
		local state = own:GetNPCState()
		local meleeActOverride
		if ( holdType=="passive" or holdType=="melee" or holdType=="melee2" ) then
			if own:IsMoving() && own:GetNavType() == NAV_GROUND then
				local shouldMeleeRun = (state==NPC_STATE_ALERT or state==NPC_STATE_COMBAT or IsValid(own.PlayerToFollow))
				meleeActOverride = ( shouldMeleeRun && ACT_RUN ) or ACT_WALK
			elseif act == ACT_IDLE_PISTOL or act == ACT_IDLE_RELAXED then
				return ACT_IDLE
			elseif act == ACT_IDLE_ANGRY_PISTOL or act == ACT_IDLE_ANGRY then
				return ACT_IDLE_ANGRY_MELEE
			end
		end

		-- No walk/run animations? Maybe it has weapon running animations
		if meleeActOverride && own:IsMoving() && own:SelectWeightedSequence(meleeActOverride) == -1 then
			meleeActOverride = ( (state==NPC_STATE_ALERT or state==NPC_STATE_COMBAT) && ACT_RUN_RIFLE ) or ACT_WALK_RIFLE
		end

		if isnumber(meleeActOverride) then
			return meleeActOverride
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
					self.NPCWorldModelOverride:AddEffects(EF_BONEMERGE_FASTCULL) -- dunno wtf this does but it fixed the leg jankin so
					self.NPCWorldModelOverride.SetupDone = true

				end

				self.NPCWorldModelOverride:SetParent(own)
				self.NPCWorldModelOverride:DrawModel()
			else
				local modelname = self:GetNWString("ZBaseNPCWorldModel", false)

				if modelname then
					self.NPCWorldModelOverride = ClientsideModel( modelname )
				else
					self:DrawModel()	
				end
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
                            PreRegisterSWEP
==================================================================================================
--]]

-- Add ZBASE SWEPS to npc weapon menu if we should
hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )
	if swep.IsZBaseWeapon && class!="weapon_zbase" && swep.NPCSpawnable then
		list.Add( "NPCUsableWeapons", { class = class, title = swep.PrintName.." ("..class..")" } )
        table.insert(ZBaseNPCWeps, class)
	end
end)

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