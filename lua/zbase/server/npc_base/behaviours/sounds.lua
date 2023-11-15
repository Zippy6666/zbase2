local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours


BEHAVIOUR.DoIdleSound = {
    MustNotHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
}
BEHAVIOUR.DoIdleEnemySound = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
}
BEHAVIOUR.Dialogue = {
    MustNotHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
}


--[[
==================================================================================================
                                           Idle Sounds
==================================================================================================
--]]
function BEHAVIOUR.DoIdleSound:ShouldDoBehaviour( self )
    if self.IdleSounds == "" then return false end
    if self:GetNPCState() == NPC_STATE_DEAD then return false end
    if self.HavingConversation then return false end

    return true
end
--[[===============================================================================================]]
function BEHAVIOUR.DoIdleSound:Delay( self )
    if self:SquadMemberIsSpeaking({"IdleSounds"}) or math.random(1, self.IdleSound_Chance)==1 then
        return ZBaseRndTblRange(self.IdleSoundCooldown)
    end
end
--[[===============================================================================================]]
function BEHAVIOUR.DoIdleSound:Run( self )
    self:EmitSound_Uninterupted(self.IdleSounds)
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSoundCooldown))
end
--[[
==================================================================================================
                                           Idle Enemy Sounds
==================================================================================================
--]]
function BEHAVIOUR.DoIdleEnemySound:ShouldDoBehaviour( self )
    if self.Idle_HasEnemy_Sounds == "" then return false end
    if self:GetNPCState() == NPC_STATE_DEAD then return false end

    return true
end
--[[===============================================================================================]]
function BEHAVIOUR.DoIdleEnemySound:Delay( self )
    if self:SquadMemberIsSpeaking() then
        return ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown)
    end
end
--[[===============================================================================================]]
function BEHAVIOUR.DoIdleEnemySound:Run( self )

    local snd = self.Idle_HasEnemy_Sounds
    local enemy = self:GetEnemy()

    self:EmitSound_Uninterupted(snd)
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown))

end
--[[
==================================================================================================
                                           Dialogue
==================================================================================================
--]]
function BEHAVIOUR.Dialogue:ShouldDoBehaviour( self )
    if self.Dialogue_Question_Sounds == "" then return false end
    if self:GetNPCState() == NPC_STATE_DEAD then return false end
    if self.HavingConversation then return false end

    return true
end
--[[===============================================================================================]]
function BEHAVIOUR.Dialogue:Delay( self )
    if self:SquadMemberIsSpeaking() or self.HavingConversation or math.random(1, self.IdleSound_Chance)==1 then
        return ZBaseRndTblRange(self.IdleSoundCooldown)
    end
end
--[[===============================================================================================]]
function BEHAVIOUR.Dialogue:Run( self )
    local ally = self:GetNearestAlly(350)


    if IsValid(ally)
    && ally.IsZBaseNPC
    && !IsValid(ally:GetEnemy())
    && !ally.HavingConversation
    && ally.Dialogue_Answer_Sounds != "" then
        self:EmitSound_Uninterupted(self.Dialogue_Question_Sounds)

        self:FullReset()
        self:Face(ally, self.InternalCurrentSoundDuration+0.2)
        self.HavingConversation = true
        self.DialogueMate = ally

        ally:FullReset()
        ally:Face(self, self.InternalCurrentSoundDuration+0.2)
        ally.HavingConversation = true
        ally.DialogueMate = self

        timer.Create("DialogueAnswer"..ally:EntIndex(), self.InternalCurrentSoundDuration, 1, function()
            if IsValid(ally) then
                ally:EmitSound_Uninterupted(ally.Dialogue_Answer_Sounds)
                ally:Face(self, ally.InternalCurrentSoundDuration)

                timer.Simple(ally.InternalCurrentSoundDuration, function()
                    if !IsValid(ally) then return end
                    ally:CancelConversation()
                end)
            end

            if IsValid(self) then
                self:Face(ally, ally.InternalCurrentSoundDuration)

                timer.Simple(ally.InternalCurrentSoundDuration, function()
                    if !IsValid(self) then return end
                    self:CancelConversation()
                end)
            end
        end)
    end


    ZBaseDelayBehaviour( ZBaseRndTblRange(self.IdleSoundCooldown) )
end
--[[===============================================================================================]]