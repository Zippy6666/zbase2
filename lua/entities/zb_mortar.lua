AddCSLuaFile()


ENT.Base = "zb_projectile"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Mortar"
ENT.Spawnable = false
ENT.Category = "ZBase"
ENT.IsZBaseProjectile = true


ENT.Model = "models/spitball_medium.mdl" -- Model to use
ENT.Invisible = true -- Should the model be invisible?


ENT.StartHealth = false -- Health of the projectile, set to false to disable projectile health


ENT.Gravity = true -- Should the projectile have gravity?
ENT.GravityGun_Pickup = true -- Can the projectile be picked up by the gravity gun?
ENT.GravityGun_Punt = true -- Can the projectile be punted by the gravity gun?


ENT.OnHitDamage = false -- Projectile damage on hit, set to false to disable
ENT.Damage_Disorient = true -- Should any damage (direct or radius) from the projectile disorient players (be deafening)?


--]]=================================================================================================================================]]
function ENT:PostInit()
    if SERVER then
        self.CombineBallEffect = ents.Create("prop_combine_ball")
        self.CombineBallEffect:SetNotSolid(true)
        self.CombineBallEffect:SetPos(self:GetPos())
        self.CombineBallEffect:SetParent(self)
        self.CombineBallEffect:SetSaveValue("m_flRadius", 12)
        self.CombineBallEffect:Spawn()
    end
end
--]]=================================================================================================================================]]
function ENT:PhysInit( phys )
end
--]]=================================================================================================================================]]
function ENT:OnHit( ent, data )
    if self.DieTimerStarted then return end

    self.DieTimerStarted = true

    timer.Simple(3, function()
        if IsValid(self) then
            self:Die()
        end
    end)
end
--]]=================================================================================================================================]]
function ENT:OnThink()

end
--]]=================================================================================================================================]]
function ENT:CustomOnTakeDamage(dmginfo)

end
--]]=================================================================================================================================]]
function ENT:OnKill(dmginfo)
    if IsValid(self.CombineBallEffect) then
        self.CombineBallEffect:SetParent(NULL) -- So that it doesn't get removed, lets us fire the explode effect
        self.CombineBallEffect:Fire("Explode")
    end

    self:ProjectileBlastDamage( 20, bit.bor(DMG_DISSOLVE, DMG_SHOCK), 400, 50 )
end
--]]=================================================================================================================================]]
function ENT:CustomOnRemove()

end
--]]=================================================================================================================================]]