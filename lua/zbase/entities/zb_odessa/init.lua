local NPC = FindZBaseTable(debug.getinfo(1,'S'))

-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {"models/odessa.mdl"}

NPC.StartHealth = 100 -- Max health

-- Health regen
NPC.HealthRegenAmount = 1
NPC.HealthCooldown = 0.2

NPC.MeleeAttackAnimations = {"meleeattack01"}

-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseOdessa.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC

-- Disable armor
-- (This NPC is derived from an NPC with this armor)
NPC.HasArmor = {
    [HITGROUP_CHEST] = false,
}