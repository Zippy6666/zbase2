local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.IsZBaseNPC = true -- Won't work right without this
NPC.Inherit = "npc_zbase" -- Inherit features from "npc_zbase" or an existing ZBase NPC
NPC.Class = "npc_citizen" -- NPC to base this NPC on
NPC.Category = "Base" -- ZBase spawnmenu category
NPC.Name = "Base" -- Spawnmenu name
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Replace = false -- Put the spawn menu name of an existing NPC to make this NPC replace it in the spawn menu