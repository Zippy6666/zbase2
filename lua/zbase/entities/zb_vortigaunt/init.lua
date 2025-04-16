local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/vortigaunt.mdl", "models/vortigaunt.mdl", "models/vortigaunt_slave.mdl"}
NPC.StartHealth = 150
NPC.BloodColor = BLOOD_COLOR_GREEN
NPC.ZBaseStartFaction = "ally"

NPC.BaseMeleeAttack = true
NPC.MeleeAttackAnimations = {
    ACT_MELEE_ATTACK1,
    ACT_MELEE_ATTACK1,
    "MeleeLow",
}
NPC.MeleeDamage_Sound = "ZBase.Melee1"
NPC.MeleeDamage_Delay = 0.5
NPC.MeleeAttackAnimationSpeed = 1.25

-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseVortigaunt.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseVortigaunt.Answer" -- Dialogue answers, emitted when the NPC is spoken to

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC

NPC.FollowPlayerSounds = "ZBaseVortigaunt.Follow" -- Sounds emitted when the NPC starts following a player
NPC.UnfollowPlayerSounds = "ZBaseVortigaunt.Unfollow" -- Sounds emitted when the NPC stops following a player

function NPC:CustomThink()
    local ene = self:GetEnemy()
    local eneIsPly = IsValid(ene) && ene:IsPlayer()

    if eneIsPly && self.CanHeal then
        self:Fire("DisableArmorRecharge")
        self.CanHeal = nil
    elseif !eneIsPly && !self.CanHeal then
        self:Fire("EnableArmorRecharge")
        self.CanHeal = true
    end
end

function NPC:CustomDealDamage( victimEnt, dmginfo )
    -- Nerf beam damage if nerf CVAR is true
    if IsValid(victimEnt) && dmginfo:IsDamageType(DMG_SHOCK) && ZBCVAR.Nerf:GetBool() && victimEnt:IsPlayer() then
        dmginfo:ScaleDamage(0.1)
    end
end