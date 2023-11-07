local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Inherit = "npc_zbase" -- Inherit features from "npc_zbase" or an existing ZBase NPC
NPC.Class = "npc_citizen" -- NPC to base this NPC on
NPC.Category = "Base" -- ZBase spawnmenu category
NPC.Name = "Base" -- Spawnmenu name
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}