local NPC = ZBaseNPCs["npc_zbase"]
-- ABOVE SHOULD BE "local NPC = FindZBaseTable(debug.getinfo(1, 'S'))" IN YOUR FILE

--[[
==================================================================================================
                                           GENERAL
==================================================================================================
--]]
 
-- NOTE FOR ADVANCED USERS: You can change any internal variable by doing NPC.m_typeNameOfInternalVar here
-- Combine soldier example:
-- NPC.m_nKickDamage = 15

-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {}
NPC.RenderMode = RENDERMODE_NORMAL -- https://wiki.facepunch.com/gmod/Enums/RENDERMODE
NPC.SubMaterials = {} -- Submaterials {*number index* = *string name*}

-- This obviously needs to be true if you want to use LUA animation events
NPC.EnableLUAAnimationEvents = true

NPC.StartHealth = 50 -- Max health

NPC.SightDistance = ZBASE_DEFAULT_SIGHT_DIST -- Sight distance, set to any number
NPC.SightAngle = 180 -- Sight angle
NPC.AlertAllies = true -- Can this NPC call their faction allies for help (even though they aren't in the same squad)?
NPC.AlertAlliesDistance = 4096 -- Call for help distance
NPC.CanBeAlertedByAlly = true -- Can this NPC be called by other allies when they need help?
NPC.HearDistMult = 1 -- Hearing distance multiplier when this addon is enabled: https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.TimeUntilLooseEnemy = 15 -- (THIS VARIABLE IS CURRENTLY UNUSED) Time until it no longer knows where the enemy is

NPC.HullType = false -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL
NPC.CollisionBounds = false -- Example: NPC.CollisionBounds = {min=Vector(-50, -50, 0), max=Vector(50, 50, 100)}, false = default

-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "none"

-- More factions this NPC should be allied towards, needs to follow this syntax:
-- NPC.ZBaseFactionsExtra = {
--     ["combine"] = true,
--     ["zombie"] = true,
-- }
NPC.ZBaseFactionsExtra = {
}

NPC.KeyValues = {} -- Ex. NPC.KeyValues = {citizentype=CT_REBEL}
NPC.SpawnFlagTbl = {} -- Ex. NPC.SpawnFlagTbl = {SF_CITIZEN_RANDOM_HEAD_FEMALE}, https://wiki.facepunch.com/gmod/Enums/SF

NPC.CanOpenDoors = true -- Can open regular doors
NPC.CanOpenAutoDoors = true -- Can open auto doors
NPC.CanUse = true -- Can push buttons, pull levers, etc

-- Do "zbase_reload" followed by "spawnmenu_reload" to apply the changes, or restart map
NPC.OnCeiling = false -- Spawn this NPC on the ceiling
NPC.Offset = false -- NPC Spawn offset from ground, false = default

-- Health regen
NPC.HealthRegenAmount = 0
NPC.HealthCooldown = 0.2

NPC.ForceAvoidDanger = false -- Force this NPC to avoid dangers such as grenades

-- Items to drop on death
-- ["item_class_name"] = {chance=1/x, max=x}
NPC.ItemDrops = {
    -- ["item_healthvial"] = {chance=2, max=1} -- Example, a healthvial that has a 1/2 chance of spawning
}
NPC.ItemDrops_TotalMax = 5 -- The NPC can never drop more than this many items

NPC.CanFollowPlayers = true -- Can it follow players when the player press their use key on them (if allied with the player)?

--[[
==================================================================================================
                                           MOVEMENT
==================================================================================================
--]]

NPC.CanPatrol = true -- Use base patrol behaviour
NPC.CanJump = true -- Can the NPC jump?

-- Multiply the NPC's movement speed by this amount (ground NPCs)
-- May not work properly for all NPCs
NPC.MoveSpeedMultiplier = 1

-- How much power to add when jumping using the controller on this NPC
-- 0 = auto
NPC.Controller_JumpPower = 0

--[[
==================================================================================================
                                           WEAPON HANDLING
==================================================================================================
--]]

NPC.MinShootDistance = 0 -- Minimum distance the NPC will fire its weapon from
NPC.MaxShootDistance = 3000 -- Maximum distance the NPC can fire its weapon from
NPC.CanSecondaryAttack = true -- Can use weapon secondary attacks
NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.MeleeWeaponAnimations = {ACT_MELEE_ATTACK1} -- Animations to use when attacking with a melee weapon
NPC.MeleeWeaponAnimations_TimeUntilDamage = 0.5 -- Time until the damage from melee weapons hit

NPC.ExtraFireWeaponActivities = {} -- NPCs will fire when they have these activities. Syntax: [ACT_SOMETHING] = true
NPC.ForceShootStance = true -- Set to false to not let the base force a shoot stance for the NPC

-- DEPRICATED, IF YOU NEED CUSTOM SHOOT ANIMATIONS, YOU WILL HAVE TO CODE IT YOURSELF, DON'T USE!! --
-- NPC.WeaponFire_Activities = {ACT_RANGE_ATTACK1, ACT_RANGE_ATTACK1_LOW} -- The NPC will randomly switch between these activities when firing their weapon
-- NPC.WeaponFire_MoveActivities = {ACT_WALK_AIM, ACT_RUN_AIM} -- The NPC will randomly switch between these activities when firing their weapon

-- DEPRICATED, IF YOU NEED CUSTOM SHOOT ANIMATIONS, YOU WILL HAVE TO CODE IT YOURSELF, DON'T USE!! --
-- NPC.WeaponFire_DoGesture = true -- Should it play a gesture animation everytime it fires the weapon when standing still?
-- NPC.WeaponFire_DoGesture_Moving = true -- Should it play a gesture animation everytime it fires the weapon when moving?
-- NPC.WeaponFire_Gestures = {ACT_GESTURE_RANGE_ATTACK1} -- The gesture animations to play

--[[
==================================================================================================
                                           BLOOD
==================================================================================================
--]]

-- Default engine blood color
-- Set to DONT_BLEED if you want to use custom blood instead
-- Set to false to use the default blood for the NPC class
NPC.BloodColor = false -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER || false

NPC.CustomBloodParticles = false -- Table of custom particles
NPC.CustomBloodDecals = false -- String name of custom decal

--[[
==================================================================================================
                                           DAMAGE
==================================================================================================
--]]

-- Armor System
-- These hitgroups will be armored
-- https://wiki.facepunch.com/gmod/Enums/HITGROUP
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
NPC.ArmorPenChance = 2 -- 1/x Chance that the armor is penetrated, false = never
NPC.ArmorAlwaysPenDamage = 40 -- Always penetrate the armor if the damage is more than this, set to false to disable
NPC.ArmorPenDamageMult = 1.5 -- Multiply damage by this amount if a armored hitgroup is penetrated
NPC.ArmorHitSpark = true -- Do a spark on armor hit

-- Scale damage against certain damage types:
-- https://wiki.facepunch.com/gmod/Enums/DMG
NPC.DamageScaling = {
    -- Example:
    -- [DMG_BLAST] = 2,
    -- [DMG_BULLET] = 0.5,
}
NPC.PhysDamageScale = 1 -- Damage scale from props

--[[
==================================================================================================
                                           FLINCH
==================================================================================================
--]]

NPC.FlinchAnimations = {} -- Flinch animations to use, leave empty to disable the base flinch
NPC.FlinchAnimationSpeed = 1 -- Speed of the flinch animation
NPC.FlinchCooldown = {1, 2} -- Flinch cooldown in seconds {min, max}
NPC.FlinchChance = 2 -- Flinch chance 1/x
NPC.FlinchIsGesture = false -- Should the flinch animation be played as a gesture?

--[[
==================================================================================================
                                           DEATH
==================================================================================================
--]]

NPC.DeathAnimations = {} -- Death animations to use, leave empty to disable the base death animation
NPC.DeathAnimationSpeed = 1 -- Speed of the death animation
NPC.DeathAnimationChance = 1 --  Death animation chance 1/x
NPC.DeathAnimation_StopAttackingMe = false -- Stop other NPCs from attacking this NPC when it is doing its death animation

-- Duration of death animation, set to false to use the default duration (note that doing so may cause issues with some models/npcs so be careful)
NPC.DeathAnimationDuration = 1

NPC.HasDeathRagdoll = true -- Should the NPC spawn a ragdoll when it dies?
NPC.RagdollApplyForce = true -- Should the ragdoll get force applied to it?
NPC.RagdollModel = "" -- Leave like this to use the default ragdoll

NPC.DissolveRagdoll = true -- Dissolve ragdoll on death from dissolve damage, may dissolve the ragdoll anyway if set to false
NPC.AddNoDissolveFlag = true -- If set to true NPCs will not dissolve instantly from ar2 altfires

-- Try messing with these if the ragdoll is buggy
NPC.RagdollUseAltPositioning = false
NPC.RagdollDontAnglePhysObjects = false

--[[
==================================================================================================
                                           MELEE ATTACK
==================================================================================================
--]]

NPC.BaseMeleeAttack = false -- Use ZBase melee attack system
NPC.MeleeAttackFaceEnemy = true -- Should it face enemy while doing the melee attack?
NPC.MeleeAttackTurnSpeed = 15 -- Speed that it turns while trying to face the enemy when melee attacking
NPC.MeleeAttackDistance = 50 -- Distance that it initiates the melee attack from
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}
NPC.MeleeAttackName = "" -- Serves no real purpose, you can use it for whatever you want

