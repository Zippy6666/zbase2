local NPC = FindZBaseTable(debug.getinfo(1,'S'))


-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {"models/mortarsynth.mdl"}
NPC.CollisionBounds = {min=Vector(-26, -26, -26), max=Vector(26, 26, 26)}
NPC.HullType = HULL_SMALL_CENTERED -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL
NPC.SNPCType = ZBASE_SNPCTYPE_FLY -- ZBASE_SNPCTYPE_WALK || ZBASE_SNPCTYPE_FLY || ZBASE_SNPCTYPE_STATIONARY

NPC.BloodColor = DONT_BLEED -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER


NPC.ZBaseStartFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody


NPC.BaseRangeAttack = true -- Use ZBase range attack system
NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeAttackCooldown = {3, 6} -- Range attack cooldown {min, max}
NPC.RangeAttackDistance = {0, 3000} -- Distance that it initiates the range attack {min, max}

-- Attachment to spawn the projectile on 
-- If set to false the projectile will spawn from the NPCs center
-- NPC.RangeProjectile_Attachment = "1"

NPC.RangeProjectile_Speed = 750 -- The speed of the projectile
NPC.RangeProjectile_Inaccuracy = 15 -- Inaccuracy, 0 = perfect, higher numbers = less accurate