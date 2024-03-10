local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )
    
    
    function NPC:ZBaseEnhancedInit()
    
        -- Don't allow combines to be elites
        -- All bines should be able to throw grenades and ar2 altfire!!!!
        self.m_fIsElite = false
        self.m_iTacticalVariant = 1
        self.m_iNumGrenades = 0

    end



    function NPC:ZBaseEnhancedThink()

        -- Put squad slot to 1 if it doesn't have any
        -- Allows multiple combines in the same squad to fire at once
        if self:GetInternalVariable("m_iMySquadSlot") == -1 then
            self:SetSaveValue("m_iMySquadSlot", 1)
        end


        -- Keep shootin boye
        self:SetSaveValue("m_nShots", 2)

    end
    
    
    function NPC:ZBaseEnhancedCreateEnt( ent )
        -- Remove default grenades
        if ent:GetClass() == "npc_grenade_frag" && !ent.IsZBaseGrenade then
            ent:Remove()
        end
    end
    
    
end