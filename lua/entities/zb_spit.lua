AddCSLuaFile()


ENT.Base = "zb_projectile"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Mortar"
ENT.Spawnable = false
ENT.Category = "ZBase"
ENT.IsZBaseProjectile = true


ENT.Model = "models/spitball_medium.mdl" -- Model to use
ENT.Invisible = false -- Should the model be invisible?


ENT.StartHealth = false -- Health of the projectile, set to false to disable projectile health


ENT.Gravity = true -- Should the projectile have gravity?
ENT.GravityGun_Pickup = false -- Can the projectile be picked up by the gravity gun?
ENT.GravityGun_Punt = false -- Can the projectile be punted by the gravity gun?


ENT.OnHitDamage = false -- Projectile damage on hit, set to false to disable

--]]=================================================================================================================================]]
function ENT:PostInit()
    self:SetColor(Color(50, 50, 255))
end
--]]=================================================================================================================================]]
function ENT:PhysInit( phys )
end
--]]=================================================================================================================================]]
function ENT:OnHit( ent, data )
    self:Die()
end
--]]=================================================================================================================================]]
function ENT:OnThink()
end
--]]=================================================================================================================================]]
function ENT:CustomOnTakeDamage(dmginfo)
end
--]]=================================================================================================================================]]
function ENT:OnKill(dmginfo)
    self:ProjectileBlastDamage( 15, DMG_ACID, 50, 10 )
    ParticleEffect("blood_impact_zbase_blue", self:GetPos(), AngleRand())
end
--]]=================================================================================================================================]]
function ENT:CustomOnRemove()
end
--]]=================================================================================================================================]]