local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))
ZBaseEnhancementTable[my_cls] = function( NPC )
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedInit()

        local MyModel = table.Random(self.NPCTable.Models)
        if MyModel then
            self:SetModel(MyModel)
        end

        self:SetAllowedEScheds({
            "SCHED_METROPOLICE_WAKE_ANGRY",
            "SCHED_METROPOLICE_CHASE_ENEMY",
            "SCHED_METROPOLICE_ESTABLISH_LINE_OF_FIRE",
            "SCHED_METROPOLICE_DRAW_PISTOL",
            "SCHED_METROPOLICE_DEPLOY_MANHACK",
            "SCHED_METROPOLICE_BURNING_RUN",
            "SCHED_METROPOLICE_BURNING_STAND",
            "SCHED_METROPOLICE_SMG_NORMAL_ATTACK",
            "SCHED_METROPOLICE_SMG_BURST_ATTACK",
            "SCHED_METROPOLICE_WARN_AND_ARREST_ENEMY",
            "SCHED_METROPOLICE_ARREST_ENEMY",
            "SCHED_METROPOLICE_ENEMY_RESISTING_ARREST",
            "SCHED_METROPOLICE_WARN_TARGET",
            "SCHED_METROPOLICE_HARASS_TARGET",
            "SCHED_METROPOLICE_SUPPRESS_TARGET",
            "SCHED_METROPOLICE_RETURN_FROM_HARASS",
            "SCHED_METROPOLICE_SHOVE",
            "SCHED_METROPOLICE_ACTIVATE_BATON",
            "SCHED_METROPOLICE_DEACTIVATE_BATON",
            "SCHED_METROPOLICE_SMASH_PROP",
        })

    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedThink()
    
    end
    --]]============================================================================================================]]
end