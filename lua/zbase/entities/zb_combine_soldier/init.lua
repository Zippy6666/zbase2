local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.StartHealth = 50 -- Max health



NPC.CanPatrol = true -- Use base patrol behaviour


NPC.ZBaseStartFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied


NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
}


NPC.m_nKickDamage = 15


NPC.BaseGrenadeAttack = true -- Use ZBase grenade attack system
NPC.ThrowGrenadeChance_Visible = 4 -- 1/x chance that it throws a grenade when the enemy is visible
NPC.ThrowGrenadeChance_Occluded = 2 -- 1/x chance that it throws a grenade when the enemy is not visible
NPC.GrenadeCoolDown = {4, 8} -- {min, max}
NPC.GrenadeAttackAnimations = {"grenthrow"} -- Grenade throw animation
NPC.GrenadeEntityClass = "npc_grenade_frag" -- The grenade to throw, can be anything, like a fucking cat or somthing
NPC.GrenadeReleaseTime = 0.85 -- Time until grenade leaves the hand
NPC.GrenadeAttachment = "anim_attachment_LH" -- The attachment to spawn the grenade on
NPC.GrenadeMaxSpin = 1000 -- The amount to spin the grenade measured in spin units or something idfk


-- Sounds (Use sound scripts to alter pitch and level and such!)
NPC.AlertSounds = "ZBaseCombine.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "ZBaseCombine.Idle" -- Sounds emitted while there is no enemy
NPC.Idle_HasEnemy_Sounds = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "" -- Sounds emitted on hurt
NPC.DeathSounds = "" -- Sounds emitted on death
NPC.KilledEnemySounds = "ZBaseCombine.KillEnemy" -- Sounds emitted when the NPC kills an enemy


NPC.LostEnemySounds = "ZBaseCombine.LostEnemy" -- Sounds emitted when the enemy is lost
NPC.SeeDangerSounds = "" -- Sounds emitted when the NPC spots a danger, such as a flaming barrel
NPC.SeeGrenadeSounds = "" -- Sounds emitted when the NPC spots a grenade
NPC.AllyDeathSounds = "" -- Sounds emitted when an ally dies
NPC.OnMeleeSounds = "" -- Sounds emitted when the NPC does its melee attack
NPC.OnRangeSounds = "" -- Sounds emitted when the NPC does its range attack
NPC.OnReloadSounds = "ZBaseCombine.Reload" -- Sounds emitted when the NPC reloads


-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseCombine.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseCombine.Answer" -- Dialogue answers, emitted when the NPC is spoken to


-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseCombine.HearSound"


--]]==============================================================================================]]
function NPC:CustomInitialize()
    local ACT_WALK_EASY = self:GetSequenceActivity(self:LookupSequence("walkeasy_all"))
    self.MoveActivityOverride = {[NPC_STATE_IDLE] = ACT_WALK_EASY}
end
--]]==============================================================================================]]
function NPC:CustomThink()
end
--]]==============================================================================================]]
function NPC:CustomOnEmitSound( sndData, sndVarName )
end
--]]==============================================================================================]]