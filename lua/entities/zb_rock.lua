AddCSLuaFile()


ENT.Base = "zb_projectile"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Rock"
ENT.Spawnable = false
ENT.Category = "ZBase"
ENT.IsZBaseProjectile = true


ENT.Model = "models/props_mining/rock_caves01c.mdl" -- Model to use
ENT.Invisible = false -- Should the model be invisible?


ENT.StartHealth = false -- Health of the projectile, set to false to disable projectile health


ENT.Gravity = true -- Should the projectile have gravity?
ENT.GravityGun_Pickup = true -- Can the projectile be picked up by the gravity gun?
ENT.GravityGun_Punt = true -- Can the projectile be punted by the gravity gun?


ENT.OnHitDamage = 10 -- Projectile damage on hit, set to false to disable
ENT.OnHitDamageType = DMG_GENERIC -- Projectile damage type on hit



--]]=================================================================================================================================]]
function ENT:PostInit()
end
--]]=================================================================================================================================]]
function ENT:PhysInit( phys )
end
--]]=================================================================================================================================]]
function ENT:OnHit( ent, data )
    SafeRemoveEntityDelayed(self, 10)
end
--]]==============================================================================================]]
function ENT:OnGravityGunPunt()
end
--]]=================================================================================================================================]]
function ENT:OnThink()
end
--]]=================================================================================================================================]]
function ENT:CustomOnTakeDamage(dmginfo)
end
--]]=================================================================================================================================]]
function ENT:OnKill(dmginfo)
end
--]]=================================================================================================================================]]
function ENT:CustomOnRemove()
end
--]]=================================================================================================================================]]