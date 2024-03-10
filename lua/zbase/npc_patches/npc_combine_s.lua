local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )
    
    
    function NPC:ZBaseEnhancedInit()
    
        self:SetSaveValue("m_fIsElite", false) -- No elites, should be handled by the user instead
        self:SetSaveValue("m_iNumGrenades", 0) -- No grenades

    end
    
    
    function NPC:ZBaseEnhancedCreateEnt( ent )

        -- Remove default grenades, if they spawn
        if ent:GetClass() == "npc_grenade_frag" && !ent.IsZBaseGrenade then
            ent:Remove()
        end
    
    end
    
    
end