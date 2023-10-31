local NPC = FindZBaseTable(debug.getinfo(1,'S'))


        -- DON'T TOUCH ANYTHING HERE --


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
    if self.UseCustomSounds && self.NextPainSound < CurTime() then
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
            if v:GetKeyValues().squadname == squadName then
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
function NPC:NewActivityDetected( act )
    self:CustomNewActivityDetected( act )
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseAlertSound()
    self:EmitSound_Uninterupted(self.AlertSounds)
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown), self, "DoIdleEnemySound")
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseThink()
    local ene = self:GetEnemy()


    -- Alert sound
    if ene != self.LastEnemy then
        self.LastEnemy = ene

        if self.LastEnemy then
            self:ZBaseAlertSound()
        end
    end


    self:Relationships()


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

    if self.ZBaseFaction == "none" then
        self:SetRelationship( ent, D_HT )
        return
    end

    if self.ZBaseFaction == ent.ZBaseFaction then
        self:SetRelationship( ent, D_LI )
        return
    end

    if (self:ZBase_VJFriendly( ent ) or self.ZBase_Class == ent.ZBase_Class) then
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
