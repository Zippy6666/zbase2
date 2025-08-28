local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))

BEHAVIOUR.Spark = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
    MustNotHaveEnemy = false, --  Don't run the behaviour if the NPC doesn't have an enemy
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}

-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.Spark:ShouldDoBehaviour( self )
    -- Already active
    if timer.Exists("AirlionSpark"..self:EntIndex()) then
        return false
    end

    -- Spark within x units
    return self:ZBaseDist(self:GetEnemy(), {within=300})
end

-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.Spark:Delay( self )
end

-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to out the behaviour on a cooldown
function BEHAVIOUR.Spark:Run( self )
    local ene = self:GetEnemy()

    -- Initial effect
    local pos = self:GetPos()
    effects.BeamRingPoint( pos, 1, 0, 500, 20, 1, col )
    effects.BeamRingPoint( pos, 0.25, 0, 1000, 30, 1, col )

    local host = self
    local nextHost = ene
    -- timer.Create("AirlionSpark"..self:EntIndex(), 0.5, 0, function()
    --     util.ParticleTracerEx( "vortigaunt_beam", host:GetPos(), nextHost:GetPos(), false, host:EntIndex(), 0 )

    --     for _, ent in ipairs(ents.FindInSphere(host:GetPos(), 1000)) do
    --         if ent:IsSolid() then

    --         end
    --     end
    -- end)
end