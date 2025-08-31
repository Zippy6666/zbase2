local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))

BEHAVIOUR.SelfHeal = {
    MustHaveEnemy = false, -- Should it only run the behaviour if it has an enemy? 
    MustNotHaveEnemy = false, --  Don't run the behaviour if the NPC doesn't have an enemy
    MustHaveVisibleEnemy = false, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = false, -- Only run the behaviour if the NPC is facing its enemy
}

-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.SelfHeal:ShouldDoBehaviour( self )
    return !self:BusyPlayingAnimation() && self:Health() < self:GetMaxHealth()
end

-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.SelfHeal:Delay( self )
end

-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to out the behaviour on a cooldown
function BEHAVIOUR.SelfHeal:Run( self )
    self.DoingSelfHeal = true
    self.Medkit = ents.Create("item_healthvial")
    self.Medkit:SetPos(self:GetAttachment(self:LookupAttachment("lefthand")).Pos)
    self.Medkit:SetParent(self, self:LookupAttachment("lefthand"))
    self.Medkit:Spawn()
    self:PlayAnimation("grenplace", true, {speedMult=1.6})
    
    self:CONV_TimerSimple(0.5, function()
        if IsValid(self.Medkit) then
            self:EmitSound("WallHealth.Start")
            self:SetHealth( math.Clamp(self:Health() + 25, 0, self:GetMaxHealth()) )
            self.DoingSelfHeal = false
            self.Medkit:Remove()
        end
    end)
end