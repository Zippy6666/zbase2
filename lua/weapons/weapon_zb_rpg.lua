AddCSLuaFile()

SWEP.Base = "weapon_zbase"
SWEP.PrintName = "Rocket Launcher"
SWEP.Author = "Zippy"
SWEP.Spawnable = false

SWEP.IsZBaseWeapon = true
SWEP.NPCSpawnable = false -- Add to NPC weapon list

SWEP.WorldModel = Model( "models/weapons/w_rocket_launcher.mdl" )

SWEP.Weight = 0
SWEP.NPCHoldType =  "ar2"
SWEP.NPCBulletSpreadMult = 1.5
SWEP.NPCShootDistanceMult = 0.75
SWEP.NPCReloadSound = "Weapon_AR2.Reload"
SWEP.MuzzleFlashFlags = 7

SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "RPG"
SWEP.Primary.ShellEject = false

function SWEP:NPCPrimaryAttack()
    local own = self:GetOwner()

    if IsValid(own) then
        local start = self:GetAttachment(self:LookupAttachment("muzzle")).Pos
        local vel = own:GetAimVector()*500

        -- Laser dot
        if !IsValid(self.LaserDot) then
            self.LaserDot = ents.Create("env_sprite")
            self.LaserDot:SetKeyValue("model", "sprites/redglow1.vmt")
            self.LaserDot:SetKeyValue("rendermode", "5")
            self.LaserDot:SetKeyValue("renderfx", "14")
            self.LaserDot:SetKeyValue("scale", "0.1 ")
            self.LaserDot:SetKeyValue("spawnflags", "1")
            self.LaserDot:Spawn()
            self.LaserDot:Activate()
            self.LaserDot.tNextThink = CurTime()
            self.LaserDot:CONV_AddHook("Think", function(lDot)
                if lDot.tNextThink > CurTime() then return end
                local vecStart = self:GetAttachment(self:LookupAttachment("muzzle")).Pos

                local tr = util.TraceLine({
                    start = vecStart,
                    endpos = vecStart + own:GetEyeDirection()*10000,
                    mask = MASK_VISIBLE_AND_NPCS,
                    filter = {self, own}
                })

                lDot:SetPos(tr.HitPos+tr.HitNormal*3)

                lDot.tNextThink = CurTime()+0.1
            end, "PositionLaserDot")
            self:DeleteOnRemove(self.LaserDot)
        end

        local rocket = ents.Create("zb_rocket")
        rocket.entTarget = self.LaserDot
        rocket:SetPos(start)
        rocket:SetOwner(own)
        rocket:SetAngles(vel:Angle())
        rocket:Spawn()
        rocket.IsZBaseDMGInfl = true

        self:EmitSound("Weapon_RPG.Single")
        self:ShootEffects()
        self:TakePrimaryAmmo(1)
    end

    return true
end