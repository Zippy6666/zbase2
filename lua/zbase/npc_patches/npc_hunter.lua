local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))

ZBasePatchTable[my_cls] = function( NPC )
    -- Fixes hunters being unable to hurt each other
    function NPC:Patch_DealDamage(dmg, ent)
        if ent:GetClass() == "npc_hunter" && !self:IsAlly(ent) && !self.DoingHunterDamageFix then
            self.DoingHunterDamageFix = true
            ent:TakeDamage(dmg:GetDamage(), self, self)
            return
        end
        self.DoingHunterDamageFix = nil
    end

    -- These are hunter specific fail schedules
    function NPC:Patch_IsFailSched(sched)
        return ZBaseESchedID("SCHED_HUNTER_FAIL_IMMEDIATE") == sched 
                || ZBaseESchedID("SCHED_ESTABLISH_LINE_OF_FIRE_FALLBACK") == sched
    end
end