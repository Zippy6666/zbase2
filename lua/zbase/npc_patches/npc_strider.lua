local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )
    

    function NPC:Patch_OnTakeDamage(dmg)
        local attacker = dmg:GetAttacker()

        -- Strider magnade death
        if IsValid(attacker) && attacker:GetClass()=="weapon_striderbuster" then
            self:Fire("break")
        end
    end
    
    
end
