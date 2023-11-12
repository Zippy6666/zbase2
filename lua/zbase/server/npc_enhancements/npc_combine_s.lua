local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))

------------------------------------------------------------------------------------=#
hook.Add("OnEntityCreated", my_cls.."_zbaseenhanced", function( NPC ) timer.Simple(0.1, function()
    if !IsValid(NPC)
    or NPC:GetClass() != my_cls
    or !NPC.IsZBaseNPC then
        return
    end


    ------------------------------------------------------------------------------------=#
    function NPC:ZBaseEnhancedThink()
        -- Put squad slot to 1 if it doesn't have any
        -- Allows multiple combines in the same squad to fire at once
        if self:GetInternalVariable("m_iMySquadSlot") == -1 then
            self:SetSaveValue("m_iMySquadSlot", 1)
        end

        -- Stop running away dammit
        local sched = self:GetCurrentSchedule()
        if sched == 186 or sched == 102 then
            self:SetSchedule(SCHED_COMBAT_FACE)
        end
    end
    ------------------------------------------------------------------------------------=#

end) end)
------------------------------------------------------------------------------------=#