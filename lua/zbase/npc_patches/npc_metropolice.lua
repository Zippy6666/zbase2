local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))

ZBasePatchTable[my_cls] = function( NPC )
    NPC.Patch_CanInterruptImportantVoiceSound = {
        ["METROPOLICE_PAIN0 "] = true,
        ["METROPOLICE_PAIN1 "] = true,
        ["METROPOLICE_PAIN2 "] = true,
        ["METROPOLICE_PAIN_LIGHT0"] = true,
        ["METROPOLICE_PAIN_HEAVY0"] = true,
        ["METROPOLICE_PAIN_HEAVY1"] = true,
        ["METROPOLICE_PAIN_HEAVY2"] = true,
        ["METROPOLICE_PAIN_HEAVY3"] = true,
    }

    -- Don't attack while in these schedules
    NPC.Patch_AIWantsToShoot_SCHED_Blacklist = {
        [ZBaseESchedID("SCHED_METROPOLICE_WARN_AND_ARREST_ENEMY")] = true,
        [ZBaseESchedID("SCHED_METROPOLICE_ARREST_ENEMY")] = true,
        [ZBaseESchedID("SCHED_METROPOLICE_DRAW_PISTOL")] = true,
    }

    function NPC:Patch_PreventGrenade()
        return self.Patch_AIWantsToShoot_SCHED_Blacklist[self:GetCurrentSchedule()]
    end
end