NPC.MeleeAttackAnimations = {} -- Example: NPC.MeleeAttackAnimations = {ACT_MELEE_ATTACK1}
NPC.MeleeAttackAnimationSpeed = 1 -- Speed multiplier for the melee attack animation

NPC.MeleeDamage = {10, 10} -- Melee damage {min, max}
NPC.MeleeDamage_Distance = 70 -- Damage reach distance
NPC.MeleeDamage_Angle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
NPC.MeleeDamage_Delay = 1 -- Time until the damage strikes, set to false to disable the timer (if you want to use animation events instead for example)
NPC.MeleeDamage_Type = DMG_GENERIC -- The damage type, https://wiki.facepunch.com/gmod/Enums/DMG
NPC.MeleeDamage_Sound = "ZBase.Melee2" -- Sound when the melee attack hits an enemy
NPC.MeleeDamage_Sound_Prop = "ZBase.Melee2" -- Sound when the melee attack hits props
NPC.MeleeDamage_AffectProps = false -- Affect props and other entites

--[[
==================================================================================================
                                           RANGE ATTACK
==================================================================================================
--]]

NPC.BaseRangeAttack = false -- Use ZBase range attack system
NPC.RangeAttackFaceEnemy = true -- Should it face enemy while doing the range attack?
NPC.RangeAttackTurnSpeed = 10 -- Speed that it turns while trying to face the enemy when range attacking
NPC.RangeAttackDistance = {0, 1000} -- Distance that it initiates the range attack {min, max}
NPC.RangeAttackCooldown = {2, 4} -- Range attack cooldown {min, max}
NPC.RangeAttackSuppressEnemy = true -- If the enemy can't be seen, target the last seen position

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

