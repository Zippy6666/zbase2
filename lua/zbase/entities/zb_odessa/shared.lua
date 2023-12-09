local NPC = FindZBaseTable(debug.getinfo(1,'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_citizen"


NPC.Name = "Odessa Cubbage" -- Name of your NPC
NPC.Category = "Humans + Resistance" -- Category in the ZBase tab
NPC.Weapons = {"weapon_rpg"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "zb_rebel" -- Inherit features from any existing zbase npc


ZBaseCreateVoiceSounds("ZBaseOdessa.Question", {
    "vo/coast/odessa/nlo_cub_roadahead.wav",
    "vo/coast/odessa/nlo_cub_service.wav",
    "vo/coast/odessa/nlo_cub_thatsthat.wav",
    "vo/coast/odessa/nlo_cub_volunteer.wav",
    "vo/coast/odessa/nlo_cub_wherewasi.wav",
    "vo/coast/odessa/nlo_cub_youllmakeit.wav",
})


ZBaseCreateVoiceSounds("ZBaseOdessa.Answer", {
    "vo/coast/odessa/nlo_cub_class01.wav",
    "vo/coast/odessa/nlo_cub_class02.wav",
    "vo/coast/odessa/nlo_cub_corkscrew.wav",
    "vo/coast/odessa/nlo_cub_farewell.wav",
    "vo/coast/odessa/nlo_cub_hello.wav",
    "vo/coast/odessa/nlo_cub_opengate.wav",
    "vo/coast/odessa/nlo_cub_radio.wav",
})


