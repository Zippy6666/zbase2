local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))

-- ------------------------------------------------------------------------=#

--         -- Speech --
-- BEHAVIOUR.Speech = {
-- }
-- ------------------------------------------------------------------------=#
-- -- Return true to allow the behaviour to run, otherwise return false
-- function BEHAVIOUR.Speech:ShouldDoBehaviour( self )
--     return true
-- end
-- ------------------------------------------------------------------------=#
-- -- Called continiously as long as it should do the behaviour 
-- -- Write whatever the NPC is going to do here
-- -- Call ZBaseDelayBehaviour( seconds ) to delay the behaviour (cooldown)
-- function BEHAVIOUR.Speech:Run( self )

--     print("test")

--     local ene = self:GetEnemy()
--     local armed = IsValid(ene:GetActiveWeapon())

--     if !self:Visible(ene) then
--         self.IdleSounds_HasEnemy = "ZBaseElitePolice.IdleEnemy_Occluded"
--     elseif armed then
--         self.IdleSounds_HasEnemy = "ZBaseElitePolice.IdleEnemyArmed"
--     else
--         self.IdleSounds_HasEnemy = ""
--     end

--     if armed then
--         self.AlertSounds = "ZBaseElitePolice.Alert"
--     else
--         self.AlertSounds = "ZBaseElitePolice.IdleEnemyArmed"
--     end

--     if self:IsOnFire() then
--         self.DeathSounds = "ZBaseElitePolice.FireDeath" -- Sounds emitted on death
--     else
--         self.DeathSounds = "ZBaseElitePolice.FireDeath" -- Sounds emitted on death
--     end

-- end
-- ------------------------------------------------------------------------=#