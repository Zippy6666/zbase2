AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Crossbow"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_crossbow.mdl" )

SWEP.PrimaryShootSound = "Weapon_Crossbow.Single"
SWEP.PrimaryDamage = 40
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "XBowBolt" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ShellEject = false
SWEP.Primary.NumShots = 1
SWEP.Primary.TracerChance = 0
SWEP.Primary.MuzzleFlash = false
SWEP.NPCBulletSpreadMult = 0.5
SWEP.NPCReloadSound = "Weapon_Crossbow.BoltElectrify"
SWEP.NPCShootDistanceMult = 2
SWEP.Weight = 6
SWEP.NPCHoldType =  "shotgun"

local trailcol = Color(255,150,100)
function SWEP:NPCPrimaryAttack()
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
        proj.IsZBaseDMGInfl = true
        util.SpriteTrail(proj, 0, trailcol, true, 2, 0, 0.75, 20, "trails/plasma")

        self:TakePrimaryAmmo(1)
        self:EmitSound(self.PrimaryShootSound)
        
    end

    return true
end