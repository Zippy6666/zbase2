local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "base_ai_zbase" if you want to create a brand new SNPC
NPC.Class = "npc_combine_s"


NPC.Name = "Overwatch Soldier" -- Name of your NPC
NPC.Category = "Default" -- Category in the ZBase tab
NPC.Weapons = {"weapon_smg1", "weapon_smg1", "weapon_ar2", "weapon_shotgun"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc


ZBaseCreateVoiceSounds("ZBaseOverwatchSoldier.HearSound", {
    "npc/combine_soldier/vo/motioncheckallradials.wav",
    "npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
    "npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
    "npc/combine_soldier/vo/stayalertreportsightlines.wav",
    "npc/combine_soldier/vo/weaponsoffsafeprepforcontact.wav",
    "npc/combine_soldier/vo/confirmsectornotsterile.wav",
})