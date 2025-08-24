local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_metropolice"

NPC.Name = "Civil Protection Elite" -- Name of your NPC
NPC.Category = "HL2: Combine" -- Category in the ZBase tab
NPC.Weapons = {"weapon_elitepolice_mp5k", "weapon_pistol", "weapon_pistol", "weapon_stunstick"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "zb_metropolice" -- Inherit features from any existing zbase npc
NPC.Author = "Zippy"

ZBaseAddGlowingEye("PoliceEye1", "models/zippy/elitepolice.mdl", 0, "ValveBiped.Bip01_Head1", Vector(3.8, 7, 1.9), 7, Color(255, 155, 0))
ZBaseAddGlowingEye("PoliceEye2", "models/zippy/elitepolice.mdl", 0, "ValveBiped.Bip01_Head1", Vector(3.8, 7, -1.9), 7, Color(255, 155, 0))

ZBaseCreateVoiceSounds("ZBaseElitePolice.Question", {
    "npc/elitepolice/mc1que_stimpatch.wav",
    "npc/elitepolice/mc1que_stomach.wav",
    "npc/elitepolice/mc1que_stunsticks.wav",
    "npc/elitepolice/mc1que_thisridiculous.wav",
    "npc/elitepolice/mc1que_yourwife.wav",
    "npc/elitepolice/mc1que_betterthings.wav",
    "npc/elitepolice/mc1que_career.wav",
    "npc/elitepolice/mc1que_enlisting.wav",
    "npc/elitepolice/mc1que_everythingihoped.wav",
    "npc/elitepolice/mc1que_feelinggood.wav",
    "npc/elitepolice/mc1que_feetkillin.wav",
    "npc/elitepolice/mc1que_goingtohell.wav",
    "npc/elitepolice/mc1que_justthought.wav",
    "npc/elitepolice/mc1que_kids.wav",
    "npc/elitepolice/mc1que_lastjob.wav",
    "npc/elitepolice/mc1que_paycut.wav",
    "npc/elitepolice/mc1que_peoplesuck.wav",
    "npc/elitepolice/mc1que_perks.wav",
    "npc/elitepolice/mc1que_raise.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Answer", {
    "npc/elitepolice/mc1ans_yeah.wav",
    "npc/elitepolice/mc1ans_yep.wav",
    "npc/elitepolice/mc1ans_youexpectme.wav",
    "npc/elitepolice/mc1ans_youreallybelieve.wav",
    "npc/elitepolice/mc1ans_believewhatyouwant.wav",
    "npc/elitepolice/mc1ans_bellyaching.wav",
    "npc/elitepolice/mc1ans_couldbe.wav",
    "npc/elitepolice/mc1ans_dontberidic.wav",
    "npc/elitepolice/mc1ans_dontwannatalk.wav",
    "npc/elitepolice/mc1ans_enoughouttayou.wav",
    "npc/elitepolice/mc1ans_fascinating.wav",
    "npc/elitepolice/mc1ans_figures.wav",
    "npc/elitepolice/mc1ans_hadtopartner.wav",
    "npc/elitepolice/mc1ans_helluvamood.wav",
    "npc/elitepolice/mc1ans_hm.wav",
    "npc/elitepolice/mc1ans_huhfigures.wav",
    "npc/elitepolice/mc1ans_letmethink.wav",
    "npc/elitepolice/mc1ans_mightbe.wav",
    "npc/elitepolice/mc1ans_mightcould.wav",
    "npc/elitepolice/mc1ans_mightnot.wav",
    "npc/elitepolice/mc1ans_nope.wav",
    "npc/elitepolice/mc1ans_rathernottalk.wav",
    "npc/elitepolice/mc1ans_rathernotthink.wav",
    "npc/elitepolice/mc1ans_shutup.wav",
    "npc/elitepolice/mc1ans_stopwhining.wav",
    "npc/elitepolice/mc1ans_theresyerproblem.wav",
    "npc/elitepolice/mc1ans_thinkso.wav",
    "npc/elitepolice/mc1ans_watchyermouth.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Alert", {
    "npc/elitepolice/deploy01.wav",
    "npc/elitepolice/deploy04.wav",
    "npc/elitepolice/pointer01.wav",
    "npc/elitepolice/pointer02.wav",
    "npc/elitepolice/pointer03.wav",
    "npc/elitepolice/pointer05.wav",
    "npc/elitepolice/takedown.wav",
    "npc/elitepolice/surprise1.wav",
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/surprise3.wav",
    "npc/elitepolice/surprise4.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.AlertArmed", {
    "npc/elitepolice/dropweapon.wav",
    "npc/elitepolice/freeze.wav",
    "npc/elitepolice/getonground.wav",
    "npc/elitepolice/hiding04.wav",
    "npc/elitepolice/hiding05.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.IdleEnemy", {
    "npc/elitepolice/deploy01.wav",
    "npc/elitepolice/deploy04.wav",
    "npc/elitepolice/pointer01.wav",
    "npc/elitepolice/pointer02.wav",
    "npc/elitepolice/pointer03.wav",
    "npc/elitepolice/pointer05.wav",
    "npc/elitepolice/takedown.wav",
    "npc/elitepolice/surprise1.wav",
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/surprise3.wav",
    "npc/elitepolice/surprise4.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.IdleEnemyOccluded", {
    "npc/elitepolice/hiding03.wav",
    "npc/elitepolice/hiding01.wav",
    "npc/elitepolice/hiding02.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.LostEnemy", {
    "npc/elitepolice/pointer04.wav",
    "npc/elitepolice/pointer06.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.KilledEnemy", {
    "npc/elitepolice/shooter01.wav",
    "npc/elitepolice/shooter02.wav",
    "npc/elitepolice/shooter03.wav",
    "npc/elitepolice/shooter04.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.AllyDeath", {
    "npc/elitepolice/mc1ans_dontberidic.wav",
    "npc/elitepolice/mc1ans_huhfigures.wav",
    "npc/elitepolice/mc1ans_stopwhining.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.SeeDanger", {
    "npc/elitepolice/pain3.wav",
    "npc/elitepolice/pain4.wav",
    "npc/elitepolice/deploy01.wav",
    "npc/elitepolice/deploy04.wav",
    "npc/elitepolice/pointer01.wav",
    "npc/elitepolice/pointer02.wav",
    "npc/elitepolice/pointer03.wav",
    "npc/elitepolice/pointer05.wav",
    "npc/elitepolice/surprise1.wav",
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/surprise3.wav",
    "npc/elitepolice/surprise4.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.HearDanger", {
    "npc/elitepolice/deploy01.wav",
    "npc/elitepolice/deploy04.wav",
    "npc/elitepolice/surprise1.wav",
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/surprise3.wav",
    "npc/elitepolice/surprise4.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Pain", {
    "npc/elitepolice/knockout3.wav",
    "npc/elitepolice/knockout1.wav",
    "npc/elitepolice/knockout2.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Death", {
    "npc/elitepolice/die4.wav",
    "npc/elitepolice/die1.wav",
    "npc/elitepolice/die2.wav",
    "npc/elitepolice/die3.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.FireDeath", {
    "npc/elitepolice/fire_scream1.wav",
    "npc/elitepolice/fire_scream2.wav",
    "npc/elitepolice/fire_scream3.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Deploy", {
    "npc/elitepolice/deploy06.wav",
    "npc/elitepolice/deploy01.wav",
    "npc/elitepolice/deploy02.wav",
    "npc/elitepolice/deploy03.wav",
    "npc/elitepolice/deploy04.wav",
    "npc/elitepolice/deploy05.wav",
})