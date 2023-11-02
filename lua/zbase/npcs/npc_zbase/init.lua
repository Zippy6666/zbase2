local NPC = FindZBaseTable(debug.getinfo(1,'S'))


---------------------------------------------------------------------------------------------------------------------=#




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
NPC.KeyValues = {} -- Ex. NPC.KeyValues = {citizentype=CT_REBEL}
NPC.CallForHelp = true -- Can this NPC call their faction allies for help (even though they aren't in the same squad)?
NPC.CallForHelpDistance = 2000 -- Call for help distance

-- Extra capabilities
-- List of capabilities: https://wiki.facepunch.com/gmod/Enums/CAP
NPC.ExtraCapabilities = {
    CAP_OPEN_DOORS, -- Can open regular doors
    CAP_MOVE_JUMP, -- Can jump
}

NPC.ZBaseFaction = "none" -- Any string, all ZBase NPCs with this faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody




---------------------------------------------------------------------------------------------------------------------=#



        -- ARMOR SYSTEM --
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



---------------------------------------------------------------------------------------------------------------------=#




        -- BASE MELEE ATTACK --

NPC.BaseMeleeAttack = false -- Use ZBase melee attack system
NPC.MeleeAttackDistance = 100

-- Melee attack animations
NPC.MeleeAttackAnimations = {
    ACT_MELEE_ATTACK1,
}
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}



---------------------------------------------------------------------------------------------------------------------=#



        -- BASE RANGE ATTACK --
NPC.BaseRangeAttack = false -- Use ZBase range attack system



---------------------------------------------------------------------------------------------------------------------=#




        -- SOUNDS --
        -- Use sound scripts to alter pitch and level etc..

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC

NPC.IdleSound_OnlyNearAllies = false -- Only do IdleSounds if there is another NPC in the same faction nearby
NPC.IdleSound_FaceAllyChance = 2 -- 1/X chance that the NPC faces its nearby ally, NPC.IdleSound_OnlyNearAllies must be true in order for this to work

NPC.AlertSounds = "" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "" -- Sounds emitted while there is no enemy
NPC.IdleSounds_HasEnemy = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "" -- Sounds emitted on hurt
NPC.DeathSounds = "" -- Sounds emitted on death
NPC.KilledEnemySound = "" -- Sounds emitted when the NPC kills an enemy

-- Sound cooldowns {min, max}
NPC.IdleSoundCooldown = {8, 16}
NPC.IdleSounds_HasEnemyCooldown = {5, 10}
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

    -- Called one tick after an entity owned by this NPC is created
    -- Very useful for replacing a combine's grenades or a hunter's flechettes or something of that nature
function NPC:CustomOnOwnedEntCreated( ent ) end
---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the base detects that the NPC is playing a new activity
function NPC:CustomNewActivityDetected( act )
end

---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the base detects that the NPC is running a new schedule
function NPC:CustomNewScheduleDetected( sched ) 
end
---------------------------------------------------------------------------------------------------------------------=#