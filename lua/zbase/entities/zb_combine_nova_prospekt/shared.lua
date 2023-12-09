local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_combine_s"


NPC.Name = "Nova Prospekt Soldier" -- Name of your NPC
NPC.Category = "HL2: Combine" -- Category in the ZBase tab
NPC.Weapons = {"weapon_smg1", "weapon_smg1", "weapon_ar2", "weapon_shotgun"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "zb_combine_soldier" -- Inherit features from any existing zbase npc


--]]==============================================================================================]]


ZBaseAddGlowingEye("models/combine_soldier_prisonguard.mdl", 0, "ValveBiped.Bip01_Head1", Vector(4.5, 5, 2), 8, Color(255, 155, 0))
ZBaseAddGlowingEye("models/combine_soldier_prisonguard.mdl", 0, "ValveBiped.Bip01_Head1", Vector(4.5, 5, -2), 8, Color(255, 155, 0))


ZBaseAddGlowingEye("models/combine_soldier_prisonguard.mdl", 1, "ValveBiped.Bip01_Head1", Vector(4.5, 5, 2), 8, Color(155, 70, 0))
ZBaseAddGlowingEye("models/combine_soldier_prisonguard.mdl", 1, "ValveBiped.Bip01_Head1", Vector(4.5, 5, -2), 8, Color(155, 70, 0))


--]]==============================================================================================]]


