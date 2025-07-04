local NPC = FindZBaseTable(debug.getinfo(1,'S'))

-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_citizen"

NPC.Name = "Dr. Arne Magnusson" -- Name of your NPC
NPC.Category = "HL2: Humans + Resistance" -- Category in the ZBase tab
NPC.Weapons = {"weapon_ar2"} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "zb_kleiner" -- Inherit features from any existing zbase npc

ZBaseCreateVoiceSounds("ZBaseMagnusson.Alert", {
    "vo/outland_11a/magtraining/mag_tutor_aimforcarap.wav",
    "vo/outland_11a/magtraining/mag_tutor_darelaunch02.wav",
})

ZBaseCreateVoiceSounds("ZBaseMagnusson.Die", {
    "vo/outland_11a/silo/mag_silo_follownags05.wav",
})

ZBaseCreateVoiceSounds("ZBaseMagnusson.SeeDanger", {
    "vo/outland_11a/silo/mag_silo_followquick04.wav",
})

ZBaseCreateVoiceSounds("ZBaseMagnusson.Question", {
    "vo/outland_11a/magtraining/mag_tutor_bitmore.wav",
    "vo/outland_11a/magtraining/mag_tutor_brawn01.wav",
    "vo/outland_11a/magtraining/mag_tutor_darelaunch03.wav",
    "vo/outland_11a/magtraining/mag_tutor_fragile.wav",
    "vo/outland_11a/magtraining/mag_tutor_fueled.wav",
    "vo/outland_11a/magtraining/mag_tutor_getinpractice.wav",
    "vo/outland_11a/silo/mag_silo_falsealarms01.wav",
    "vo/outland_11a/silo/mag_silo_needahand02.wav",
    "vo/outland_11a/silo/mag_silo_kleinercert01.wav",
})

ZBaseCreateVoiceSounds("ZBaseMagnusson.Answer", {
    "vo/outland_11a/magtraining/mag_tutor_moveon.wav",
    "vo/outland_11a/magtraining/mag_tutor_hadenough.wav",
    "vo/outland_11a/magtraining/mag_tutor_looklively.wav",
    "vo/outland_11a/magtraining/mag_tutor_magdevice02.wav",
    "vo/outland_11a/magtraining/mag_tutor_overhere.wav",
    "vo/outland_11a/magtraining/mag_tutor_squander.wav",
    "vo/outland_11a/silo/mag_silo_excuseme01.wav",
    "vo/outland_11a/silo/mag_silo_guarant.wav",
    "vo/outland_11a/silo/mag_silo_kleinercert02.wav",
})

ZBaseCreateVoiceSounds("ZBaseMagnusson.AllyDeath", {
    "vo/outland_11a/magtraining/mag_tutor_takeyourtime.wav",
})

ZBaseCreateVoiceSounds("ZBaseMagnusson.HearDanger", {
    "vo/outland_11a/silo/mag_silo_falsealarms01.wav",
    "vo/outland_11a/silo/mag_silo_falsealarms02.wav",
    "vo/outland_11a/silo/mag_silo_falsealarms03.wav",
})

ZBaseCreateVoiceSounds("ZBaseMagnusson.KillEnemy", {
    "vo/outland_11a/magtraining/mag_tutor_nottoohard01.wav",
    "vo/outland_11a/magtraining/mag_tutor_nottoohard02.wav",
    "vo/outland_11a/silo/mag_silo_changeplans01.wav",
    "vo/outland_11a/silo/mag_silo_lamarr.wav",
})