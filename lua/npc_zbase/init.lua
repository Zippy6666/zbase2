local NPC = FindZBaseTable(debug.getinfo(1,'S'))


        -- GENERAL --

-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {}

NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.BloodColor = BLOOD_COLOR_RED -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER	

NPC.SightDistance = 7000 -- Sight distance
NPC.StartHealth = 50 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour

NPC.ZBaseFaction = "none" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"

-- Hitgroups with armor:
NPC.HasArmor = {
    [HITGROUP_GENERIC] = false,
    [HITGROUP_HEAD] = false,
    [HITGROUP_CHEST] = false,
    [HITGROUP_STOMACH] = false,
    [HITGROUP_LEFTARM] = false,
    [HITGROUP_RIGHTARM] = false,
    [HITGROUP_LEFTLEG] = false,
    [HITGROUP_RIGHTLEG] = false,
    [HITGROUP_GEAR] = false,
}
NPC.ArmorPenChance = 4 -- 1/x Chance that the armor is penetrated
NPC.ArmorAlwaysPenDamage = 40 -- Always penetrate the armor if the damage is more than this
NPC.ArmorPenDamageMult = 1.5 -- Multiply damage by this amount if a armored hitgroup is penetrated
NPC.ArmorHitSpark = true -- Do a spark on armor hit

-- Extra capabilities
-- List of capabilities: https://wiki.facepunch.com/gmod/Enums/CAP
NPC.ExtraCapabilities = {
    CAP_OPEN_DOORS, -- Can open regular doors
    CAP_MOVE_JUMP, -- Can jump1
}

 -- Keyvalues
NPC.KeyValues = {} -- Ex. NPC.KeyValues = {SquadName="cool squad", citizentype=CT_REBEL}

