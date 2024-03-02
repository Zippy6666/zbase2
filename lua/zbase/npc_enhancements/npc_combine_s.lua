local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))


ZBaseEnhancementTable[my_cls] = function( NPC )
    
    
    function NPC:ZBaseEnhancedInit()
    
        -- Don't allow combines to be elites
        -- All bines should be able to throw grenades and ar2 altfire!!!!
        self.m_fIsElite = false
        self.m_iTacticalVariant = 1
        self.m_iNumGrenades = 0

        self:SetAllowedEScheds({
            "SCHED_COMBINE_COMBAT_FAIL",
            "SCHED_COMBINE_HIDE_AND_RELOAD",
            "SCHED_COMBINE_PRESS_ATTACK",
            "SCHED_COMBINE_RANGE_ATTACK1",
            "SCHED_COMBINE_TAKE_COVER_FROM_BEST_SOUND",
            "SCHED_COMBINE_RUN_AWAY_FROM_BEST_SOUND",
            "SCHED_COMBINE_TAKECOVER_FAILED",
            "SCHED_COMBINE_BUGBAIT_DISTRACTION",
            "SCHED_COMBINE_CHARGE_PLAYER",
            "SCHED_COMBINE_BURNING_STAND",
            "SCHED_COMBINE_COMBAT_FACE",
        })

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