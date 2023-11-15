local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_combine_s" -- NPC to base this NPC on
NPC.Category = "ZBase" -- Spawnmenu category
NPC.Name = "Nova Prospekt Soldier" -- Spawnmenu name
NPC.Weapons = {
    "weapon_ar2",
    "weapon_smg1",
    "weapon_smg1",
    "weapon_smg1",
    "weapon_shotgun",
}
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_combine_z" -- Inherit features from an existing ZBase NPC
NPC.Replace = "CombinePrison" -- Put the spawn menu name of an existing NPC to make this NPC replace it in the spawn menu

ZBaseCreateVoiceSounds("ZBaseNovaProspekt.Idle", {
    "npc/combine_soldier/vo/prison_soldier_activatecentral.wav",
    "npc/combine_soldier/vo/prison_soldier_boomersinbound.wav",
    "npc/combine_soldier/vo/prison_soldier_bunker1.wav",
    "npc/combine_soldier/vo/prison_soldier_bunker2.wav",
    "npc/combine_soldier/vo/prison_soldier_bunker3.wav",
    "npc/combine_soldier/vo/prison_soldier_containd8.wav",
    "npc/combine_soldier/vo/prison_soldier_fallback_b4.wav",
    "npc/combine_soldier/vo/prison_soldier_freeman_antlions.wav",
    "npc/combine_soldier/vo/prison_soldier_fullbioticoverrun.wav",
    "npc/combine_soldier/vo/prison_soldier_leader9dead.wav",
    "npc/combine_soldier/vo/prison_soldier_negativecontainment.wav",
    "npc/combine_soldier/vo/prison_soldier_prosecuted7.wav",
    "npc/combine_soldier/vo/prison_soldier_sundown3dead.wav",
    "npc/combine_soldier/vo/prison_soldier_tohighpoints.wav",
    "npc/combine_soldier/vo/prison_soldier_visceratorsa5.wav",
})