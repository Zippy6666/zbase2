local NPC = ZBaseNPCs["npc_zbase"]


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
        if !v:IsNPC() then continue end

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

    -- Check if an entity or position is within a certain distance
    -- If tbl.within is given, return true if the entity is within x units from itself
    -- If tbl.away is given, return true if the entity is x units away from itself
    -- Example: self:ZBaseDist( self:GetEnemy(), {within=400, away=200} ) --> Returns true if enemy is 200 units away, but still within 400 units
function NPC:ZBaseDist( ent_or_pos, tbl )
    local dSqr

    if isvector(ent_or_pos) then
        dSqr = self:GetPos():DistToSqr(ent_or_pos)
    elseif IsValid(ent_or_pos) then
        dSqr = self:GetPos():DistToSqr(ent_or_pos:GetPos())
    end

    if !dSqr then return false end
    if tbl.away && dSqr < tbl.away^2 then return false end
    if tbl.within && dSqr > tbl.within^2 then return false end

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
--------------------------------------------------------------------------------=#


	-- Make the NPC face certain directions
	-- 'face' - A position or an entity to face, or a number representing the yaw.
    -- 'duration' - Face duration, if not set, you can run the function in think for example
    -- 'speed' - Turn speed, if not set, it will be the default turn speed
function NPC:Face( face, duration, speed )
	local function turn( yaw )
        if GetConVar("ai_disabled"):GetBool() then return end

        local turnSpeed = speed
        or (self.IsZBase_SNPC && self.m_fMaxYawSpeed)
        or 10
        
		self:SetIdealYawAndUpdate(yaw, turnSpeed)
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
    else
        faceFunc()
    end
end
--------------------------------------------------------------------------------=#

    -- Play an activity or sequence
    -- Note: NPCs cannot play sequences that aren't bound to an activity, SNPCs however, can do so.
    -- 'anim' - The sequence or activity to play, accepts sequences as strings
    -- 'faceEnemy' - Set to true to constantly face enemy while the animation is playing
    -- 'extraData' (table)
        -- extraData.face - Position or entity to constantly face
        -- extraData.speedMult - Speed multiplier for the animation
        -- extraData.cutOff - Stop the animation after this amount of time in seconds
        -- extraData.faceSpeed - Face turn speed
function NPC:PlayAnimation( anim, faceEnemy, extraData )
    extraData = extraData or {}

    local enemy = self:GetEnemy()
    local face = extraData.face or (faceEnemy && IsValid(enemy) && enemy) or nil

    self:InternalPlayAnimation(anim, extraData.cutOff, extraData.speedMult, SCHED_NPC_FREEZE, face, extraData.faceSpeed )
end
--------------------------------------------------------------------------------=#


    -- Just like entity:EmitSound(), except it will prevent certain sounds from playing over it
function NPC:EmitSound_Uninterupted( ... )
    ZBase_DontSpeakOverThisSound = true
    self:EmitSound(...)
    ZBase_DontSpeakOverThisSound = false
end
--------------------------------------------------------------------------------=#

    -- Does the base melee attack damage code
function NPC:MeleeAttackDamage()
    local dmgData = self.CurrentMeleeDMGData

    if !dmgData then
        dmgData = {
            dist=self.MeleeDamage_Distance,
            ang=self.MeleeDamage_Angle,
            type=self.MeleeDamage_Type,
            amt=self.MeleeDamage,
            hitSound=self.MeleeDamage_Sound,
            affectProps=self.MeleeDamage_AffectProps,
            name = self.MeleeAttackName,
            hitSoundProps = self.MeleeDamage_Sound_Prop,
        }
    end

    self:InternalMeleeAttackDamage(dmgData)
end
--------------------------------------------------------------------------------=#