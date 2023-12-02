local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_combine_s"


NPC.Name = "Overwatch Soldier" -- Name of your NPC
NPC.Category = "Combine" -- Category in the ZBase tab
NPC.Weapons = {"weapon_smg1", "weapon_smg1", "weapon_ar2", "weapon_shotgun"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc


--]]==============================================================================================]]


ZBaseAddGlowingEye("models/combine_soldier.mdl", 0, "ValveBiped.Bip01_Head1", Vector(4.5, 5, 2), 8, Color(0, 50, 255))
ZBaseAddGlowingEye("models/combine_soldier.mdl", 0, "ValveBiped.Bip01_Head1", Vector(4.5, 5, -2), 8, Color(0, 50, 255))


ZBaseAddGlowingEye("models/combine_soldier.mdl", 1, "ValveBiped.Bip01_Head1", Vector(4.5, 5, 2), 8, Color(155, 20, 0))
ZBaseAddGlowingEye("models/combine_soldier.mdl", 1, "ValveBiped.Bip01_Head1", Vector(4.5, 5, -2), 8, Color(155, 20, 0))


--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseCombine.Idle", {
    "npc/combine_soldier/vo/prison_soldier_activatecentral.wav",
    "npc/combine_soldier/vo/prison_soldier_boomersinbound.wav",
    "npc/combine_soldier/vo/prison_soldier_bunker1.wav",
    "npc/combine_soldier/vo/prison_soldier_bunker2.wav",
    "npc/combine_soldier/vo/prison_soldier_bunker3.wav",
    "npc/combine_soldier/vo/prison_soldier_containd8.wav",
    "npc/combine_soldier/vo/prison_soldier_fallback_b4.wav",
    "npc/combine_soldier/vo/prison_soldier_freeman_antlions.wav",
    "npc/combine_soldier/vo/prison_soldier_fullbioticoverrun.wav",
    "npc/combine_soldier/vo/prison_soldier_leader9dead.wav",
    "npc/combine_soldier/vo/prison_soldier_negativecontainment.wav",
    "npc/combine_soldier/vo/prison_soldier_prosecuted7.wav",
    "npc/combine_soldier/vo/prison_soldier_sundown3dead.wav",
    "npc/combine_soldier/vo/prison_soldier_tohighpoints.wav",
    "npc/combine_soldier/vo/prison_soldier_visceratorsa5.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseCombine.Question", {
    "npc/combine_soldier/vo/gridsundown46.wav",
    "npc/combine_soldier/vo/noviscon.wav",
    "npc/combine_soldier/vo/ovewatchorders3ccstimboost.wav",
    "npc/combine_soldier/vo/reportallpositionsclear.wav",
    "npc/combine_soldier/vo/reportallradialsfree.wav",
    "npc/combine_soldier/vo/reportingclear.wav",
    "npc/combine_soldier/vo/sectorissecurenovison.wav",
    "npc/combine_soldier/vo/sightlineisclear.wav",
    "npc/combine_soldier/vo/stabilizationteamhassector.wav",
    "npc/combine_soldier/vo/stabilizationteamholding.wav",
    "npc/combine_soldier/vo/teamdeployedandscanning.wav",
    "npc/combine_soldier/vo/unitisclosing.wav",
    "npc/combine_soldier/vo/wehavenontaggedviromes.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseCombine.Answer", {
    "npc/combine_soldier/vo/copy.wav",
    "npc/combine_soldier/vo/copythat.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseCombine.Alert", {
    "npc/combine_soldier/vo/contact.wav",
    "npc/combine_soldier/vo/viscon.wav",
    "npc/combine_soldier/vo/alert1.wav",
    "npc/combine_soldier/vo/contactconfirmprosecuting.wav",
    "npc/combine_soldier/vo/contactconfim.wav",
    "npc/combine_soldier/vo/outbreak.wav",
    "npc/combine_soldier/vo/fixsightlinesmovein.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseCombine.KillEnemy", {
    "npc/combine_soldier/vo/targetcompromisedmovein.wav",
    "npc/combine_soldier/vo/targetblackout.wav",
    "npc/combine_soldier/vo/affirmativewegothimnow.wav",
    "npc/combine_soldier/vo/overwatchconfirmhvtcontained.wav",
    "npc/combine_soldier/vo/overwatchtargetcontained.wav",
    "npc/combine_soldier/vo/overwatchtarget1sterilized.wav",
    "npc/combine_soldier/vo/onecontained.wav",
    "npc/combine_soldier/vo/payback.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseCombine.Reload", {
    "npc/combine_soldier/vo/cover.wav",
    "npc/combine_soldier/vo/coverme.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseCombine.HearSound", {
    "npc/combine_soldier/vo/motioncheckallradials.wav",
    "npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
    "npc/combine_soldier/vo/prepforcontact.wav",
    "npc/combine_soldier/vo/readycharges.wav",
    "npc/combine_soldier/vo/readyextractors.wav",
    "npc/combine_soldier/vo/readyweapons.wav",
    "npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
    "npc/combine_soldier/vo/stayalert.wav",
    "npc/combine_soldier/vo/stayalertreportsightlines.wav",
    "npc/combine_soldier/vo/weaponsoffsafeprepforcontact.wav",
    "npc/combine_soldier/vo/confirmsectornotsterile.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseCombine.LostEnemy", {
    "npc/combine_soldier/vo/skyshieldreportslostcontact.wav",
    "npc/combine_soldier/vo/lostcontact.wav",
})
--]]==============================================================================================]]