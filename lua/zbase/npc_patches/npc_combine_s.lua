local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )

    NPC.Patch_CanInterruptImportantVoiceSound = {
        ["COMBINE_PAIN0"] = true,
        ["COMBINE_PAIN1"] = true,
        ["COMBINE_PAIN2"] = true,
    }

    NPC.Patch_AIWantsToShoot_SCHED_Blacklist = {
        [ZBaseESchedID("SCHED_COMBINE_HIDE_AND_RELOAD")] = true,
    }

    
    function NPC:Patch_Init()
    
        self:SetSaveValue("m_fIsElite", false) -- No elites, should be handled by the user instead
        self:SetSaveValue("m_iNumGrenades", 0) -- No grenades

    end
    
    
    function NPC:Patch_CreateEnt( ent )

        -- Remove default grenades, if they spawn
        if ent:GetClass() == "npc_grenade_frag" && !ent.IsZBaseGrenade then
            ent:Remove()
        end
    
    end


    function NPC:Patch_IsFailSched(sched)

        if ZBaseESchedID("SCHED_COMBINE_COMBAT_FAIL") == sched or ZBaseESchedID("SCHED_COMBINE_TAKECOVER_FAILED") == sched then
            return true
        end

        return false

    end
    
end