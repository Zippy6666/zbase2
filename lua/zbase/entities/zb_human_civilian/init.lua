local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.WeaponProficiency = WEAPON_PROFICIENCY_AVERAGE -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.StartHealth = 30 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour


NPC.ZBaseStartFaction = "ally" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"


NPC.CanSecondaryAttack = false -- Can use weapon secondary attacks


NPC.BaseMeleeAttack = true
NPC.MeleeAttackAnimations = {"swing"}
NPC.MeleeWeaponAnimations = {"swing"} -- Animations to use when attacking with a melee weapon
NPC.MeleeAttackAnimationSpeed = 1
NPC.MeleeDamage_Delay = 0.5 -- Time until the damage strikes


NPC.BaseRangeAttack = true -- Use ZBase range attack system
NPC.RangeAttackFaceEnemy = true -- Should it face enemy while doing the range attack?
NPC.RangeAttackTurnSpeed = 20 -- Speed that it turns while trying to face the enemy when range attacking
NPC.RangeAttackDistance = {200, 1500} -- Distance that it initiates the range attack {min, max}
NPC.RangeAttackCooldown = {2, 3} -- Range attack cooldown {min, max}
NPC.RangeAttackSuppressEnemy = false -- If the enemy can't be seen, target the last seen position

NPC.RangeAttackAnimations = {"throw1"} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeAttackAnimationSpeed = 1.5 -- Speed multiplier for the range attack animation


-- Time until the projectile code is ran
-- Set to false to disable the timer (if you want to use animation events instead for example)
NPC.RangeProjectile_Delay = 0.75


-- Attachment to spawn the projectile on 
-- If set to false the projectile will spawn from the NPCs center
NPC.RangeProjectile_Attachment = "anim_attachment_RH"
NPC.RangeProjectile_Offset = false -- Projectile spawn offset, example: {forward=50, up=25, right=0}
NPC.RangeProjectile_Speed = 1200 -- The speed of the projectile
NPC.RangeProjectile_Inaccuracy = 20 -- Inaccuracy, 0 = perfect, higher numbers = less accurate


NPC.AlertSounds = "ZBaseMale.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.KilledEnemySounds = "ZBaseMale.KillEnemy" -- Sounds emitted when the NPC kills an enemy
NPC.OnMeleeSounds = "ZBaseMale.Melee" -- Sounds emitted when the NPC does its melee attack
NPC.OnRangeSounds = "ZBaseMale.Melee"
NPC.OnGrenadeSounds = "ZBaseMale.Grenade" -- Sounds emitted when the NPC throws a grenade

-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseMale.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseMale.Answer" -- Dialogue answers, emitted when the NPC is spoken to


-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseMale.HearSound"


NPC.FollowPlayerSounds = "ZBaseMale.Follow" -- Sounds emitted when the NPC starts following a player
NPC.UnfollowPlayerSounds = "ZBaseMale.Unfollow" -- Sounds emitted when the NPC stops following a player


NPC.OnMeleeSound_Chance = 2
NPC.OnRangeSound_Chance = 3


NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC


--]]==============================================================================================]]
function NPC:CustomInitialize()
end
--]]==============================================================================================]]
function NPC:RangeAttackProjectile()
    local projStartPos = self:Projectile_SpawnPos()

    local proj = ents.Create("zb_rock")
    proj:SetPos(projStartPos)
    proj:SetAngles(self:GetAngles())
    proj:SetOwner(self)
    proj:Spawn()

    local proj_phys = proj:GetPhysicsObject()
    if IsValid(proj_phys) then
        proj_phys:SetVelocity(self:RangeAttackProjectileVelocity()+Vector(0, 0, 200))
    end
end
--]]==============================================================================================]]
function NPC:PreventRangeAttack()
    return IsValid(self:GetActiveWeapon()) or !self:IsFacing(self:GetEnemy(), 45)
end
--]]==============================================================================================]]