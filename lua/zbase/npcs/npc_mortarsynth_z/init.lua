local NPC = FindZBaseTable(debug.getinfo(1,'S'))


-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {"models/zippy/mortarsynth.mdl"}
NPC.CollisionBounds = {min=Vector(-30, -30, -30), max=Vector(30, 30, 30)}
NPC.HullType = HULL_LARGE_CENTERED -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL
NPC.SNPCType = ZBASE_SNPCTYPE_FLY -- ZBASE_SNPCTYPE_WALK || ZBASE_SNPCTYPE_FLY || ZBASE_SNPCTYPE_STATIONARY

NPC.BloodColor = DONT_BLEED
NPC.CustomBloodParticles = {"blood_impact_synth_01"} -- Table of custom particles
NPC.CustomBloodDecals = "ZBaseBloodSynth" -- String name of custom decal


NPC.ZBaseStartFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody


NPC.BaseRangeAttack = true -- Use ZBase range attack system
NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeAttackCooldown = {1, 1} -- Range attack cooldown {min, max}
NPC.RangeAttackDistance = {0, 3000} -- Distance that it initiates the range attack {min, max}

-- Attachment to spawn the projectile on 
-- If set to false the projectile will spawn from the NPCs center
-- NPC.RangeProjectile_Attachment = "1"

NPC.RangeProjectile_Speed = 750 -- The speed of the projectile
NPC.RangeProjectile_Inaccuracy = 15 -- Inaccuracy, 0 = perfect, higher numbers = less accurate


--]]==============================================================================================]]
function NPC:CustomInitialize()
end
--]]==============================================================================================]]