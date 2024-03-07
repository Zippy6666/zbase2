ZBCVAR = {}


local Flags = bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED)


--[[
==================================================================================================
                                           GENERAL
==================================================================================================
--]]


ZBCVAR.HPMult = CreateConVar("zbase_hp_mult", "1", Flags)
ZBCVAR.DMGMult = CreateConVar("zbase_dmg_mult", "1", Flags)
ZBCVAR.SvGlowingEyes = CreateConVar("zbase_sv_glowing_eyes", "1", Flags)
ZBCVAR.PlayerHurtAllies = CreateConVar("zbase_ply_hurt_ally", "0", Flags)
ZBCVAR.Precache = CreateConVar("zbase_precache", "1", Flags)
ZBCVAR.Patrol = CreateConVar("zbase_patrol", "1", Flags)

--[[
==================================================================================================
                                           RANDOM WEAPON
==================================================================================================
--]]

ZBCVAR.RandWep = CreateConVar("zbase_randwep", "0", Flags)


local NPCBlackList = "beta_unit_combine_assassin"
ZBCVAR.RandWepNPCBlackList = CreateConVar("zbase_randwep_blacklist_npc", NPCBlackList, Flags)

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
                                           ZOMBIES
==================================================================================================
--]]


ZBCVAR.ZombieHeadcrabs = CreateConVar("zbase_zombie_headcrabs", "0", Flags)
ZBCVAR.ZombieRedBlood = CreateConVar("zbase_zombie_red_blood", "1", Flags)



--[[
==================================================================================================
                                           CLIENT
==================================================================================================
--]]

if CLIENT then


    ZBCVAR.GlowingEyes = CreateConVar("zbase_glowing_eyes", "1", FCVAR_ARCHIVE)


end

--[[
==================================================================================================
                                           GUI
==================================================================================================
--]]


ZBCVAR.StartMsg = CreateConVar("zbase_start_msg", "1", Flags)
ZBCVAR.Replace = CreateConVar("zbase_replace", "1", Flags)
ZBCVAR.DefaultMenu = CreateConVar("zbase_defmenu", "1", Flags)


--[[
==================================================================================================
                                           DEV
==================================================================================================
--]]


ZBCVAR.ShowNavigator = CreateConVar("zbase_show_navigator", "0", Flags)
ZBCVAR.ShowSched = CreateConVar("zbase_show_sched", "0", Flags)
ZBCVAR.ReloadSpawnMenu = CreateConVar("zbase_reload_spawnmenu", "1", Flags)






