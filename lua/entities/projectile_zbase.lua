AddCSLuaFile()
------------------------------------------------------------------------------------=#
ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Projectile"
ENT.Spawnable = true
ENT.Category = "ZBase"
ENT.IsZBaseProjectile = true
------------------------------------------------------------------------------------=#

ENT.Model = "models/dav0r/hoverball.mdl" -- Model to use
ENT.Invisible = false -- Should the model be invisible?
ENT.Gravity = false -- Should the projectile have gravity?
ENT.Damage_Disorient = true -- Should the projectile blast damage function disorient players (be deafening)?
ENT.GravityGun_Pickup = true -- Can the projectile be picked up by the gravity gun?
ENT.GravityGun_Punt = true -- Can the projectile be punted by the gravity gun?



    -- Change these functions to your liking --

------------------------------------------------------------------------------------=#

    -- When the projectile is created
function ENT:PostInit()
    if SERVER then
        -- Dynamic light
        local glow = ents.Create("light_dynamic")
        glow:SetKeyValue("brightness", "2")
        glow:SetKeyValue("distance", "200")
        glow:SetPos(self:WorldSpaceCenter())
        glow:SetParent(self)
        glow:Fire("Color", "50 50 255")
        glow:Spawn()
        glow:Activate()
        glow:Fire("TurnOn", "", 0)
        self:DeleteOnRemove(glow)

        -- Particle
        ParticleEffectAttach("larvae_glow", PATTACH_ABSORIGIN_FOLLOW, self, 0)

        -- Looping sound
        local snd = CreateSound( self, "Weapon_Gauss.ChargeLoop" )
        snd:Play()
        self:CallOnRemove("StopLoopSound", function() snd:Stop() end)
    end
end
------------------------------------------------------------------------------------=#

    -- When the projectile's physics object is created
    -- Change things about it here
function ENT:PhysInit( phys )
end
------------------------------------------------------------------------------------=#

    -- When the projectile hits an entity
function ENT:OnHit( ent, data )
    -- Direct damage --
    -- ProjectileDamage( entity, damage, damageType )
    -- VVV Example VVV
    self:ProjectileDamage( ent, 10, DMG_SONIC )
    ------------------------------------------------------=#


    -- Blast/Radius damage --
    -- ProjectileBlastDamage( damage, damageType, radius, force )
    -- VVV Example VVV
    self:ProjectileBlastDamage( 10, DMG_DISSOLVE, 400, 50 )
    ------------------------------------------------------=#



    -- Sound
    self:EmitSound("Weapon_Mortar.Impact")

    -- Screen shake
    util.ScreenShake(self:WorldSpaceCenter(), 5, 200, 1, 400)

    -- Dynamic light flash
    local glow = ents.Create("light_dynamic")
    glow:SetKeyValue("brightness", "5")
    glow:SetKeyValue("distance", "500")
    glow:SetPos(self:WorldSpaceCenter())
    glow:Fire("Color", "50 50 255")
    glow:Spawn()
    glow:Activate()
    glow:Fire("TurnOn", "", 0)
    SafeRemoveEntityDelayed(glow, 0.15)

    -- Explosion particle
    ParticleEffect("Weapon_Combine_Ion_Cannon_Explosion", self:WorldSpaceCenter(), AngleRand())



    self:SetMoveType(MOVETYPE_NONE) -- Prevents stupid physics sounds from playing when the projectile hits something
    self:Remove() -- Lastly, remove the projectile
end
------------------------------------------------------------------------------------=#

    -- Called continiously
function ENT:OnThink()
end
------------------------------------------------------------------------------------=#








    -- Don't change these! --

------------------------------------------------------------------------------------=#
function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetNoDraw(self.Invisible)
    self:DrawShadow(!self.Invisible)

    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableGravity(self.Gravity)
            phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

            self:PhysInit(phys)
        end
    end

    self:PostInit()
end
------------------------------------------------------------------------------------=#
function ENT:Think()
    self:OnThink()
end
------------------------------------------------------------------------------------=#
function ENT:PhysicsCollide( colData, collider )
    self:OnHit( colData.HitEntity, colData )
end
------------------------------------------------------------------------------------=#
function ENT:ProjectileDamage( ent, dmg, dmgtype )
    if !SERVER then return end

    local own = self:GetOwner()
    local dmginfo = DamageInfo()

    dmginfo:SetInflictor(self)
    dmginfo:SetAttacker(IsValid(own) && own or self)
    dmginfo:SetDamage(dmg)
    dmginfo:SetDamageType(dmgtype)
    dmginfo:SetDamageForce(self:GetVelocity()*10)

    ent:TakeDamageInfo(dmginfo)

    ZBaseBleed(ent, self:WorldSpaceCenter()+VectorRand()*10)
end
------------------------------------------------------------------------------------=#
function ENT:ProjectileBlastDamage( dmg, dmgtype, radius, force )
    if !SERVER then return end

    local own = self:GetOwner()
    local dmginfo = DamageInfo()

    dmginfo:SetInflictor(self)
    dmginfo:SetAttacker(IsValid(own) && own or self)
    dmginfo:SetDamage(dmg)
    dmginfo:SetDamageType(dmgtype)

    local physexplosion = ents.Create("env_physexplosion")
    physexplosion:SetPos(self:WorldSpaceCenter())
    physexplosion:SetKeyValue("spawnflags", bit.bor(1, 2, 8))

    physexplosion:SetKeyValue("magnitude", force)
    physexplosion:SetKeyValue("radius", radius)
    physexplosion:SetKeyValue("inner_radius", 0)
    physexplosion:Spawn()
    physexplosion:Fire("Explode")
    SafeRemoveEntityDelayed(physexplosion, 1)

    util.BlastDamageInfo(dmginfo, self:WorldSpaceCenter(), radius)
end
------------------------------------------------------------------------------------=#
hook.Add("PostEntityTakeDamage", "ZBaseProjectile", function( ent, dmg )
    local infl = dmg:GetInflictor()

    if infl.IsZBaseProjectile && infl.Damage_Disorient && ent:IsPlayer() then
        ent:SetDSP(32)
    end
end)
------------------------------------------------------------------------------------=#
hook.Add("GravGunPunt", "ZBaseProjectile", function( ply, ent )
    if ent.IsZBaseProjectile && !ent.GravityGun_Punt then
        return false
    end
end)
------------------------------------------------------------------------------------=#
hook.Add("GravGunPickupAllowed", "ZBaseProjectile", function( ply, ent )
    if ent.IsZBaseProjectile && !ent.GravityGun_Pickup then
        return false
    end
end)
------------------------------------------------------------------------------------=#