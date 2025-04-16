local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))

ZBasePatchTable[my_cls] = function( NPC )
    -- Turrets don't use regular spawn flags
    -- if we were to give them the default ZBASE ones
    -- they would behave unexpectedly.
    -- For example, they won't shoot.
    NPC.Patch_DontApplyDefaultFlags = true
end