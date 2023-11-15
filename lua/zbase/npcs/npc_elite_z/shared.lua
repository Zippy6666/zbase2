local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_combine_s" -- NPC to base this NPC on
NPC.Category = "Combine" -- Spawnmenu category
NPC.Name = "Overwatch Elite" -- Spawnmenu name
NPC.Weapons = {
    "weapon_ar2",
}
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_combine_z" -- Inherit features from an existing ZBase NPC
NPC.Replace = "CombineElite" -- Put the spawn menu name of an existing NPC to make this NPC replace it in the spawn menu