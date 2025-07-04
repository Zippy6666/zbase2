local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))

ZBasePatchTable[my_cls] = function( NPC )
    -- Prevents default gibs from spawning when the helicopter dies
    function NPC:Patch_PreDeath( dmg )
        self:SetHealth(math.huge)
        hook.Run("OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor())
    end
end