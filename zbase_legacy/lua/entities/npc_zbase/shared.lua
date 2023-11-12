AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName		= "ZBase"
ENT.Author			= "Zippy"
ENT.Category = "ZBase"
ENT.AutomaticFrameAdvance = false

ENT.IsZBaseSNPC = true

-- Default weapons
-- Remember to change it to the same class name as your SNPC (not "npc_zbase" as it is right now)!
-- You need to start a new map for it to take effect!
ZBASE_NPC_WEAPONS["npc_zbase"] = {"weapon_zbase_ak47"} -- Add as many weapons as you want