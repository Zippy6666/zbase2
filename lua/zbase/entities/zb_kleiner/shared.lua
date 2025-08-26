local NPC = FindZBaseTable(debug.getinfo(1,'S'))

-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_citizen"

NPC.Name = "Dr. Isaac Kleiner" -- Name of your NPC
NPC.Category = "HL2: Humans + Resistance" -- Category in the ZBase tab
NPC.Weapons = {"weapon_shotgun"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc
NPC.Author = "Zippy"

ZBaseCreateVoiceSounds("ZBaseKleiner.Alert", {
    "vo/k_lab/kl_fiddlesticks.wav",
    "vo/k_lab/kl_getoutrun02.wav",
    "vo/k_lab/kl_getoutrun03.wav",
    "vo/k_lab/kl_interference.wav",
})

ZBaseCreateVoiceSounds("ZBaseKleiner.Die", {
    "vo/k_lab/kl_ohdear.wav",
})

ZBaseCreateVoiceSounds("ZBaseKleiner.SeeDanger", {
    "vo/k_lab/kl_ahhhh.wav",
})

ZBaseCreateVoiceSounds("ZBaseKleiner.Question", {
    "vo/k_lab/kl_blast.wav",
    "vo/k_lab/kl_finalsequence.wav",
    "vo/k_lab/kl_fruitlessly.wav",
    "vo/k_lab/kl_hesnotthere.wav",
    "vo/k_lab/kl_holdup02.wav",
    "vo/k_lab/kl_initializing.wav",
    "vo/k_lab/kl_initializing2.wav",
    "vo/k_lab/kl_masslessfieldflux.wav",
    "vo/k_lab/kl_modifications01.wav",
    "vo/k_lab/kl_modifications02.wav",
    "vo/k_lab/kl_moduli02.wav",
    "vo/k_lab/kl_mygoodness03.wav",
    "vo/k_lab/kl_opportunetime02.wav",
    "vo/k_lab/kl_redletterday02.wav",
    "vo/k_lab/kl_weowe.wav",
    "vo/k_lab2/kl_blowyoustruck02.wav",
    "vo/k_lab2/kl_givenuphope.wav",
    "vo/k_lab2/kl_nolongeralone_b.wav",
})

ZBaseCreateVoiceSounds("ZBaseKleiner.Answer", {
    "vo/k_lab/kl_almostforgot.wav",
    "vo/k_lab/kl_dearme.wav",
    "vo/k_lab/kl_excellent.wav",
    "vo/k_lab/kl_fewmoments01.wav",
    "vo/k_lab/kl_fewmoments02.wav",
    "vo/k_lab/kl_mygoodness01.wav",
    "vo/k_lab/kl_nonsense.wav",
    "vo/k_lab/kl_nownow01.wav",
    "vo/k_lab/kl_nownow02.wav",
    "vo/k_lab/kl_packing01.wav",
    "vo/k_lab/kl_wishiknew.wav",
    "vo/k_lab/kl_whatisit.wav",
    "vo/k_lab2/kl_aweekago01.wav",
    "vo/k_lab2/kl_blowyoustruck01.wav",
    "vo/k_lab2/kl_cantleavelamarr.wav",
    "vo/k_lab2/kl_slowteleport01.wav",
})

ZBaseCreateVoiceSounds("ZBaseKleiner.AllyDeath", {
    "vo/k_lab/kl_bonvoyage.wav",
    "vo/k_lab/kl_cantwade.wav",
    "vo/k_lab/kl_hedyno03.wav",
    "vo/k_lab2/kl_atthecitadel01.wav",
})

ZBaseCreateVoiceSounds("ZBaseKleiner.HearDanger", {
    "vo/k_lab/kl_comeout.wav",
    "vo/k_lab/kl_hedyno01.wav",
    "vo/k_lab/kl_hedyno02.wav",
})

ZBaseCreateVoiceSounds("ZBaseKleiner.KillEnemy", {
    "vo/k_lab/kl_relieved.wav",
    "vo/k_lab2/kl_greatscott.wav",
})