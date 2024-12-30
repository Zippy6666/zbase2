local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )
    

    function NPC:Patch_DealDamage(dmg, ent)

        -- Fixes hunters being unable to hurt each other
        if ent:GetClass() == "npc_hunter" && !self:IsAlly(ent) && !self.DoingHunterDamageFix then

            self.DoingHunterDamageFix = true
            ent:TakeDamage(dmg:GetDamage(), self, self)
            return

        end
        
        self.DoingHunterDamageFix = nil
        
    end

    function NPC:Patch_TakeDamage( dmg )
        local infl = dmg:GetInflictor()

        if infl:IsValid() && infl:GetClass() == "prop_combine_ball" then
            self.RagdollApplyForce = false -- Don't fly a fkin mile
            self:InduceDeath(dmg, true)
        end
    end


    function NPC:Patch_IsFailSched(sched)

        return ZBaseESchedID("SCHED_HUNTER_FAIL_IMMEDIATE") == sched or ZBaseESchedID("SCHED_ESTABLISH_LINE_OF_FIRE_FALLBACK") == sched

    end
    
end