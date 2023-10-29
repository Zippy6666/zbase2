local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Inherit = "npc_police_z" -- Inherit features from an existing ZBase NPC

ZBaseCreateVoiceSounds("ZBaseElitePolice.Alert", {

    "npc/elitepolice/surprise1.wav",
    "npc/elitepolice/surprise2.wav",
    "npc/elitepolice/surprise3.wav",
    "npc/elitepolice/surprise4.wav",
    "npc/elitepolice/takedown.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Pain", {
    "npc/elitepolice/knockout1.wav",
    "npc/elitepolice/knockout2.wav",
    "npc/elitepolice/knockout3.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Death", {
    "npc/elitepolice/die1.wav",
    "npc/elitepolice/die3.wav",
    "npc/elitepolice/die4.wav",
    "npc/elitepolice/die5.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.FireDeath", {
    "npc/elitepolice/fire_scream1.wav",
    "npc/elitepolice/fire_scream2.wav",
    "npc/elitepolice/fire_scream3.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Idle", {

})

ZBaseCreateVoiceSounds("ZBaseElitePolice.Deploy", {

})

ZBaseCreateVoiceSounds("ZBaseElitePolice.IdleEnemy_Occluded", {
    "npc/elitepolice/hiding01.wav",
    "npc/elitepolice/hiding02.wav",
    "npc/elitepolice/hiding03.wav",
    "npc/elitepolice/hiding04.wav",
    "npc/elitepolice/hiding05.wav",
    "npc/elitepolice/pointer01.wav",
    "npc/elitepolice/pointer02.wav",
    "npc/elitepolice/pointer03.wav",
    "npc/elitepolice/pointer04.wav",
    "npc/elitepolice/pointer05.wav",
    "npc/elitepolice/pointer06.wav",
})

ZBaseCreateVoiceSounds("ZBaseElitePolice.IdleEnemyArmed", {
    "npc/elitepolice/shooter01.wav",
    "npc/elitepolice/shooter02.wav",
    "npc/elitepolice/shooter03.wav",
    "npc/elitepolice/shooter04.wav",
    "npc/elitepolice/shooter05.wav",
    "npc/elitepolice/freeze.wav",
    "npc/elitepolice/getonground.wav",
})


