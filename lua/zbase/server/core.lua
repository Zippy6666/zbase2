local NPC = ZBaseNPCs["npc_zbase"]

local VJ_Translation = {
    ["CLASS_COMBINE"] = "combine",
    ["CLASS_ZOMBIE"] = "zombie",
    ["CLASS_ANTLION"] = "antlion",
    ["CLASS_PLAYER_ALLY"] = "ally",
}

local VJ_Translation_Flipped = {
    ["combine"] = "CLASS_COMBINE",
    ["zombie"] = "CLASS_ZOMBIE",
    ["antlion"] = "CLASS_ANTLION",
    ["ally"] = "CLASS_PLAYER_ALLY",
}

---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseInit( tbl )

    -- Model
    if !table.IsEmpty(self.Models) then
        self:SetModel(table.Random(self.Models))
    end

    self:SetMaxHealth(self.StartHealth)
    self:SetHealth(self.StartHealth)
    self:SetMaxLookDistance(self.SightDistance)
    self:SetCurrentWeaponProficiency(self.WeaponProficiency)
    self:SetBloodColor(self.BloodColor)
    self:SetNWString("ZBaseName", self.Name)

    for _, v in ipairs(self.ExtraCapabilities) do
        self:CapabilitiesAdd(v)
    end

    self:CapabilitiesAdd(bit.bor(
        CAP_SQUAD,
        CAP_TURN_HEAD,
        CAP_ANIMATEDFACE,
        CAP_SKIP_NAV_GROUND_CHECK,
        CAP_FRIENDLY_DMG_IMMUNE
    ))

    self:ZBaseSetSaveValues()
    self:ZBaseSquad()

    ZBaseBehaviourInit( self )

    -- Better position
    if !self.IsZBase_SNPC then
        self:SetPos(self:GetPos()+Vector(0, 0, 20))
    end

    self.NextPainSound = CurTime()

    -- Custom init
    self:CustomInitialize()

end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnEmitSound( data )
    local val = self:CustomOnEmitSound( data )
    local squad = self:GetKeyValues().squadname

    if isstring(val) then
        return val
    elseif val == false then
        return false
    elseif squad != "" && ZBase_DontSpeakOverThisSound then
        -- Make sure squad doesn't speak over each other
        ZBaseSpeakingSquads[squad] = true
        timer.Create("ZBaseUnmute_"..squad, SoundDuration(data.SoundName), 1, function()
            ZBaseSpeakingSquads[squad] = nil
        end) 
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnKilledEnt( ent )
    if ent == self:GetEnemy() then
        self:EmitSound_Uninterupted(self.KilledEnemySound)
    end
    
    self:CustomOnKilledEnt( ent )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnHurt( dmg )
    if self.NextPainSound < CurTime() then
        self:EmitSound(self.PainSounds)
        self.NextPainSound = CurTime()+ZBaseRndTblRange( self.PainSoundCooldown )
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSquad()
    if self.ZBaseFaction == "none" then return end


    local squadName = self.ZBaseFaction.."1"
    local i = 1
    while true do
        local squadMemberCount = 0

        for _, v in ipairs(ZBaseNPCInstances) do
            if IsValid(v) && v:GetKeyValues().squadname == squadName then
                squadMemberCount = squadMemberCount+1
            end
        end

        if squadMemberCount >= 4 then
            i = i+1
            squadName = self.ZBaseFaction..i
        else
            break
        end
    end


    self:SetKeyValue("squadname", squadName)
    --self.ZBaseSquadName = squadName
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSetSaveValues()
    for k, v in pairs(self:GetTable()) do
        if string.StartWith(k, "m_") then
            self:SetSaveValue(k, v)
        end
    end
end
---------------------------------------------------------------------------------------------------------------------=#
local ReloadActs = {
    [ACT_RELOAD] = true,
    [ACT_RELOAD_SHOTGUN] = true,
    [ACT_RELOAD_SHOTGUN_LOW] = true,
    [ACT_RELOAD_SMG1] = true,
    [ACT_RELOAD_SMG1_LOW] = true,
    [ACT_RELOAD_PISTOL] = true,
    [ACT_RELOAD_PISTOL_LOW] = true,
}

function NPC:NewActivityDetected( act )
    -- Reload ZBase weapon sound:
    local wep = self:GetActiveWeapon()
    if ReloadActs[act] && IsValid(wep) && wep.IsZBaseWeapon && wep.NPCReloadSound != "" then
        wep:EmitSound(wep.NPCReloadSound)
    end

    self:CustomNewActivityDetected( act )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseAlertSound()
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown), self, "DoIdleEnemySound")
    
    timer.Simple(math.Rand(0, 1), function()
        if !IsValid(self) then return end
        self:EmitSound_Uninterupted(self.AlertSounds)
    end)
