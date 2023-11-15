local NPC = FindZBaseTable(debug.getinfo(1,'S'))

--[[
==================================================================================================
                                           COOL SEPARATOR
==================================================================================================
--]]

        -- GENERAL --

-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {}

NPC.CanSecondaryAttack = true -- Can use weapon secondary attacks
NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.BloodColor = BLOOD_COLOR_RED -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER	

NPC.SightDistance = 7000 -- Sight distance
NPC.SightAngle = 90 -- Sight angle
NPC.MaxShootDistance = 3000 -- Maximum distance the NPC can fire its weapon from
NPC.StartHealth = 50 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour
NPC.KeyValues = {} -- Ex. NPC.KeyValues = {citizentype=CT_REBEL}
NPC.SpawnFlagTbl = {} -- Ex. NPC.SpawnFlagTbl = {SF_NPC_NO_WEAPON_DROP}, https://wiki.facepunch.com/gmod/Enums/SF
NPC.CallForHelp = true -- Can this NPC call their faction allies for help (even though they aren't in the same squad)?
NPC.CallForHelpDistance = 2000 -- Call for help distance
NPC.HullType = false -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL
NPC.CollisionBounds = false -- Example: NPC.CollisionBounds = {min=Vector(-50, -50, 0), max=Vector(50, 50, 100)}, false = default
NPC.CanJump = true -- Can the NPC jump?
NPC.HearDistMult = 1

-- Extra capabilities
-- List of capabilities: https://wiki.facepunch.com/gmod/Enums/CAP
NPC.ExtraCapabilities = {
    CAP_OPEN_DOORS, -- Can open regular doors
}

NPC.ZBaseStartFaction = "none" -- Any string, all ZBase NPCs with this faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody


--[[===============================================================================================]]

        -- DAMAGE AND DEATH --


    -- Armor System --
NPC.HasArmor = {
    -- [HITGROUP_GENERIC] = false,
    -- [HITGROUP_HEAD] = false,
    -- [HITGROUP_CHEST] = false,
    -- [HITGROUP_STOMACH] = false,
    -- [HITGROUP_LEFTARM] = false,
    -- [HITGROUP_RIGHTARM] = false,
    -- [HITGROUP_LEFTLEG] = false,
    -- [HITGROUP_RIGHTLEG] = false,
    -- [HITGROUP_GEAR] = false,
}
NPC.ArmorPenChance = 2 -- 1/x Chance that the armor is penetrated, false = never
NPC.ArmorAlwaysPenDamage = 40 -- Always penetrate the armor if the damage is more than this, set to false to disable
NPC.ArmorPenDamageMult = 1.5 -- Multiply damage by this amount if a armored hitgroup is penetrated
NPC.ArmorHitSpark = true -- Do a spark on armor hit
NPC.ArmorReflectsBullets = false -- Should the armor visually reflect bullets?

-- Scale damage against certain damage types:
-- https://wiki.facepunch.com/gmod/Enums/DMG
NPC.DamageScaling = {
    -- Example:
    -- [DMG_BLAST] = 0.5,
    -- [DMG_BULLET] = 2,
}
NPC.PhysDamageScale = 1 -- Damage scale from props
NPC.EnergyBallDamageScale = 1 -- Damage scale from combine energy balls
NPC.ExplodeEnergyBall = false -- Should combine energy balls explode when they hit this NPC?
NPC.CanDissolve = true -- Can the NPC be dissolved?


NPC.HasDeathRagdoll = true -- Should the NPC spawn a ragdoll when it dies?


--[[===============================================================================================]]




        -- BASE MELEE ATTACK --

NPC.BaseMeleeAttack = false -- Use ZBase melee attack system
NPC.MeleeAttackFaceEnemy = true -- Should it face enemy while doing the melee attack?
NPC.MeleeAttackTurnSpeed = 5 -- Speed that it turns while trying to face the enemy when melee attacking
NPC.MeleeAttackDistance = 75
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}
NPC.MeleeAttackName = "" -- Serves no real purpose, you can use it for whatever you want

-- Melee attack animations
NPC.MeleeAttackAnimations = {} -- Example: NPC.MeleeAttackAnimations = {ACT_MELEE_ATTACK1}
NPC.MeleeAttackAnimationSpeed = 1 -- Speed multiplier for the melee attack animation

