local NPC = FindZBaseTable(debug.getinfo(1,'S'))
local col = Color(255, 255, 0)

NPC.StartHealth = 100 -- Max health
NPC.Models = {"models/antlion.mdl"}

NPC.SNPCType = ZBASE_SNPCTYPE_FLY -- SNPC Type: ZBASE_SNPCTYPE_WALK || ZBASE_SNPCTYPE_FLY
NPC.Fly_DistanceFromGround = 110 -- Minimum distance to try to keep from the ground when flying
NPC.Fly_DistanceFromGround_IgnoreWhenMelee = false -- Should it ignore the distance from ground limit when in melee attack distance?
NPC.Fly_FaceEnemy = true -- Should it face the enemy while fly moving?
NPC.Fly_MoveSpeed = 500 -- Flying movement speed
NPC.Fly_Accelerate = 40 -- Flying movement accelerate speed
NPC.Fly_Decelerate = 10 -- Flying movement decelerate speed
NPC.Fly_GravGunPuntForceMult = 1 -- How much should the flying SNPC be affected by the gravity gun push attack?

NPC.BaseMeleeAttack = false -- Use ZBase melee attack system

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