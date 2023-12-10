local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_citizen"


NPC.Name = "Male Civilian" -- Name of your NPC
NPC.Category = "HL2: Humans + Resistance" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc



--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.Alert", {
    "vo/npc/male01/headsup01.wav",
    "vo/npc/male01/headsup02.wav",
    "vo/npc/male01/incoming02.wav",
    "vo/npc/male01/heretheycome01.wav",
    "vo/npc/male01/overthere01.wav",
    "vo/npc/male01/overthere02.wav",
    "npc/vo/zbase/npc/male01/cit_shock01.wav",
    "npc/vo/zbase/npc/male01/cit_shock02.wav",
    "npc/vo/zbase/npc/male01/cit_shock03.wav",
    "npc/vo/zbase/npc/male01/cit_shock04.wav",
    "npc/vo/zbase/npc/male01/cit_shock05.wav",
    "npc/vo/zbase/npc/male01/cit_shock06.wav",
    "npc/vo/zbase/npc/male01/cit_shock07.wav",
    "npc/vo/zbase/npc/male01/cit_shock08.wav",
    "npc/vo/zbase/npc/male01/cit_shock09.wav",
    "npc/vo/zbase/npc/male01/cit_shock10.wav",
    "npc/vo/zbase/npc/male01/cit_shock11.wav",
    "npc/vo/zbase/npc/male01/cit_alert_head06.wav",
    "npc/vo/zbase/npc/male01/cit_alert_rollers04.wav",
    "npc/vo/zbase/npc/male01/cit_alert_zombie09.wav",
    "npc/vo/zbase/npc/male01/cit_alert_zombie06.wav",
    "npc/vo/zbase/npc/male01/cit_alert_antlions06.wav",
    "npc/vo/zbase/npc/male01/cit_alert_antlions08.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.Question", {
    "vo/npc/male01/question01.wav", 
    "vo/npc/male01/question02.wav", 
    "vo/npc/male01/question03.wav", 
    "vo/npc/male01/question04.wav", 
    "vo/npc/male01/question05.wav", 
    "vo/npc/male01/question06.wav", 
    "vo/npc/male01/question07.wav", 
    "vo/npc/male01/question08.wav", 
    "vo/npc/male01/question09.wav", 
    "vo/npc/male01/question10.wav",
    "vo/npc/male01/question11.wav",
    "vo/npc/male01/question12.wav",
    "vo/npc/male01/question13.wav",
    "vo/npc/male01/question14.wav",
    "vo/npc/male01/question15.wav",
    "vo/npc/male01/question16.wav",
    "vo/npc/male01/question17.wav",
    "vo/npc/male01/question18.wav",
    "vo/npc/male01/question19.wav",
    "vo/npc/male01/question20.wav",
    "vo/npc/male01/question21.wav",
    "vo/npc/male01/question22.wav",
    "vo/npc/male01/question23.wav",
    "vo/npc/male01/question24.wav",
    "vo/npc/male01/question25.wav",
    "vo/npc/male01/question26.wav",
    "vo/npc/male01/question27.wav",
    "vo/npc/male01/question28.wav",
    "vo/npc/male01/question29.wav",
    "vo/npc/male01/question30.wav",
    "vo/npc/male01/question31.wav",
    "npc/vo/zbase/npc/male01/cit_remarks01.wav",
    "npc/vo/zbase/npc/male01/cit_remarks02.wav",
    "npc/vo/zbase/npc/male01/cit_remarks03.wav",
    "npc/vo/zbase/npc/male01/cit_remarks04.wav",
    "npc/vo/zbase/npc/male01/cit_remarks05.wav",
    "npc/vo/zbase/npc/male01/cit_remarks06.wav",
    "npc/vo/zbase/npc/male01/cit_remarks07.wav",
    "npc/vo/zbase/npc/male01/cit_remarks08.wav",
    "npc/vo/zbase/npc/male01/cit_remarks09.wav",
    "npc/vo/zbase/npc/male01/cit_remarks10.wav",
    "npc/vo/zbase/npc/male01/cit_remarks11.wav",
    "npc/vo/zbase/npc/male01/cit_remarks12.wav",
    "npc/vo/zbase/npc/male01/cit_remarks13.wav",
    "npc/vo/zbase/npc/male01/cit_remarks14.wav",
    "npc/vo/zbase/npc/male01/cit_remarks15.wav",
    "npc/vo/zbase/npc/male01/cit_remarks16.wav",
    "npc/vo/zbase/npc/male01/cit_remarks17.wav",
    "npc/vo/zbase/npc/male01/cit_remarks18.wav",
    "npc/vo/zbase/npc/male01/cit_remarks19.wav",
    "npc/vo/zbase/npc/male01/cit_remarks20.wav",
    "npc/vo/zbase/npc/male01/cit_remarks21.wav",
    "npc/vo/zbase/npc/male01/cit_remarks22.wav",
    "npc/vo/zbase/npc/male01/cit_remarks23.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.Answer", {
    "vo/npc/male01/answer01.wav",
    "vo/npc/male01/answer02.wav",
    "vo/npc/male01/answer03.wav",
    "vo/npc/male01/answer04.wav",
    "vo/npc/male01/answer05.wav",
    "vo/npc/male01/answer07.wav",
    "vo/npc/male01/answer08.wav",
    "vo/npc/male01/answer09.wav",
    "vo/npc/male01/answer10.wav",
    "vo/npc/male01/answer11.wav",
    "vo/npc/male01/answer12.wav",
    "vo/npc/male01/answer13.wav",
    "vo/npc/male01/answer14.wav",
    "vo/npc/male01/answer15.wav",
    "vo/npc/male01/answer16.wav",
    "vo/npc/male01/answer17.wav",
    "vo/npc/male01/answer18.wav",
    "vo/npc/male01/answer19.wav",
    "vo/npc/male01/answer20.wav",
    "vo/npc/male01/answer21.wav",
    "vo/npc/male01/answer22.wav",
    "vo/npc/male01/answer23.wav",
    "vo/npc/male01/answer24.wav",
    "vo/npc/male01/answer25.wav",
    "vo/npc/male01/answer26.wav",
    "vo/npc/male01/answer27.wav",
    "vo/npc/male01/answer28.wav",
    "vo/npc/male01/answer29.wav",
    "vo/npc/male01/answer30.wav",
    "vo/npc/male01/answer31.wav",
    "vo/npc/male01/answer32.wav",
    "vo/npc/male01/answer33.wav",
    "vo/npc/male01/answer34.wav",
    "vo/npc/male01/answer35.wav",
    "vo/npc/male01/answer36.wav",
    "vo/npc/male01/answer37.wav",
    "vo/npc/male01/answer38.wav",
    "vo/npc/male01/answer39.wav",
    "vo/npc/male01/answer40.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.KillEnemy", {
    "vo/npc/male01/gotone01.wav",
    "vo/npc/male01/gotone02.wav",
    "vo/npc/male01/likethat.wav",
    "npc/vo/zbase/npc/male01/reb2_killshots01.wav",
    "npc/vo/zbase/npc/male01/reb2_killshots22.wav",
    "npc/vo/zbase/npc/male01/cit_alert_head05.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.HearSound", {
    "vo/npc/male01/startle01.wav",
    "vo/npc/male01/startle02.wav",
    "npc/vo/zbase/npc/male01/cit_alert_antlions09.wav",
    "npc/vo/zbase/npc/male01/cit_alert_antlions11.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.Melee", {
    "vo/npc/male01/gethellout.wav",
    "vo/npc/male01/getdown02.wav",
    "npc/vo/zbase/npc/male01/reb2_antlions05.wav",
    "npc/vo/zbase/npc/male01/reb2_buddykilled13.wav",
})
--]]==============================================================================================]]