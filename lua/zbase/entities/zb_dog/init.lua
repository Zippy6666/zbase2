local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.StartHealth = 1500 -- Max health

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
NPC.MeleeAttackDistance = 300 -- Distance that it initiates the melee attack from
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}
NPC.MeleeAttackName = "" -- Serves no real purpose, you can use it for whatever you want


NPC.MeleeAttackAnimations = {"pound"} -- Example: NPC.MeleeAttackAnimations = {ACT_MELEE_ATTACK1}
NPC.MeleeAttackAnimationSpeed = 1.5 -- Speed multiplier for the melee attack animation


NPC.MeleeDamage = {50, 50} -- Melee damage {min, max}
NPC.MeleeDamage_Distance = 400 -- Damage reach distance
NPC.MeleeDamage_Angle = 360 -- Damage angle (180 = everything in front of the NPC is damaged)
NPC.MeleeDamage_Delay = 1 -- Time until the damage strikes, set to false to disable the timer (if you want to use animation events instead for example)
NPC.MeleeDamage_Type = DMG_BLAST -- The damage type, https://wiki.facepunch.com/gmod/Enums/DMG
NPC.MeleeDamage_Sound = "" -- Sound when the melee attack hits an enemy
NPC.MeleeDamage_Sound_Prop = "" -- Sound when the melee attack hits props
NPC.MeleeDamage_AffectProps = true -- Affect props and other entites

NPC.FootStepSounds = "NPC_dog.RunFootstepLeft"



-- Sounds (Use sound scripts to alter pitch and level and such!)
NPC.AlertSounds = "NPC_dog.Angry_2" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "" -- Sounds emitted while there is no enemy
NPC.Idle_HasEnemy_Sounds = "NPC_dog.Growl_1" -- Sounds emitted while there is an enemy
NPC.PainSounds = "NPC_dog.Pain_1" -- Sounds emitted on hurt
NPC.DeathSounds = "NPC_dog.Scared_1" -- Sounds emitted on death
NPC.KilledEnemySounds = "NPC_dog.Laugh_1" -- Sounds emitted when the NPC kills an enemy


NPC.LostEnemySounds = "NPC_dog.Growl_2" -- Sounds emitted when the enemy is lost
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
NPC.HearDangerSounds = "NPC_dog.Curious_1"



    -- Called when the base detects that the NPC is playing a new schedule
function NPC:CustomNewSchedDetected( sched, oldSched )
    if self:SeeEne() && sched != SCHED_CHASE_ENEMY then
        self:SetSchedule(SCHED_CHASE_ENEMY)
    end
end

    -- Force to apply to entities affected by the melee attack damage, relative to the NPC
function NPC:MeleeDamageForce( dmgData )
    return {forward=400, up=100, right=0, randomness=200}
end

local ringCol = Color(25, 25, 25)
function NPC:D0G_Pound()
    self:EmitSound("physics/concrete/boulder_impact_hard3.wav", 140, math.random(80, 90), 1, CHAN_AUTO)

    local ef = EffectData()
    ef:SetOrigin(self:GetPos())
    ef:SetEntity(self)
    ef:SetScale(100)
    util.Effect("ThumperDust", ef, true, true)
    util.ScreenShake(self:GetPos(), 12, 200, 1, 750, true)

    effects.BeamRingPoint( self:GetPos(), 0.25, 0, 800, 70, 0, ringCol, {material="sprites/smoke"} )
end



function NPC:OnMeleeAttackDamage( hitEnts )
    self:D0G_Pound()
end