NPC.MeleeDamage = {10, 10} -- Melee damage {min, max}
NPC.MeleeDamage_Distance = 100 -- Distance the damage travels
NPC.MeleeDamage_Angle = 180 -- Damage angle (180 = everything in front of the NPC is damaged)
NPC.MeleeDamage_Delay = 1 -- Time until the damage strikes, set to false to disable the timer (if you want to use animation events instead for example)
NPC.MeleeDamage_Type = DMG_GENERIC -- The damage type, https://wiki.facepunch.com/gmod/Enums/DMG
NPC.MeleeDamage_Sound = "ZBase.Melee2" -- Sound when the melee attack hits an enemy
NPC.MeleeDamage_Sound_Prop = "ZBase.Melee2" -- Sound when the melee attack hits props
NPC.MeleeDamage_AffectProps = false -- Affect props and other entites
--[[===============================================================================================]]



        -- BASE RANGE ATTACK --
NPC.BaseRangeAttack = false -- Use ZBase range attack system
NPC.RangeAttackFaceEnemy = true -- Should it face enemy while doing the range attack?
NPC.RangeAttackTurnSpeed = 10 -- Speed that it turns while trying to face the enemy when range attacking
NPC.RangeAttackDistance = {0, 1000} -- Distance that it initiates the range attack {min, max}
NPC.RangeAttackCooldown = {2, 4} -- Range attack cooldown {min, max}
NPC.RangeAttackSuppressEnemy = true -- If the enemy can't be seen, target the last seen position

-- Range attack animations
NPC.RangeAttackAnimations = {} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeAttackAnimationSpeed = 1 -- Speed multiplier for the range attack animation

-- Time until the projectile code is ran
-- Set to false to disable the timer (if you want to use animation events instead for example)
NPC.RangeProjectile_Delay = 1

-- Attachment to spawn the projectile on 
-- If set to false the projectile will spawn from the NPCs center
NPC.RangeProjectile_Attachment = false

NPC.RangeProjectile_Offset = false -- Projectile spawn offset, example: {forward=50, up=25, right=0}
NPC.RangeProjectile_Speed = 1000 -- The speed of the projectile
NPC.RangeProjectile_Inaccuracy = 0 -- Inaccuracy, 0 = perfect, higher numbers = less accurate

--[[===============================================================================================]]

    -- SNPC ONLY --


-- General
NPC.m_fMaxYawSpeed = 10 -- Max turning speed
NPC.SNPCType = ZBASE_SNPCTYPE_WALK -- ZBASE_SNPCTYPE_WALK || ZBASE_SNPCTYPE_FLY || ZBASE_SNPCTYPE_STATIONARY
NPC.CantReachEnemyBehaviour = ZBASE_CANTREACHENEMY_HIDE -- ZBASE_CANTREACHENEMY_HIDE || ZBASE_CANTREACHENEMY_FACE

-- Squadmembers of this NPC should try to make this amount of room to the NPC if its moving
-- Only used when in combat
NPC.SquadGiveSpace = 128


-- Flying
NPC.Fly_DistanceFromGround = 100 -- Minimum distance to try to keep from the ground when flying
NPC.Fly_DistanceFromGround_IgnoreWhenMelee = true -- Should it ignore the distance from ground limit when in melee attack distance?
NPC.Fly_FaceEnemy = false -- Should it face the enemy while fly moving?
NPC.Fly_MoveSpeed = 200 -- Flying movement speed
NPC.Fly_Accelerate = 15 -- Flying movement accelerate speed
NPC.Fly_Decelerate = 15 -- Flying movement decelerate speed
NPC.Fly_GravGunPuntForceMult = 1

--[[===============================================================================================]]


        -- SOUNDS --
        -- Use sound scripts to alter pitch and level etc..

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC

NPC.AlertSounds = "" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "" -- Sounds emitted while there is no enemy
NPC.Idle_HasEnemy_Sounds = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "" -- Sounds emitted on hurt
NPC.DeathSounds = "" -- Sounds emitted on death
NPC.KilledEnemySounds = "" -- Sounds emitted when the NPC kills an enemy
NPC.HearDangerSounds = ""
NPC.LostEnemySounds = ""
NPC.SeeDangerSounds = ""
NPC.SeeGrenadeSounds = ""
NPC.AllyDeathSounds = ""
NPC.OnMeleeSounds = ""
NPC.OnRangeSounds = ""
NPC.OnReloadSounds = ""
NPC.Dialogue_Question_Sounds = ""
NPC.Dialogue_Answer_Sounds = ""


