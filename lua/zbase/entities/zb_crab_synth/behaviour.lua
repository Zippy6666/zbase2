local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))


BEHAVIOUR.ChargeAttack = {
    MustHaveEnemy = false, -- Should it only run the behaviour if it has an enemy? 
    MustNotHaveEnemy = false, --  Don't run the behaviour if the NPC doesn't have an enemy
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}





-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.ChargeAttack:ShouldDoBehaviour( self )
    if self:BusyPlayingAnimation() then return false end
    return true
end




-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.ChargeAttack:Delay( self )
    if !self:ZBaseDist(self:GetEnemy(), {within=1250, away=300})
    or math.abs(self:GetPos().z - self:GetEnemy():GetPos().z) > 100
    or math.random(1, 3) > 1 then
        return math.Rand(2, 4)
    end
end




-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to out the behaviour on a cooldown
function BEHAVIOUR.ChargeAttack:Run( self )
    self:EmitSound_Uninterupted("ZBaseCrabSynth.Announce")
    self:PlayAnimation(ACT_SPECIAL_ATTACK1, true, {faceSpeed=5, duration=math.Rand(5, 7), speedMult=1.2})
    ZBaseDelayBehaviour(math.Rand(18, 22))
end

