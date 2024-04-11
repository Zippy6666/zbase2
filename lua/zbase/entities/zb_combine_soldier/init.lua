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


NPC.BaseMeleeAttack = true -- Use ZBase melee attack system
NPC.MeleeAttackAnimations = {ACT_MELEE_ATTACK1} -- Example: NPC.MeleeAttackAnimations = {ACT_MELEE_ATTACK1}
NPC.MeleeAttackAnimationSpeed = 1 -- Speed multiplier for the melee attack animation

NPC.BaseGrenadeAttack = true -- Use ZBase grenade attack system
NPC.ThrowGrenadeChance_Visible = 4 -- 1/x chance that it throws a grenade when the enemy is visible
NPC.ThrowGrenadeChance_Occluded = 2 -- 1/x chance that it throws a grenade when the enemy is not visible
NPC.GrenadeCoolDown = {4, 8} -- {min, max}
NPC.GrenadeAttackAnimations = {"grenthrow"} -- Grenade throw animation
NPC.GrenadeEntityClass = "npc_grenade_frag" -- The grenade to throw, can be anything, like a fucking cat or somthing
NPC.GrenadeReleaseTime = 0.85 -- Time until grenade leaves the hand
NPC.GrenadeAttachment = "anim_attachment_LH" -- The attachment to spawn the grenade on
NPC.GrenadeMaxSpin = 1000 -- The amount to spin the grenade measured in spin units or something idfk


NPC.AlertSounds = "ZBaseCombine.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "ZBaseCombine.Idle" -- Sounds emitted while there is no enemy
NPC.KilledEnemySounds = "ZBaseCombine.KillEnemy" -- Sounds emitted when the NPC kills an enemy


NPC.LostEnemySounds = "ZBaseCombine.LostEnemy" -- Sounds emitted when the enemy is lost
NPC.OnReloadSounds = "ZBaseCombine.Reload" -- Sounds emitted when the NPC reloads
NPC.OnGrenadeSounds = "ZBaseCombine.Grenade" -- Sounds emitted when the NPC throws a grenade


-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseCombine.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseCombine.Answer" -- Dialogue answers, emitted when the NPC is spoken to


-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseCombine.HearSound"


NPC.FootStepSounds = "ZBaseCombine.Step" -- Footstep sound


NPC.FollowPlayerSounds = "ZBaseCombine.Answer" -- Sounds emitted when the NPC starts following a player
NPC.UnfollowPlayerSounds = "ZBaseCombine.Answer" -- Sounds emitted when the NPC stops following a player


NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC



-- Items to drop on death
-- ["item_class_name"] = {chance=1/x, max=x}
NPC.ItemDrops = {
    ["item_healthvial"] = {chance=3, max=2}, -- Example, a healthvial that has a 1/2 chance of spawning
    ["item_battery"] = {chance=4, max=1}, -- Example, a healthvial that has a 1/2 chance of spawning
    ["item_ammo_smg1_grenade"] = {chance=4, max=1}, -- Example, a healthvial that has a 1/2 chance of spawning
    ["item_ammo_ar2_altfire"] = {chance=5, max=1}, -- Example, a healthvial that has a 1/2 chance of spawning
    ["weapon_frag"] = {chance=4, max=1},
}
NPC.ItemDrops_TotalMax = 2 -- The NPC can never drop more than this many items



local ShouldHaveRadioSound = {
    ["LostEnemySounds"] = true,
    ["OnReloadSounds"] = true,
    ["Dialogue_Question_Sounds"] = true,
    ["Dialogue_Answer_Sounds"] = true,
    ["AlertSounds"] = true,
    ["KilledEnemySounds"] = true,
    ["OnGrenadeSounds"] = true,
}



function NPC:OnInitCap()
    self:CapabilitiesRemove(CAP_INNATE_MELEE_ATTACK1)
end


function NPC:OnFireWeapon()

    local wep = self:GetActiveWeapon()
    if !IsValid(wep) then return end

    -- Shotgunner gesture
    if wep:GetHoldType()=="shotgun" then
        self:PlayAnimation(ACT_GESTURE_RANGE_ATTACK_SHOTGUN, false, {isGesture=true})
    end

end


function NPC:CustomOnSoundEmitted( sndData, duration, sndVarName )
    if ShouldHaveRadioSound[sndVarName] then
        self:EmitSound("npc/combine_soldier/vo/on"..math.random(1, 2)..".wav")


        timer.Simple(duration, function()
            if !IsValid(self) then return end
            self:EmitSound("npc/combine_soldier/vo/off"..math.random(1, 3)..".wav")
        end)
    end
end

