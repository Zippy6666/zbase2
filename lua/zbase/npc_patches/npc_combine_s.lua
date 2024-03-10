local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )
    
    
    function NPC:ZBaseEnhancedInit()
    
        self:SetSaveValue("m_fIsElite", false) -- No elites, should be handled by the user instead
        self:SetSaveValue("m_iNumGrenades", 0) -- No grenades

    end



    function NPC:ZBaseEnhancedThink()

        -- Put squad slot to 1 if it doesn't have any
        -- Allows multiple combines in the same squad to fire at once
        if self:GetInternalVariable("m_iMySquadSlot") == -1 then
            self:SetSaveValue("m_iMySquadSlot", 1)
        end


        -- Keeps them shooting
        self:SetSaveValue("m_nShots", 2)

    end
    
    
    function NPC:ZBaseEnhancedCreateEnt( ent )

        -- Remove default grenades, if they spawn
        if ent:GetClass() == "npc_grenade_frag" && !ent.IsZBaseGrenade then
            ent:Remove()
        end
    
    end
    
    
end