--[[
==================================================================================================
                                           THROW GRENADE
==================================================================================================
--]]

NPC.BaseGrenadeAttack = false -- Use ZBase grenade attack system
NPC.ThrowGrenadeChance_Visible = 5 -- 1/x chance that it throws a grenade when the enemy is visible
NPC.ThrowGrenadeChance_Occluded = 3 -- 1/x chance that it throws a grenade when the enemy is not visible
NPC.GrenadeCoolDown = {4, 8} -- {min, max}
NPC.GrenadeAttackAnimations = {} -- Grenade throw animation
NPC.GrenadeEntityClass = {"npc_grenade_frag"} -- The type of grenade(s) to throw, can be anything. Randomized.
NPC.GrenadeReleaseTime = 0.85 -- Time until grenade leaves the hand
NPC.GrenadeAttachment = "anim_attachment_LH" -- The attachment to spawn the grenade on
NPC.GrenadeMaxSpin = 11-- The amount to spin the grenade measured in spin units or something idfk

--[[
==================================================================================================
                                           SNPC ONLY
==================================================================================================
--]]

-- What is this SNPC classified as? (don't confuse with faction!) https://wiki.facepunch.com/gmod/Enums/CLASS
-- -1 = Pick automatically
NPC.m_iClass = -1
NPC.m_fMaxYawSpeed = 10 -- Max turning speed
NPC.SNPCType = ZBASE_SNPCTYPE_WALK -- SNPC Type: ZBASE_SNPCTYPE_WALK || ZBASE_SNPCTYPE_FLY

NPC.CantReachEnemyBehaviour = ZBASE_CANTREACHENEMY_HIDE -- How should it behave when it cannot reach the enemy while chasing
-- ZBASE_CANTREACHENEMY_HIDE - Hide from enemy
-- ZBASE_CANTREACHENEMY_FACE - Stand still and face enemy

-- Minimum distance it chases before doing it runs SNPCChase_TooClose
-- SNPCChase_TooClose will by default cause the SNPC to stop and face the enemy
-- 0 = Chase enemy regardless of how close it is
NPC.ChaseMinDistance = 0

NPC.LookPoseParams = false -- Enable looking pose parameters
NPC.LookPoseParamNames = {
    Pitch = {"aim_pitch"},
    Yaw = {"aim_yaw"}
}

NPC.UseVPhysics = false -- Make NPC physical like a prop

--[[
==================================================================================================
                                           FLYING SNPC ONLY
==================================================================================================
--]]

NPC.Fly_DistanceFromGround = 60 -- Minimum distance to try to keep from the ground when flying
NPC.Fly_DistanceFromGround_IgnoreWhenMelee = true -- Should it ignore the distance from ground limit when in melee attack distance?
NPC.Fly_FaceEnemy = false -- Should it face the enemy while fly moving?
NPC.Fly_MoveSpeed = 200 -- Flying movement speed
NPC.Fly_Accelerate = 15 -- Flying movement accelerate speed
NPC.Fly_Decelerate = 15 -- Flying movement decelerate speed
NPC.Fly_GravGunPuntForceMult = 1 -- How much should the flying SNPC be affected by the gravity gun push attack?
--[[
==================================================================================================
                                           SOUNDS
==================================================================================================
--]]

NPC.MuteDefaultVoice = true -- Mute all default voice sounds emitted by this NPC
NPC.MuteAllDefaultSoundEmittions = false -- Mute all default sounds emitted by this NPC

-- Sounds (Use sound scripts to alter pitch and level and such!)
-- It's recommended to uses different soundscripts for each sound or else captions might not work right

NPC.AlertSounds = "" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "" -- Sounds emitted while there is no enemy
NPC.Idle_HasEnemy_Sounds = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "" -- Sounds emitted on hurt
NPC.DeathSounds = "" -- Sounds emitted on death
NPC.KilledEnemySounds = "" -- Sounds emitted when the NPC kills an enemy

NPC.LostEnemySounds = "" -- Sounds emitted when the enemy is lost
NPC.SeeDangerSounds = "" -- Sounds emitted when the NPC spots a danger, such as a flaming barrel
NPC.SeeGrenadeSounds = "" -- Sounds emitted when the NPC spots a grenade
NPC.AllyDeathSounds = "" -- Sounds emitted when an ally dies
NPC.OnMeleeSounds = "" -- Sounds emitted when the NPC does its melee attack
NPC.OnRangeSounds = "" -- Sounds emitted when the NPC does its range attack
NPC.OnReloadSounds = "" -- Sounds emitted when the NPC reloads
NPC.OnGrenadeSounds = "" -- Sounds emitted when the NPC throws a grenade
NPC.FollowPlayerSounds = "" -- Sounds emitted when the NPC starts following a player
NPC.UnfollowPlayerSounds = "" -- Sounds emitted when the NPC stops following a player

-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "" -- Dialogue answers, emitted when the NPC is spoken to

-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = ""

NPC.FootStepSounds = "ZBase.Step" -- Footstep sound

-- Footstep timer (if active)
NPC.FootStepSoundDelay_Walk = 0.5 -- Step cooldown when walking
NPC.FootStepSoundDelay_Run = 0.3 -- Step cooldown when running

-- Sound cooldowns {min, max}
NPC.IdleSoundCooldown = {8, 16}
NPC.IdleSounds_HasEnemyCooldown = {5, 10}
NPC.PainSoundCooldown = {1, 2.5}
NPC.AlertSoundCooldown = {8, 12}

-- Sound chance 1/X
NPC.IdleSound_Chance = 3
NPC.AllyDeathSound_Chance = 2
NPC.OnMeleeSound_Chance = 2
NPC.OnRangeSound_Chance = 2
NPC.OnReloadSound_Chance = 2

--[[
==================================================================================================
                                           INIT/THINK
==================================================================================================
--]]

-- Called when the NPC is created --
function NPC:CustomInitialize()
end

-- Called BEFORE the NPC spawns --
function NPC:CustomPreSpawn()
end

-- Called when the base gives the NPC capabilities, you can do self:CapabilitiesRemove(CAP_YOUR_CAP) here for example
function NPC:OnInitCap()
end

-- Called when the NPC controller sets up attacks
-- Add your own attacks here
function NPC:CustomControllerInitAttacks()
end

-- Called if NPC is SNPC and uses VPhysics
function NPC:OnInitPhys(phys)
    -- Example:
    -- phys:SetMass(100)
end

-- Should the NPC have glowing eyes on spawn if the model supports it?
function NPC:ShouldGlowEyes()
    return true
end

-- Called continiously
function NPC:CustomThink()
end

-- Called continiously when thinking is enabled
function NPC:AIThink()
end

-- Called continiously --
-- But EVERY server tick --
-- Should be used sparingly! --
function NPC:CustomFrameTick()
end

--[[
==================================================================================================
                                           TAKE DAMAGE FUNCTIONS
==================================================================================================
--]]

-- On NPC hurt, dmginfo:ScaleDamage(0) to prevent damage --
-- HitGroup = HITGROUP_GENERIC || HITGROUP_HEAD || HITGROUP_CHEST || HITGROUP_STOMACH || HITGROUP_LEFTARM
-- || HITGROUP_RIGHTARM || HITGROUP_LEFTLEG || HITGROUP_RIGHTLEG || HITGROUP_GEAR
function NPC:CustomTakeDamage( dmginfo, HitGroup )
end

-- On armor hit --
-- HitGroup = HITGROUP_GENERIC || HITGROUP_HEAD || HITGROUP_CHEST || HITGROUP_STOMACH || HITGROUP_LEFTARM
-- || HITGROUP_RIGHTARM || HITGROUP_LEFTLEG || HITGROUP_RIGHTLEG || HITGROUP_GEAR
function NPC:HitArmor( dmginfo, HitGroup )
    -- Check that damage type can be blocked by armor
    if !(dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_BUCKSHOT)) then return end

    if self.ArmorAlwaysPenDamage && dmginfo:GetDamage() >= self.ArmorAlwaysPenDamage then
        -- Penetrated armor because of high damage

        dmginfo:ScaleDamage(self.ArmorPenDamageMult)
        return
    end

    if !self.ArmorPenChance or math.random(1, self.ArmorPenChance) != 1 then
        -- Armor deflect

        if self.ArmorHitSpark && ZBCVAR.ArmorSparks:GetBool() then
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
        -- Penetrated armor
        dmginfo:ScaleDamage(self.ArmorPenDamageMult)
    end
