local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))

ZBasePatchTable[my_cls] = function( NPC )
    
    function NPC:Patch_PreDeath( dmg )
        -- Must be called to get death notice + custom death run etc..
        hook.Run("OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor())

        -- Prevents default gibs from spawning when the helicopter dies
        -- Yes, both are needed
        self:SetHealth(math.huge)
        self:Remove()
    end

end