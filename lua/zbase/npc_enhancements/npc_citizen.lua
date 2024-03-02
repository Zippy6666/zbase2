local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))


ZBaseEnhancementTable[my_cls] = function( NPC )

    function NPC:ZBaseEnhancedThink()

        -- Fix medics trying to heal players when they are enemies --
        if IsValid(ene) && ene:IsPlayer() then
            self:SetSaveValue("m_flPlayerHealTime", 5)
        end


        -- self:Fire("RemoveFromPlayerSquad")

    end

end