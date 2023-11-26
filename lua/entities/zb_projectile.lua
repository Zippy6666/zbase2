AddCSLuaFile()


ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Projectile"
ENT.Spawnable = false
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

--]]==============================================================================================]]

    -- When the projectile is created
function ENT:PostInit()
    -- Example:

    if SERVER then
        -- Dynamic light
        local glow = ents.Create("light_dynamic")
        glow:SetKeyValue("brightness", "2")
        glow:SetKeyValue("distance", "200")
        glow:SetPos(self:WorldSpaceCenter())
        glow:SetParent(self)
        glow:Fire("Color", "50 255 155")
        glow:Spawn()
        glow:Activate()
        glow:Fire("TurnOn", "", 0)
        self:DeleteOnRemove(glow)

        -- Particle
        ParticleEffectAttach("vortigaunt_hand_glow", PATTACH_ABSORIGIN_FOLLOW, self, 0)

        -- Looping sound
        -- self.HumSound = CreateSound( self, "Weapon_Gauss.ChargeLoop" )
        -- self.HumSound:Play()
    end
end
--]]==============================================================================================]]

    -- When the projectile's physics object is created
    -- Change things about it here
function ENT:PhysInit( phys )
end
--]]==============================================================================================]]

    -- When the projectile hits an entity
function ENT:OnHit( ent, data )
    -- Example:

    self:Die()
end
--]]==============================================================================================]]

    -- Called continiously
function ENT:OnThink()
    -- Example:

    -- if SERVER then
    --     -- Random pitches for the looping sound
    --     self.HumSound:ChangePitch(math.random(60, 140), 1)
    -- end
end
--]]==============================================================================================]]

    -- Called when it's pushed by the gravity gun
function ENT:OnGravityGunPunt()
end
--]]==============================================================================================]]

    -- Called when a player tries to pick it up with their gravity gun
    -- Return true to allow
    -- Return false to not
function ENT:OnTryGravityGunPickup()
    return true
end
--]]==============================================================================================]]

    -- When the projectile takes damage
function ENT:CustomOnTakeDamage(dmginfo)
end
--]]==============================================================================================]]

    -- When the projectile "dies"
function ENT:OnKill(dmginfo)
    -- Example:

    -- -- Blast/Radius damage --
    -- -- ProjectileBlastDamage( damage, damageType, radius, force )
    -- -- VVV Example VVV
    -- self:ProjectileBlastDamage( 10, DMG_GENERIC, 400, 50 )
    -- ----------------------------------------------------=#

    -- -- Sound
    -- self:EmitSound("Weapon_Mortar.Impact")

    -- -- Screen shake
    -- util.ScreenShake(self:WorldSpaceCenter(), 5, 200, 1, 400)

    -- -- Dynamic light flash
    -- local glow = ents.Create("light_dynamic")
    -- glow:SetKeyValue("brightness", "5")
    -- glow:SetKeyValue("distance", "500")
    -- glow:SetPos(self:WorldSpaceCenter())
    -- glow:Fire("Color", "50 50 255")
    -- glow:Spawn()
    -- glow:Activate()
    -- glow:Fire("TurnOn", "", 0)
    -- SafeRemoveEntityDelayed(glow, 0.15)

    -- -- Explosion particle
    -- ParticleEffect("Weapon_Combine_Ion_Cannon_Explosion", self:WorldSpaceCenter(), AngleRand())
end
--]]==============================================================================================]]

    -- When the projectile is removed
function ENT:CustomOnRemove()
    -- Example:

    -- if SERVER then
    --     -- Stop the looping sound
    --     self.HumSound:Stop()
    -- end
end
--]]==============================================================================================]]





    -- Don't change these! --

--]]==============================================================================================]]
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


        if self.StartHealth then
            self:SetHealth(self.StartHealth)
            self:SetMaxHealth(self.StartHealth)
        end

        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
    end

    self.GravGunPlayer = NULL

    self:PostInit()
end
--]]==============================================================================================]]
function ENT:Think()
    self:OnThink()
end
--]]==============================================================================================]]
function ENT:PhysicsCollide( colData, collider )
    self:OnHit( colData.HitEntity, colData )

    if self.OnHitDamage then
        self:ProjectileDamage(colData.HitEntity, self.OnHitDamage, self.OnHitDamageType)
    end
end
--]]==============================================================================================]]
function ENT:ProjectileDamage( ent, dmg, dmgtype )
    if !SERVER then return end

    local own = self:GetOwner()
    local dmginfo = DamageInfo()

    dmginfo:SetInflictor(self)
    dmginfo:SetAttacker(
        (IsValid(self.GravGunPlayer) && self.GravGunPlayer)
        or (IsValid(own) && own)
        or self
    )
    dmginfo:SetDamage(dmg)
    dmginfo:SetDamageType(dmgtype)
    dmginfo:SetDamageForce(self:GetVelocity()*10)

    ent:TakeDamageInfo(dmginfo)

    ZBaseBleed(ent, self:WorldSpaceCenter()+VectorRand()*10)
end
--]]==============================================================================================]]
function ENT:ProjectileBlastDamage( dmg, dmgtype, radius, force )
    if !SERVER then return end

    local own = self:GetOwner()
    local dmginfo = DamageInfo()

    dmginfo:SetInflictor(self)
    dmginfo:SetAttacker(
        (IsValid(self.GravGunPlayer) && self.GravGunPlayer)
        or (IsValid(own) && own)
        or self
    )
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
--]]==============================================================================================]]
function ENT:Die( dmg )
    if self.Dead then return end
    self.Dead = true
    self:OnKill( dmg )
    self:SetMoveType(MOVETYPE_NONE)
    self:Remove()
end
--]]==============================================================================================]]
function ENT:OnTakeDamage( dmg )
    if !self.StartHealth then return end

    self:CustomOnTakeDamage()

    self:SetHealth(self:Health()-dmg:GetDamage())

    if self:Health() <= 0 then
        self:Die( dmg )
    end

    return dmg:GetDamage()
end
--]]==============================================================================================]]
function ENT:OnRemove()
    self:CustomOnRemove()
end
--]]==============================================================================================]]
hook.Add("PostEntityTakeDamage", "ZBaseProjectile", function( ent, dmg )
    local infl = dmg:GetInflictor()

    if infl.IsZBaseProjectile && infl.Damage_Disorient && ent:IsPlayer() then
        ent:SetDSP(32)
    end
end)
--]]==============================================================================================]]
hook.Add("GravGunPunt", "ZBaseProjectile", function( ply, ent )
    if ent.IsZBaseProjectile then
        if ent.GravityGun_Punt then

            ent.GravGunPlayer = ply
            ent:SetOwner(NULL)

            timer.Create("ResetGravGunPlayer", 5, 1, function()
                if !IsValid(ent) then return end
                ent.GravGunPlayer = NULL
            end)


            ent:OnGravityGunPunt()

        else
            return false
        end
    end
end)
--]]==============================================================================================]]
hook.Add("GravGunPickupAllowed", "ZBaseProjectile", function( ply, ent )
    if ent.IsZBaseProjectile then
        if ent.GravityGun_Pickup then
            return ent:OnTryGravityGunPickup()
        else
            return false
        end
    end
end)
--]]==============================================================================================]]