ZBCVAR = {}


local Flags = bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED)


--[[
==================================================================================================
                                           CORPSE/GIBS
==================================================================================================
--]]


ZBCVAR.RemoveRagdollTime = CreateConVar("zbase_rag_remove_time", "0", Flags)
ZBCVAR.MaxRagdolls = CreateConVar("zbase_rag_max", "30", Flags)


ZBCVAR.RemoveGibTime = CreateConVar("zbase_gib_remove_time", "60", Flags)
ZBCVAR.MaxGibs = CreateConVar("zbase_gib_max", "30", Flags)
ZBCVAR.GibCollide = CreateConVar("zbase_gib_collide", "0", Flags)


--[[
==================================================================================================
                                           WEAPONS
==================================================================================================
--]]


ZBCVAR.FullHL2WepDMG_NPC = CreateConVar("zbase_full_hl2_wep_damage_npc", "1", Flags)
ZBCVAR.FullHL2WepDMG_PLY = CreateConVar("zbase_full_hl2_wep_damage_ply", "0", Flags)