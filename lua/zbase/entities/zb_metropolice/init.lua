local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.StartHealth = 40 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour
NPC.CanSecondaryAttack = false -- Can use weapon secondary attacks


NPC.ZBaseStartFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"


NPC.HasArmor = {
    [HITGROUP_CHEST] = true,
}


NPC.BaseMeleeAttack = true
NPC.MeleeDamage_Delay = 0.5
NPC.MeleeAttackAnimations = {
    "Swing",
}


local SF_ARREST = 2097152
NPC.SpawnFlagTbl = {SF_ARREST, SF_NPC_DROP_HEALTHKIT}
NPC.KeyValues = {weapondrawn="1"}


NPC.AlertSounds = "ZBaseMetrocop.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "ZBaseMetrocop.Idle" -- Sounds emitted while there is no enemy
NPC.KilledEnemySounds = "ZBaseMetrocop.KillEnemy" -- Sounds emitted when the NPC kills an enemy


-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseMetrocop.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseMetrocop.Answer" -- Dialogue answers, emitted when the NPC is spoken to


-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseMetrocop.HearSound"


NPC.FootStepSounds = "ZBaseMetrocop.Step" -- Footstep sound


local ShouldHaveRadioSound = {
    ["LostEnemySounds"] = true,
    ["OnReloadSounds"] = true,
    ["Dialogue_Question_Sounds"] = true,
    ["Dialogue_Answer_Sounds"] = true,
    ["AlertSounds"] = true,
    ["KilledEnemySounds"] = true,
    ["OnGrenadeSounds"] = true,
}
--]]==============================================================================================]]
function NPC:CustomInitialize()

    local Manhacks = math.random(0, 1)
    self.m_iManhacks = Manhacks
    self:SetBodygroup(0, Manhacks)

end
--]]==============================================================================================]]
function NPC:CustomOnSoundEmitted( sndData, duration, sndVarName )
    if ShouldHaveRadioSound[sndVarName] then
        self:EmitSound("npc/metropolice/vo/on"..math.random(1, 2)..".wav")


        timer.Simple(duration, function()
            if !IsValid(self) then return end
            self:EmitSound("npc/metropolice/vo/off"..math.random(1, 4)..".wav")
        end)
    end
end
--]]==============================================================================================]]