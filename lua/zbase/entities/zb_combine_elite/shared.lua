local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_combine_s"

NPC.Name = "Overwatch Elite" -- Name of your NPC
NPC.Category = "HL2: Combine" -- Category in the ZBase tab
NPC.Weapons = {"weapon_ar2"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "zb_combine_soldier" -- Inherit features from any existing zbase npc

ZBaseAddGlowingEye("SuperSoldierEye", "models/combine_super_soldier.mdl", 0, "ValveBiped.Bip01_Head1", Vector(5, 5.5, 0), 16, Color(190, 25, 0))