NPC.CallForHelp = true -- Can this NPC call their faction allies for help (even though they aren't in the same squad)?
NPC.CallForHelpDistance = 2000 -- Call for help distance


---------------------------------------------------------------------------------------------------------------------=#



        -- CUSTOM SOUNDS --
        -- Use sound scripts to alter pitch and level etc..

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC, use ZBaseEmitSound instead of EmitSound if this is set to true!
NPC.UseCustomSounds = false -- Should the NPC be able to use custom sounds?
NPC.IdleSound_OnlyNearAllies = false -- Only do IdleSounds if there is another NPC in the same faction nearby

NPC.AlertSounds = "" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "" -- Sounds emitted while there is no enemy
NPC.IdleSounds_HasEnemy = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "" -- Sounds emitted on hurt
NPC.DeathSounds = "" -- Sounds emitted on death
NPC.KilledEnemySound = "" -- Sounds emitted when the NPC kills an enemy

-- Sound cooldowns {min, max}
NPC.IdleSoundCooldown = {2, 7}
NPC.IdleSounds_HasEnemyCooldown = {2, 7}
NPC.PainSoundCooldown = {1, 2.5}


---------------------------------------------------------------------------------------------------------------------=#



        -- Functions you can change --

---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the NPC is created --
function NPC:CustomInitialize() end
---------------------------------------------------------------------------------------------------------------------=#

    -- Called continiously --
function NPC:CustomThink() end
---------------------------------------------------------------------------------------------------------------------=#

    -- On NPC hurt, dmginfo:ScaleDamage(0) to prevent damage --
    -- HitGroup = HITGROUP_GENERIC || HITGROUP_HEAD || HITGROUP_CHEST || HITGROUP_STOMACH || HITGROUP_LEFTARM
    -- || HITGROUP_RIGHTARM || HITGROUP_LEFTLEG || HITGROUP_RIGHTLEG || HITGROUP_GEAR
function NPC:CustomTakeDamage( dmginfo, HitGroup ) end
---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the NPC hurts an entity, return true to prevent damage --
function NPC:DealDamage( victimEnt, dmginfo ) end
---------------------------------------------------------------------------------------------------------------------=#

    -- Accept input, return true to prevent --
function NPC:CustomAcceptInput( input, activator, caller, value ) end
---------------------------------------------------------------------------------------------------------------------=#

    -- On Armor hit, dmginfo:ScaleDamage(0) to prevent damage --
    -- HitGroup = HITGROUP_GENERIC || HITGROUP_HEAD || HITGROUP_CHEST || HITGROUP_STOMACH || HITGROUP_LEFTARM
    -- || HITGROUP_RIGHTARM || HITGROUP_LEFTLEG || HITGROUP_RIGHTLEG || HITGROUP_GEAR
function NPC:HitArmor( dmginfo, HitGroup )

    if dmginfo:GetDamage() >= self.ArmorAlwaysPenDamage then
        dmginfo:ScaleDamage(self.ArmorPenDamageMult)
        return
    end

    if math.random(1, self.ArmorPenChance) != 1 then
    
        if self.ArmorHitSpark then
            local spark = ents.Create("env_spark")
            spark:SetKeyValue("spawnflags", 256)
            spark:SetKeyValue("TrailLength", 1)
            spark:SetKeyValue("Magnitude", 1)
            spark:SetPos(dmginfo:GetDamagePosition())
            spark:SetAngles(-dmginfo:GetDamageForce():Angle())
            spark:Spawn()
            spark:Activate()
            spark:Fire("SparkOnce")
            SafeRemoveEntityDelayed(spark, 0.1)
        end

        self:EmitSound("ZBase.Ricochet")
        dmginfo:ScaleDamage(0)

    else
        dmginfo:ScaleDamage(self.ArmorPenDamageMult)
    end

end
---------------------------------------------------------------------------------------------------------------------=#

    -- Select schedule (only used by SNPCs!)
function NPC:ZBaseSNPC_SelectSchedule()
	-- Example
	if IsValid(self:GetEnemy()) then
		self:SetSchedule(SCHED_COMBAT_FACE)
	else
		self:SetSchedule(SCHED_IDLE_STAND)
	end
end
---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the NPC emits a sound
    -- Return true to apply all changes done to the data table.
    -- Return false to prevent the sound from playing.
    -- Return nil or nothing to play the sound without altering it.
function NPC:CustomOnEmitSound( sndData ) end
---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the NPC kills another entity (player or NPC)
function NPC:CustomOnKilledEnt( ent ) end
---------------------------------------------------------------------------------------------------------------------=#









        -- Functions you can call --

---------------------------------------------------------------------------------------------------------------------=#
    -- Check if an entity is within a certain distance
    -- If maxdist is given, return true if the entity is within x units from itself
    -- If mindist is given, return true if the entity is x units away from itself
function NPC:WithinDistance( ent, maxdist, mindist )
    if !IsValid(ent) then return false end

    local dSqr = self:GetPos():DistToSqr(ent:GetPos())
    if mindist && dSqr < mindist^2 then return false end
    if maxdist && dSqr > maxdist^2 then return false end

    return true
end
---------------------------------------------------------------------------------------------------------------------=#
    -- Check if the NPC is facing an entity
function NPC:IsFacing( ent )
    if !IsValid(ent) then return false end

    local ang = (ent:GetPos() - self:GetPos()):Angle()
    local yawDif = math.abs(self:WorldToLocalAngles(ang).Yaw)

    return yawDif < 22.5
end
---------------------------------------------------------------------------------------------------------------------=#
/*
	-- self:PlayAnimation( anim, duration, face ) --
	anim - String sequence name, or an activity (https://wiki.facepunch.com/gmod/Enums/ACT).
	duration - Duration that it won't allow the sequence to be interupted.
	face - What direction will it face when doing the sequence?
		"none" - The SNPC will face whatever direction it wants to (lets you change it manually)
		"lock" - The SNPC will constantly face the direction the sequence started with
		"enemy" - The SNPC will face the enemy if it has one
		"enemy_visible" - Same as enemy, but the enemy has to be visible

*/
function NPC:PlayAnimation( anim, duration, face )

	if !face then face = "none" end
	self.SequenceFaceType = face
	self.AnimFacePos = self:GetPos()+self:GetForward()*100

	self.CurrentAnimation = anim

	if isstring(anim) then

		local act = self:GetSequenceActivity(self:LookupSequence(anim))
		if act == -1 then
			self:ResetSequence(self.CurrentAnimation)
		end
	
	else

		self:ResetIdealActivity(anim)
	
	end

	self:StopAndPreventSelectSchedule( duration )

	timer.Create("ZNPC_StopPlayAnimation"..self:EntIndex(), duration, 1, function()
		if !IsValid(self) then return end
		self.CurrentAnimation = nil
		self.SequenceFaceType = nil
		self.AnimFacePos = nil
		self:ResetIdealActivity(ACT_IDLE) -- Helps reseting the animation
	end)

end
--------------------------------------------------------------------------------=#
/*
	-- self:Face( face ) --
	face - A position or an entity to face, or a number representing the yaw.
*/
function NPC:Face( face )

	local function turn( yaw )

		self:SetIdealYawAndUpdate(yaw)

		-- Turning aid
		if self:IsMoving() then
			local myAngs = self:GetAngles()
			local newAng = Angle(myAngs.pitch, yaw, myAngs.roll)
			self:SetAngles(LerpAngle(self.m_fMaxYawSpeed/100, myAngs, newAng))
		end
		
	end

	if isnumber(face) then
		turn(face)
	elseif IsValid(face) then
		turn( (face:GetPos() - self:GetPos()):Angle().y )
	elseif isvector(face) then
		turn( (face - self:GetPos()):Angle().y )
	end

end
--------------------------------------------------------------------------------=#










        -- DON'T TOUCH ANYTHING BELOW HERE --



local VJ_Translation = {
    ["CLASS_COMBINE"] = "combine",
    ["CLASS_ZOMBIE"] = "zombie",
    ["CLASS_ANTLION"] = "antlion",
    ["CLASS_PLAYER_ALLY"] = "ally",
}

local VJ_Translation_Flipped = {
    ["combine"] = "CLASS_COMBINE",
    ["zombie"] = "CLASS_ZOMBIE",
    ["antlion"] = "CLASS_ANTLION",
    ["ally"] = "CLASS_PLAYER_ALLY",
}

---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseInit( tbl )

    -- Model
    if !table.IsEmpty(self.Models) then
        self:SetModel(table.Random(self.Models))
    end

    self:SetMaxHealth(self.StartHealth)
    self:SetHealth(self.StartHealth)
    self:SetMaxLookDistance(self.SightDistance)
    self:SetCurrentWeaponProficiency(self.WeaponProficiency)
    self:SetBloodColor(self.BloodColor)
    self:SetNWString("ZBaseName", self.Name)

    for _, v in ipairs(self.ExtraCapabilities) do
        self:CapabilitiesAdd(v)
    end

    self:CapabilitiesAdd(bit.bor(
        CAP_SQUAD,
        CAP_TURN_HEAD,
        CAP_ANIMATEDFACE,
        CAP_SKIP_NAV_GROUND_CHECK,
        CAP_FRIENDLY_DMG_IMMUNE
    ))

    self:ZBaseSetSaveValues()
    self:ZBaseSquad()

    ZBaseBehaviourInit( self )

    -- Better position
    if !self.IsZBase_SNPC then
        self:SetPos(self:GetPos()+Vector(0, 0, 20))
    end

    self.NextPainSound = CurTime()

    -- Custom init
    self:CustomInitialize()

end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnEmitSound( data )
    local val = self:CustomOnEmitSound( data )
    local squad = self:GetKeyValues().squadname

    if isstring(val) then
        return val
    elseif val == false then
        return false
    elseif squad != "" && ZBase_DontSpeakOverThisSound then
        -- Make sure squad doesn't speak over each other
        ZBaseSpeakingSquads[squad] = true
        timer.Create("ZBaseUnmute_"..squad, SoundDuration(data.SoundName), 1, function()
            ZBaseSpeakingSquads[squad] = nil
        end) 
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnKilledEnt( ent )
    if ent == self:GetEnemy() then
        self:EmitSound(self.KilledEnemySound)
    end
    self:CustomOnKilledEnt( ent )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnHurt( dmg )
    if self.UseCustomSounds && self.NextPainSound < CurTime() then
        self:EmitSound(self.PainSounds)
        self.NextPainSound = CurTime()+ZBaseRndTblRange( self.PainSoundCooldown )
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSquad()
    if self.ZBaseFaction == "none" then return end


    local squadName = self.ZBaseFaction.."1"
    local i = 1
    while true do
        local squadMemberCount = 0

        for _, v in ipairs(ZBaseNPCInstances) do
            if v:GetKeyValues().squadname == squadName then
                squadMemberCount = squadMemberCount+1
            end
        end

        if squadMemberCount >= 4 then
            i = i+1
            squadName = self.ZBaseFaction..i
        else
            break
        end
    end


    self:SetKeyValue("squadname", squadName)
    --self.ZBaseSquadName = squadName
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSetSaveValues()
    for k, v in pairs(self:GetTable()) do
        if string.StartWith(k, "m_") then
            self:SetSaveValue(k, v)
        end
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseThink()

    self:Relationships()

    local ene = self:GetEnemy()

    -- Alert sound
    if ene != self.LastEnemy then
        self.LastEnemy = ene

        if self.LastEnemy then
            ZBase_DontSpeakOverThisSound = true
            self:EmitSound(self.AlertSounds)
            ZBase_DontSpeakOverThisSound = false
            ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown), self, "DoIdleEnemySound")
        end
    end

