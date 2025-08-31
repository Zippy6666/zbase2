local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_citizen"

NPC.Name = "OCMU" -- Name of your NPC
NPC.Category = "HL2: Combine" -- Category in the ZBase tab
NPC.Weapons = {"weapon_smg1"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "zb_combine_soldier" -- Inherit features from any existing zbase npc
NPC.Author = "Zippy"

ZBaseAddGlowingEye("CombineEye1", "models/zippy/combine_medic.mdl", 0, "ValveBiped.Bip01_Head1", Vector(4.5, 5, 2), 8, Color(0, 255, 75))
ZBaseAddGlowingEye("CombineEye2", "models/zippy/combine_medic.mdl", 0, "ValveBiped.Bip01_Head1", Vector(4.5, 5, -2), 8, Color(0, 255, 75))

ZBaseCreateVoiceSounds("ZBaseCombineMedic.Death", {
    "npc/elitepolice/fire_scream1.wav",
    "npc/elitepolice/fire_scream2.wav",
    "npc/elitepolice/fire_scream3.wav",
})

ZBaseCreateVoiceSounds("ZBaseCombineMedic.Pain", {
    "npc/elitepolice/pain3.wav",
    "npc/elitepolice/knockout3.wav"
})