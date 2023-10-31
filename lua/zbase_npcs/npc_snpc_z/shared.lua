local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Class = "base_ai_zbase" -- NPC to base this NPC on
NPC.Category = "Base" -- Spawnmenu category
NPC.Name = "SNPC" -- Spawnmenu name
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_zbase" -- Inherit features from an existing ZBase NPC