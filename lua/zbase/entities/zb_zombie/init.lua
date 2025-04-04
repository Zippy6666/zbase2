local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.StartHealth = 60 -- Max health


NPC.MoveSpeedMultiplier = 1.33 -- Multiply the NPC's movement speed by this amount (ground NPCs)


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "zombie"


-- Default engine blood color, set to DONT_BLEED if you want to use custom blood instead
NPC.BloodColor = BLOOD_COLOR_ZOMBIE -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER


NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC


NPC.TorsoModel = "models/Zombie/Classic_torso.mdl"
NPC.LegsModel = "models/Zombie/Classic_legs.mdl"


function NPC:CustomPreSpawn()
    if ZBCVAR.ZombieRedBlood:GetBool() then
        self.BloodColor = BLOOD_COLOR_RED
    end
end


function NPC:CustomInitialize()
    if ZBCVAR.ZombieHeadcrabs:GetBool() then
        self:Zombie_GiveHeadCrabs()
    end
end


function NPC:ShouldGib( dmginfo, hit_gr )
    if !(self.NPCName=="zb_zombie" or self.NPCName=="zb_zombine" or self.NPCName=="zb_fastzombie") then
        return
    end

    if dmginfo:IsDamageType(DMG_NEVERGIB) then
        return false
    end

    if dmginfo:GetDamage() < 60 or (dmginfo:IsBulletDamage() && hit_gr != HITGROUP_CHEST && hit_gr != HITGROUP_STOMACH && hit_gr != HITGROUP_GENERIC) then
        return false
    end

    local Gib1 = self:CreateGib(self.TorsoModel, {offset=Vector(0, 0, 0), IsRagdoll=true, SmartPositionRagdoll=true})
    local Gib2 = self:CreateGib(self.LegsModel, {offset=Vector(0, 0, 0), IsRagdoll=true, SmartPositionRagdoll=true})
    local bloodColor = self:GetBloodColor()

    if IsValid(Gib1) then
        -- Headcrab for gib
        Gib1:SetBodygroup(1, self:GetBodygroup(1))
        
        Gib1:SetSkin(self:GetSkin())
        
        if bloodColor==BLOOD_COLOR_RED then
            ParticleEffectAttach("blood_advisor_puncture_withdraw", PATTACH_POINT_FOLLOW, Gib1, 0)
        elseif bloodColor == BLOOD_COLOR_ZOMBIE then
            ParticleEffectAttach("blood_zombie_split", PATTACH_POINT, Gib1, 0)
        end
    end

    if IsValid(Gib2) then
        Gib2:SetSkin(self:GetSkin())

        if bloodColor==BLOOD_COLOR_RED then
            ParticleEffectAttach("blood_advisor_puncture_withdraw", PATTACH_POINT_FOLLOW, Gib2, 0)
        elseif bloodColor == BLOOD_COLOR_ZOMBIE then
            ParticleEffectAttach("blood_zombie_split", PATTACH_POINT, Gib2, 0)
        end
    end

    return true
end