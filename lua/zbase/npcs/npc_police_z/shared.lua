local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_metropolice" -- NPC to base this NPC on
NPC.Category = "ZBase" -- Spawnmenu category
NPC.Name = "Civil Protection" -- Spawnmenu name
NPC.Weapons = {
    "weapon_pistol",
    "weapon_pistol",
    "weapon_pistol",
    "weapon_stunstick",
    "weapon_smg1",
    "weapon_smg1",
}
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_zbase" -- Inherit features from an existing ZBase NPC
NPC.Replace = "npc_metropolice" -- Put the spawn menu name of an existing NPC to make this NPC replace it in the spawn menu