local NPC = ZBaseNPCs["npc_zbase"]
local BEHAVIOUR = NPC.Behaviours

BEHAVIOUR.MeleeAttack = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}
BEHAVIOUR.PreMeleeAttack = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
}

local BusyScheds = {
    [SCHED_MELEE_ATTACK1] = true,
    [SCHED_MELEE_ATTACK2] = true,
    [SCHED_RANGE_ATTACK1] = true,
    [SCHED_RANGE_ATTACK2] = true,
    [SCHED_RELOAD] = true,
}

-----------------------------------------------------------------------------------------------------------------------------------------=#
function NPC:TooBusyForMelee()
    local sched = self:GetCurrentSchedule()
    return BusyScheds[sched] or sched > 88
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function NPC:MeleeAttackDamage(dist, ang, type, amt, hitSound)
    local mypos = self:WorldSpaceCenter()
    local soundEmitted = false

    for _, ent in ipairs(ents.FindInSphere(mypos, dist)) do
        if ent == self then continue end
        if ent.GetNPCState && ent:GetNPCState() == NPC_STATE_DEAD then continue end
        local disp = self:Disposition(ent) if disp == D_LI or disp == D_NU then continue end
        if !self:Visible(ent) then continue end

        local entpos = ent:WorldSpaceCenter()


        -- Angle check
        if ang != 360 then
            local yawDiff = math.abs( self:WorldToLocalAngles( (entpos-mypos):Angle() ).Yaw )*2
            if ang < yawDiff then continue end
        end


        -- Bleed
        ZBaseBleed( ent, (mypos + entpos)*0.5+VectorRand(-15, 15) )


        -- Damage
        local dmg = DamageInfo()
        dmg:SetAttacker(self)
        dmg:SetInflictor(self)
        dmg:SetDamage(ZBaseRndTblRange(amt))
        dmg:SetDamageType(type)
        ent:TakeDamageInfo(dmg)


        -- Sound
        if !soundEmitted then
            ent:EmitSound(hitSound)
            soundEmitted = true
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end 
    if table.IsEmpty(self.MeleeAttackAnimations) then return false end

    return !self:TooBusyForMelee()
    && self:WithinDistance(self:GetEnemy(), self.MeleeAttackDistance)
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:Run( self )
        -- Animation --
    local anim = table.Random(self.MeleeAttackAnimations)
    self:InternalPlayAnimation(anim, nil, self.MeleeAttackAnimationSpeed, SCHED_NPC_FREEZE, self.MeleeAttackFaceEnemy && self:GetEnemy())
    -----------------------------------------------------------------=#


        -- Damage --
    local dist = self.MeleeDamage_Distance
    local ang = self.MeleeDamage_Angle
    local type = self.MeleeDamage_Type
    local amt = self.MeleeDamage
    local hitSound = self.MeleeDamage_Sound
    
    timer.Simple(self.MeleeDamage_Delay, function()
        if !IsValid(self) then return end
        if self:GetNPCState()==NPC_STATE_DEAD then return end
        self:MeleeAttackDamage(dist, ang, type, amt, hitSound)
    end)
    -----------------------------------------------------------------=#


    ZBaseDelayBehaviour(self:SequenceDuration() + ZBaseRndTblRange(self.MeleeAttackCooldown))
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.PreMeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end 
    if self:TooBusyForMelee() then return false end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.PreMeleeAttack:Run( self )
    self:MultipleMeleeAttacks()
end
-----------------------------------------------------------------------------------------------------------------------------------------=#