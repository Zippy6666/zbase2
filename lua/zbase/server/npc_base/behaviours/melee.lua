local NPC = ZBaseNPCs["npc_zbase"]
local BEHAVIOUR = NPC.Behaviours

BEHAVIOUR.MeleeAttack = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
}
BEHAVIOUR.PreMeleeAttack = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
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
    -- return BusyScheds[sched] or sched > 88 or self.DoingPlayAnim
    return self.DoingPlayAnim
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function NPC:CanBeMeleed( ent )
    local mtype = ent:GetMoveType()
    return mtype == MOVETYPE_STEP -- NPC
    or mtype == MOVETYPE_VPHYSICS -- Prop
    or mtype == MOVETYPE_WALK -- Player
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function NPC:InternalMeleeAttackDamage(dmgData)
    local mypos = self:WorldSpaceCenter()
    local soundEmitted = false
    local soundPropEmitted = false

    for _, ent in ipairs(ents.FindInSphere(mypos, dmgData.dist)) do
        if ent == self then continue end
        if ent.GetNPCState && ent:GetNPCState() == NPC_STATE_DEAD then continue end

        local disp = self:Disposition(ent)
        if disp == D_LI
        or (!dmgData.affectProps && disp == D_NU) then continue end
        if self.ZBaseFaction == ent.ZBaseFaction then continue end

        if !self:Visible(ent) then continue end


        local entpos = ent:WorldSpaceCenter()
        local undamagable = (ent:Health()==0 && ent:GetMaxHealth()==0)
        local forcevec 


        -- Angle check
        if dmgData.ang != 360 then
            local yawDiff = math.abs( self:WorldToLocalAngles( (entpos-mypos):Angle() ).Yaw )*2
            if dmgData.ang < yawDiff then continue end
        end


        if self:CanBeMeleed(ent) then
            local tbl = self:MeleeDamageForce(dmgData)

            if tbl then
                forcevec = self:GetForward()*(tbl.forward or 0) + self:GetUp()*(tbl.up or 0) + self:GetRight()*(tbl.right or 0)

                if tbl.randomness then
                    forcevec = forcevec + VectorRand()*tbl.randomness
                end
            end
        else
            continue
        end


        -- Push
        if forcevec then
            local phys = ent:GetPhysicsObject()

            if IsValid(phys) then
                phys:SetVelocity(forcevec)
            end

            ent:SetVelocity(forcevec)
        end


        -- Damage
        if !undamagable then
            local dmg = DamageInfo()
            dmg:SetAttacker(self)
            dmg:SetInflictor(self)
            dmg:SetDamage(ZBaseRndTblRange(dmgData.amt))
            dmg:SetDamageType(dmgData.type)
            ent:TakeDamageInfo(dmg)

            if !(ent:IsPlayer() && dmg:IsDamageType(DMG_SLASH)) && dmg:GetDamage()>0 then
                ZBaseBleed( ent, entpos+VectorRand(-15, 15) ) -- Bleed
            end
        end
    

        -- Sound
        if disp == D_NU && !soundPropEmitted then -- Prop probably
            sound.Play(dmgData.hitSoundProps, entpos)
            soundPropEmitted = true
        elseif !soundEmitted && dist != D_NU then
            ent:EmitSound(dmgData.hitSound)
            soundEmitted = true
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:ShouldDoBehaviour( self )
    if !self.BaseMeleeAttack then return false end 

    local ene = self:GetEnemy()
    if !self.MeleeAttackFaceEnemy && !self:IsFacing(ene) then return false end

    return !self:TooBusyForMelee()
    && self:ZBaseDist(ene, {within=self.MeleeAttackDistance})
end
-----------------------------------------------------------------------------------------------------------------------------------------=#
function BEHAVIOUR.MeleeAttack:Run( self )
    self:MeleeAttack()
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