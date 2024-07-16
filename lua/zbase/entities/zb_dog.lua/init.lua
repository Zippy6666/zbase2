local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.StartHealth = 2000 -- Max health

-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "ally"

NPC.MoveSpeedMultiplier = 1.25 -- Multiply the NPC's movement speed by this amount (ground NPCs)

NPC.BloodColor = BLOOD_COLOR_MECH -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER

NPC.HullType = HULL_LARGE -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL
NPC.CollisionBounds = {min=Vector(-40, -40, 0), max=Vector(40, 40, 80)} -- Example: NPC.CollisionBounds = {min=Vector(-50, -50, 0), max=Vector(50, 50, 100)}, false = default

NPC.BaseMeleeAttack = true -- Use ZBase melee attack system
NPC.MeleeAttackFaceEnemy = false -- Should it face enemy while doing the melee attack?
NPC.MeleeAttackTurnSpeed = 15 -- Speed that it turns while trying to face the enemy when melee attacking
NPC.MeleeAttackDistance = 200 -- Distance that it initiates the melee attack from
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}
NPC.MeleeAttackName = "" -- Serves no real purpose, you can use it for whatever you want


NPC.MeleeAttackAnimations = {"pound"} -- Example: NPC.MeleeAttackAnimations = {ACT_MELEE_ATTACK1}
NPC.MeleeAttackAnimationSpeed = 2 -- Speed multiplier for the melee attack animation


NPC.MeleeDamage = {50, 50} -- Melee damage {min, max}
NPC.MeleeDamage_Distance = 500 -- Damage reach distance
NPC.MeleeDamage_Angle = 360 -- Damage angle (180 = everything in front of the NPC is damaged)
NPC.MeleeDamage_Delay = 1 -- Time until the damage strikes, set to false to disable the timer (if you want to use animation events instead for example)
NPC.MeleeDamage_Type = DMG_CLUB -- The damage type, https://wiki.facepunch.com/gmod/Enums/DMG
NPC.MeleeDamage_Sound = "ZBase.Melee2" -- Sound when the melee attack hits an enemy
NPC.MeleeDamage_Sound_Prop = "ZBase.Melee2" -- Sound when the melee attack hits props
NPC.MeleeDamage_AffectProps = false -- Affect props and other entites

NPC.FootStepSounds = "NPC_dog.RunFootstepLeft"


    -- Called when the base detects that the NPC is playing a new schedule
function NPC:CustomNewSchedDetected( sched, oldSched )
    if self:SeeEne() && sched == SCHED_TAKE_COVER_FROM_ENEMY then
        self:SetSchedule(SCHED_CHASE_ENEMY)
    end
end