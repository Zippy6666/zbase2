local Flags = bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY)

ZBCVAR = {}

ZBCVAR.HPMult =                 CreateConVar("zbase_hp_mult", "1", Flags)
ZBCVAR.DMGMult =                CreateConVar("zbase_dmg_mult", "1", Flags)
ZBCVAR.MoveSpeedMult =          CreateConVar("zbase_speed_mult", "1", Flags)
ZBCVAR.PlayerHurtAllies =       CreateConVar("zbase_ply_hurt_ally", "0", Flags)
ZBCVAR.FriendlyFire =           CreateConVar("zbase_friendly_fire", "0", Flags)

ZBCVAR.Nerf =                   CreateConVar("zbase_nerf", "1", Flags)
ZBCVAR.MaxNPCsShootPly =        CreateConVar("zbase_max_npcs_shoot_ply", "3", Flags)
ZBCVAR.GrenCount =              CreateConVar("zbase_gren_count", "2", Flags)
ZBCVAR.AltCount =               CreateConVar("zbase_alt_count", "-1", Flags)
ZBCVAR.GrenAltRand =            CreateConVar("zbase_gren_alt_rand", "0", Flags)

ZBCVAR.FallbackNav =            CreateConVar("zbase_fallback_nav", "1", Flags)
ZBCVAR.MoreJumping =            CreateConVar("zbase_more_jumping", "0", Flags)
ZBCVAR.NPCNocollide =           CreateConVar("zbase_nocollide", "0", Flags)

ZBCVAR.ArmorSparks =            CreateConVar("zbase_armor_sparks", "1", Flags)
ZBCVAR.MuzzleLight =            CreateConVar("zbase_muzzle_light", "0", Flags)
ZBCVAR.Muzzle =                 CreateConVar("zbase_muzztyle", "mmod", Flags)
ZBCVAR.AR2Muzzle =              CreateConVar("zbase_mar2tyle", "mmod", Flags)

ZBCVAR.Patrol =                 CreateConVar("zbase_patrol", "1", Flags)
ZBCVAR.CallForHelp =            CreateConVar("zbase_callforhelp", "1", Flags)
ZBCVAR.AutoSquad =              CreateConVar("zbase_autosquad", "0", Flags)
ZBCVAR.FollowingEnabled =       CreateConVar("zbase_followplayers", "1", Flags)
ZBCVAR.SightDist =              CreateConVar("zbase_sightdist", "4096", Flags)
ZBCVAR.SightDistOverride =      CreateConVar("zbase_sightdist_override", "0", Flags)

ZBCVAR.ItemDrop =               CreateConVar("zbase_item_drops", "1", Flags)
ZBCVAR.DissolveWep =            CreateConVar("zbase_dissolve_wep", "0", Flags)
ZBCVAR.RemoveRagdollTime =      CreateConVar("zbase_rag_remove_time", "0", Flags)
ZBCVAR.MaxRagdolls =            CreateConVar("zbase_rag_max", "30", Flags)
ZBCVAR.ClientRagdolls =         CreateConVar("zbase_cl_ragdolls", "0", Flags)
ZBCVAR.RemoveGibTime =          CreateConVar("zbase_gib_remove_time", "60", Flags)
ZBCVAR.MaxGibs =                CreateConVar("zbase_gib_max", "30", Flags)
ZBCVAR.GibCollide =             CreateConVar("zbase_gib_collide", "0", Flags)

ZBCVAR.ZombieHeadcrabs =        CreateConVar("zbase_zombie_headcrabs", "1", Flags)
ZBCVAR.ZombieRedBlood =         CreateConVar("zbase_zombie_red_blood", "1", Flags)

ZBCVAR.CitizenRocks =           CreateConVar("zbase_cit_rocks", "1", Flags)
ZBCVAR.RebelAmmo =              CreateConVar("zbase_reb_ammo", "0", Flags)

ZBCVAR.MetroCopGlowEyes =       CreateConVar("zbase_metrocop_glow_eyes", "0", Flags)
ZBCVAR.MetroCopArrest =         CreateConVar("zbase_metrocop_arrest", "0", Flags)

ZBCVAR.SvGlowingEyes =          CreateConVar("zbase_sv_glowing_eyes", "1", Flags)

ZBCVAR.Replace =                CreateConVar("zbase_replace", "0", Flags)
ZBCVAR.CampaignReplace =        CreateConVar("zbase_camp_replace", "0", Flags)
ZBCVAR.CustomClass =            CreateConVar("zbase_custom_class", "1", Flags)
ZBCVAR.DefaultMenu =            CreateConVar("zbase_defmenu", "0", Flags)
ZBCVAR.MenuMixin =              CreateConVar("zbase_mixmenu", "0", Flags)
ZBCVAR.NoDefHL2 =               CreateConVar("zbase_nodefhl2", "1", Flags)
ZBCVAR.ReloadSpawnMenu =        CreateConVar("zbase_reload_spawnmenu", "0", Flags)

ZBCVAR.ShowNavigator =          CreateConVar("zbase_show_navigator", "0", Flags)
ZBCVAR.ShowSched =              CreateConVar("zbase_show_sched", "0", Flags)

ZBCVAR.SpawnerCooldown =        CreateConVar("zbase_spawner_cooldown", "3", Flags)
ZBCVAR.SpawnerVisibility =      CreateConVar("zbase_spawner_vis", "0", Flags)
ZBCVAR.SpawnerDistance =        CreateConVar("zbase_spawner_mindist", "0", Flags)

ZBCVAR.FactionAdminOnly =       CreateConVar("zbase_faction_admin_only", "1", Flags)

if CLIENT then
    ZBCVAR.GlowingEyes =        CreateConVar("zbase_glowing_eyes", "1", FCVAR_ARCHIVE)
    ZBCVAR.FollowHalo =         CreateConVar("zbase_follow_halo", "1", FCVAR_ARCHIVE)

    ZBCVAR.PopUp =              CreateConVar("zbase_popup", "1", FCVAR_ARCHIVE)
    ZBCVAR.CollapseCat =        CreateConVar("zbase_collapse_cat", "1", FCVAR_ARCHIVE)
    
    ZBCVAR.RandWep =            CreateConVar("zbase_randwep", "0", FCVAR_ARCHIVE)
end