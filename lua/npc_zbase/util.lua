local NPC = FindZBaseTable(debug.getinfo(1,'S'))


        -- These are functions you can call! Don't change them! --

---------------------------------------------------------------------------------------------------------------------=#

    -- Check if an entity is allied with the NPC
function NPC:IsAlly( ent )
    if self.ZBaseFaction == "none" then return false end
    return ent.ZBaseFaction == self.ZBaseFaction
end
---------------------------------------------------------------------------------------------------------------------=#

    -- Get the nearest allied NPC/ent in a certain radius
    -- Returns nil if none was found
function NPC:GetNearestAlly( radius )
    local mindist
    local ally

    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if v == self then continue end

        if self:IsAlly(v) then
            local dist = self:GetPos():DistToSqr(v:GetPos())

            if !mindist or dist < mindist then
                mindist = dist
                ally = v
            end
        end
    end

    return ally
end
---------------------------------------------------------------------------------------------------------------------=#

    -- Check if an entity is within a certain distance
    -- If maxdist is given, return true if the entity is within x units from itself
    -- If mindist is given, return true if the entity is x units away from itself
function NPC:WithinDistance( ent, maxdist, mindist )
    if !IsValid(ent) then return false end

    local dSqr = self:GetPos():DistToSqr(ent:GetPos())
    if mindist && dSqr < mindist^2 then return false end
    if maxdist && dSqr > maxdist^2 then return false end

    return true
end
---------------------------------------------------------------------------------------------------------------------=#

    -- Check if the NPC is facing an entity
function NPC:IsFacing( ent )
    if !IsValid(ent) then return false end

    local ang = (ent:GetPos() - self:GetPos()):Angle()
    local yawDif = math.abs(self:WorldToLocalAngles(ang).Yaw)

    return yawDif < 22.5
end
---------------------------------------------------------------------------------------------------------------------=#

/*
	-- self:PlayAnimation( anim, duration, face ) --
	anim - String sequence name, or an activity (https://wiki.facepunch.com/gmod/Enums/ACT).
	duration - Duration that it won't allow the sequence to be interupted.
	face - What direction will it face when doing the sequence?
		"none" - The SNPC will face whatever direction it wants to (lets you change it manually)
		"lock" - The SNPC will constantly face the direction the sequence started with
		"enemy" - The SNPC will face the enemy if it has one
		"enemy_visible" - Same as enemy, but the enemy has to be visible

*/
function NPC:PlayAnimation( anim, duration, face )

	if !face then face = "none" end
	self.SequenceFaceType = face
	self.AnimFacePos = self:GetPos()+self:GetForward()*100

	self.CurrentAnimation = anim

	if isstring(anim) then

		local act = self:GetSequenceActivity(self:LookupSequence(anim))
		if act == -1 then
			self:ResetSequence(self.CurrentAnimation)
		end
	
	else

		self:ResetIdealActivity(anim)
	
	end

	self:StopAndPreventSelectSchedule( duration )

	timer.Create("ZNPC_StopPlayAnimation"..self:EntIndex(), duration, 1, function()
		if !IsValid(self) then return end
		self.CurrentAnimation = nil
		self.SequenceFaceType = nil
		self.AnimFacePos = nil
		self:ResetIdealActivity(ACT_IDLE) -- Helps reseting the animation
	end)

end
--------------------------------------------------------------------------------=#

/*
	-- self:Face( face ) --
    -- You probably only want to use this for SNPCs
	face - A position or an entity to face, or a number representing the yaw.
    duration - Face duration, does not have to be set (you can run this function in think)
*/
function NPC:Face( face, duration )

	local function turn( yaw )

		self:SetIdealYawAndUpdate(yaw)

		-- Turning aid
		if self:IsMoving() then
			local myAngs = self:GetAngles()
			local newAng = Angle(myAngs.pitch, yaw, myAngs.roll)
			self:SetAngles(LerpAngle(self.m_fMaxYawSpeed/100, myAngs, newAng))
		end
		
	end


    local faceFunc
	if isnumber(face) then
		faceFunc = function() turn(face) end
	elseif IsValid(face) then
		faceFunc = function() turn( (face:GetPos() - self:GetPos()):Angle().y ) end
	elseif isvector(face) then
		faceFunc = function() turn( (face - self:GetPos()):Angle().y ) end
	end

    if !faceFunc then return end


    if duration then
        self.TimeUntilStopFace = CurTime()+duration

        timer.Create("ZBaseFace"..self:EntIndex(), 0, 0, function()
            if !IsValid(self) or self.TimeUntilStopFace < CurTime() then
                timer.Remove("ZBaseFace"..self:EntIndex())
                return
            end

            faceFunc()
        end)
    end

end
--------------------------------------------------------------------------------=#

    -- Just like entity:EmitSound(), except it will prevent future idle sounds and such from playing over it
    -- https://wiki.facepunch.com/gmod/Entity:EmitSound
function NPC:EmitSound_Uninterupted( ... )
    ZBase_DontSpeakOverThisSound = true
    self:EmitSound(...)
    ZBase_DontSpeakOverThisSound = false
end
--------------------------------------------------------------------------------=#