local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_vortigaunt" -- NPC to base this NPC on
NPC.Category = "ZBase" -- Spawnmenu category
NPC.Name = "Vortigaunt" -- Spawnmenu name
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_zbase" -- Inherit features from an existing ZBase NPC
NPC.Replace = "npc_vortigaunt" -- Put the spawn menu name of an existing NPC to make this NPC replace it in the spawn menu