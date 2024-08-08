local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )
    

    NPC.Patch_DontApplyDefaultFlags = true
    NPC.Patch_SkipDeathRoutine = true
    

end