-- Sound cooldowns {min, max}
NPC.IdleSoundCooldown = {8, 16}
NPC.IdleSounds_HasEnemyCooldown = {5, 10}
NPC.PainSoundCooldown = {1, 2.5}
NPC.AlertSoundCooldown = {4, 8}

-- Sound chance 1/X
NPC.IdleSound_Chance = 3
NPC.AllyDeathSound_Chance = 2
NPC.OnMeleeSound_Chance = 2
NPC.OnRangeSound_Chance = 2
NPC.OnReloadSound_Chance = 2


--[[===============================================================================================]]






        -- Functions you can change --

--[[===============================================================================================]]

    -- Called when the NPC is created --
function NPC:CustomInitialize()
end
--[[===============================================================================================]]

    -- Called continiously --
function NPC:CustomThink()
end
--[[===============================================================================================]]

    -- On NPC hurt, dmginfo:ScaleDamage(0) to prevent damage --
    -- HitGroup = HITGROUP_GENERIC || HITGROUP_HEAD || HITGROUP_CHEST || HITGROUP_STOMACH || HITGROUP_LEFTARM
    -- || HITGROUP_RIGHTARM || HITGROUP_LEFTLEG || HITGROUP_RIGHTLEG || HITGROUP_GEAR
function NPC:CustomTakeDamage( dmginfo, HitGroup )
end
--[[===============================================================================================]]

    -- Called when the NPC hurts an entity, return true to prevent damage --
function NPC:DealDamage( victimEnt, dmginfo )
end
--[[===============================================================================================]]

    -- Accept input, return true to prevent --
function NPC:CustomAcceptInput( input, activator, caller, value )
end
--[[===============================================================================================]]

    -- On armor hit --
    -- HitGroup = HITGROUP_GENERIC || HITGROUP_HEAD || HITGROUP_CHEST || HITGROUP_STOMACH || HITGROUP_LEFTARM
    -- || HITGROUP_RIGHTARM || HITGROUP_LEFTLEG || HITGROUP_RIGHTLEG || HITGROUP_GEAR
function NPC:HitArmor( dmginfo, HitGroup )

    if !(dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_BUCKSHOT)) then return end

    if self.ArmorAlwaysPenDamage && dmginfo:GetDamage() >= self.ArmorAlwaysPenDamage then
        dmginfo:ScaleDamage(self.ArmorPenDamageMult)
        return
    end

    if !self.ArmorPenChance or math.random(1, self.ArmorPenChance) != 1 then
    
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
--[[===============================================================================================]]

    -- Return a new sound name to play that sound instead.
    -- Return false to prevent the sound from playing.
function NPC:CustomOnEmitSound( sndData, sndVarName )
end
--[[===============================================================================================]]

    -- Called when the NPC kills another entity (player or NPC)
function NPC:CustomOnKilledEnt( ent )
end
--[[===============================================================================================]]

    -- Called a tick after an entity owned by this NPC is created
    -- Very useful for replacing a combine's grenades or a hunter's flechettes or something of that nature
function NPC:CustomOnOwnedEntCreated( ent )
end
--[[===============================================================================================]]

    -- Called when the base detects that the NPC is playing a new activity
function NPC:CustomNewActivityDetected( act )
end
--[[===============================================================================================]]

    -- Called continiusly if the NPC has a melee attack
    -- Useful for changing things about the melee attack based on given conditions
function NPC:MultipleMeleeAttacks()
    -- Example:
    -- if self:ZBaseDist(self:GetEnemy(), {within=40}) then
    --     -- Enemy is x units away, switch to another melee attack animation
    --     self.MeleeAttackAnimations = {ACT_SPECIAL_ATTACK1}
    -- else
    --     self.MeleeAttackAnimations = {ACT_MELEE_ATTACK1}
    -- end
end
--[[===============================================================================================]]

    -- Force to apply to entities affected by the melee attack damage, relative to the NPC
