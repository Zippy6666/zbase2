local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/zippy/Synth.mdl"}
NPC.StartHealth = 300

NPC.BloodColor = DONT_BLEED

NPC.CollisionBounds = {min=Vector(-75, -75, 0), max=Vector(75, 75, 90)}
NPC.HullType = HULL_LARGE -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL

NPC.ZBaseStartFaction = "combine"

NPC.BaseMeleeAttack = true -- Use ZBase melee attack system
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}
NPC.MeleeDamage_AffectProps = true -- Affect props and other entites

NPC.MeleeAttackAnimationSpeed = 1.33 -- Speed multiplier for the melee attack animation
NPC.MeleeDamage = {20, 30} -- Melee damage {min, max}
NPC.MeleeDamage_Distance = 200 -- Distance the damage travels
NPC.MeleeDamage_Type = DMG_SLASH -- The damage type, https://wiki.facepunch.com/gmod/Enums/DMG
NPC.MeleeDamage_Delay = false -- Time until the damage strikes, set to false to disable the timer (if you want to use animation events instead)

        -- ARMOR SYSTEM --
NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
}
NPC.ArmorPenChance = false -- 1/x Chance that the armor is penetrated, false = never
NPC.ArmorAlwaysPenDamage = false -- Always penetrate the armor if the damage is more than this, set to false to disable
NPC.ArmorHitSpark = false -- Do a spark on armor hit
NPC.ArmorReflectsBullets = true -- Should the armor reflect bullets?

NPC.SquadGiveSpace = 256
NPC.CantReachEnemyBehaviour = ZBASE_CANTREACHENEMY_FACE -- ZBASE_CANTREACHENEMY_HIDE || ZBASE_CANTREACHENEMY_FACE

        -- BASE RANGE ATTACK --
NPC.BaseRangeAttack = false -- Use ZBase range attack system
NPC.RangeAttackAnimations = {} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeProjectile_Inaccuracy = 0.05
NPC.RangeAttackCooldown = {8, 12} -- Range attack cooldown {min, max}
NPC.RangeAttackDistance = {300, 1000} -- Distance that it initiates the range attack {min, max}
NPC.RangeAttackTurnSpeed = 10 -- Speed that it turns while trying to face the enemy when range attacking

-- Time until the projectile code is ran
-- Set to false to disable the timer (if you want to use animation events instead for example)
NPC.RangeProjectile_Delay = false

NPC.FlinchAnimations = {"attack2"} -- Flinch animations to use, leave empty to disable the base flinch
NPC.FlinchAnimationSpeed = 2 -- Speed of the flinch animation
NPC.FlinchCooldown = {1, 3} -- Flinch cooldown in seconds {min, max}
NPC.FlinchChance = 2 -- Flinch chance 1/x

---------------------------------------------------------------------------------------------------------------------=#
function NPC:MultipleMeleeAttacks()
    local rnd = math.random(1, 3)
    if rnd == 1 then
        self.MeleeAttackAnimations = {"attack2"}
        self.MeleeDamage = {20, 30} -- Melee damage {min, max}
        self.MeleeDamage_Angle = 180 -- Damage angle (180 = everything in front of the NPC is damaged)
        self.MeleeAttackName = "bigmelee" -- Serves no real purpose, you can use it for whatever you want
        self.MeleeAttackFaceEnemy = true -- Should it face enemy while doing the melee attack?
        self.MeleeAttackDistance = 190
    elseif rnd == 2 then
        self.MeleeAttackAnimations = {"attack1"}
        self.MeleeDamage = {20, 20} -- Melee damage {min, max}
        self.MeleeDamage_Angle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
        self.MeleeAttackName = "smallmelee" -- Serves no real purpose, you can use it for whatever you want
        self.MeleeAttackFaceEnemy = true -- Should it face enemy while doing the melee attack?
        self.MeleeAttackDistance = 190
    elseif rnd == 3 then
        self.MeleeAttackAnimations = {ACT_MELEE_ATTACK2}
        self.MeleeDamage = {20, 20} -- Melee damage {min, max}
        self.MeleeDamage_Angle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
        self.MeleeAttackName = "runmelee" -- Serves no real purpose, you can use it for whatever you want
        self.MeleeAttackFaceEnemy = false -- Should it face enemy while doing the melee attack?
        self.MeleeAttackDistance = 250
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:CustomThink()
    local seqName = self:GetSequenceName(self:GetSequence())
    if seqName == "range_loop" or seqName == "range_start" then
        self:Face(self:RangeAttack_IdealFacePos(), nil, self.RangeAttackTurnSpeed)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnRangeAttack()
    local duration = math.Rand(3, 6)
    self:PlayAnimation(ACT_RANGE_ATTACK1, false, {duration=duration})
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:RangeAttackProjectile()
    local projStartPos = self:Projectile_SpawnPos()

    self:FireBullets({
        Attacker = self,
        Inflictor = self,
        Damage = 3,
        Dir = (self:Projectile_TargetPos() - projStartPos):GetNormalized(),
        Src = projStartPos,
        Spread = Vector(self.RangeProjectile_Inaccuracy, self.RangeProjectile_Inaccuracy),
        TracerName = "HelicopterTracer",
    })
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:MeleeDamageForce( dmgData )
    if dmgData.name == "smallmelee" then
        return {forward=150, up=325, right=-350, randomness=75}
    elseif dmgData.name == "bigmelee" then
        return {forward=500, up=75, right=0, randomness=150}
    elseif dmgData.name == "runmelee" then
        return {forward=300, up=350, right=0, randomness=75}
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SNPCHandleAnimEvent(event, eventTime, cycle, type, option) 
    if event == 5 then
        self:MeleeAttackDamage()
    end

    if event == 2042 then
        self:RangeAttackProjectile()
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnFlinch(dmginfo, HitGroup, flinchAnim)

end
---------------------------------------------------------------------------------------------------------------------=#