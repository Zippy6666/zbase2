AddCSLuaFile()


ENT.Base = "zb_projectile"
ENT.Type = "anim"
ENT.Author = "You"
ENT.PrintName = "Dummy Projectile"
ENT.Spawnable = true
ENT.Category = "ZBase"
ENT.IsZBaseProjectile = true


ENT.Model = "models/spitball_medium.mdl" -- Model to use
ENT.Invisible = false -- Should the model be invisible?


ENT.StartHealth = false -- Health of the projectile, set to false to disable projectile health


ENT.Gravity = false -- Should the projectile have gravity?
ENT.GravityGun_Pickup = true -- Can the projectile be picked up by the gravity gun?
ENT.GravityGun_Punt = true -- Can the projectile be punted by the gravity gun?


ENT.OnHitDamage = 10 -- Projectile damage on hit, set to false to disable
ENT.OnHitDamageType = DMG_GENERIC -- Projectile damage type on hit


ENT.Damage_Disorient = false -- Should any damage (direct or radius) from the projectile disorient players (be deafening)?




    -- Change these functions to your liking --

    

    -- When the projectile is created
function ENT:PostInit()
end



    -- When the projectile's physics object is created
    -- Change things about it here
function ENT:PhysInit( phys )
end



    -- When the projectile hits an entity
function ENT:OnHit( ent, data )

    -- Example:
    self:Die()

end



    -- Called continiously
function ENT:OnThink()
end



    -- Called when it's pushed by the gravity gun
function ENT:OnGravityGunPunt()
end



    -- Called when a player tries to pick it up with their gravity gun
    -- Return true to allow
    -- Return false to not
function ENT:OnTryGravityGunPickup()
    return true
end



    -- When the projectile takes damage
function ENT:CustomOnTakeDamage(dmginfo)
end



    -- When the projectile "dies"
function ENT:OnKill(dmginfo)
end



    -- When the projectile is removed
function ENT:CustomOnRemove()
end

