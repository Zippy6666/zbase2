local NPC = FindZBaseTable(debug.getinfo(1,'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_hunter"


NPC.Name = "Hunter" -- Name of your NPC
NPC.Category = "HL2: Combine" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc


ZBaseAddGlowingEye("models/hunter.mdl", 0, "MiniStrider.topEyeClose", Vector(0,0,0), 18, Color(0, 100, 255))
ZBaseAddGlowingEye("models/hunter.mdl", 0, "MiniStrider.bottomEyeClose", Vector(0,0,0), 18, Color(0, 100, 255))


sound.Add({
    name = "ZBaseHunter.HearSound",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 105,
	pitch = {95, 105},
	sound = {
        "npc/ministrider/hunter_scan1.wav",
        "npc/ministrider/hunter_scan2.wav",
        "npc/ministrider/hunter_scan3.wav",
        "npc/ministrider/hunter_scan4.wav",
    }
})


sound.Add({
    name = "ZBaseHunter.SeeDanger",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 105,
	pitch = {95, 105},
	sound = {
        "npc/ministrider/hunter_defendstrider1.wav",
        "npc/ministrider/hunter_defendstrider2.wav",
        "npc/ministrider/hunter_defendstrider3.wav",
        "npc/ministrider/hunter_foundenemy3.wav",
    }
})


sound.Add({
    name = "ZBaseHunter.Step",
	channel = CHAN_AUTO,
	volume = 0.7,
	level = 90,
	pitch = {110, 120},
	sound = {
        "npc/ministrider/ministrider_footstep1.wav",
        "npc/ministrider/ministrider_footstep2.wav",
        "npc/ministrider/ministrider_footstep3.wav",
        "npc/ministrider/ministrider_footstep4.wav",
        "npc/ministrider/ministrider_footstep5.wav",
    },
})



sound.Add({
    name = "ZBaseHunter.Idle",
	channel = CHAN_VOICE,
	volume = 0.9,
	level = 105,
	pitch = {100, 115},
	sound = {
        "npc/ministrider/hunter_laugh1.wav",
        "npc/ministrider/hunter_laugh2.wav",
        "npc/ministrider/hunter_laugh3.wav",
        "npc/ministrider/hunter_laugh4.wav",
        "npc/ministrider/hunter_laugh5.wav",
    },
})




