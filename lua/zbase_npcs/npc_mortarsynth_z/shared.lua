local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.IsZBaseNPC = true -- Won't work right without this
NPC.Inherit = "npc_zbase" -- Inherit features from "npc_zbase" or an existing ZBase NPC
NPC.Class = "npc_cscanner" -- NPC to base this NPC on
NPC.Category = "Base" -- ZBase spawnmenu category
NPC.Name = "Mortar Synth" -- Spawnmenu name
