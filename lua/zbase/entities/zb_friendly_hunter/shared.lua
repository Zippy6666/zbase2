local NPC = FindZBaseTable(debug.getinfo(1,'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_hunter"


NPC.Name = "Resistance Hunter" -- Name of your NPC
NPC.Category = "Humans + Resistance" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "zb_hunter" -- Inherit features from any existing zbase npc


ZBaseAddGlowingEye("models/zippy/resistancehunter.mdl", 0, "MiniStrider.topEyeClose", Vector(0,0,0), 18, Color(255, 100, 0))
ZBaseAddGlowingEye("models/zippy/resistancehunter.mdl", 0, "MiniStrider.bottomEyeClose", Vector(0,0,0), 18, Color(255, 100, 0))