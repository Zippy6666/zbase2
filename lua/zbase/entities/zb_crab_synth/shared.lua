local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_zbase_snpc"


NPC.Name = "Crab Synth" -- Name of your NPC
NPC.Category = "Combine" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc


--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.Idle",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 95,
	pitch = {95, 105},
	sound = {
        "npc/crabsynth/cs_idle01.wav",
		"npc/crabsynth/cs_idle02.wav",
		"npc/crabsynth/cs_idle03.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.Alert",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 95,
	pitch = {95, 105},
	sound = {
        "npc/crabsynth/cs_alert01.wav",
		"npc/crabsynth/cs_alert02.wav",
		"npc/crabsynth/cs_alert03.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.HearSound",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 105,
	pitch = {95, 105},
	sound = {
        "npc/crabsynth/cs_distant01.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.LostEnemy",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 105,
	pitch = {95, 105},
	sound = {
		"npc/crabsynth/cs_distant02.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.Announce",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 95,
	pitch = {95, 105},
	sound = {
        "npc/crabsynth/cs_pissed01.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.Pain",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 95,
	pitch = {95, 105},
	sound = {
        "npc/crabsynth/cs_roar01.wav",
        "npc/crabsynth/cs_roar02.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.Death",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 95,
	pitch = {95, 105},
	sound = {
        "npc/crabsynth/cs_die.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.MeleeHit",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 85,
	pitch = {95, 105},
	sound = {
        "npc/crabsynth/cs_skewer.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.MinigunLoop",
	channel = CHAN_AUTO,
	volume = 0.9,
	level = 105,
	pitch = {100, 100},
	sound = {
		"npc/crabsynth/minigun_loop.wav",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.MinigunStart",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 105,
	pitch = {95, 105},
	sound = {
		"npc/crabsynth/minigun_start.ogg",
    }
})
--]]==============================================================================================]]
sound.Add({
    name = "ZBaseCrabSynth.MinigunStop",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 105,
	pitch = {95, 105},
	sound = {
		"npc/crabsynth/minigun_stop.wav",
    }
})
--]]==============================================================================================]]
