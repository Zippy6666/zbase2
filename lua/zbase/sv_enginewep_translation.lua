ZBase_EngineWeapon_Attributes = {


    --[[
    ======================================================================================================================================================
                                            Pistol
    ======================================================================================================================================================
    --]]


    ["weapon_pistol"] = {
        PrimaryShootSound = "Weapon_Pistol.NPC_Single", 
        PrimaryDamage = 3,
        Primary = {
            DefaultClip = 18, 
            Ammo = "Pistol", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = "1", 
            ShellType = "ShellEject", -- https://wiki.facepunch.com/gmod/Effects
            NumShots = 1,
        },
        NPCBurstMin = 1, 
        NPCBurstMax = 1, 
        NPCFireRate = 0.2, 
        NPCFireRestTimeMin = 0.2, 
        NPCFireRestTimeMax = 1,
        NPCBulletSpreadMult = 1,
        NPCReloadSound = "Weapon_Pistol.Reload", 
        NPCShootDistanceMult = 0.75,
        NPCHoldType =  "pistol" -- https://wiki.facepunch.com/gmod/Hold_Types
    },


    --[[
    ======================================================================================================================================================
                                            SMG
    ======================================================================================================================================================
    --]]


    ["weapon_smg1"] = {
        PrimaryShootSound = "Weapon_SMG1.Single",
        PrimaryDamage = 2,
        Primary = {
            DefaultClip = 45, 
            Ammo = "SMG1", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = "1", 
            ShellType = "ShellEject", -- https://wiki.facepunch.com/gmod/Effects
            NumShots = 1,
        },
        NPCBurstMin = 1, 
        NPCBurstMax = 1, 
        NPCFireRate = 0.1, 
        NPCFireRestTimeMin = 0.1, 
        NPCFireRestTimeMax = 0.1,
        NPCBulletSpreadMult = 1, 
        NPCReloadSound = "Weapon_SMG1.NPC_Reload", 
        NPCShootDistanceMult = 0.75,
        NPCHoldType =  "smg" -- https://wiki.facepunch.com/gmod/Hold_Types
    },


    --[[
    ======================================================================================================================================================
                                            AR2
    ======================================================================================================================================================
    --]]
    

    ["weapon_ar2"] = {
        PrimaryShootSound = "Weapon_AR2.NPC_Single",
        PrimaryDamage = 3,
        Primary = {
            DefaultClip = 30, 
            Ammo = "AR2", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = false, 
            NumShots = 1,
            MuzzleFlashFlags = 5,
            TracerName = "AR2Tracer",
            TracerChance = 1,
        },
        NPCBurstMin = 3,
        NPCBurstMax = 8,
        NPCFireRate = 0.1,
        NPCFireRestTimeMin = 0.2, 
        NPCFireRestTimeMax = 1,
        NPCBulletSpreadMult = 0.25, 
        NPCReloadSound = "Weapon_AR2.NPC_Reload", 
        NPCShootDistanceMult = 1,
        NPCHoldType =  "ar2" -- https://wiki.facepunch.com/gmod/Hold_Types
    },


    --[[
    ======================================================================================================================================================
                                            SMG
    ======================================================================================================================================================
    --]]


    ["weapon_shotgun"] = {
        PrimaryShootSound = "Weapon_Shotgun.Single",
        PrimarySpread = 0.02, 
        PrimaryDamage = 3,
        Primary = {
            DefaultClip = 8, 
            Ammo = "Buckshot", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = "1", 
            ShellType = "ShotgunShellEject", -- https://wiki.facepunch.com/gmod/Effects
            NumShots = 7,
        },
        NPCBurstMin = 1,
        NPCBurstMax = 1,
        NPCFireRate = 0,
        NPCFireRestTimeMin = 1, 
        NPCFireRestTimeMax = 2,
        NPCBulletSpreadMult = 1, 
        NPCReloadSound = "Weapon_Shotgun.NPC_Reload", 
        NPCShootDistanceMult = 0.5,
        NPCHoldType =  "shotgun" -- https://wiki.facepunch.com/gmod/Hold_Types
    },


    --[[
    ======================================================================================================================================================
                                            AR2
    ======================================================================================================================================================
    --]]
    

    ["weapon_crossbow"] = {
        PrimaryShootSound = "Weapon_AR2.NPC_Single",
        PrimaryDamage = 10,
        Primary = {
            DefaultClip = 1, 
            Ammo = "XBowBolt", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = false, 
            NumShots = 1,
            TracerChance = 0,
            MuzzleFlash = false
        },
        NPCBurstMin = 3,
        NPCBurstMax = 8,
        NPCFireRate = 0.1,
        NPCFireRestTimeMin = 0.2, 
        NPCFireRestTimeMax = 1,
        NPCBulletSpreadMult = 0.25, 
        NPCReloadSound = "Weapon_AR2.NPC_Reload", 
        NPCShootDistanceMult = 1,
        NPCHoldType =  "ar2" -- https://wiki.facepunch.com/gmod/Hold_Types
    },
}