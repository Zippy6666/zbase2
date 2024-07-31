local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/zippy/ElitePolice.mdl"}
NPC.StartHealth = 60 -- Max health

NPC.WeaponProficiency = WEAPON_PROFICIENCY_PERFECT -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.BaseGrenadeAttack = true -- Use ZBase grenade attack system
NPC.ThrowGrenadeChance_Visible = 4 -- 1/x chance that it throws a grenade when the enemy is visible
NPC.ThrowGrenadeChance_Occluded = 2 -- 1/x chance that it throws a grenade when the enemy is not visible
NPC.GrenadeCoolDown = {4, 8} -- {min, max}
NPC.GrenadeAttackAnimations = {"grenadethrow"} -- Grenade throw animation
NPC.GrenadeEntityClass = "npc_grenade_frag" -- The grenade to throw, can be anything, like a fucking cat or somthing
NPC.GrenadeReleaseTime = 0.85 -- Time until grenade leaves the hand
NPC.GrenadeAttachment = "anim_attachment_LH" -- The attachment to spawn the grenade on
NPC.GrenadeMaxSpin = 1000 -- The amount to spin the grenade measured in spin units or something idfk


NPC.HasArmor = {
    [HITGROUP_CHEST] = true,
    [HITGROUP_HEAD] = true,
}


-- Items to drop on death
-- ["item_class_name"] = {chance=1/x, max=x}
NPC.ItemDrops = {
    ["item_healthvial"] = {chance=3, max=2}, -- Example, a healthvial that has a 1/2 chance of spawning
    ["item_battery"] = {chance=4, max=1}, -- Example, a healthvial that has a 1/2 chance of spawning
    ["weapon_frag"] = {chance=4, max=1},
}
NPC.ItemDrops_TotalMax = 2 -- The NPC can never drop more than this many items


NPC.MuteDefaultVoice = true -- Mute all default voice sounds emitted by this NPC
NPC.AlertSounds = "ZBaseElitePolice.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.PainSounds = "ZBaseElitePolice.Pain" -- Sounds emitted on hurt
NPC.DeathSounds = "ZBaseElitePolice.Death" -- Sounds emitted on death
NPC.KilledEnemySounds = "ZBaseElitePolice.KilledEnemy" -- Sounds emitted when the NPC kills an enemy
NPC.LostEnemySounds = "ZBaseElitePolice.LostEnemy"
NPC.SeeDangerSounds = "ZBaseElitePolice.SeeDanger"
NPC.AllyDeathSounds = "ZBaseElitePolice.AllyDeath"
NPC.HearDangerSounds = "ZBaseElitePolice.HearDanger"
NPC.Dialogue_Question_Sounds = "ZBaseElitePolice.Question"
NPC.Dialogue_Answer_Sounds = "ZBaseElitePolice.Answer"


function NPC:BeforeEmitSound( sndData, sndVarName )
    if sndVarName == "DeathSounds" && self:IsOnFire() then
        return "ZBaseElitePolice.FireDeath"
    end


    local ene = self:GetEnemy()


    if sndVarName == "AlertSounds"
    && IsValid(ene)
    && self.EnemyVisible
    && self:ZBaseDist(ene, {within=1500})
    && IsValid(ene:GetActiveWeapon()) then
        return "ZBaseElitePolice.AlertArmed"
    end


    if sndVarName == "Idle_HasEnemy_Sounds" && IsValid(ene)
    && !self.EnemyVisible && math.random(1, 2) == 1 then
        return "ZBaseElitePolice.IdleEnemyOccluded"
    end
end


function NPC:CustomNewActivityDetected( act )
    -- 2152 = Deploy manhack
    if act==2152 then
        self:EmitSound_Uninterupted("ZBaseElitePolice.Deploy")
    end
end

