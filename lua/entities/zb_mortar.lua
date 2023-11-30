AddCSLuaFile()


ENT.Base = "zb_projectile"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Mortar"
ENT.Spawnable = false
ENT.Category = "ZBase"
ENT.IsZBaseProjectile = true


ENT.Model = "models/spitball_large.mdl" -- Model to use
ENT.Invisible = true -- Should the model be invisible?


ENT.StartHealth = 10 -- Health of the projectile, set to false to disable projectile health


ENT.Gravity = true -- Should the projectile have gravity?
ENT.GravityGun_Pickup = true -- Can the projectile be picked up by the gravity gun?
ENT.GravityGun_Punt = true -- Can the projectile be punted by the gravity gun?


ENT.OnHitDamage = false -- Projectile damage on hit, set to false to disable
ENT.OnHitDamageType = bit.bor(DMG_DISSOLVE, DMG_SHOCK) -- Projectile damage type on hit


ENT.Damage_Disorient = false -- Should any damage (direct or radius) from the projectile disorient players (be deafening)?


ENT.IsMortarSynthProjectile = true


local white = Color(255,255,255,255)

--]]=================================================================================================================================]]
function ENT:PostInit()
    if SERVER then
        self.CombineBallEffect = ents.Create("prop_combine_ball")
        self.CombineBallEffect:SetNotSolid(true)
        self.CombineBallEffect:SetPos(self:GetPos())
        self.CombineBallEffect:SetParent(self)
        self.CombineBallEffect:SetSaveValue("m_flRadius", 15)
        self.CombineBallEffect:Spawn()
        util.SpriteTrail(self, 0, white, true, 9, 0, 0.75, 20, "trails/plasma")
        
        self:EmitSound("NPC_CombineBall.HoldingInPhysCannon")
    end
end
--]]=================================================================================================================================]]
function ENT:PhysInit( phys )

end
--]]=================================================================================================================================]]
function ENT:OnHit( ent, data )
    -- Explode from hitting something hard
    if self.ExplodeOnImpact then
        self:Die()
        return
    end


    if data.Speed > 50 then
        -- Impact effect

        local effectdata = EffectData()
        effectdata:SetOrigin(data.HitPos)
        effectdata:SetNormal(-data.HitNormal)
        effectdata:SetRadius(10)
        util.Effect("cball_bounce", effectdata, true, true)

        self:EmitSound("NPC_CombineBall.Impact")
    end


    if data.Speed > 150 then
        self.OnHitDamage = 15 -- Projectile damage on hit, set to false to disable
    else
        self.OnHitDamage = false -- Projectile damage on hit, set to false to disable
    end


    -- Explode after some time
    if !self.DieTimerStarted then
        self.DieTimerStarted = true

        timer.Simple(2, function()
            if IsValid(self) then
                self:Die()
            end
        end)
    end
end
--]]==============================================================================================]]
function ENT:OnGravityGunPunt()
    self.ExplodeOnImpact = true
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

    self.Damage_Disorient = true -- Should any damage (direct or radius) from the projectile disorient players (be deafening)?
    self:ProjectileBlastDamage( 20, bit.bor(DMG_DISSOLVE, DMG_SHOCK), 400, 50 )

    -- self:EmitSound("Weapon_Mortar.Impact")
end
--]]=================================================================================================================================]]
function ENT:CustomOnRemove()
    self:StopSound("NPC_CombineBall.HoldingInPhysCannon")
end
--]]=================================================================================================================================]]