local NPC = FindZBaseTable(debug.getinfo(1, 'S'))

-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_vortigaunt"

NPC.Name = "Vortigaunt" -- Name of your NPC
NPC.Category = "HL2: Humans + Resistance" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc
NPC.Author = "Zippy"

ZBaseCreateVoiceSounds("ZBaseVortigaunt.Question", {
    "vo/npc/vortigaunt/vortigese11.wav",
    "vo/npc/vortigaunt/vortigese12.wav",
    "vo/npc/vortigaunt/vques01.wav",
    "vo/npc/vortigaunt/vques02.wav",
    "vo/npc/vortigaunt/vques03.wav",
    "vo/npc/vortigaunt/vques04.wav",
    "vo/npc/vortigaunt/vques05.wav",
    "vo/npc/vortigaunt/vques06.wav",
    "vo/npc/vortigaunt/vques07.wav",
    "vo/npc/vortigaunt/vques08.wav",
    "vo/npc/vortigaunt/vques09.wav",
    "vo/npc/vortigaunt/vques10.wav",
})

ZBaseCreateVoiceSounds("ZBaseVortigaunt.Answer", {
    "vo/npc/vortigaunt/vanswer01.wav",
    "vo/npc/vortigaunt/vanswer02.wav",
    "vo/npc/vortigaunt/vanswer03.wav",
    "vo/npc/vortigaunt/vanswer04.wav",
    "vo/npc/vortigaunt/vanswer05.wav",
    "vo/npc/vortigaunt/vanswer06.wav",
    "vo/npc/vortigaunt/vanswer07.wav",
    "vo/npc/vortigaunt/vanswer08.wav",
    "vo/npc/vortigaunt/vanswer09.wav",
    "vo/npc/vortigaunt/vanswer10.wav",
    "vo/npc/vortigaunt/vanswer11.wav",
    "vo/npc/vortigaunt/vanswer12.wav",
    "vo/npc/vortigaunt/vanswer13.wav",
    "vo/npc/vortigaunt/vanswer14.wav",
    "vo/npc/vortigaunt/vanswer15.wav",
    "vo/npc/vortigaunt/vanswer16.wav",
    "vo/npc/vortigaunt/vanswer17.wav",
    "vo/npc/vortigaunt/vanswer18.wav",
})

ZBaseCreateVoiceSounds("ZBaseVortigaunt.Follow", {
    "vo/npc/vortigaunt/weareyours.wav",
    "vo/npc/vortigaunt/wewillhelp.wav",
    "vo/npc/vortigaunt/wefollowfm.wav",
    "vo/npc/vortigaunt/ourhonor.wav",
    "vo/npc/vortigaunt/leadon.wav",
    "vo/npc/vortigaunt/leadus.wav",
    "vo/npc/vortigaunt/honorfollow.wav",
    "vo/npc/vortigaunt/herewestay.wav",
})

ZBaseCreateVoiceSounds("ZBaseVortigaunt.Unfollow", {
    "vo/npc/vortigaunt/willremain.wav",
    "vo/npc/vortigaunt/ourplacehere.wav",
    "vo/npc/vortigaunt/herewestay.wav",
    "vo/npc/vortigaunt/asyouwish.wav",
})