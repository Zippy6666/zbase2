local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))

BEHAVIOUR.D0GLeap   = {}
local D0GsDoingLeap = {}
local upVec         = Vector(0,0,600)

-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.D0GLeap:ShouldDoBehaviour( self )
    if self:BusyPlayingAnimation() then return false end
    
    local npcState = self:GetNPCState()
    local goal = self:GetGoalPos()

    if npcState != NPC_STATE_COMBAT then return false end

    if goal:IsZero() then return false end
    if !self:ZBaseDist(goal, {away=300, within=1200}) then return false end

    return true
end

-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.D0GLeap:Delay( self )
    -- Delay my next leap if any other D0G is leaping right now
    if !table.IsEmpty(D0GsDoingLeap) then
        return math.Rand(2, 4)
    end
end

-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to out the behaviour on a cooldown
function BEHAVIOUR.D0GLeap:Run( self )
    D0GsDoingLeap[self] = true
    self:CallOnRemove("RemoveFromD0GsDoingLeap", function() D0GsDoingLeap[self] = nil end)

    local jumpAssumedFinished = 2.2
    local jumpPos = self:GetGoalPos()
    debugoverlay.Cross(jumpPos, 25, 1)
    self:MoveJumpStart( (jumpPos-self:GetPos())*0.5+upVec )
    self:PlayAnimation("klab_exit", false, {speedMult=0.75, duration=jumpAssumedFinished, face=jumpPos})
    self:EmitSound("NPC_dog.Angry_3")

    self:CONV_TimerSimple(jumpAssumedFinished, function()
        self:StopCurrentAnimation()
        self:PlayAnimation("roll", false, {speedMult=2})
        self:MeleeAttackDamage()
        D0GsDoingLeap[self] = nil
    end)

    ZBaseDelayBehaviour(math.Rand(5, 10))
end