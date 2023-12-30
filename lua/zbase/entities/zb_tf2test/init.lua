local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.Models = {"models/player/soldier.mdl"}


NPC.StartHealth = 60 -- Max health


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "none"


NPC.WeaponFire_Activities = {2264} -- The NPC will randomly switch between these activities when firing their weapon
NPC.WeaponFire_MoveActivities = {ACT_MP_WALK, ACT_MP_RUN} -- The NPC will randomly switch between these activities when firing their weapon

NPC.WeaponFire_DoGesture = false -- Should it play a gesture animation everytime it fires the weapon when standing still?
NPC.WeaponFire_DoGesture_Moving = true -- Should it play a gesture animation everytime it fires the weapon when moving?
NPC.WeaponFire_Gestures = {1155} -- The gesture animations to play



--[[
==================================================================================================
                                           MELEE ATTACK
==================================================================================================
--]]


NPC.BaseMeleeAttack = true -- Use ZBase melee attack system
NPC.MeleeAttackFaceEnemy = true -- Should it face enemy while doing the melee attack?
NPC.MeleeAttackTurnSpeed = 15 -- Speed that it turns while trying to face the enemy when melee attacking
NPC.MeleeAttackDistance = 75 -- Distance that it initiates the melee attack from
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}
NPC.MeleeAttackName = "" -- Serves no real purpose, you can use it for whatever you want


NPC.MeleeAttackAnimations = {"taunt_yeti"} -- Example: NPC.MeleeAttackAnimations = {ACT_MELEE_ATTACK1}
NPC.MeleeAttackAnimationSpeed = 1 -- Speed multiplier for the melee attack animation


NPC.MeleeDamage = {10, 10} -- Melee damage {min, max}
NPC.MeleeDamage_Distance = 100 -- Damage reach distance
NPC.MeleeDamage_Angle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
NPC.MeleeDamage_Delay = 1 -- Time until the damage strikes, set to false to disable the timer (if you want to use animation events instead for example)
NPC.MeleeDamage_Type = DMG_GENERIC -- The damage type, https://wiki.facepunch.com/gmod/Enums/DMG
NPC.MeleeDamage_Sound = "ZBase.Melee2" -- Sound when the melee attack hits an enemy
NPC.MeleeDamage_Sound_Prop = "ZBase.Melee2" -- Sound when the melee attack hits props
NPC.MeleeDamage_AffectProps = false -- Affect props and other entites



--]]==============================================================================================]]
function NPC:CustomInitialize()

    -- self:GetSequenceActivityName( self:LookupSequence("CROUCH_PRIMARY") )
    for k, v in pairs(self:GetSequenceList()) do
        print(k, v, self:GetSequenceActivityName(k), self:GetSequenceActivity(k))
    end
end
--]]==============================================================================================]]