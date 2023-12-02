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

        self:SetAllowedEScheds({
            "SCHED_COMBINE_COMBAT_FAIL",
            "SCHED_COMBINE_HIDE_AND_RELOAD",
            "SCHED_COMBINE_PRESS_ATTACK",
            "SCHED_COMBINE_RANGE_ATTACK1",
            "SCHED_COMBINE_TAKE_COVER_FROM_BEST_SOUND",
            "SCHED_COMBINE_RUN_AWAY_FROM_BEST_SOUND",
            "SCHED_COMBINE_GRENADE_COVER1",
            "SCHED_COMBINE_TOSS_GRENADE_COVER1",
            "SCHED_COMBINE_TAKECOVER_FAILED",
            "SCHED_COMBINE_GRENADE_AND_RELOAD",
            "SCHED_COMBINE_BUGBAIT_DISTRACTION",
            "SCHED_COMBINE_DROP_GRENADE",
            "SCHED_COMBINE_CHARGE_PLAYER",
            "SCHED_COMBINE_BURNING_STAND",
            "SCHED_COMBINE_AR2_ALTFIRE",
            "SCHED_COMBINE_FORCED_GRENADE_THROW",
            "SCHED_COMBINE_MOVE_TO_FORCED_GREN_LOS",
        })
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