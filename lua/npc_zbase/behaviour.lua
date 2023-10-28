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
-- Return a number to delay the behaviour by said number (in seconds)
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

    -- Patrol

BEHAVIOUR.Patrol = {
    MustNotHaveEnemy = true, -- Should it only run the behaviour if it doesn't have an enemy?
}

function BEHAVIOUR.Patrol:ShouldDoBehaviour( self )
    return self.CanPatrol
end

function BEHAVIOUR.Patrol:Run( self )
    print("BEHAVIOUR.Patrol:Run(", self.Name, ")")
    self:SetSchedule(SCHED_PATROL_WALK)
    ZBaseDelayBehaviour(math.random(5, 10))
end

------------------------------------------------------------------------=#

-- Sounds

local function UseCustomSounds( _, self )
    if self:GetNPCState() == NPC_STATE_DEAD then return false end
    return self.UseCustomSounds
end

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

function BEHAVIOUR.DoIdleSound:Run( self )

    self:EmitSound(self.IdleSounds)
    ZBaseDelayBehaviour(math.Rand(5, 10))

end

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