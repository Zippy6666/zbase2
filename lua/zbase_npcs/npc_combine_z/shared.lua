local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_combine_s" -- NPC to base this NPC on
NPC.Category = "Combine" -- Spawnmenu category
NPC.Name = "Overwatch Soldier" -- Spawnmenu name
NPC.Weapons = {
    "weapon_ar2",
    "weapon_smg1",
    "weapon_smg1",
    "weapon_smg1",
}
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_zbase" -- Inherit features from an existing ZBase NPC