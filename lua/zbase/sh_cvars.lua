local flags = bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY)

ZBCVAR = {}

ZBCVAR.HPMult =                 CreateConVar("zbase_hp_mult", "1", flags)
ZBCVAR.DMGMult =                CreateConVar("zbase_dmg_mult", "1", flags)
ZBCVAR.MoveSpeedMult =          CreateConVar("zbase_speed_mult", "1", flags)
ZBCVAR.PlayerHurtAllies =       CreateConVar("zbase_ply_hurt_ally", "1", flags)
ZBCVAR.FriendlyFire =           CreateConVar("zbase_friendly_fire", "0", flags)

ZBCVAR.Nerf =                   CreateConVar("zbase_nerf", "1", flags)
ZBCVAR.GrenCount =              CreateConVar("zbase_gren_count", "2", flags)
ZBCVAR.AltCount =               CreateConVar("zbase_alt_count", "-1", flags)
ZBCVAR.GrenAltRand =            CreateConVar("zbase_gren_alt_rand", "0", flags)

ZBCVAR.FallbackNav =            CreateConVar("zbase_fallback_nav", "1", flags)
ZBCVAR.MoreJumping =            CreateConVar("zbase_more_jumping", "0", flags)
ZBCVAR.NPCNocollide =           CreateConVar("zbase_nocollide", "0", flags)

ZBCVAR.ArmorSparks =            CreateConVar("zbase_armor_sparks", "1", flags)
ZBCVAR.MuzzleLight =            CreateConVar("zbase_muzzle_light", "1", flags)
ZBCVAR.Muzzle =                 CreateConVar("zbase_muzztyle", "mmod", flags)
ZBCVAR.AR2Muzzle =              CreateConVar("zbase_mar2tyle", "mmod", flags)

ZBCVAR.Patrol =                 CreateConVar("zbase_patrol", "1", flags)
ZBCVAR.CallForHelp =            CreateConVar("zbase_callforhelp", "1", flags)
ZBCVAR.FollowingEnabled =       CreateConVar("zbase_followplayers", "1", flags)
ZBCVAR.SightDist =              CreateConVar("zbase_sightdist", "10000", flags)
ZBCVAR.SightDistOverride =      CreateConVar("zbase_sightdist_override", "0", flags)

ZBCVAR.ItemDrop =               CreateConVar("zbase_item_drops", "1", flags)
ZBCVAR.DissolveWep =            CreateConVar("zbase_dissolve_wep", "0", flags)
ZBCVAR.RemoveRagdollTime =      CreateConVar("zbase_rag_remove_time", "0", flags)
ZBCVAR.MaxRagdolls =            CreateConVar("zbase_rag_max", "30", flags)
ZBCVAR.ClientRagdolls =         CreateConVar("zbase_cl_ragdolls", "0", flags)
ZBCVAR.RemoveGibTime =          CreateConVar("zbase_gib_remove_time", "60", flags)
ZBCVAR.MaxGibs =                CreateConVar("zbase_gib_max", "30", flags)
ZBCVAR.GibCollide =             CreateConVar("zbase_gib_collide", "0", flags)

ZBCVAR.ZombieHeadcrabs =        CreateConVar("zbase_zombie_headcrabs", "1", flags)
ZBCVAR.ZombieRedBlood =         CreateConVar("zbase_zombie_red_blood", "0", flags)

ZBCVAR.CitizenRocks =           CreateConVar("zbase_cit_rocks", "1", flags)
ZBCVAR.RebelAmmo =              CreateConVar("zbase_reb_ammo", "0", flags)

ZBCVAR.MetroCopGlowEyes =       CreateConVar("zbase_metrocop_glow_eyes", "0", flags)
ZBCVAR.MetroCopArrest =         CreateConVar("zbase_metrocop_arrest", "0", flags)

ZBCVAR.SvGlowingEyes =          CreateConVar("zbase_sv_glowing_eyes", "1", flags)

ZBCVAR.CampaignReplace =        CreateConVar("zbase_camp_replace", "0", flags)

ZBCVAR.CustomClass =            CreateConVar("zbase_custom_class", "1", flags)

ZBCVAR.NoDefHL2 =               CreateConVar("zbase_nodefhl2", "1", flags)
ZBCVAR.ReloadSpawnMenu =        CreateConVar("zbase_reload_spawnmenu", "0", flags)

ZBCVAR.ShowNavigator =          CreateConVar("zbase_show_navigator", "0", flags)
ZBCVAR.ShowSched =              CreateConVar("zbase_show_sched", "0", flags)

ZBCVAR.SpawnerCooldown =        CreateConVar("zbase_spawner_cooldown", "1", flags)
ZBCVAR.SpawnerVisibility =      CreateConVar("zbase_spawner_vis", "0", flags)
ZBCVAR.SpawnerDistance =        CreateConVar("zbase_spawner_mindist", "0", flags)

ZBCVAR.FactionAdminOnly =       CreateConVar("zbase_faction_admin_only", "1", flags)

if CLIENT then
    ZBCVAR.GlowingEyes =        CreateConVar("zbase_glowing_eyes", "1", FCVAR_ARCHIVE)
    ZBCVAR.FollowHalo =         CreateConVar("zbase_follow_halo", "1", FCVAR_ARCHIVE)

    ZBCVAR.PopUp =              CreateConVar("zbase_popup", "1", FCVAR_ARCHIVE)
    ZBCVAR.CollapseCat =        CreateConVar("zbase_collapse_cat", "1", FCVAR_ARCHIVE)
    ZBCVAR.NPCTabHide =         CreateConVar("zbase_npctabhide", "0", FCVAR_ARCHIVE)
    
    ZBCVAR.RandWep =            CreateClientConVar("zbase_randwep", "0", true, true)
    ZBCVAR.GuardOnSpwn =        CreateClientConVar("zbase_guardonspwn", "0", true, true)
    ZBCVAR.SpawnDocile =        CreateClientConVar("zbase_spwndocile", "0", true, true)
    ZBCVAR.ClPlyFaction =       CreateClientConVar("zbase_clplyfaction", "ally", false, true)
end