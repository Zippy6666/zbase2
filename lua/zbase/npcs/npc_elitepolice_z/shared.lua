local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "base_ai_zbase" if you want to create a brand new SNPC
NPC.Class = "npc_metropolice"


NPC.Name = "Civil Protection Elite" -- Name of your NPC
NPC.Category = "Default" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_police_z" -- Inherit features from any existing zbase npc


--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.Idle", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.Question", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.Answer", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.Alert", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.IdleEnemy", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.LostEnemy", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.KilledEnemy", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.AllyDeath", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.HearDanger", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.Pain", {
})
--]]==============================================================================================]]
ZBaseCreateVoiceSounds("ZBaseElitePolice.Death", {
})
--]]==============================================================================================]]