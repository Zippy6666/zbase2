local NPC = FindZBaseTable(debug.getinfo(1,'S'))
local col = Color(255, 255, 0)

NPC.StartHealth = 100 -- Max health
NPC.Models = {"models/antlion.mdl"}

NPC.SNPCType = ZBASE_SNPCTYPE_FLY -- SNPC Type: ZBASE_SNPCTYPE_WALK || ZBASE_SNPCTYPE_FLY
NPC.Fly_DistanceFromGround = 60 -- Minimum distance to try to keep from the ground when flying
NPC.Fly_DistanceFromGround_IgnoreWhenMelee = true -- Should it ignore the distance from ground limit when in melee attack distance?
NPC.Fly_FaceEnemy = false -- Should it face the enemy while fly moving?
NPC.Fly_MoveSpeed = 500 -- Flying movement speed
NPC.Fly_Accelerate = 40 -- Flying movement accelerate speed
NPC.Fly_Decelerate = 40 -- Flying movement decelerate speed
NPC.Fly_GravGunPuntForceMult = 1 -- How much should the flying SNPC be affected by the gravity gun push attack?

NPC.BaseMeleeAttack = true -- Use ZBase melee attack system
NPC.MeleeAttackFaceEnemy = true -- Should it face enemy while doing the melee attack?
NPC.MeleeAttackTurnSpeed = 15 -- Speed that it turns while trying to face the enemy when melee attacking
NPC.MeleeAttackDistance = 110 -- Distance that it initiates the melee attack from
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}
NPC.MeleeAttackName = "" -- Serves no real purpose, you can use it for whatever you want

NPC.MeleeAttackAnimations = {"drown"} -- Example: NPC.MeleeAttackAnimations = {ACT_MELEE_ATTACK1}
NPC.MeleeAttackAnimationSpeed = 1.2 -- Speed multiplier for the melee attack animation

NPC.MeleeDamage = {20, 20} -- Melee damage {min, max}
NPC.MeleeDamage_Distance = 120 -- Damage reach distance
NPC.MeleeDamage_Angle = 180 -- Damage angle (180 = everything in front of the NPC is damaged)
NPC.MeleeDamage_Delay = 0.4 -- Time until the damage strikes, set to false to disable the timer (if you want to use animation events instead for example)
NPC.MeleeDamage_Type = DMG_GENERIC -- The damage type, https://wiki.facepunch.com/gmod/Enums/DMG
NPC.MeleeDamage_Sound = "ZBase.Melee2" -- Sound when the melee attack hits an enemy
NPC.MeleeDamage_Sound_Prop = "ZBase.Melee2" -- Sound when the melee attack hits props
NPC.MeleeDamage_AffectProps = false -- Affect props and other entites

-- Minimum distance it chases before doing it runs SNPCChase_TooClose
-- SNPCChase_TooClose will by default cause the SNPC to stop and face the enemy
NPC.ChaseMinDistance = 0

-- Default engine blood color, set to DONT_BLEED if you want to use custom blood instead
NPC.BloodColor = BLOOD_COLOR_ANTLION_WORKER -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER
NPC.CustomBloodParticles = {"blood_impact_zbase_green"} -- Table of custom particles
NPC.CustomBloodDecals = "ZBaseBloodGreen" -- String name of custom decal

NPC.SubMaterials = {
    [2] = "models/antlionspitter/antlionhigh_sheet2",
}

-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "antlion"

NPC.GibMaterial = "models/antlionspitter/antlionhigh_sheet2"
NPC.GibParticle = "blood_impact_zbase_green"

function NPC:CustomInitialize()
    self:SetColor(col)
    self:SetSkin(1)
    self:SetBodygroup(1,1)
    self:EmitSound("NPC_Antlion.WingsOpen")
    self.FlyWobbleTimeMlt = math.Rand(4, 7)
end

-- Called continiusly for flying SNPCs
-- You can change anything about their flying velocity here
function NPC:SNPCFlyVelocity(destinationDirection, destinationCurrentSpeed)
    -- Fly anim
    if !self:BusyPlayingAnimation() then
        self:SetActivity(ACT_GLIDE)
    end

    -- Wobble
    local flyvel = destinationDirection*destinationCurrentSpeed
    local sin1 = math.sin(CurTime()*self.FlyWobbleTimeMlt)*40
    flyvel = flyvel + Vector(0, 0, sin1)

    return flyvel
end

-- Called after death
-- You can do stuff with its ragdoll here if it has any (remember to check if it's valid!)
-- This may not get called for all NPC classes
function NPC:CustomOnDeath( dmginfo, hit_gr, rag )
            -- local pos = self:GetPos()
            -- effects.BeamRingPoint( pos, 1, 0, 500, 20, 1, col )
            -- effects.BeamRingPoint( pos, 0.25, 0, 1000, 30, 1, col )
            -- util.BlastDamageInfo(conv.damageBasic(100, DMG_BLAST+DMG_DISSOLVE+DMG_SHOCK, pos, self), pos, 500)
end

function NPC:OnRemove()
    self:StopSound("NPC_Antlion.WingsOpen")
end