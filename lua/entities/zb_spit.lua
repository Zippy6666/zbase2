AddCSLuaFile()

ENT.Base = "zb_projectile"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Spit"
ENT.Spawnable = false
ENT.Category = "ZBase"
ENT.IsZBaseProjectile = true

ENT.Model = "models/spitball_large.mdl" -- Model to use
ENT.Invisible = false -- Should the model be invisible?

ENT.StartHealth = false -- Health of the projectile, set to false to disable projectile health

ENT.Gravity = true -- Should the projectile have gravity?
ENT.GravityGun_Pickup = false -- Can the projectile be picked up by the gravity gun?
ENT.GravityGun_Punt = false -- Can the projectile be punted by the gravity gun?

ENT.OnHitDamage = false -- Projectile damage on hit, set to false to disable

function ENT:PostInit()
    self:SetColor(Color(50, 50, 255))
    self.NextParticleEmit = CurTime()
end

function ENT:PhysInit( phys )
end

function ENT:OnHit( ent, data )
    util.Decal("ZBaseBloodBlue", data.HitPos-data.HitNormal, data.HitPos+data.HitNormal, self)
    self:Die()
end

function ENT:OnThink()
    if self.NextParticleEmit < CurTime() then
        ParticleEffect("blood_impact_zbase_blue", self:GetPos(), AngleRand())
        self.NextParticleEmit = CurTime()+math.Rand(0, 0.15)
    end
end

function ENT:CustomOnTakeDamage(dmginfo)
end

function ENT:OnKill(dmginfo)
    self:ProjectileBlastDamage( 25, bit.bor(DMG_POISON, DMG_ACID), 50, 10 )

    self:EmitSound("GrenadeBugBait.Splat")
    self:EmitSound("Flesh_Bloody.ImpactHard")
    
    ParticleEffect("blood_impact_zbase_blue", self:GetPos(), AngleRand())
end

function ENT:CustomOnRemove()
end
