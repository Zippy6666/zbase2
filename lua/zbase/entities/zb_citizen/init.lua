local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.WeaponProficiency = WEAPON_PROFICIENCY_AVERAGE -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.StartHealth = 30 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour


NPC.ZBaseStartFaction = "ally" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"


NPC.BaseMeleeAttack = true
NPC.MeleeAttackAnimations = {"swing"}
NPC.MeleeAttackAnimationSpeed = 1
NPC.MeleeDamage_Delay = 0.5 -- Time until the damage strikes


NPC.BaseRangeAttack = true -- Use ZBase range attack system
NPC.RangeAttackFaceEnemy = true -- Should it face enemy while doing the range attack?
NPC.RangeAttackTurnSpeed = 20 -- Speed that it turns while trying to face the enemy when range attacking
NPC.RangeAttackDistance = {200, 1500} -- Distance that it initiates the range attack {min, max}
NPC.RangeAttackCooldown = {2, 3} -- Range attack cooldown {min, max}
NPC.RangeAttackSuppressEnemy = false -- If the enemy can't be seen, target the last seen position

NPC.RangeAttackAnimations = {"throw1"} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeAttackAnimationSpeed = 1.5 -- Speed multiplier for the range attack animation


-- Time until the projectile code is ran
-- Set to false to disable the timer (if you want to use animation events instead for example)
NPC.RangeProjectile_Delay = 0.75


-- Attachment to spawn the projectile on 
-- If set to false the projectile will spawn from the NPCs center
NPC.RangeProjectile_Attachment = "anim_attachment_RH"
NPC.RangeProjectile_Offset = false -- Projectile spawn offset, example: {forward=50, up=25, right=0}
NPC.RangeProjectile_Speed = 1200 -- The speed of the projectile
NPC.RangeProjectile_Inaccuracy = 20 -- Inaccuracy, 0 = perfect, higher numbers = less accurate


--]]==============================================================================================]]
function NPC:CustomInitialize()
end
--]]==============================================================================================]]
function NPC:RangeAttackProjectile()
    local projStartPos = self:Projectile_SpawnPos()

    local proj = ents.Create("zb_rock")
    proj:SetPos(projStartPos)
    proj:SetAngles(self:GetAngles())
    proj:SetOwner(self)
    proj:Spawn()

    local proj_phys = proj:GetPhysicsObject()
    if IsValid(proj_phys) then
        proj_phys:SetVelocity(self:RangeAttackProjectileVelocity()+Vector(0, 0, 200))
    end
end
--]]==============================================================================================]]
function NPC:PreventRangeAttack()
    return IsValid(self:GetActiveWeapon()) or !self:IsFacing(self:GetEnemy(), 45)
end
--]]==============================================================================================]]