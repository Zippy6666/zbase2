local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_citizen"


NPC.Name = "Female Civilian" -- Name of your NPC
NPC.Category = "HL2: Humans + Resistance" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "zb_human_civilian" -- Inherit features from any existing zbase npc


--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseFemale.Alert", {
    "vo/npc/female01/headsup01.wav",
    "vo/npc/female01/headsup02.wav",
    "vo/npc/female01/incoming02.wav",
    "vo/npc/female01/heretheycome01.wav",
    "vo/npc/female01/overthere01.wav",
    "vo/npc/female01/overthere02.wav",
    "npc/vo/zbase/npc/female01/cit_shock01.wav",
    "npc/vo/zbase/npc/female01/cit_shock02.wav",
    "npc/vo/zbase/npc/female01/cit_shock03.wav",
    "npc/vo/zbase/npc/female01/cit_shock04.wav",
    "npc/vo/zbase/npc/female01/cit_shock05.wav",
    "npc/vo/zbase/npc/female01/cit_shock06.wav",
    "npc/vo/zbase/npc/female01/cit_alert_antlions06.wav",
    "npc/vo/zbase/npc/female01/cit_alert_antlions08.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseFemale.Question", {
    "vo/npc/female01/question01.wav", 
    "vo/npc/female01/question02.wav", 
    "vo/npc/female01/question03.wav", 
    "vo/npc/female01/question04.wav", 
    "vo/npc/female01/question05.wav", 
    "vo/npc/female01/question06.wav", 
    "vo/npc/female01/question07.wav", 
    "vo/npc/female01/question08.wav", 
    "vo/npc/female01/question09.wav", 
    "vo/npc/female01/question10.wav",
    "vo/npc/female01/question11.wav",
    "vo/npc/female01/question12.wav",
    "vo/npc/female01/question13.wav",
    "vo/npc/female01/question14.wav",
    "vo/npc/female01/question15.wav",
    "vo/npc/female01/question16.wav",
    "vo/npc/female01/question17.wav",
    "vo/npc/female01/question18.wav",
    "vo/npc/female01/question19.wav",
    "vo/npc/female01/question20.wav",
    "vo/npc/female01/question21.wav",
    "vo/npc/female01/question22.wav",
    "vo/npc/female01/question23.wav",
    "vo/npc/female01/question24.wav",
    "vo/npc/female01/question25.wav",
    "vo/npc/female01/question26.wav",
    "vo/npc/female01/question27.wav",
    "vo/npc/female01/question28.wav",
    "vo/npc/female01/question29.wav",
    "vo/npc/female01/question30.wav",
    "vo/npc/female01/question31.wav",
    "npc/vo/zbase/npc/female01/cit_remarks01.wav",
    "npc/vo/zbase/npc/female01/cit_remarks02.wav",
    "npc/vo/zbase/npc/female01/cit_remarks03.wav",
    "npc/vo/zbase/npc/female01/cit_remarks04.wav",
    "npc/vo/zbase/npc/female01/cit_remarks05.wav",
    "npc/vo/zbase/npc/female01/cit_remarks06.wav",
    "npc/vo/zbase/npc/female01/cit_remarks07.wav",
    "npc/vo/zbase/npc/female01/cit_remarks08.wav",
    "npc/vo/zbase/npc/female01/cit_remarks09.wav",
    "npc/vo/zbase/npc/female01/cit_remarks10.wav",
    "npc/vo/zbase/npc/female01/cit_remarks11.wav",
    "npc/vo/zbase/npc/female01/cit_remarks12.wav",
    "npc/vo/zbase/npc/female01/cit_remarks13.wav",
    "npc/vo/zbase/npc/female01/cit_remarks14.wav",
    "npc/vo/zbase/npc/female01/cit_remarks15.wav",
    "npc/vo/zbase/npc/female01/cit_remarks16.wav",
    "npc/vo/zbase/npc/female01/cit_remarks17.wav",
    "npc/vo/zbase/npc/female01/cit_remarks18.wav",
    "npc/vo/zbase/npc/female01/cit_remarks19.wav",
    "npc/vo/zbase/npc/female01/cit_remarks20.wav",
    "npc/vo/zbase/npc/female01/cit_remarks21.wav",
    "npc/vo/zbase/npc/female01/cit_remarks22.wav",
    "npc/vo/zbase/npc/female01/cit_remarks23.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseFemale.Answer", {
    "vo/npc/female01/answer01.wav",
    "vo/npc/female01/answer02.wav",
    "vo/npc/female01/answer03.wav",
    "vo/npc/female01/answer04.wav",
    "vo/npc/female01/answer05.wav",
    "vo/npc/female01/answer06.wav",
    "vo/npc/female01/answer07.wav",
    "vo/npc/female01/answer08.wav",
    "vo/npc/female01/answer09.wav",
    "vo/npc/female01/answer10.wav",
    "vo/npc/female01/answer11.wav",
    "vo/npc/female01/answer12.wav",
    "vo/npc/female01/answer13.wav",
    "vo/npc/female01/answer14.wav",
    "vo/npc/female01/answer15.wav",
    "vo/npc/female01/answer16.wav",
    "vo/npc/female01/answer17.wav",
    "vo/npc/female01/answer18.wav",
    "vo/npc/female01/answer19.wav",
    "vo/npc/female01/answer20.wav",
    "vo/npc/female01/answer21.wav",
    "vo/npc/female01/answer22.wav",
    "vo/npc/female01/answer23.wav",
    "vo/npc/female01/answer24.wav",
    "vo/npc/female01/answer25.wav",
    "vo/npc/female01/answer26.wav",
    "vo/npc/female01/answer27.wav",
    "vo/npc/female01/answer28.wav",
    "vo/npc/female01/answer29.wav",
    "vo/npc/female01/answer30.wav",
    "vo/npc/female01/answer31.wav",
    "vo/npc/female01/answer32.wav",
    "vo/npc/female01/answer33.wav",
    "vo/npc/female01/answer34.wav",
    "vo/npc/female01/answer35.wav",
    "vo/npc/female01/answer36.wav",
    "vo/npc/female01/answer37.wav",
    "vo/npc/female01/answer38.wav",
    "vo/npc/female01/answer39.wav",
    "vo/npc/female01/answer40.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseFemale.KillEnemy", {
    "vo/npc/female01/gotone01.wav",
    "vo/npc/female01/gotone02.wav",
    "vo/npc/female01/likethat.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseFemale.HearSound", {
    "vo/npc/female01/startle01.wav",
    "vo/npc/female01/startle02.wav",
    "npc/vo/zbase/npc/female01/cit_alert_antlions09.wav",
    "npc/vo/zbase/npc/female01/cit_alert_antlions11.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseFemale.Melee", {
    "vo/npc/female01/gethellout.wav",
    "vo/npc/female01/getdown02.wav",
})
--]]==============================================================================================]]