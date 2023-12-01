local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))
ZBaseEnhancementTable[my_cls] = function( NPC )
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedInit()
    
        -- Don't allow combines to be elites
        -- All bines should be able to throw grenades and ar2 altfire!!!!
        self.m_fIsElite = false
        self.m_iTacticalVariant = 1

        self.ProhibitCustomEScheds = true
        self.AllowedCustomEScheds = {
            [270] = true,
            [100] = true,
            [92] = true,
            [93] = true,
            [98] = true,
            [103] = true,
        }

    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedThink()

        -- Put squad slot to 1 if it doesn't have any
        -- Allows multiple combines in the same squad to fire at once
        if self:GetInternalVariable("m_iMySquadSlot") == -1 then
            self:SetSaveValue("m_iMySquadSlot", 1)
        end

    end
    --]]============================================================================================================]]
end