end

-- Called when the NPC hurts an entity, return true to prevent damage --
function NPC:CustomDealDamage( victimEnt, dmginfo )
end

-- Called when the NPC kills another entity (player or NPC)
function NPC:CustomOnKilledEnt( ent )
end

--[[
==================================================================================================
                                           FLINCH FUNCTIONS
==================================================================================================
--]]

-- Called before the NPC flinches
-- Only called on ZBase flinches, not from engine ones
-- Return false to prevent the flinch
function NPC:OnFlinch(dmginfo, HitGroup, flinchAnim)
end

-- Called before the NPC flinches
-- Only called on ZBase flinches, not from engine ones
-- Return a animation to be used instead of the ones from the FlinchAnimations table (string sequence, or number activity)
function NPC:GetFlinchAnimation(dmginfo, HitGroup)
    return table.Random(self.FlinchAnimations)
end

-- Animation code
function NPC:FlinchAnimation( anim )
    return self:PlayAnimation(anim, false, {
        speedMult=self.FlinchAnimationSpeed,
        isGesture=self.FlinchIsGesture,
        face = false,
        noTransitions = true,
    })
end

--[[
==================================================================================================
                                           MELEE ATTACK FUNCTIONS
==================================================================================================
--]]

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

-- Force to apply to entities affected by the melee attack damage, relative to the NPC
function NPC:MeleeDamageForce( dmgData )
    -- Example:
    -- return {forward=500, up=500, right=0, randomness=100}
