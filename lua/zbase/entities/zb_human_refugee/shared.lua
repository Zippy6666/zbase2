local NPC = FindZBaseTable(debug.getinfo(1,'S'))

-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_citizen"

NPC.Name = "Male Refugee" -- Name of your NPC
NPC.Category = "HL2: Humans + Resistance" -- Category in the ZBase tab
NPC.Weapons = {"weapon_smg1", "weapon_crowbar", "weapon_stunstick", "weapon_pistol", "weapon_alyxgun",
    "weapon_zb_canalspipe"}
NPC.Inherit = "zb_human_civilian" -- Inherit features from any existing zbase npc
NPC.Author = "Zippy"