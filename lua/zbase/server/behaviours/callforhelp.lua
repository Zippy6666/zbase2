local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours

BEHAVIOUR.FactionCallForHelp = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
}

------------------------------------------------------------------------=#
function BEHAVIOUR.FactionCallForHelp:ShouldDoBehaviour( self )
    return self.CallForHelp!=false && self.ZBaseFaction != "none"
end
------------------------------------------------------------------------=#
function BEHAVIOUR.FactionCallForHelp:Run( self )
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), self.CallForHelpDistance)) do

        if !v:IsNPC() then continue end
        if v == self then continue end
        if v.ZBaseFaction == "none" then continue end
        if IsValid(v:GetEnemy()) then continue end -- Ally already busy with an enemy

        if v.ZBaseFaction == self.ZBaseFaction then
            local ene = self:GetEnemy()
            v:UpdateEnemyMemory(ene, ene:GetPos())
            v:AlertSound()
        end

    end

    ZBaseDelayBehaviour(math.Rand(2, 3.5))
end
------------------------------------------------------------------------=#