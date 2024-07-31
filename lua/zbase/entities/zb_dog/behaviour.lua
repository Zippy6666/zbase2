local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))


BEHAVIOUR.D0GLeap = {
}


local D0GsDoingLeap = {}


-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.D0GLeap:ShouldDoBehaviour( self )

    if self:BusyPlayingAnimation() then return false end
    
    local npcState = self:GetNPCState()
    local goal = self:GetGoalPos()

    if npcState != NPC_STATE_COMBAT && npcState != NPC_STATE_ALERT then return false end

    if goal:IsZero() then return false end
    if self:ZBaseDist(goal, {away=1000, within=400}) then return false end


    return true

end




-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.D0GLeap:Delay( self )

    if !table.IsEmpty(D0GsDoingLeap) then
        return math.Rand(2, 4)
    end

end




-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to out the behaviour on a cooldown
local upVec = Vector(0,0,600)
function BEHAVIOUR.D0GLeap:Run( self )

    D0GsDoingLeap[self] = true
    self:CallOnRemove("RemoveFromD0GsDoingLeap", function() D0GsDoingLeap[self] = nil end)


    local jumpPos = self:GetGoalPos()
    debugoverlay.Cross(jumpPos, 25, 1)
    self:MoveJumpStart( (jumpPos-self:GetPos())*0.5+upVec )
    self:PlayAnimation("klab_exit", true, {speedMult=0.75, duration=1.8})

    self:CONV_TimerSimple(2, function()
        self:MeleeAttackDamage()
        D0GsDoingLeap[self] = nil
    end)


    ZBaseDelayBehaviour(math.Rand(5, 10))

end

