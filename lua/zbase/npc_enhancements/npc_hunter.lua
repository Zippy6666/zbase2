local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))
ZBaseEnhancementTable[my_cls] = function( NPC )
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedInit()
        -- self:SetAllowedEScheds({
        --     "SCHED_HUNTER_RANGE_ATTACK2",
        --     "SCHED_HUNTER_CHASE_ENEMY",
        --     "SCHED_HUNTER_CHARGE_ENEMY",
        --     "SCHED_HUNTER_MELEE_ATTACK1",
        --     "SCHED_HUNTER_STAGGER",
        --     "SCHED_HUNTER_COMBAT_FACE",
        --     "SCHED_HUNTER_FLANK_ENEMY",
        --     "SCHED_HUNTER_PATROL_RUN",
        -- })
    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedThink()
    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedDealDamage(dmg, ent)
        -- Fixes hunters being unable to hurt eachother
        if ent:GetClass() == "npc_hunter" && !self:IsAlly(ent) && !self.DoingHunterDamageFix then

            self.DoingHunterDamageFix = true
            ent:TakeDamage(dmg:GetDamage(), self, self)
            return

        end

        self.DoingHunterDamageFix = false
    end
    --]]============================================================================================================]]
end