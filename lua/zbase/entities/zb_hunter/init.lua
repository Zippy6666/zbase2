local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.StartHealth = 210 -- Max health


-- Default engine blood color, set to DONT_BLEED if you want to use custom blood instead
NPC.BloodColor = DONT_BLEED -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER
NPC.CustomBloodParticles = false -- Table of custom particles
NPC.CustomBloodDecals = "ZBaseBloodSynth" -- String name of custom decal


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "combine"


    -- Death animations to use, leave empty to disable the base death animation
NPC.DeathAnimations = {
    "death_stagger_e",
    "death_stagger_s",
    "death_stagger_w",
}
NPC.DeathAnimationSpeed = 1.25 -- Speed of the death animation
NPC.DeathAnimationChance = 1 --  Death animation chance 1/x
NPC.DeathAnimationDuration = false -- Duration of death animation
NPC.RagdollUseAltPositioning = true -- Try setting this to true if the ragdoll positioning is buggy


NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC
NPC.IdleSounds = "ZBaseHunter.Idle"

NPC.HearDistMult = 2 -- Hearing distance multiplier when this addon is enabled: https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseHunter.HearSound"


NPC.ForceAvoidDanger = true -- Force this NPC to avoid dangers such as grenades
NPC.SeeDangerSounds = "ZBaseHunter.SeeDanger" -- Sounds emitted when the NPC spots a danger, such as a flaming barrel


NPC.FootStepSounds = "ZBaseHunter.Step"


NPC.DodgeAnimations = {
    Left = "dodge_w",
    Right = "dodge_e",
}


local HUNTER_DODGE_LEFT = 1
local HUNTER_DODGE_RIGHT = 2



function NPC:OnRangeThreatened( ent )
    local Center = self:WorldSpaceCenter()


    local TraceRight = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos()+self:GetRight()*200,
        mask = MASK_NPCSOLID,
        filter = self,
    })


    local TraceLeft = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos()-self:GetRight()*200,
        mask = MASK_NPCSOLID,
        filter = self,
    })


    if math.random(1, 2) == 1 && !TraceRight.Hit then

        self:PlayAnimation(self.DodgeAnimations.Right, false, {face=ent, speedMult=1.3})

    elseif !TraceLeft.Hit then

        self:PlayAnimation(self.DodgeAnimations.Left, false, {face=ent, speedMult=1.3})
    end


    self:EmitSound(self.SeeDangerSounds)


end

