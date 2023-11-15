local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_citizen" -- NPC to base this NPC on
NPC.Category = "ZBase" -- Spawnmenu category
NPC.Name = "Citizen" -- Spawnmenu name
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_zbase" -- Inherit features from an existing ZBase NPC
NPC.Replace = "npc_citizen" -- Put the spawn menu name of an existing NPC to make this NPC replace it in the spawn menu