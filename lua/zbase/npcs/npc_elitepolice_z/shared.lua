local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Inherit = "npc_police_z" -- Inherit features from an existing ZBase NPC
NPC.Name = "Civil Protection Elite" -- Spawnmenu name
NPC.NPCCategory = "ZBase" -- Normal spawnmenu category
NPC.Replace = false -- Put the spawn menu name of an existing NPC to make this NPC replace it in the spawn menu

NPC.Weapons = {
    "weapon_pistol",
    "weapon_pistol",
    "weapon_pistol",
    "weapon_stunstick",
    "weapon_elitepolice_mp5k",
    "weapon_elitepolice_mp5k",
}

ZBaseCreateVoiceSounds("ZBaseElitePolice.Pain", {
    "npc/elitepolice/knockout1.wav",
    "npc/elitepolice/knockout2.wav",
    "npc/elitepolice/knockout3.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Death", {
    "npc/elitepolice/die1.wav",
    "npc/elitepolice/die2.wav",
    "npc/elitepolice/die3.wav",
    "npc/elitepolice/die4.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.FireDeath", {
    "npc/elitepolice/fire_scream1.wav",
    "npc/elitepolice/fire_scream2.wav",
    "npc/elitepolice/fire_scream3.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Idle", {
    "npc/elitepolice/mc1ans_bellyaching.wav",
    "npc/elitepolice/mc1ans_fascinating.wav",
    "npc/elitepolice/mc1ans_helluvamood.wav",
    "npc/elitepolice/mc1ans_hm.wav",
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
    "npc/elitepolice/mc1que_stimpatch.wav",
    "npc/elitepolice/mc1que_stomach.wav",
    "npc/elitepolice/mc1que_stunsticks.wav",
    "npc/elitepolice/mc1que_thisridiculous.wav",
    "npc/elitepolice/mc1que_yourwife.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Deploy", {
    "npc/elitepolice/deploy01.wav",
    "npc/elitepolice/deploy02.wav",
    "npc/elitepolice/deploy03.wav",
    "npc/elitepolice/deploy04.wav",
    "npc/elitepolice/deploy05.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.IdleEnemy", {
    "npc/elitepolice/surprise1.wav",
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/surprise3.wav",
    "npc/elitepolice/surprise4.wav",
    "npc/elitepolice/takedown.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.SeeDanger", {
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/pointer02.wav",
    "npc/elitepolice/pain4.wav",
    "npc/elitepolice/deploy01.wav",
    "npc/elitepolice/deploy04.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.AllyDeath", {
    "npc/elitepolice/mc1ans_stopwhining.wav",
    "npc/elitepolice/mc1ans_dontberidic.wav",
    "npc/elitepolice/mc1ans_hm.wav",
    "npc/elitepolice/mc1ans_huhfigures.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.IdleEnemyOccluded", {
    "npc/elitepolice/hiding01.wav",
    "npc/elitepolice/hiding02.wav",
    "npc/elitepolice/hiding03.wav",
    "npc/elitepolice/hiding04.wav",
    "npc/elitepolice/hiding05.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.LostEnemy", {
    "npc/elitepolice/pointer04.wav",
    "npc/elitepolice/pointer06.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.KilledEnemy", {
    "npc/elitepolice/shooter01.wav",
    "npc/elitepolice/shooter02.wav",
    "npc/elitepolice/shooter03.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Alert", {
    "npc/elitepolice/surprise1.wav",
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/surprise3.wav",
    "npc/elitepolice/surprise4.wav",
    "npc/elitepolice/pointer01.wav",
    "npc/elitepolice/pointer02.wav",
    "npc/elitepolice/pointer03.wav",
    "npc/elitepolice/pointer05.wav",
    "npc/elitepolice/takedown.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.AlertArmed", {
    "npc/elitepolice/getonground.wav",
    "npc/elitepolice/dropweapon.wav",
    "npc/elitepolice/takedown.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.HearDangerClose", {
    "npc/elitepolice/hiding02.wav",
    "npc/elitepolice/hiding04.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.HearDanger", {
    "npc/elitepolice/deploy01.wav",
    "npc/elitepolice/deploy04.wav",
    "npc/elitepolice/surprise1.wav",
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/surprise3.wav",
    "npc/elitepolice/surprise4.wav",
})