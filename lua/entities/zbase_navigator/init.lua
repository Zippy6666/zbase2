include("shared.lua")


ENT.m_iClass = CLASS_NONE
ENT.ZBaseFaction = "neutral"
ENT.IsZBaseNavigator = true


-----------------------------------------------------------------------------------=#
function ENT:Initialize()
	self:SetModel( "models/Humans/Group01/Male_Cheaple.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetNotSolid(true)
	self:SetMoveType( MOVETYPE_STEP )
	self:CapabilitiesAdd( bit.bor(CAP_MOVE_GROUND, CAP_SKIP_NAV_GROUND_CHECK ))
	self:AddFlags(FL_NOTARGET)
    self:AddFlags(EFL_DONTBLOCKLOS)
    self:SetNoDraw(true)
end
-----------------------------------------------------------------------------------=#
function ENT:SelectSchedule()
	if IsValid(self.ForceEnemy) then
		self:AddEntityRelationship(self.ForceEnemy, D_HT, 99)
		self:SetEnemy(self.ForceEnemy)
		self:UpdateEnemyMemory(self.ForceEnemy, self.ForceEnemy:GetPos())
	end


	if istable(self.Sched) then
		self:StartSchedule(self.Sched)
	elseif isnumber(self.Sched) then
		self:SetSchedule(self.Sched)
	end


	local own = self:GetOwner()
	timer.Simple(0.5, function()
		if IsValid(self) && IsValid(own) then
			local waypoint = self:GetGoalPos()

			if waypoint:IsZero() then
				self:Remove()
			else
				own.AerialGoal = waypoint+Vector(0, 0, own.Fly_DistanceFromGround)
				debugoverlay.Sphere(waypoint, 35, 2, Color( 50, 155, 255, 100 ))
			end
		end
	end)
end
-----------------------------------------------------------------------------------=#