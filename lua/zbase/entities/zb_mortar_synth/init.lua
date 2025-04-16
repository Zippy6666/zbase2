local NPC                   = FindZBaseTable(debug.getinfo(1,'S'))
local RANGE_ATTACK_MORTAR   = 1
local RANGE_ATTACK_BOLT     = 2

-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {"models/zippy/mortarsynth.mdl"}
NPC.RenderMode = RENDERMODE_TRANSALPHA -- https://wiki.facepunch.com/gmod/Enums/RENDERMODE
NPC.CollisionBounds = {min=Vector(-26, -26, -26), max=Vector(26, 26, 26)}
NPC.HullType = HULL_LARGE_CENTERED -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL
NPC.SNPCType = ZBASE_SNPCTYPE_FLY -- ZBASE_SNPCTYPE_WALK || ZBASE_SNPCTYPE_FLY || ZBASE_SNPCTYPE_STATIONARY
NPC.StartHealth = 110

NPC.BloodColor = DONT_BLEED
NPC.CustomBloodParticles = {"blood_impact_synth_01"} -- Table of custom particles
NPC.CustomBloodDecals = "ZBaseBloodSynth" -- String name of custom decal

NPC.ZBaseStartFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody

-- Minimum distance it chases before doing it runs SNPCChase_TooClose
-- SNPCChase_TooClose will by default cause the SNPC to stop and face the enemy
NPC.ChaseMinDistance = 500

NPC.Fly_DistanceFromGround = 80 -- Minimum distance to try to keep from the ground when flying
NPC.Fly_MoveSpeed = 350 -- Flying movement speed
NPC.Fly_Accelerate = 15 -- Flying movement accelerate speed
NPC.Fly_Decelerate = 15 -- Flying movement decelerate speed
NPC.Fly_FaceEnemy = false

NPC.BaseRangeAttack = true -- Use ZBase range attack system
NPC.RangeAttackFaceEnemy = true -- Should it face enemy while doing the range attack?
NPC.RangeAttackTurnSpeed = 5 -- Speed that it turns while trying to face the enemy when range attacking
NPC.RangeAttackDistance = {0, 2000} -- Distance that it initiates the range attack {min, max}
NPC.RangeAttackCooldown = {1, 3} -- Range attack cooldown {min, max}
NPC.RangeAttackSuppressEnemy = true -- If the enemy can't be seen, target the last seen position

NPC.RangeAttackAnimations = {} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeAttackAnimationSpeed = 1.3 -- Speed multiplier for the range attack animation

-- Time until the projectile code is ran
-- Set to false to disable the timer (if you want to use animation events instead for example)
NPC.RangeProjectile_Delay = 0.8

-- Attachment to spawn the projectile on 
-- If set to false the projectile will spawn from the NPCs center
NPC.RangeProjectile_Attachment = 4
NPC.RangeProjectile_Offset = false -- Projectile spawn offset, example: {forward=50, up=25, right=0}
NPC.RangeProjectile_Speed = 1000 -- The speed of the projectile
NPC.RangeProjectile_Inaccuracy = 0 -- Inaccuracy, 0 = perfect, higher numbers = less accurate

NPC.FlinchAnimations = {"mortar_corpse"} -- Flinch animations to use, leave empty to disable the base flinch
NPC.FlinchCooldown = {2, 3} -- Flinch cooldown in seconds {min, max}
NPC.FlinchChance = 1 -- Flinch chance 1/x
NPC.FlinchIsGesture = false -- Should the flinch animation be played as a gesture?

-- Sounds (Use sound scripts to alter pitch and level and such!)
NPC.AlertSounds = "ZBaseMortarSynth.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.PainSounds = "ZBaseMortarSynth.Hurt" -- Sounds emitted on hurt
NPC.DeathSounds = "ZBaseMortarSynth.Die" -- Sounds emitted on death
NPC.HearDangerSounds = "ZBaseMortarSynth.Alert"

function NPC:CustomInitialize()
    -- Hum sound
    self.HumSound = CreateSound( self, "ZBaseMortarSynth.hover" )
    self.HumSound:Play()
end

function NPC:SNPCChase_TooClose()
    -- Back away if enemy too close
    return ZSched.BackAwayFromEnemy
end

function NPC:RangeAttackAnimation()
    -- Play animation as usual
    self:PlayAnimation(table.Random(self.RangeAttackAnimations), false, {
        speedMult=self.RangeAttackAnimationSpeed,
        noTransitions = false,
    })

    -- Glow effects before doing bolt attack
    if self.RangeAttackType == RANGE_ATTACK_BOLT then
        ParticleEffectAttach("mortarsynth_hand_glow", PATTACH_POINT_FOLLOW, self, 1)
        ParticleEffectAttach("mortarsynth_hand_glow", PATTACH_POINT_FOLLOW, self, 2)
    end
end

function NPC:MultipleRangeAttacks()
    -- Pick between two range attacks randomly
    -- and based on distance factors
    if ( math.random(1, 2) == 1 && self:ZBaseDist(self:GetEnemy(), {within=1000}) ) or self:ZBaseDist(self:GetEnemy(), {within=400}) then
        -- Electric bolt
        self.RangeAttackAnimations = {ACT_RANGE_ATTACK2}
        self.RangeAttackType = RANGE_ATTACK_BOLT
    else
        -- Mortar
        self.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
        self.RangeAttackType = RANGE_ATTACK_MORTAR
    end
