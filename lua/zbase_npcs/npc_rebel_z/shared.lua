local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Class = "npc_citizen" -- NPC to base this NPC on
NPC.Category = "Resistance" -- Spawnmenu category
NPC.Name = "Rebel" -- Spawnmenu name
NPC.Weapons = {
    "weapon_357",
    "weapon_pistol",
    "weapon_crossbow",
    "weapon_crowbar",
    "weapon_rpg",
    "weapon_ar2",
    "weapon_ar2",
    "weapon_shotgun",
    "weapon_shotgun",
    "weapon_shotgun",
    "weapon_smg1",
    "weapon_smg1",
    "weapon_smg1",
}
NPC.IsZBaseNPC = true
NPC.Inherit = "npc_citizen_z" -- Inherit features from an existing ZBase NPC
NPC.KeyValues = {citizentype = CT_REBEL} -- Keyvalues