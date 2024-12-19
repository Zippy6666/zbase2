local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )

    NPC.Patch_AIWantsToShoot_SCHED_Blacklist = {
        [ZBaseESchedID("SCHED_METROPOLICE_WARN_AND_ARREST_ENEMY")] = true,
        [ZBaseESchedID("SCHED_METROPOLICE_ARREST_ENEMY")] = true,
        [ZBaseESchedID("SCHED_METROPOLICE_DRAW_PISTOL")] = true,
    }

    function NPC:Patch_PreventGrenade()
        return !self.Patch_AIWantsToShoot_SCHED_Blacklist[self:GetCurrentSchedule()]
    end

end