end

-- Called when a melee attack is started
function NPC:OnMelee()
end

-- Called before a melee attack is started
-- Return true to prevent it
function NPC:PreventMeleeAttack()
    return false 
end

-- Called when the melee damage code is ran
-- 'hitEnts' table of entities affected by the damage, can be empty
function NPC:OnMeleeAttackDamage( hitEnts )
end

-- Animation code
function NPC:MeleeAnimation()
    return self:PlayAnimation(table.Random(self.MeleeAttackAnimations), self.MeleeAttackFaceEnemy, {
        speedMult=self.MeleeAttackAnimationSpeed,
        turnSpeed=self.MeleeAttackTurnSpeed,
        face=self.MeleeEntToFace,
        noTransitions = true,
    })
end

-- Animation code for melee weapons
function NPC:Weapon_MeleeAnim()
    return self:PlayAnimation(table.Random(self.MeleeWeaponAnimations), true,  {
        noTransitions = true,
    })
end

--[[
==================================================================================================
                                           RANGE ATTACK FUNCTIONS
==================================================================================================
--]]

-- The range attack projectile code
-- Called by the base, but can be called whenever you like
function NPC:RangeAttackProjectile()
    local projStartPos = self:Projectile_SpawnPos()

    -- Projectile code --
    local proj = ents.Create("zb_projectile")
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

