include("shared.lua")

-- ENT.StartHealth = 300
-- ENT.Models = ZBASE_TBL({"models/hunter.mdl"}) -- Add as many as you want
-- ENT.BloodColor = -1
-- ENT.StartHullType = HULL_LARGE -- https://wiki.facepunch.com/gmod/Enums/HULL
-- ENT.ZBase_Factions = ZBASE_TBL({"CLASS_COMBINE"}) -- Add as many as you want

-- -- Melee Attack
-- ENT.MeleeAttack = true -- Should it melee attack?
-- ENT.MeleeAttackAnimations = ZBASE_TBL({"melee_02", "meleert", "melee_left"})
-- ENT.MeleeAttackSequenceDuration = 0.9
-- ENT.MeleeAttackDamage = 25 -- Melee attack damage
-- ENT.MeleeAttackDamageDelay = 0.6 -- Time until damage

-- ENT.Patrol = "turn"
-- --------------------------------------------------------------------------------=#
-- function ENT:CustomOnInitialize()
--     self.ShootTopEye = true

--     self.bulletprop1 = ents.Create("base_gmodentity")
--     self.bulletprop1:SetModel("models/hunter/blocks/cube025x025x025.mdl")
--     self.bulletprop1:SetPos(self:GetAttachment(4).Pos)
--     self.bulletprop1:SetParent(self, 4)
--     self.bulletprop1:SetSolid(SOLID_NONE)
--     self.bulletprop1:AddEFlags(EFL_DONTBLOCKLOS)
--     self.bulletprop1:SetNoDraw(true)
--     self.bulletprop1:Spawn()

--     self.bulletprop2 = ents.Create("base_gmodentity")
--     self.bulletprop2:SetModel("models/hunter/blocks/cube025x025x025.mdl")
--     self.bulletprop2:SetPos(self:GetAttachment(5).Pos + self:GetForward()*6)
--     self.bulletprop2:SetParent(self, 5)
--     self.bulletprop2:SetSolid(SOLID_NONE)
--     self.bulletprop2:AddEFlags(EFL_DONTBLOCKLOS)
--     self.bulletprop2:SetNoDraw(true)
--     self.bulletprop2:Spawn()

--     self.NextTopFlechette = CurTime()
--     self.NextBottomFlechette = CurTime()
--     self.NextRangeAttack = CurTime()
-- end
-- --------------------------------------------------------------------------------=#
-- function ENT:FireFlechette( shootPos, shootVec )
-- 	local ent = ents.Create( "hunter_flechette" )
-- 	ent:SetPos( shootPos + shootVec * 32 )
-- 	ent:SetAngles( shootVec:Angle() )
-- 	ent:SetOwner( self )
-- 	ent:Spawn()
-- 	ent:Activate()
-- 	ent:SetVelocity( shootVec * 1000 )
--     ent:CallOnRemove("FlechetteBigExplosion", function()
--         local comball = ents.Create("prop_combine_ball")
--         comball:SetPos(ent:GetPos())
--         comball:Spawn()

--         local dmg = DamageInfo()
--         dmg:SetDamage(10)
--         dmg:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_SHOCK))
--         dmg:SetAttacker(IsValid(self) && self or ent)
--         dmg:SetInflictor(ent)
--         util.BlastDamageInfo(dmg, comball:GetPos(), 200)

--         -- effects.BeamRingPoint( comball:GetPos(), 1.5, 200, 0, 20, 5, Color(0, 100, 255) )
--         -- effects.BeamRingPoint( comball:GetPos(), 0.75, 0, 400, 20, 5, Color(0, 100, 255) )
--         comball:Fire("Explode")
--     end)

-- 	local light = ents.Create( "env_sprite" )
-- 	light:SetKeyValue( "model","sprites/blueflare1.spr" )
-- 	light:SetKeyValue( "rendercolor","0 50 255" )
-- 	light:SetPos( ent:GetAttachment(1).Pos )
-- 	light:SetParent( ent, 1 )
-- 	light:SetKeyValue( "scale","0.24" )
-- 	light:SetKeyValue( "rendermode","9" )
-- 	light:Spawn()
-- 	light:DeleteOnRemove(light)

--     --ParticleEffectAttach("hunter_flechette_trail_striderbuster", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
--     ParticleEffectAttach("hunter_muzzle_flash", PATTACH_POINT, self, self.ShootTopEye && 5 or 4 )

--     self:EmitSound("NPC_Hunter.FlechetteShoot")
-- end
-- --------------------------------------------------------------------------------=#
-- function ENT:Shoot( pos )
--     local ent = self.ShootTopEye && self.bulletprop2 or self.bulletprop1
--     local shootPos = ent:GetPos()
--     local shootVec = (pos - shootPos):GetNormalized()

--     if self.ShootTopEye && self.NextTopFlechette < CurTime() then
--         self:FireFlechette( shootPos, shootVec )
--         self.NextTopFlechette = CurTime() + math.Rand(1, 8)
--     elseif self.NextBottomFlechette < CurTime() then
--         self:FireFlechette( shootPos, shootVec )
--         self.NextBottomFlechette = CurTime() + math.Rand(1, 8)
--     else
--         ent:FireBullets({
--             Damage = 8,
--             TracerName = "AirboatGunTracer",
--             Dir = shootVec,
--             Spread = Vector( 0.05, 0.05, 0 ),
--             Src = shootPos,
--             Attacker = self,
--             IgnoreEntity = self,
--         })

--         local data = EffectData()
--         data:SetEntity(self)
--         data:SetAttachment(self.ShootTopEye && 5 or 4)
--         util.Effect("AirboatMuzzleFlash", data)
--         self:EmitSound("Weapon_AR2.NPC_Single")
--     end

--     self.ShootTopEye = !self.ShootTopEye
-- end
-- --------------------------------------------------------------------------------=#
-- function ENT:CustomOnThink()
--     local enemy = self:GetEnemy()

--     if IsValid(enemy) && self:Visible(enemy) && self:WithinDistance(enemy, 0, 2000) then
--         if self.NextRangeAttack < CurTime() then
--             self:PlayAnimation("plant", 0.75, "lock")
--             timer.Simple(0.75, function() if IsValid(self)then self:PlayAnimation("shoot_minigun", 3) end end)
--             self.NextRangeAttack = CurTime() + math.Rand(5, 7)
--         end
--         self.LastEnemyPos = enemy:WorldSpaceCenter()
        
--     end

--     if !IsValid(enemy) then
--         self.LastEnemyPos = nil
--     end

--     if self.CurrentAnimation == "shoot_minigun" then
--         local pos = self.LastEnemyPos or self:GetAttachment(4).Pos+self:GetForward()*100
--         self:Face(pos)
--         self:Shoot(pos)
--     end
-- end
-- --------------------------------------------------------------------------------=#
-- function ENT:AfterTakeDamage( dmginfo )
--     ParticleEffect("blood_impact_synth_01", dmginfo:GetDamagePosition(), AngleRand())
--     if self.CurrentAnimation != "stagger_all" && dmginfo:GetDamage() >= 40 then
--         self:PlayAnimation("stagger_all", 0.75)
--     end
-- end
-- --------------------------------------------------------------------------------=#