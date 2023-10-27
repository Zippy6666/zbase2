local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_citizen" -- NPC to base this NPC on
NPC.Category = "ZBase" -- Spawnmenu category
NPC.Name = "Example" -- Spawnmenu name

NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.IsZBaseNPC = true