local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))

ZBasePatchTable[my_cls] = function( NPC )
    -- Pain sounds that can interrupt other prio voice sounds
    NPC.Patch_CanInterruptImportantVoiceSound = {
        ["COMBINE_PAIN0"] = true,
        ["COMBINE_PAIN1"] = true,
        ["COMBINE_PAIN2"] = true,
    }

    function NPC:Patch_Init()
        -- No elites, should be handled by the user instead
        self:SetSaveValue("m_fIsElite", false)

        -- No grenades, use ZBase's system instead
        self:SetSaveValue("m_iNumGrenades", 0) 

        -- Deprecated thing, used still by some mods
        -- Add ACT_CROUCHIDLE as weapon attack anim
        self.ExtraFireWeaponActivities[ACT_CROUCHIDLE] = true
    end
    
    -- Remove default grenades, if they spawn
    function NPC:Patch_CreateEnt( ent )
        if ent:GetClass() == "npc_grenade_frag" && !ent.IsZBaseGrenade then
            ent:Remove()
        end
    end

    -- Deprecated stuff, still used by some ZBase addons
    -- Don't shoot if doing this sched
    NPC.Patch_AIWantsToShoot_SCHED_Blacklist = {
        [ZBaseESchedID("SCHED_COMBINE_HIDE_AND_RELOAD")] = true,
    }
    function NPC:Patch_IsFailSched(sched)
        -- Detect fail scheds native to combine
        if ZBaseESchedID("SCHED_COMBINE_COMBAT_FAIL") == sched or ZBaseESchedID("SCHED_COMBINE_TAKECOVER_FAILED") == sched then
            return true
        end
        return false
    end
end