local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )

    function NPC:Patch_Think()

        -- Fix medics trying to heal players when they are enemies --
        if IsValid(ene) && ene:IsPlayer() then
            self:SetSaveValue("m_flPlayerHealTime", 5)
        end

    end

end