local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_combine_s"


NPC.Name = "Overwatch Soldier" -- Name of your NPC
NPC.Category = "HL2: Combine" -- Category in the ZBase tab
NPC.Weapons = {"weapon_smg1", "weapon_smg1", "weapon_ar2", "weapon_shotgun"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc


-- EYES --

ZBaseAddGlowingEye("CombineEye1", "models/combine_soldier.mdl", 0, "ValveBiped.Bip01_Head1", Vector(4.5, 5, 2), 8, Color(0, 50, 255))
ZBaseAddGlowingEye("CombineEye2", "models/combine_soldier.mdl", 0, "ValveBiped.Bip01_Head1", Vector(4.5, 5, -2), 8, Color(0, 50, 255))


ZBaseAddGlowingEye("CombineShottyEye1", "models/combine_soldier.mdl", 1, "ValveBiped.Bip01_Head1", Vector(4.5, 5, 2), 8, Color(155, 20, 0))
ZBaseAddGlowingEye("CombineShottyEye2", "models/combine_soldier.mdl", 1, "ValveBiped.Bip01_Head1", Vector(4.5, 5, -2), 8, Color(155, 20, 0))


-- SENTENCES --


ZBaseAddScriptedSentence({
    name 	= "ZB_Combine_Alert1.SS",
    channel = CHAN_VOICE,
    volume 	= 1,
    level 	= 75,
    caption	= { "<clr:0,100,255>Combine Radio: ", 2 },
    sound 	= { 
        "radio_on.wav",
        { "npc/combine_soldier/vo/callhotpoint.wav", "npc/combine_soldier/vo/containmentproceeding.wav", "npc/combine_soldier/vo/contactconfim.wav", "npc/combine_soldier/vo/contactconfirmprosecuting.wav", "npc/combine_soldier/vo/contact.wav" }, -- Will choose random random option.
        { dps = 55, caption = { "Call hot point, ", "Containment proceeding, ", "Contact confirm, ", "Contact confirm, prosecuting, ", "Contact, " } }, -- If present, it will detect settings for the previous table. You can put anything here to override the sound or add captions.
        {"npc/combine_soldier/vo/targetcontactat.wav", "npc/combine_soldier/vo/targetisat.wav"},
        { dps = 55, caption = { "target contact at ", "target is at " } },
        {"npc/combine_soldier/vo/sector.wav", "npc/combine_soldier/vo/apex.wav", "npc/combine_soldier/vo/dagger.wav","npc/combine_soldier/vo/grid.wav"},
        { dps = 55, caption = { "sector ", "apex ", "dagger ", "grid " } },
        {"npc/combine_soldier/vo/eighteen.wav", "npc/combine_soldier/vo/fourteen.wav", "npc/combine_soldier/vo/one.wav", "npc/combine_soldier/vo/sixty.wav"},
        { dps = 55, caption = { "eighteen! ", "fourteen! ", "one! ", "sixty! " } },
        "radio_off.wav",
    }
})



ZBaseAddScriptedSentence({
    name 	= "ZB_Combine_LostEnemy1.SS",
    channel = CHAN_VOICE,
    volume 	= 1,
    level 	= 75,
    caption	= { "<clr:0,100,255>Combine Radio: ", 2 },
    sound 	= { 
        "radio_on.wav",
        { "npc/combine_soldier/vo/lostcontact.wav", "npc/combine_soldier/vo/skyshieldreportslostcontact.wav" },
        { dps = 55, caption = { "Lost contact, ", "Skyshield reports lost contact, " } },
        { "npc/combine_soldier/vo/scar.wav", "npc/combine_soldier/vo/striker.wav", "npc/combine_soldier/vo/ranger.wav", "npc/combine_soldier/vo/reaper.wav", "npc/combine_soldier/vo/phantom.wav" },
        { dps = 55, caption = { "Scar, ", "Striker, ", "Ranger, ", "Reaper, ", "Phantom, " } }, 
        { "npc/combine_soldier/vo/reportallpositionsclear.wav", "npc/combine_soldier/vo/reportingclear.wav", "npc/combine_soldier/vo/reportallradialsfree.wav", "npc/combine_soldier/vo/stayalertreportsightlines.wav", "npc/combine_soldier/vo/stayalert.wav" }, 
        { dps = 55, caption = { "Report all positions clear. ", "Reporting clear. ", "Report all radials free. ", "Stay alert, report sightlines. ", "Stay alert. " } },
        "radio_off.wav",
    }
})



-- SOUND SCRIPTS --


sound.Add({
    name = "ZBaseCombine.Step",
	channel = CHAN_AUTO,
	volume = 0.7,
	level = 80,
	pitch = {90, 110},
	sound = {
        "npc/combine_soldier/gear1.wav",
		"npc/combine_soldier/gear2.wav",
		"npc/combine_soldier/gear3.wav",
		"npc/combine_soldier/gear4.wav",
		"npc/combine_soldier/gear5.wav",
        "npc/combine_soldier/gear6.wav",
    },
})


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


ZBaseCreateVoiceSounds("ZBaseCombine.Answer", {
    "npc/combine_soldier/vo/copy.wav",
    "npc/combine_soldier/vo/copythat.wav",
})


ZBaseCreateVoiceSounds("ZBaseCombine.Follow", {
    "npc/combine_soldier/vo/copythat.wav",
})

ZBaseCreateVoiceSounds("ZBaseCombine.Unfollow", {
    "npc/combine_soldier/vo/copy.wav",
})


ZBaseCreateVoiceSounds("ZBaseCombine.Alert", {
    "ZB_Combine_Alert1.SS",
})


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


ZBaseCreateVoiceSounds("ZBaseCombine.Reload", {
    "npc/combine_soldier/vo/cover.wav",
    "npc/combine_soldier/vo/coverme.wav",
})


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


ZBaseCreateVoiceSounds("ZBaseCombine.LostEnemy", {
    "ZB_Combine_LostEnemy1.SS",
})


ZBaseCreateVoiceSounds("ZBaseCombine.Grenade", {
    "npc/combine_soldier/vo/extractoraway.wav",
    "npc/combine_soldier/vo/extractorislive.wav",
})

