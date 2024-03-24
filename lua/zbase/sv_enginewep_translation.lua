local trailcol = Color(255,150,100) -- For crossbow


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
        NPCFireRestTimeMax = 0.6,
        NPCBulletSpreadMult = 1.5,
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
        PrimaryShootSound = "Weapon_SMG1.NPC_Single",
        PrimaryDamage = 2,
        Primary = {
            DefaultClip = 45, 
            Ammo = "SMG1", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = "1", 
            ShellType = "ShellEject", -- https://wiki.facepunch.com/gmod/Effects
            NumShots = 1,
            MuzzleFlashChance = 2,
        },
        NPCBurstMin = 1, 
        NPCBurstMax = 1, 
        NPCFireRate = 0.1, 
        NPCFireRestTimeMin = 0.1, 
        NPCFireRestTimeMax = 0.1,
        NPCBulletSpreadMult = 1.5, 
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
        NPCFireRestTimeMax = 0.5,
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
        NPCFireRestTimeMin = 0.5, 
        NPCFireRestTimeMax = 1,
        NPCBulletSpreadMult = 1.5, 
        NPCReloadSound = "Weapon_Shotgun.NPC_Reload", 
        NPCShootDistanceMult = 0.5,
        NPCHoldType =  "shotgun" -- https://wiki.facepunch.com/gmod/Hold_Types
    },


    --[[
    ======================================================================================================================================================
                                            CROSSBOW
    ======================================================================================================================================================
    --]]
    

    ["weapon_crossbow"] = {
        PrimaryShootSound = "Weapon_Crossbow.Single",
        PrimaryDamage = 40,
        Primary = {
            DefaultClip = 1, 
            Ammo = "XBowBolt", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = false, 
            NumShots = 1,
            TracerChance = 0,
            MuzzleFlash = false
        },
        NPCBulletSpreadMult = 0.5, 
        NPCReloadSound = "Weapon_Crossbow.BoltElectrify", 
        NPCShootDistanceMult = 2,
        NPCHoldType =  "shotgun", -- https://wiki.facepunch.com/gmod/Hold_Types
        NPCPrimaryAttack = function( self )
            local own = self:GetOwner()

            if IsValid(own) then

                local start = self:GetAttachment(self:LookupAttachment("muzzle")).Pos
                local vel = own:GetAimVector()*3000

                local proj = ents.Create("crossbow_bolt")
                proj:SetPos(start)
                proj:SetAngles(vel:Angle())
                proj:SetOwner(own)
                proj:Spawn()
                proj:SetVelocity(vel)
                proj.IsZBaseCrossbowFiredBolt = true
                util.SpriteTrail(proj, 0, trailcol, true, 2, 0, 0.75, 20, "trails/plasma")

                self:TakePrimaryAmmo(1)
                self:EmitSound(self.PrimaryShootSound)
                
            end

            return true
        end,
    },


    --[[
    ======================================================================================================================================================
                                            .357
    ======================================================================================================================================================
    --]]


    ["weapon_357"] = {
        PrimaryShootSound = "Weapon_357.Single",
        NPCReloadSound = "Weapon_357.RemoveLoader", 
        NPCFireRestTimeMin = 0.5, 
        NPCFireRestTimeMax = 1,
        NPCHoldType =  "revolver", -- https://wiki.facepunch.com/gmod/Hold_Types
        NPCBulletSpreadMult = 1.5, 
        NPCShootDistanceMult = 0.75,
        PrimaryDamage = 30,
        Primary = {
            DefaultClip = 6, 
            Ammo = "357", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = false, 
        },
    },


    --[[
    ======================================================================================================================================================
                                            CROWBAR
    ======================================================================================================================================================
    --]]


    ["weapon_crowbar"] = {
        NPCIsMeleeWep = true,
        NPCHoldType =  "melee", -- https://wiki.facepunch.com/gmod/Hold_Types
    },


    --[[
    ======================================================================================================================================================
                                            RPG
    ======================================================================================================================================================
    --]]


    ["weapon_rpg"] = {
        NPCHoldType =  "rpg", -- https://wiki.facepunch.com/gmod/Hold_Types
        NPCBulletSpreadMult = 1.5, 
        NPCShootDistanceMult = 0.75,
        MuzzleFlashFlags = 7,
        Primary = {
            DefaultClip = 1, 
            Ammo = "RPG", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = false, 
        },
        NPCPrimaryAttack = function( self )
            local own = self:GetOwner()


            if IsValid(own) then
                local start = self:GetAttachment(self:LookupAttachment("muzzle")).Pos
                local vel = own:GetAimVector()*500


                local rocket = ents.Create("rpg_missile")
                rocket:SetPos(start)
                rocket:SetOwner(own)
                rocket:SetVelocity(vel+Vector(0,0,100))
                rocket:SetAngles(vel:Angle())
                rocket.IsZBaseDMGInfl = true
                rocket:Spawn()
                rocket:SetSaveValue("m_flDamage", 150)


                self:EmitSound("Weapon_RPG.Single")


                self:ShootEffects()
                self:TakePrimaryAmmo(1)
                
            end


            return true
        end,
    },


    --[[
    ======================================================================================================================================================
                                            STUNSTICK
    ======================================================================================================================================================
    --]]


    ["weapon_stunstick"] = {
        NPCIsMeleeWep = true,
        NPCHoldType =  "melee", -- https://wiki.facepunch.com/gmod/Hold_Types
        NPCMeleeWep_Damage = {10, 20}, -- Melee weapon damage {min, max}
        NPCMeleeWep_DamageType = DMG_SHOCK, -- Melee weapon damage type
        NPCMeleeWep_HitSound = "Weapon_StunStick.Melee_Hit", -- Sound when the melee weapon hits an entity
        NPCMeleeWep_DamageAngle = 90, -- Damage angle (180 = everything in front of the NPC is damaged)
        NPCMeleeWep_DamageDist = 100, -- Melee weapon damage reach distance
    },


    --[[
    ======================================================================================================================================================
                                            HL1 SHOTGUN
    ======================================================================================================================================================
    --]]


    ["weapon_shotgun_hl1"] = {
        PrimaryShootSound = "HL1Weapon_Shotgun.Single",
        NPCReloadSound = "HL1Weapon_Shotgun.Reload",
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
        NPCFireRestTimeMin = 0.5, 
        NPCFireRestTimeMax = 1,
        NPCBulletSpreadMult = 1.5, 
        NPCShootDistanceMult = 0.5,
        NPCHoldType =  "shotgun" -- https://wiki.facepunch.com/gmod/Hold_Types
    },


    --[[
    ======================================================================================================================================================
                                            HL1 .357
    ======================================================================================================================================================
    --]]


    ["weapon_357_hl1"] = {
        PrimaryShootSound = "HL1Weapon_357.Single",
        NPCReloadSound = "HL1Weapon_357.Reload", 
        NPCFireRestTimeMin = 0.5, 
        NPCFireRestTimeMax = 1,
        NPCHoldType =  "revolver", -- https://wiki.facepunch.com/gmod/Hold_Types
        NPCBulletSpreadMult = 1.5, 
        NPCShootDistanceMult = 0.75,
        PrimaryDamage = 30,
        Primary = {
            DefaultClip = 6, 
            Ammo = "357", -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
            ShellEject = false, 
        },
    },


    --[[
    ======================================================================================================================================================
                                            HL1 GLOCK
    ======================================================================================================================================================
    --]]


    ["weapon_glock_hl1"] = {
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
        NPCBulletSpreadMult = 1.5,
        NPCShootDistanceMult = 0.75,
        NPCHoldType =  "pistol",  -- https://wiki.facepunch.com/gmod/Hold_Types
        PrimaryShootSound = "HL1Weapon_Glock.Single",
        NPCReloadSound = "Weapon_Pistol.Reload", 
    },
    
}