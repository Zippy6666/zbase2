local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.StartHealth = 30 -- Max health


-- Default engine blood color, set to DONT_BLEED if you want to use custom blood instead
NPC.BloodColor = BLOOD_COLOR_ANTLION -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "antlion"


NPC.GibMaterial = false
NPC.GibParticle = "AntlionGib"

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC


NPC.FootStepSounds = "NPC_Antlion.Footstep"


NPC.RagdollUseAltPositioning = true -- Try setting this to true if the ragdoll positioning is buggy


function NPC:OnInitCap()
    self:CapabilitiesRemove(CAP_INNATE_RANGE_ATTACK1)
end


function NPC:ShouldGib( dmginfo, hit_gr )
    if dmginfo:GetDamage() < 40 then return end

    local Gibs  = {
        self:CreateGib("models/gibs/antlion_gib_large_1.mdl", {offset=vector_origin}),
        self:CreateGib("models/gibs/antlion_gib_large_2.mdl", {offset=vector_origin}),
        self:CreateGib("models/gibs/antlion_gib_large_3.mdl", {offset=vector_origin}),
        self:CreateGib("models/gibs/antlion_gib_medium_1.mdl", {offset=vector_origin}),
        self:CreateGib("models/gibs/antlion_gib_medium_2.mdl", {offset=vector_origin}),
        self:CreateGib("models/gibs/antlion_gib_small_1.mdl", {offset=vector_origin}),
        self:CreateGib("models/gibs/antlion_gib_small_2.mdl", {offset=vector_origin}),   
    }

    for _, v in ipairs(Gibs) do
        if self.GibMaterial then
            v:SetMaterial(self.GibMaterial)
        end
        
        local phys = v:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(dmginfo:GetDamageForce()*0.1 + VectorRand()*200)
        end
    end

    ParticleEffect(self.GibParticle, self:GetPos(), self:GetAngles())
    self:EmitSound("NPC_Antlion.RunOverByVehicle")

    return true
end

