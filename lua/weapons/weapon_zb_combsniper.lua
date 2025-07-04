AddCSLuaFile()

-- TODO:
-- Add distant sounds
-- Add laser
-- Add realistic sonic boom

sound.Add({
    name = "ZBASE.Sniper",
    volume = 1,
    level = 140,
    pitch = {90, 110},
    channel = CHAN_WEAPON,
    sound = {
        "^weapons/nova/sniper/echo1.mp3",
    }
})

sound.Add({
    name = "ZBASE.SniperReload",
    volume = 0.9,
    level = 80,
    pitch = {95, 105},
    channel = CHAN_AUTO,
    sound = {
        "weapons/nova/sniper/reload1.mp3",
    }
})

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Combine Sniper"
SWEP.Author = "Zippy"
SWEP.Spawnable = false
SWEP.Weight = 7
SWEP.WorldModel = Model( "models/weapons/w_combine_sniper.mdl" )

SWEP.CustomWorldModel = {
    Active      = true,                        -- Needs to be true if you want to change things about the world model, such as positioning
    Bone        = "ValveBiped.Bip01_R_Hand",    -- The bone the model should be attached to, default is the right hand
    Offset      = Vector(20, -2, -4),              -- Position offset
    AngOffset   = Angle(180, 0, 0)                -- Angle offset
}

SWEP.Primary.MuzzleFlashPos = {
    ShouldUse   = true,             -- Set to true to use manual positioning instead of attachment
    Offset      = Vector(-30,0,0),  -- Position offset
    AngOffset   = Angle(0,180,0)    -- Angle offset
}

SWEP.Primary.BulletPos = {
    ShouldUse   = true,             -- Set to true to use manual positioning instead of attachment
    Offset      = Vector(50,0,0),  -- Position offset
    AngOffset   = Angle(0,0,0)    -- Angle offset
}

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = true -- Add to NPC weapon list

SWEP.PrimaryShootSound = "ZBASE.Sniper"
SWEP.PrimarySpread = 0.01
SWEP.PrimaryDamage = 90
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "357" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = "1" 
SWEP.Primary.ShellType = "RifleShellEject" -- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.TracerName = "AirboatGunTracer"
SWEP.Primary.TracerChance = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.MuzzleFlashFlags = 5
SWEP.NPCBurstMin = 1
SWEP.NPCBurstMax = 1
SWEP.NPCFireRate = 0
SWEP.NPCFireRestTimeMin = 0.75 
SWEP.NPCFireRestTimeMax = 1.25
SWEP.NPCBulletSpreadMult = 0.5
SWEP.NPCReloadSound = "ZBASE.SniperReload" 
SWEP.NPCShootDistanceMult = 3
SWEP.NPCHoldType =  "ar2" -- https://wiki.facepunch.com/gmod/Hold_Types

function SWEP:CustomDoImpactEffect( tr, damageType )
    local effectdata = EffectData()
    effectdata:SetOrigin(tr.HitPos)
    effectdata:SetNormal(tr.HitNormal)
    util.Effect("AR2Impact", effectdata, true, true)
end