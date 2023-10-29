local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.CanPatrol = false -- Use base patrol behaviour

-------------------------------------------------------------------------------------------------------------------------=#
    -- Select schedule (only used by SNPCs!)
function NPC:ZBaseSNPC_SelectSchedule()
	-- Example
	if IsValid(self:GetEnemy()) then
		self:SetSchedule(SCHED_CHASE_ENEMY)
	else
		self:SetSchedule(SCHED_IDLE_STAND)
	end
end
-------------------------------------------------------------------------------------------------------------------------=#