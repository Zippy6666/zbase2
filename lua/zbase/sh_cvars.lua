local Flags = bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY)

 
ZBCVAR = {}
ZBCVAR.HPMult = CreateConVar("zbase_hp_mult", "1", Flags)
ZBCVAR.DMGMult = CreateConVar("zbase_dmg_mult", "1", Flags)
ZBCVAR.Nerf = CreateConVar("zbase_nerf", "1", Flags)
ZBCVAR.MaxNPCsShootPly = CreateConVar("zbase_max_npcs_shoot_ply", "2", Flags)
ZBCVAR.GrenCount = CreateConVar("zbase_gren_count", "-1", Flags)
ZBCVAR.AltCount = CreateConVar("zbase_alt_count", "-1", Flags)
ZBCVAR.GrenAltRand = CreateConVar("zbase_gren_alt_rand", "0", Flags)
ZBCVAR.PlayerHurtAllies = CreateConVar("zbase_ply_hurt_ally", "0", Flags)
ZBCVAR.Precache = CreateConVar("zbase_precache", "0", Flags)
ZBCVAR.Patrol = CreateConVar("zbase_patrol", "1", Flags)
ZBCVAR.CallForHelp = CreateConVar("zbase_callforhelp", "1", Flags)
ZBCVAR.CampaignReplace = CreateConVar("zbase_camp_replace", "0", Flags)
ZBCVAR.ItemDrop = CreateConVar("zbase_item_drops", "1", Flags)
ZBCVAR.DissolveWep = CreateConVar("zbase_dissolve_wep", "0", Flags)
ZBCVAR.Static = CreateConVar("zbase_static", "0", Flags)
ZBCVAR.RandWep = CreateConVar("zbase_randwep", "0", Flags)
ZBCVAR.RandWepNPCBlackList = CreateConVar("zbase_randwep_blacklist_npc", "beta_unit_combine_assassin", Flags)
ZBCVAR.RandWepBlackList = CreateConVar("zbase_randwep_blacklist_wep", "", Flags)
ZBCVAR.MuzzleLight = CreateConVar("zbase_muzzle_light", "1", Flags)
ZBCVAR.RemoveRagdollTime = CreateConVar("zbase_rag_remove_time", "0", Flags)
ZBCVAR.MaxRagdolls = CreateConVar("zbase_rag_max", "30", Flags)
ZBCVAR.RemoveGibTime = CreateConVar("zbase_gib_remove_time", "60", Flags)
ZBCVAR.MaxGibs = CreateConVar("zbase_gib_max", "30", Flags)
ZBCVAR.GibCollide = CreateConVar("zbase_gib_collide", "0", Flags)
ZBCVAR.ZombieHeadcrabs = CreateConVar("zbase_zombie_headcrabs", "0", Flags)
ZBCVAR.ZombieRedBlood = CreateConVar("zbase_zombie_red_blood", "1", Flags)
ZBCVAR.MetroCopGlowEyes = CreateConVar("zbase_metrocop_glow_eyes", "0", Flags)
ZBCVAR.SvGlowingEyes = CreateConVar("zbase_sv_glowing_eyes", "1", Flags)
ZBCVAR.StartMsg = CreateConVar("zbase_start_msg", "1", Flags)
ZBCVAR.Replace = CreateConVar("zbase_replace", "0", Flags)
ZBCVAR.DefaultMenu = CreateConVar("zbase_defmenu", "0", Flags)
ZBCVAR.ReloadSpawnMenu = CreateConVar("zbase_reload_spawnmenu", "0", Flags)
ZBCVAR.ShowNavigator = CreateConVar("zbase_show_navigator", "0", Flags)
ZBCVAR.ShowSched = CreateConVar("zbase_show_sched", "0", Flags)
ZBCVAR.FollowingEnabled = CreateConVar("zbase_followplayers", "1", Flags)
ZBCVAR.NPCNocollide = CreateConVar("zbase_nocollide", "0", Flags)

if CLIENT then
    ZBCVAR.GlowingEyes = CreateConVar("zbase_glowing_eyes", "1", FCVAR_ARCHIVE)
    ZBCVAR.AllCat = CreateConVar("zbase_allcat", "1", FCVAR_ARCHIVE)
end









