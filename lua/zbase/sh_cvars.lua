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
                                           DEBUG
==================================================================================================
--]]


ZBCVAR.NoThink = CreateConVar("zbase_no_think", "0", Flags)
ZBCVAR.ShowNavigator = CreateConVar("zbase_show_navigator", "0", Flags)
ZBCVAR.ShowSched = CreateConVar("zbase_show_sched", "0", Flags)


--[[
==================================================================================================
                                           OTHER
==================================================================================================
--]]


ZBCVAR.ReloadSpawnMenu = CreateConVar("zbase_reload_spawnmenu", "1", Flags)
ZBCVAR.HPMult = CreateConVar("zbase_hp_mult", "1", Flags)
ZBCVAR.DMGMult = CreateConVar("zbase_dmg_mult", "1", Flags)
ZBCVAR.SvGlowingEyes = CreateConVar("zbase_sv_glowing_eyes", "1", Flags)
ZBCVAR.PlayerHurtAllies = CreateConVar("zbase_ply_hurt_ally", "0", Flags)