local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

NPC.Name = "Test NPC" -- Spawnmenu name
NPC.Class = "npc_zombine"
NPC.Weapons = {}

sound.Add( {
	name = "ZBase.Idle",
	channel = CHAN_VOICE,
	volume = 0.6,
	level = 75,
	pitch = {70, 80},
	sound = {
        "npc/zombie_poison/pz_idle4.wav",
    }
} )

sound.Add( {
	name = "ZBase.IdleEnemy",
	channel = CHAN_VOICE,
	volume = 0.8,
	level = 75,
	pitch = {70, 80},
	sound = {
		"npc/zombie/zombie_pain1.wav",
		"npc/zombie/zombie_pain2.wav",
		"npc/zombie/zombie_pain3.wav",
		"npc/zombie/zombie_pain4.wav",
		"npc/zombie/zombie_pain5.wav",
		"npc/zombie/zombie_pain6.wav",
    }
} )

sound.Add( {
	name = "ZBase.Pain",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 80,
	pitch = {90, 110},
	sound = {
		"npc/barnacle/barnacle_pull1.wav",
		"npc/barnacle/barnacle_pull2.wav",
		"npc/barnacle/barnacle_pull3.wav",
		"npc/barnacle/barnacle_pull4.wav",
    }
} )

sound.Add( {
	name = "ZBase.Death",
	channel = CHAN_VOICE,
	volume = 0.6,
	level = 80,
	pitch = {80, 90},
	sound = {
		"npc/zombie_poison/pz_die2.wav",
    }
} )

sound.Add( {
	name = "ZBase.Alert",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 80,
	pitch = {80, 90},
	sound = {
		"npc/zombie_poison/pz_throw2.wav",
    }
} )