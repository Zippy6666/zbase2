local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )
    

    function NPC:ZBaseEnhancedDealDamage(dmg, ent)

        -- Fixes hunters being unable to hurt each other
        if ent:GetClass() == "npc_hunter" && !self:IsAlly(ent) && !self.DoingHunterDamageFix then

            self.DoingHunterDamageFix = true
            ent:TakeDamage(dmg:GetDamage(), self, self)
            return

        end


        self.DoingHunterDamageFix = false
        
    end
    
    
end