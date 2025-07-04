local my_cls                    = ZBasePatchNPCClass(debug.getinfo(1,'S'))
local SF_MANHACK_USE_AIR_NODES  = 262144

ZBasePatchTable[my_cls] = function( NPC )
    -- Manhacks use air nodes
    function NPC:Patch_PreSpawn()
        self:CONV_AddSpawnFlags(SF_MANHACK_USE_AIR_NODES)
    end
end