local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))


/*
    -- In this file you can add custom NPC behaviours


    -- Example --
BEHAVIOUR.SayWhat = {
    MustHaveEnemy = false, -- Should it only run the behaviour if it has an enemy?
    MustHaveVisibleEnemy = false, -- Should it only run the behaviour if it has a enemy, and its enemy is visible?
    MustNotHaveEnemy = false, -- Should it only run the behaviour if it doesn't have an enemy?
}

-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.SayWhat:ShouldDoBehaviour( self )
    return true
end

-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.SayWhat:Delay( self )
end

-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to delay the behaviour (cooldown)
function BEHAVIOUR.SayWhat:Run( self )
    PrintMessage(HUD_PRINTTALK, "WHAT")
    ZBaseDelayBehaviour( 3 )
end
*/


------------------------------------------------------------------------=#
local function UseCustomSounds( _, self )
    if self:GetNPCState() == NPC_STATE_DEAD then return false end
    return self.UseCustomSounds
end
------------------------------------------------------------------------=#


BEHAVIOUR.Patrol = {
    MustNotHaveEnemy = true, -- Should it only run the behaviour if it doesn't have an enemy?
}
BEHAVIOUR.FactionCallForHelp = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it doesn't have an enemy?
}
BEHAVIOUR.DoIdleSound = {
    MustNotHaveEnemy = true, -- Should it only run the behaviour if it doesn't have an enemy?
    ShouldDoBehaviour = UseCustomSounds
}
BEHAVIOUR.DoIdleEnemySound = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy?
    ShouldDoBehaviour = UseCustomSounds
}
BEHAVIOUR.DoPainSound = {
    ShouldDoBehaviour = UseCustomSounds
}
BEHAVIOUR.SecondaryFire = {
    MustHaveVisibleEnemy = true, -- Should it only run the behaviour if it has a enemy, and its enemy is visible?
}



------------------------------------------------------------------------=#
function BEHAVIOUR.FactionCallForHelp:ShouldDoBehaviour( self )
    return self.CallForHelp!=false && self.ZBaseFaction != "none"
end
------------------------------------------------------------------------=#
function BEHAVIOUR.FactionCallForHelp:Run( self )
    for _, v in ipairs(ZBaseNPCInstances) do

        if !IsValid(v) then continue end
        if v == self then continue end
        if v.ZBaseFaction == "none" then continue end
        if IsValid(v:GetEnemy()) then continue end -- Ally already busy with an enemy
        if !self:WithinDistance(v, self.CallForHelpDistance) then continue end
        if !v:WithinDistance(self, v.CallForHelpDistance) then continue end

        if v.ZBaseFaction == self.ZBaseFaction then
            local ene = self:GetEnemy()
            v:UpdateEnemyMemory(ene, ene:GetPos())
        end

    end

    ZBaseDelayBehaviour(math.Rand(1, 3))
end
------------------------------------------------------------------------=#




------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:ShouldDoBehaviour( self )
    return self.CanPatrol
end
------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:Run( self )
    self:SetSchedule(SCHED_PATROL_WALK)
    ZBaseDelayBehaviour(math.random(5, 10))
end

------------------------------------------------------------------------=#




------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleSound:Run( self )

    self:EmitSound(self.IdleSounds)
    ZBaseDelayBehaviour(math.Rand(5, 10))

end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleEnemySound:Run( self )

    local snd = self.IdleSounds_HasEnemy
    local enemy = self:GetEnemy()

    if IsValid(enemy) && enemy != self.AlertSound_LastEnemy then
        snd = self.AlertSounds
        self.AlertSound_LastEnemy = enemy
    end

    self:EmitSound(snd)
    ZBaseDelayBehaviour(math.Rand(2, 7))

end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoPainSound:Run( self )

    local health = self:Health()

    if !self.PainSound_LastHealth then
        self.PainSound_LastHealth = health
    end

    if health < self.PainSound_LastHealth then
        self:EmitSound(self.PainSounds)
        self.PainSound_LastHealth = health
        ZBaseDelayBehaviour(math.Rand(0.5, 2.5))
    end

end

------------------------------------------------------------------------=#

-- Secondary fire

local SecondaryFireWeapons = {
    ["weapon_ar2"] = {dist=4000},
    ["weapon_smg1"] = {dist=1500},
}

------------------------------------------------------------------------=#
function SecondaryFireWeapons.weapon_ar2:Func( self, wep, enemy )


end
------------------------------------------------------------------------=#
function SecondaryFireWeapons.weapon_smg1:Func( self, wep, enemy )

    local startPos = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos
    local grenade = ents.Create("grenade_ar2")
    grenade:SetOwner(self)
    grenade:SetPos(startPos)
    grenade:Spawn()
    grenade:SetVelocity((enemy:GetPos() - startPos):GetNormalized()*1250 + Vector(0,0,200))
    grenade:SetLocalAngularVelocity(AngleRand())
    wep:EmitSound("Weapon_AR2.Double")

    local effectdata = EffectData()
    effectdata:SetFlags(7)
    effectdata:SetEntity(wep)
    util.Effect( "MuzzleFlash", effectdata, true, true )

end
------------------------------------------------------------------------=#
function BEHAVIOUR.SecondaryFire:ShouldDoBehaviour( self )
    local wep = self:GetActiveWeapon()

    if !IsValid(wep) then return false end
    if !SecondaryFireWeapons[wep:GetClass()] then return false end

    return self:WithinDistance( self:GetEnemy(), SecondaryFireWeapons[wep:GetClass()].dist, 300 )
end
------------------------------------------------------------------------=#
function BEHAVIOUR.SecondaryFire:Delay( self )

    local enemy = self:GetEnemy()

    if !IsValid(enemy) then return end

    if !self:Visible(enemy) then
        return math.Rand(0.5, 3)
    end

end
------------------------------------------------------------------------=#
function BEHAVIOUR.SecondaryFire:Run( self )
    local enemy = self:GetEnemy()
    local wep = self:GetActiveWeapon()
    SecondaryFireWeapons[wep:GetClass()]:Func( self, wep, enemy )
    ZBaseDelayBehaviour(2)
end
------------------------------------------------------------------------=#