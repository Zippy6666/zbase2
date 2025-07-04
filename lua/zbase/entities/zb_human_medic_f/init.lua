local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.SpawnFlagTbl = {SF_CITIZEN_RANDOM_HEAD_FEMALE, SF_CITIZEN_MEDIC}

NPC.AlertSounds = "ZBaseFemale.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.KilledEnemySounds = "ZBaseFemale.KillEnemy" -- Sounds emitted when the NPC kills an enemy
NPC.OnMeleeSounds = "ZBaseFemale.Melee" -- Sounds emitted when the NPC does its melee attack
NPC.OnRangeSounds = "ZBaseFemale.Melee"
NPC.OnGrenadeSounds = "ZBaseFemale.Grenade" -- Sounds emitted when the NPC throws a grenade

NPC.AllyDeathSounds = "ZBaseFemale.AllyDeath"

-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseFemale.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseFemale.Answer" -- Dialogue answers, emitted when the NPC is spoken to

-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseFemale.HearSound"

NPC.FollowPlayerSounds = "ZBaseFemale.Follow" -- Sounds emitted when the NPC starts following a player
NPC.UnfollowPlayerSounds = "ZBaseFemale.Unfollow" -- Sounds emitted when the NPC stops following a player