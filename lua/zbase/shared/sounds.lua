AddCSLuaFile()

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

sound.Add( {
	name = "ZBase.Melee1",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 75,
	pitch = {95, 105},
	sound = {
        "npc/fast_zombie/claw_strike1.wav",
		"npc/fast_zombie/claw_strike2.wav",
		"npc/fast_zombie/claw_strike3.wav",
    }
} )

sound.Add( {
	name = "ZBase.Melee2",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 75,
	pitch = {95, 105},
	sound = {
        "physics/body/body_medium_impact_hard1.wav",
		"physics/body/body_medium_impact_hard2.wav",
		"physics/body/body_medium_impact_hard3.wav",
        "physics/body/body_medium_impact_hard4.wav",
		"physics/body/body_medium_impact_hard5.wav",
		"physics/body/body_medium_impact_hard6.wav",
    }
} )

sound.Add( {
	name = "ZBase.Ricochet",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 75,
	pitch = {90, 110},
	sound = {
        "weapons/fx/rics/ric1.wav",
        "weapons/fx/rics/ric2.wav",
        "weapons/fx/rics/ric3.wav",
        "weapons/fx/rics/ric4.wav",
        "weapons/fx/rics/ric5.wav"
    }
} )