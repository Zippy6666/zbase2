local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours


BEHAVIOUR.AdjustSightAngAndDist = {
}
------------------------------------------------------------------------=#
-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.AdjustSightAngAndDist:ShouldDoBehaviour( self )
    return true
end
------------------------------------------------------------------------=#
-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to delay the behaviour (cooldown)
function BEHAVIOUR.AdjustSightAngAndDist:Run( self )
    local ene = self:GetEnemy()

    if self:ShootTargetTooFarAway() then
        self:PreventFarShoot()
    else
        local fieldOfView = math.cos( (self.SightAngle*(math.pi/180))*0.5 )
        self:SetSaveValue("m_flFieldOfView", fieldOfView)
        self:SetMaxLookDistance(self.SightDistance)
    end
end
------------------------------------------------------------------------=#

