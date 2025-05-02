AddCSLuaFile()

local vecUp             = Vector(0, 0, 200)

ENT.Base                = "zb_projectile"
ENT.Type                = "anim"
ENT.Author              = "Zippy"
ENT.PrintName           = "Rocket"
ENT.Spawnable           = false
ENT.Category            = "ZBase"
ENT.IsZBaseProjectile   = true

ENT.Model               = "models/weapons/w_missile_launch.mdl" -- Model to use
ENT.Invisible           = true -- Should the model be invisible?

ENT.StartHealth         = 100 -- Health of the projectile, set to false to disable projectile health

ENT.Gravity             = true -- Should the projectile have gravity?
ENT.GravityGun_Pickup   = false -- Can the projectile be picked up by the gravity gun?
ENT.GravityGun_Punt     = false -- Can the projectile be punted by the gravity gun?

ENT.OnHitDamage         = false -- Projectile damage on hit, set to false to disable
ENT.Damage_Disorient    = true

ENT.entTarget           = NULL
ENT.bIgnited            = false
ENT.tNextSteer          = CurTime()

function ENT:PostInit()
    if SERVER then
        self.FakeRocket = ents.Create("rpg_missile")
        self.FakeRocket:SetPos(self:GetPos())
        self.FakeRocket:SetAngles(self:GetAngles())
        self.FakeRocket:SetAbsVelocity(vector_origin)
        self.FakeRocket:SetOwner(self:GetOwner())
        self.FakeRocket:SetParent(self, 0)
        self.FakeRocket:Spawn()
        self:DeleteOnRemove(self.FakeRocket)

        self:CONV_TimerSimple(0.3, function() self:RocketIgnite() end)
    end
end

function ENT:PhysInit( phys )
    if IsValid(self.entTarget) then
        local mvDir = self.entTarget:GetPos() - self:GetPos()
        phys:SetVelocity(self:GetForward()*300 + vecUp)
    end
end

function ENT:RocketIgnite()
    -- Thrust effect
    self:CONV_AddHook("Think", function()
        if self.tNextSteer > CurTime() then return end

        local phys = self:GetPhysicsObject()

        if IsValid(phys) && self.bIgnited && IsValid(self.entTarget) then
            -- Follow target
            local mvDir = self.entTarget:GetPos() - self:GetPos()
            self:SetAngles(LerpAngle(0.1, self:GetAngles(), mvDir:Angle()))
            phys:SetVelocity(self:GetForward()*1500)
        end

        if IsValid(self.FakeRocket) then
            self.FakeRocket:SetPos(self:GetPos())
            self.FakeRocket:SetAngles(self:GetAngles())
            self.FakeRocket:SetVelocity(vector_origin)
            self.FakeRocket:SetAbsVelocity(vector_origin)
        end

        self.tNextSteer = CurTime()+.1
    end, "RocketSteer")

    self.bIgnited = true
end

function ENT:OnKill(dmginfo)
    self:ProjectileBlastDamage( 150, DMG_BLAST, 400, 50 )

    local exp = ents.Create("env_explosion")
    exp:SetPos(self:GetPos())
    exp:Spawn()
    exp:Fire("Explode")
    SafeRemoveEntity(exp)
end