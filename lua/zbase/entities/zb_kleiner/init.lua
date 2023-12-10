local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.StartHealth = 100 -- Max health


-- Health regen
NPC.HealthRegenAmount = 1
NPC.HealthCooldown = 0.2


NPC.WeaponProficiency = WEAPON_PROFICIENCY_PERFECT -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "ally"


NPC.BaseMeleeAttack = true
NPC.MeleeAttackAnimations = {"meleeattack01"}
NPC.MeleeAttackAnimationSpeed = 1
NPC.MeleeDamage_Delay = 0.5 -- Time until the damage strikes


-- Sounds (Use sound scripts to alter pitch and level and such!)
NPC.AlertSounds = "ZBaseKleiner.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "" -- Sounds emitted while there is no enemy
NPC.Idle_HasEnemy_Sounds = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "" -- Sounds emitted on hurt
NPC.DeathSounds = "ZBaseKleiner.Die" -- Sounds emitted on death
NPC.KilledEnemySounds = "ZBaseKleiner.KillEnemy" -- Sounds emitted when the NPC kills an enemy


NPC.LostEnemySounds = "" -- Sounds emitted when the enemy is lost
NPC.SeeDangerSounds = "ZBaseKleiner.SeeDanger" -- Sounds emitted when the NPC spots a danger, such as a flaming barrel
NPC.SeeGrenadeSounds = "" -- Sounds emitted when the NPC spots a grenade
NPC.AllyDeathSounds = "ZBaseKleiner.AllyDeath" -- Sounds emitted when an ally dies
NPC.OnMeleeSounds = "" -- Sounds emitted when the NPC does its melee attack
NPC.OnRangeSounds = "" -- Sounds emitted when the NPC does its range attack
NPC.OnReloadSounds = "" -- Sounds emitted when the NPC reloads


-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseKleiner.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseKleiner.Answer" -- Dialogue answers, emitted when the NPC is spoken to


-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseKleiner.HearDanger"


NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC


--]]==============================================================================================]]
function NPC:CustomInitialize()

end
--]]==============================================================================================]]