-- The velocity to apply to the projectile when it spawns
function NPC:RangeAttackProjectileVelocity()
    local startPos = self:Projectile_SpawnPos()

    if self.RangeProjectile_Inaccuracy > 0 then
        startPos = startPos + VectorRand()*self.RangeProjectile_Inaccuracy
    end

    return (self:Projectile_TargetPos() - startPos):GetNormalized()*self.RangeProjectile_Speed  
end

-- Called continiusly if the NPC has a range attack
-- Useful for changing things about the range attack based on given conditions
function NPC:MultipleRangeAttacks()
end

-- Called when a range attack is started
function NPC:OnRangeAttack()
end

-- Called before a range attack is started
-- Return true to prevent it
function NPC:PreventRangeAttack()
    return false 
end

-- Animation code
function NPC:RangeAttackAnimation()
    local rangeAttack = self.RangeAttackAnimations

    if ( istable(rangeAttack) ) then
        rangeAttack = rangeAttack[math.random(1, #rangeAttack)]
    end

    return self:PlayAnimation(rangeAttack, false, {
        speedMult = self.RangeAttackAnimationSpeed,
        turnSpeed = self.RangeAttackTurnSpeed,
        noTransitions = true,
    })
end

--[[
==================================================================================================
                                           GRENADE ATTACK
==================================================================================================
--]]

-- The position to spawn the grenade at
function NPC:GrenadeSpawnPos()
    local attachment = self.GrenadeAttachment

    if ( istable(attachment) ) then
        attachment = attachment[math.random(1, #attachment)]
    end

    return self:GetAttachment(self:LookupAttachment(self.GrenadeAttachment)).Pos
end

-- The velocity to apply to the grenade
function NPC:GrenadeVelocity()
    local StartPos = self:GrenadeSpawnPos()
    local EndPos = self:GetEnemyLastSeenPos()

    local UpAmount = math.Clamp(EndPos.z - StartPos.z, 150, 10000)

    return (EndPos - StartPos)+Vector(0, 0, UpAmount)
end

-- Animation code
function NPC:GrenadeAnimation()
    local grenadeAnim = self.GrenadeAttackAnimations

    if ( istable(grenadeAnim) ) then
        grenadeAnim = grenadeAnim[math.random(1, #grenadeAnim)]
    end

    return self:PlayAnimation(grenadeAnim, true, {noTransitions = true})
end

-- Called when the grenade entity spawned, allowing you to do stuff with it
function NPC:OnGrenadeSpawned( grenade )
end

--[[
==================================================================================================
                                           WEAPON FUNCTIONS
==================================================================================================
--]]

-- Called when the NPC fires its weapon
function NPC:OnFireWeapon()
end

-- Called when the NPC wants to fire its weapon
-- Return false to prevent it from doing so
function NPC:ShouldFireWeapon()
    return true
end

-- Called when the NPC fires a bullet
-- return true to apply changes to the bulletData table
-- return false to disallow the bullet
function NPC:OnFireBullet( bulletData )
end

--[[
==================================================================================================
                                           AI GENERAL
==================================================================================================
--]]

-- Called when the NPC's enemy is updated
-- 'enemy' - The new enemy, or nil if the enemy was lost
function NPC:EnemyStatus( enemy )
end

-- Called when the NPC reacts to a sound
-- Only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
-- 'loudness' How loud the NPC percieved the sound to be
-- NPC_HEAR_BANG = 1 - Like a gunshot
-- NPC_HEAR_VOICE = 2 - Like a human voice
-- NPC_HEAR_STEP = 3 - Like footsteps
-- NPC_HEAR_QUIET = 4 - Not loud
function NPC:OnReactToSound(Emitter, pos, loudness)
end

-- Called when the NPC follows or unfollows a player
-- 'ply' - The player to follow, or NULL if the player was unfollowed
function NPC:FollowPlayerStatus( ply )
end

-- Called when the NPC calls an ally outside their squad for help
function NPC:OnAlertAllies( ally )
end

-- Called when the base is detecting a danger
-- https://wiki.facepunch.com/gmod/Structures/SoundHintData
function NPC:OnDangerDetected( DangerHint )
end

-- Called when the base detects that the NPC is playing a new activity
function NPC:CustomNewActivityDetected( act )
end

-- Called when the base detects that the NPC is playing a new sequence
function NPC:CustomNewSequenceDetected( sequence, SequenceName )
end

-- Called when the base detects that the NPC is playing a new schedule
function NPC:CustomNewSchedDetected( sched, oldSched )
end

-- Called when the base plays an animation (from NPC:PlayAnimation() that is)
-- 'anim' - The sequence (as a string) or activity (https://wiki.facepunch.com/gmod/Enums/ACT) to play
-- 'faceEnemy' - True if it should constantly face enemy while the animation is playing
-- 'extraData' (table)
    -- extraData.isGesture - If true, it will play the animation as a gesture
    -- extraData.face - Position or entity to constantly face, if set to false, it will face the direction it started the animation in
    -- extraData.speedMult - Speed multiplier for the animation
    -- extraData.duration - The animation duration
    -- extraData.faceSpeed - Face turn speed
    -- extraData.noTransitions - If true, it won't do any transition animations
function NPC:OnPlayAnimation( anim, faceEnemy, extraData )
end

-- Called when the base ends an animation (from NPC:PlayAnimation() that is, including transition animations)
function NPC:OnAnimEnded( anim, faceEnemy, extraData )
end

-- Called when the base plays an animation (from NPC:PlayAnimation() that is),
-- but the animation fails at some point
-- 'seq' - The sequence that failed
function NPC:OnPlayAnimationFailed( seq )
end

-- Called a tick after an entity owned by this NPC is created
-- Very useful for replacing a combine's grenades or a hunter's flechettes or something of that nature
function NPC:CustomOnOwnedEntCreated( ent )
end

-- Called a tick after child entity of this NPC is spawned
-- Similiar to the function above
function NPC:CustomOnParentedEntCreated( ent )
end

-- Accept input, return true to prevent
function NPC:CustomAcceptInput( input, activator, caller, value )
end

-- Called when the NPC notices that an entity is trying to do some kind of range attack on it
-- Like shooting it with a gun or something
function NPC:OnRangeThreatened( ent )
end

-- Tries to override the movement activity
-- Return any activity to override the movement activity with said activity
-- Return false to not override
function NPC:OverrideMovementAct()
    return false
end

-- Called when the base decides how this NPC should feel about another entity
-- Return false to prevent the relationship change
-- https://wiki.facepunch.com/gmod/Enums/D
function NPC:CustomOnBaseSetRel(ent, rel)
    return true
end

-- Called when a player presses their USE key on the NPC
function NPC:OnUse(ply)
end

-- Called when an ally dies
function NPC:OnAllyDeath(ally)
end

-- Your hook for handling custom defined LUA animation events
-- Add new animation events by calling:
-- self:AddAnimationEvent("your_animation", your_frame, your_event_id),
-- in CustomInitialize
function NPC:HandleLUAAnimationEvent(seq, ev) 
end

--[[
==================================================================================================
                                           SNPC ONLY FUNCTIONS
==================================================================================================
--]]

-- Select schedule
-- Here you can change how the SNPC should behave entirely
-- This function is called whenever the SNPC isn't doing a schedule, allowing you to set it to whatever schedule you want
-- Do so by returning said schedule
-- Engine schedules: https://wiki.facepunch.com/gmod/Enums/SCHED
-- Supports any custom schedule!
function NPC:SNPCSelectSchedule(iNPCState)
    -- Example:
    local ene = self:GetEnemy()

    if IsValid(ene) then
        -- ZBase advanced chase schedule
        -- Strongly recommended if you want the SNPC to chase the enemy
        return ZSched.CombatChase

    else
        -- No enemy, just stand in idle
        return SCHED_IDLE_STAND

    end
end

-- Do this when we are too close to the enemy for chase
-- Return a engine or custom schedule to set schedule
-- Engine schedules: https://wiki.facepunch.com/gmod/Enums/SCHED
function NPC:SNPCChase_TooClose()
    -- Stand still and face enemy if we are too close
    return ZSched.CombatFace
end

-- Called when the SNPC takes damage
function NPC:SNPCOnHurt(dmginfo)
    -- Example:
	if !IsValid(self:GetEnemy()) then

        -- Face the direction of the damage
		self:FaceHurtPos(dmginfo)

	end
end

-- Called when an animation event is fired
function NPC:SNPCHandleAnimEvent(event, eventTime, cycle, type, option)
    -- Example:

    -- if event == 5 then
    --     self:MeleeAttackDamage()
    -- end
end

-- Called continiusly for flying SNPCs
-- You can change anything about their flying velocity here
function NPC:SNPCFlyVelocity(destinationDirection, destinationCurrentSpeed)
    return destinationDirection*destinationCurrentSpeed
end

--[[
==================================================================================================
                                           SOUND FUNCTIONS
==================================================================================================
--]]

-- Called before emitting a sound
-- Return a new sound name to play that sound instead.
-- Return false to prevent the sound from playing.
function NPC:BeforeEmitSound( sndData, sndVarName )
end

-- Called after a sound is going to be emitted
function NPC:CustomOnSoundEmitted( sndData, duration, sndVarName )
end

-- Timer based foot steps
function NPC:FootStepTimer()
    if !self:IsMoving_Cheap() then return end
    if self.HasEngineFootSteps then return end

    self:EmitFootStepSound()

    -- Set footstep cooldown
    if string.find(self:GetCurrentActivityName(), "ACT_RUN") then
        -- Run animation, do faster steps
        self.NextFootStepTimer = CurTime()+self.FootStepSoundDelay_Run

    else
        -- Walk animation probably, do slower steps
        self.NextFootStepTimer = CurTime()+self.FootStepSoundDelay_Walk

    end
end

-- Called when the NPC is trying to do a footstep sound
-- Not all NPCs do this
function NPC:OnEngineFootStep()
    self:EmitSound(self.FootStepSounds)
    self.HasEngineFootSteps = true
end

--[[
==================================================================================================
                                           DEATH/REMOVAL
==================================================================================================
--]]

-- Called before death
-- Return true to not spawn ragdoll
-- Create gibs here
function NPC:ShouldGib( dmginfo, hit_gr )
end

-- Called after death
-- You can do stuff with its ragdoll here if it has any (remember to check if it's valid!)
-- This may not get called for all NPC classes
function NPC:CustomOnDeath( dmginfo, hit_gr, rag )
end

-- Death animation code
function NPC:DeathAnimation_Animation()
    return self:PlayAnimation(table.Random(self.DeathAnimations), false, {
        speedMult=self.DeathAnimationSpeed,
        face=false,
        duration=self.DeathAnimationDuration,
        noTransitions = true,
        freezeForever = self.DeathAnimationDuration==false,
        onFinishFunc = function() self:InduceDeath() end, -- Kill NPC when the animation ends
    })
end

-- Called when the NPC is removed
function NPC:OnRemove()
end