end
---------------------------------------------------------------------------------------------------------------------=#
-- function NPC:DoCurrentAnimation()
--     if !self.CurrentAnimation then return end


-- 	-- Animation stuff --
-- 	if isstring(self.CurrentAnimation) then

-- 		-- Sequence, try to convert to activity
-- 		local act = self:GetSequenceActivity(self:LookupSequence(self.CurrentAnimation))

-- 		if act != -1 then
-- 			-- Success, play as activity
-- 			self:SetActivity(act)
-- 		else
-- 			-- No activity for the sequence, set it directly instead of setting the activity 
-- 			self:SetSequence(self.CurrentAnimation)
-- 		end

-- 	elseif isnumber(self.CurrentAnimation) then

-- 		-- 'self.CurrentAnimation' is activity
-- 		self:SetActivity(self.CurrentAnimation)

-- 	end
-- 	-----------------------------=#

	
-- 	-- Facing stuff --
-- 	local face = self.SequenceFaceType
-- 	local enemy = self:GetEnemy()
-- 	local enemyPos = IsValid(enemy) && enemy:GetPos()

-- 	if face == "enemy" && enemyPos then
-- 		-- Face enemy
-- 		self.AnimFacePos = enemyPos
-- 	elseif face == "enemy_visible" && enemyPos && self:Visible(enemy) then
-- 		-- Face enemy visible
-- 		self.AnimFacePos = enemyPos
-- 	end

-- 	if face != "none" then
-- 		-- Face static direction
-- 		self:Face(self.AnimFacePos)
-- 	end
-- 	-----------------------------=#


-- 	-- Try to make sure NPC is still
-- 	self:SetMoveVelocity(Vector())
-- end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseThink()

    local ene = self:GetEnemy()

    if ene != self.Alert_LastEnemy then
        self.Alert_LastEnemy = ene

        if self.Alert_LastEnemy then
            self:StopSound(self.IdleSounds)
            self:ZBaseAlertSound()
        end
    end

    self:Relationships()
    -- self:DoCurrentAnimation()

    -- Activity change detection
    local act = self:GetActivity()
    if act && act != self.ZBaseCurrentACT then
        self.ZBaseCurrentACT = act
        self:NewActivityDetected( self.ZBaseCurrentACT )
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:SetRelationship( ent, rel )
    self:AddEntityRelationship(ent, rel, 99)
    if ent:IsNPC() then
        ent:AddEntityRelationship(self, rel, 99)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBase_VJFriendly( ent )
    if !ent.IsVJBaseSNPC then return false end

    for _, v in ipairs(ent.VJ_NPC_Class) do
        if VJ_Translation[v] == self.ZBaseFaction then return true end
    end

    return false
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:Relationship( ent )
    -- Me or the ent has faction neutral, like
    if self.ZBaseFaction == "neutral" or ent.ZBaseFaction=="neutral" then
        self:SetRelationship( ent, D_LI )
        return
    end

    -- My faction is none, hate everybody
    if self.ZBaseFaction == "none" then
        self:SetRelationship( ent, D_HT )
        return
    end

    -- Are their factions the same?
    if self.ZBaseFaction == ent.ZBaseFaction or self:ZBase_VJFriendly( ent ) then
        self:SetRelationship( ent, D_LI )
    else
        self:SetRelationship( ent, D_HT )
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:Relationships()

    if VJ_Translation_Flipped[self.ZBaseFaction] then
        self.VJ_NPC_Class = {VJ_Translation_Flipped[self.ZBaseFaction]}
    end

    for _, v in ipairs(ZBaseNPCInstances) do
        if !IsValid(v) then continue end
        if v != self then self:Relationship(v) end
    end

    for _, v in ipairs(ZBase_NonZBaseNPCs) do
        self:Relationship(v)
    end

    for _, v in ipairs(player.GetAll()) do
        self:Relationship(v)
    end

end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:HasCapability( cap )
    return bit.band(self:CapabilitiesGet(), cap)==cap
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:OnOwnedEntCreated( ent )
    self:CustomOnOwnedEntCreated( ent )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:InternalSetAnimation( anim )
	if isstring(anim) then

		-- Sequence, try to convert to activity
		local act = self:GetSequenceActivity(self:LookupSequence(anim))

		if act != -1 then
			-- Success, play as activity
			self:SetActivity(act)
		end

	elseif isnumber(anim) then

		self:SetActivity(anim)

	end
end
---------------------------------------------------------------------------------------------------------------------=#
