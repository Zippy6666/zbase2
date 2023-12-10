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
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.Answer", {
    "vo/npc/male01/answer01.wav",
    "vo/npc/male01/answer02.wav",
    "vo/npc/male01/answer03.wav",
    "vo/npc/male01/answer04.wav",
    "vo/npc/male01/answer05.wav",
    "vo/npc/male01/answer06.wav",
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
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.HearSound", {

})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.LostEnemy", {

})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.Grenade", {
    "vo/npc/male01/headsup01.wav",
    "vo/npc/male01/headsup02.wav",
    "vo/npc/male01/incoming02.wav",
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseMale.Melee", {
    "vo/npc/male01/gethellout.wav",
    "vo/npc/male01/getdown02.wav",
})
--]]==============================================================================================]]