local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_citizen" -- NPC to base this NPC on
NPC.Category = "Resistance" -- Spawnmenu category
NPC.Name = "Citizen" -- Spawnmenu name
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_zbase" -- Inherit features from an existing ZBase NPC