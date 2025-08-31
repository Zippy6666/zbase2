-- local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))

-- BEHAVIOUR.Spark = {
--     MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
--     MustNotHaveEnemy = false, --  Don't run the behaviour if the NPC doesn't have an enemy
--     MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
--     MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
-- }

-- -- Return true to allow the behaviour to run, otherwise return false
-- function BEHAVIOUR.Spark:ShouldDoBehaviour( self )
--     -- Already active
--     if timer.Exists("AirlionSpark"..self:EntIndex()) then
--         return false
--     end

--     -- Spark within x units
--     return self:ZBaseDist(self:GetEnemy(), {within=300})
-- end

-- -- Called before running the behaviour
-- -- Return a number to suppress and delay the behaviour by said number (in seconds)
-- function BEHAVIOUR.Spark:Delay( self )
-- end

-- -- Called continiously as long as it should do the behaviour 
-- -- Write whatever the NPC is going to do here
-- -- Call ZBaseDelayBehaviour( seconds ) to out the behaviour on a cooldown
-- function BEHAVIOUR.Spark:Run( self )
--     local ene = self:GetEnemy()

--     -- Initial effect
--     local pos = self:GetPos()
--     effects.BeamRingPoint( pos, 1, 0, 500, 20, 1, col )
--     effects.BeamRingPoint( pos, 0.25, 0, 1000, 30, 1, col )

--     local host = self
--     local nextHost = ene
--     local timerName = "AirlionSpark"..self:EntIndex()
--     timer.Create(timerName, 1, 0, function()
--         -- Handle self dead logic when spark is still active
--         if !IsValid(self) then
--             timer.Remove(timerName)
--             return
--         end

--         local mindist = math.huge
--         local bNewHost = false
--         for _, ent in ipairs(ents.FindInSphere(host:GetPos(), 500)) do
--             -- Spark cannot jump from the host back to itself
--             if ent == host then
--                 continue
--             end

--             -- Jump between solid entities
--             if ent:IsSolid() then
--                 local dist = ent:GetPos():DistToSqr(host:GetPos())

--                 if dist < mindist then
--                     mindist = dist
--                     nextHost = ent
--                     bNewHost = true
--                 end
--             end
--         end

--         -- No new host, spark dies
--         if bNewHost == false then
--             timer.Remove(timerName)
--             return
--         end

--         util.ParticleTracerEx( "vortigaunt_beam", host:GetPos(), nextHost:GetPos(), false, host:EntIndex(), 0 )
--         effects.BeamRingPoint( host:GetPos(), 0.4, 0, 100, 20, 1, col )
--         effects.BeamRingPoint( nextHost:GetPos(), 0.4, 100, 0, 20, 1, col )

--         host = nextHost
--     end)
-- end