end

function NPC:RangeAttackProjectile()
    -- Range attack variants

    local ProjStartPos = self:Projectile_SpawnPos()

    -- Use mortar catapult
    if self.RangeAttackType == RANGE_ATTACK_MORTAR then
        -- Mortar

        local proj = ents.Create("zb_mortar")
        proj:SetPos(ProjStartPos)
        proj:SetAngles(self:GetAngles())
        proj:SetOwner(self)
        proj:Spawn()
        local proj_phys = proj:GetPhysicsObject()
        if IsValid(proj_phys) then
            proj_phys:SetVelocity(self:RangeAttackProjectileVelocity()+Vector(0,0,200))
        end

        self:EmitSound("Weapon_Mortar.Single")

        -- Flash
        local effectdata = EffectData()
        effectdata:SetEntity(self)
        effectdata:SetAttachment(4)
        util.Effect("ChopperMuzzleFlash", effectdata, true, true)
    elseif self.RangeAttackType == RANGE_ATTACK_BOLT then
        -- Electric bolt

        local TargetPos = self:Projectile_TargetPos()
        local StartPos_Dmg = self:WorldSpaceCenter()
        local Nrm = (TargetPos - self:WorldSpaceCenter()):GetNormalized()

        -- "Muzzle" effects
        for i = 1, 2 do
            local tr = util.TraceLine({
                start = StartPos_Dmg,
                endpos = StartPos_Dmg+Nrm*10000,
                filter = self,
            })

            local StartPos = self:GetAttachment(i).Pos
            ParticleEffect("mortarsynth_beam", StartPos, self:GetAngles())
        end
    
        -- Damage
        local tr = util.TraceLine({
            start = StartPos_Dmg,
            endpos = StartPos_Dmg+Nrm*10000,
            filter = self,
        })
        local dmginfo = DamageInfo()
        dmginfo:SetAttacker(self)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(10)
        dmginfo:SetDamageType(DMG_SHOCK)
        util.BlastDamageInfo(dmginfo, tr.HitPos, 75)

        -- Impact effect
        ParticleEffect("mortarsynth_beam", tr.HitPos, self:GetAngles())

        -- Sound
        self:EmitSound("ZBaseMortarSynth.Shock")

        self:StopParticles() -- Stop charge particles
    end
end

function NPC:CustomTakeDamage( dmginfo, HitGroup )
    -- More damage if it was from its own projectile
    local infl = dmginfo:GetInflictor()

    if IsValid(infl) && infl.IsMortarSynthProjectile then
        dmginfo:ScaleDamage(2.5)
    end
end

function NPC:GetFlinchAnimation(dmginfo, HitGroup)
    -- Decide if it is a big or small flinch
    local FlinchType = "mortar_flinch_"
    self.FlinchAnimationSpeed = 2 -- Speed of the flinch animation

    if dmginfo:GetDamage() >= 50 then
        FlinchType = "mortar_bigflinch_"
        self.FlinchAnimationSpeed = 1.5 -- Speed of the flinch animation
    end

    -- Decide the direction for the flinch
    local FlinchDir
    local Yaw = self:WorldToLocalAngles( (dmginfo:GetDamagePosition() - self:GetPos()):Angle() ).Yaw
    if math.abs(Yaw) < 45 then
        FlinchDir = "front"
    elseif math.abs(Yaw) > 135 then
        FlinchDir = "back"
    elseif Yaw > 45 && Yaw < 135 then
        FlinchDir = "left"
    elseif Yaw < -45 && Yaw > -135 then
        FlinchDir = "right"
    end

    if FlinchDir then
        return FlinchType..FlinchDir
    end
end

function NPC:OnFlinch(dmginfo, HitGroup, flinchAnim)
    -- Don't flinch if already playing important animation
    if self:BusyPlayingAnimation() then
        return false
    end
end

function NPC:ShouldGib( dmginfo, hit_gr )
    -- Gibs / explosion effects

    self:CreateGib("models/gibs/mortarsynth_gib_01.mdl", {offset=Vector(0, 0, 0)})
    self:CreateGib("models/gibs/mortarsynth_gib_02.mdl", {offset=Vector(-20, 0, 0)})
    self:CreateGib("models/gibs/mortarsynth_gib_03.mdl", {offset=Vector(0, 0, -15)})
    self:CreateGib("models/gibs/mortarsynth_gib_04.mdl", {offset=Vector(15, -28, -30)})
    self:CreateGib("models/gibs/mortarsynth_gib_05.mdl", {offset=Vector(15, 28, -30)})

    ParticleEffect("striderbuster_break_shell", self:GetPos(), self:GetAngles())
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(self:WorldSpaceCenter())
    explosion:SetKeyValue("spawnflags", bit.bor(1, 64, 256))
    explosion:Spawn()
    explosion:Fire("Explode")
    explosion:Remove()

    return true
end

function NPC:OnRemove()
    -- Stop hum sound when removed
    
    self.HumSound:Stop()
end
