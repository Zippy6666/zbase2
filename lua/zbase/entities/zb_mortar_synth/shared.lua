local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_zbase_snpc"


NPC.Name = "Mortar Synth" -- Name of your NPC
NPC.Category = "Combine" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc


sound.Add({
    name = "ZBaseMortarSynth.Alert",
	channel = CHAN_VOICE,
	volume = 1,
	level = 85,
	pitch = {95, 105},
	sound = {
        "npc/mortarsynth/alert1.wav",
        "npc/mortarsynth/alert2.wav",
    }
})

sound.Add({
    name = "ZBaseMortarSynth.Die",
	channel = CHAN_VOICE,
	volume = 1,
	level = 90,
	pitch = {95, 105},
	sound = {
        "npc/mortarsynth/die.wav",
    }
})

sound.Add({
    name = "ZBaseMortarSynth.Hurt",
	channel = CHAN_VOICE,
	volume = 1,
	level = 85,
	pitch = {50, 60},
	sound = {
        "npc/mortarsynth/hurt1.wav",
        "npc/mortarsynth/hurt2.wav",
    }
})

sound.Add({
    name = "ZBaseMortarSynth.Shock",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 100,
	pitch = {95, 105},
	sound = {
        "npc/mortarsynth/shock.wav",
    }
})

sound.Add({
    name = "ZBaseMortarSynth.hover",
	channel = CHAN_AUTO,
	volume = 0.7,
	level = 80,
	pitch = 100,
	sound = {
        "npc/mortarsynth/hover.wav",
    }
})