function NPC:MeleeDamageForce( dmgData )
    -- Example:
    -- return {forward=500, up=500, right=0, randomness=100}
end
--[[===============================================================================================]]

    -- Called when a melee attack is started
function NPC:OnMelee()
end
--[[===============================================================================================]]


    -- The range attack projectile code
    -- Called by the base, but can be called whenever you like
function NPC:RangeAttackProjectile()

    -- Don't let this function run when the NPC is dead
    if self:GetNPCState() == NPC_STATE_DEAD then return end


    local projStartPos = self:Projectile_SpawnPos()


    -- Projectile code --
    local proj = ents.Create("projectile_zbase")
    proj:SetPos(projStartPos)
    proj:SetAngles(self:GetAngles())
    proj:SetOwner(self)
    proj:Spawn()

    local proj_phys = proj:GetPhysicsObject()
    if IsValid(proj_phys) then
        proj_phys:SetVelocity(self:RangeAttackProjectileVelocity())
    else
        proj:SetVelocity(self:RangeAttackProjectileVelocity())
    end
    ---------------------------------------=#


    -- Bullet code --
    -- self:FireBullets({
    --     Attacker = self,
    --     Inflictor = self,
    --     Damage = 3,
    --     Dir = (self:Projectile_TargetPos() - projStartPos):GetNormalized(),
    --     Src = projStartPos,
    --     Spread = Vector(self.RangeProjectile_Inaccuracy, self.RangeProjectile_Inaccuracy)
    -- })
    -- https://wiki.facepunch.com/gmod/Structures/Bullet
    ---------------------------------------=#
end

--[[===============================================================================================]]

    -- The velocity to apply to the projectile when it spawns
function NPC:RangeAttackProjectileVelocity()
    local startPos = self:Projectile_SpawnPos()

    if self.RangeProjectile_Inaccuracy > 0 then
        startPos = startPos + VectorRand()*self.RangeProjectile_Inaccuracy
    end

    return (self:Projectile_TargetPos() - startPos):GetNormalized()*self.RangeProjectile_Speed  
end
--[[===============================================================================================]]

    -- Called continiusly if the NPC has a range attack
    -- Useful for changing things about the range attack based on given conditions
function NPC:MultipleRangeAttacks()
end
--[[===============================================================================================]]

    -- Called when a range attack is started
function NPC:OnRangeAttack()
end
--[[===============================================================================================]]








    -- SNPC only functions that you can change --
--[[===============================================================================================]]

    -- Called when the SNPC fires an animation event
function NPC:SNPCHandleAnimEvent(event, eventTime, cycle, type, option) 
    -- Example:
    -- if event == 5 then
    --     self:MeleeAttackDamage()
    -- end
end
--[[===============================================================================================]]

    -- Select schedule
    -- Here you can change how the SNPC should behave entirely
    -- This function is called whenever the SNPC isn't doing a schedule, allowing you to set it to whatever schedule you want
    -- Use self:SetSchedule() for engine schedules: https://wiki.facepunch.com/gmod/Enums/SCHED
    -- Use self:StartSchedule() for custom schedules, such as the ZBase built in ones, or your own
function NPC:SNPCSelectSchedule(iNPCState)
    -- Example:
    local ene = self:GetEnemy()

    if IsValid(ene) then

        self:StartSchedule(ZSched.CombatChase)

    else

        -- No enemy, just stand in idle
        self:SetSchedule(SCHED_IDLE_STAND)

    end
end

--[[===============================================================================================]]

    -- Called when the SNPC takes damage
function NPC:SNPCOnHurt(dmginfo)
    -- Example:
	if !IsValid(self:GetEnemy()) then
        -- Face the direction of the damage
		self:FaceHurtPos(dmginfo)
	end
end
--[[===============================================================================================]]

    -- Called continiusly for flying SNPCs
    -- You can change anything about their flying velocity here
function NPC:SNPCFlyVelocity(destinationDirection, destinationCurrentSpeed)
    -- You can mess with their angles here
    -- This example will cause them to tilt forward in the direction they are moving
    -- local myang = self:GetAngles()
    -- self:SetAngles(Angle(destinationCurrentSpeed*0.1, myang.yaw, myang.roll))

    return destinationDirection*destinationCurrentSpeed
end
--[[===============================================================================================]]