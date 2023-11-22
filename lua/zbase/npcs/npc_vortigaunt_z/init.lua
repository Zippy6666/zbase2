local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/vortigaunt.mdl", "models/vortigaunt.mdl", "models/vortigaunt_slave.mdl"}
NPC.StartHealth = 10
NPC.BloodColor = BLOOD_COLOR_YELLOW
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

---------------------------------------------------------------------------------------------------------------------=#
    -- Called when the NPC is created --
function NPC:CustomInitialize()
end
---------------------------------------------------------------------------------------------------------------------=#
