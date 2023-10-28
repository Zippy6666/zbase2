local NPC = FindZBaseTable(debug.getinfo(1,'S'))


        -- GENERAL --

-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {}

NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.BloodColor = BLOOD_COLOR_RED -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER	

NPC.SightDistance = 7000 -- Sight distance
NPC.StartHealth = 100 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour

NPC.ZBaseFaction = "none" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"

-- Hitgroups with armor:
NPC.HasArmor = {
    [HITGROUP_GENERIC] = false,
    [HITGROUP_HEAD] = false,
    [HITGROUP_CHEST] = false,
    [HITGROUP_STOMACH] = false,
    [HITGROUP_LEFTARM] = false,
    [HITGROUP_RIGHTARM] = false,
    [HITGROUP_LEFTLEG] = false,
    [HITGROUP_RIGHTLEG] = false,
    [HITGROUP_GEAR] = false,
}
NPC.ArmorPenChance = 4 -- 1/x Chance that the armor is penetrated
NPC.ArmorAlwaysPenDamage = 40 -- Always penetrate the armor if the damage is more than this
NPC.ArmorPenDamageMult = 1.5 -- Multiply damage by this amount if a armored hitgroup is penetrated

-- Extra capabilities
-- List of capabilities: https://wiki.facepunch.com/gmod/Enums/CAP
NPC.ExtraCapabilities = {
    CAP_OPEN_DOORS, -- Can open regular doors
    CAP_MOVE_JUMP, -- Can jump1
}

 -- Keyvalues
NPC.KeyValues = {} -- Ex. NPC.KeyValues = {SquadName="cool squad", citizentype=CT_REBEL}

NPC.CallForHelp = true -- Can this NPC call their faction allies for help (even though they aren't in the same squad)?
NPC.CallForHelpDistance = 3000 -- Call for help distance

---------------------------------------------------------------------------------------------------------------------=#



        -- CUSTOM SOUNDS --
        -- Use sound scripts to alter pitch and level etc..

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC, use ZBaseEmitSound instead of EmitSound if this is set to true!
NPC.UseCustomSounds = false -- Should the NPC be able to use custom sounds?

NPC.AlertSounds = "" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "" -- Sounds emitted while there is no enemy
NPC.IdleSounds_HasEnemy = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "" -- Sounds emitted on hurt
NPC.DeathSounds = "" -- Sounds emitted on death

---------------------------------------------------------------------------------------------------------------------=#



        -- Functions you can change --



---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the NPC is created --
function NPC:CustomInitialize() end
---------------------------------------------------------------------------------------------------------------------=#

    -- Called continiously --
function NPC:CustomThink() end
---------------------------------------------------------------------------------------------------------------------=#

    -- On NPC hurt, dmginfo:ScaleDamage(0) to prevent damage --
    -- HitGroup = HITGROUP_GENERIC || HITGROUP_HEAD || HITGROUP_CHEST || HITGROUP_STOMACH || HITGROUP_LEFTARM
    -- || HITGROUP_RIGHTARM || HITGROUP_LEFTLEG || HITGROUP_RIGHTLEG || HITGROUP_GEAR
function NPC:CustomTakeDamage( dmginfo, HitGroup ) end
---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the NPC hurts an entity, return true to prevent damage --
function NPC:DealDamage( victimEnt, dmginfo ) end
---------------------------------------------------------------------------------------------------------------------=#

    -- Accept input, return true to prevent --
function NPC:CustomAcceptInput( input, activator, caller, value ) end
---------------------------------------------------------------------------------------------------------------------=#

    -- On Armor hit, dmginfo:ScaleDamage(0) to prevent damage --
    -- HitGroup = HITGROUP_GENERIC || HITGROUP_HEAD || HITGROUP_CHEST || HITGROUP_STOMACH || HITGROUP_LEFTARM
    -- || HITGROUP_RIGHTARM || HITGROUP_LEFTLEG || HITGROUP_RIGHTLEG || HITGROUP_GEAR
function NPC:HitArmor( dmginfo, HitGroup )

    if dmginfo:GetDamage() >= self.ArmorAlwaysPenDamage then
        dmginfo:ScaleDamage(self.ArmorPenDamageMult)
        return
    end

    if math.random(1, self.ArmorPenChance) != 1 then
        local spark = ents.Create("env_spark")
        spark:SetKeyValue("spawnflags", 256)
        spark:SetKeyValue("TrailLength", 1)
        spark:SetKeyValue("Magnitude", 1)
        spark:SetPos(dmginfo:GetDamagePosition())
        spark:SetAngles(-dmginfo:GetDamageForce():Angle())
        spark:Spawn()
        spark:Activate()
        spark:Fire("SparkOnce")
        SafeRemoveEntityDelayed(spark, 0.1)
        self:EmitSound("ZBase.Ricochet")
        dmginfo:ScaleDamage(0)
    else
        dmginfo:ScaleDamage(self.ArmorPenDamageMult)
    end

end
---------------------------------------------------------------------------------------------------------------------=#




        -- Functions you can call --




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



        -- DON'T TOUCH ANYTHING BELOW HERE --



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
function NPC:ZBaseInit( name )

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
    self:SetPos(self:GetPos()+Vector(0, 0, 20))

    -- Custom init
    self:CustomInitialize()

end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSquad()
    local squadName = self.ZBaseFaction.."1"
    local i = 1

    while true do
        local squadMemberCount = 0

        for _, v in ipairs(ZBaseNPCInstances) do
            if v.ZBaseSquadName == squadName then
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
    self.ZBaseSquadName = squadName
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseSetSaveValues()
    for k, v in pairs(self:GetTable()) do
        if string.StartWith(k, "m_") && self:GetInternalVariable(k) then
            local success = self:SetSaveValue(k, v)
            print(k, "set to", v, "success = ", success)
        end
    end
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseThink()

    self:Relationships()

    if !IsValid(self:GetEnemy()) then
        self.AlertSound_LastEnemy = NULL
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

    for _, v in ipairs(ZBase_NonZBaseNPCs) do
        if v != self then self:Relationship(v) end
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
