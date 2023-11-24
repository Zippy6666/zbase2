ZBCVAR = {}


local Flags = bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED)


--[[
==================================================================================================
                                           RAGDOLLS
==================================================================================================
--]]


ZBCVAR.RemoveRagdollTime = CreateConVar("zbase_rag_remove_time", "0", Flags)
ZBCVAR.MaxRagdolls = CreateConVar("zbase_rag_max", "30", Flags)