local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))


BEHAVIOUR.DeployTurret = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}
------------------------------------------------------------------------=#
-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.DeployTurret:ShouldDoBehaviour( self )
    return IsValid(self.Turret)
end
------------------------------------------------------------------------=#
-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.DeployTurret:Delay( self )
end
------------------------------------------------------------------------=#
-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to delay the behaviour (cooldown)
function BEHAVIOUR.DeployTurret:Run( self )
    print("testicle")
    self:PlayAnimation("turret_drop")
    ZBaseDelayBehaviour(100)
end
------------------------------------------------------------------------=#