end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SetRelationship( ent, rel )
    self:AddEntityRelationship(ent, rel, 99)
    if ent:IsNPC() then
        ent:AddEntityRelationship(self, rel, 99)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBase_VJFriendly( ent )
    if !ent.IsVJBaseSNPC then return false end

    for _, v in ipairs(ent.VJ_NPC_Class) do
        if VJ_Translation[v] == self.ZBaseFaction then return true end
    end

    return false
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:Relationship( ent )

    if self.ZBaseFaction == "none" then
        self:SetRelationship( ent, D_HT )
        return
    end

    if self.ZBaseFaction == ent.ZBaseFaction then
        self:SetRelationship( ent, D_LI )
        return
    end

    if (self:ZBase_VJFriendly( ent ) or self.ZBase_Class == ent.ZBase_Class) then
        self:SetRelationship( ent, D_LI )
    else
        self:SetRelationship( ent, D_HT )
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:Relationships()

    if VJ_Translation_Flipped[self.ZBaseFaction] then
        self.VJ_NPC_Class = {VJ_Translation_Flipped[self.ZBaseFaction]}
    end

    for _, v in ipairs(ZBaseNPCInstances) do
        if !IsValid(v) then continue end
        if v != self then self:Relationship(v) end
    end

    for _, v in ipairs(ZBase_NonZBaseNPCs) do
        self:Relationship(v)
    end

    for _, v in ipairs(player.GetAll()) do
        self:Relationship(v)
    end

end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:HasCapability( cap )
    return bit.band(self:CapabilitiesGet(), cap)==cap
end
---------------------------------------------------------------------------------------------------------------------=#
