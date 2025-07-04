local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.StartHealth = 210 -- Max health

-- Default engine blood color, set to DONT_BLEED if you want to use custom blood instead
NPC.BloodColor = DONT_BLEED -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER
NPC.CustomBloodDecals = "ZBaseBloodSynth" -- String name of custom decal

NPC.DeathAnimations = {"death_stagger_e", "death_stagger_s", "death_stagger_se", "death_stagger_sw", "death_stagger_e"} -- Death animations to use, leave empty to disable the base death animation
NPC.DeathAnimation_StopAttackingMe = false -- Stop other NPCs from attacking this NPC when it is doing its death animation

-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "combine"

NPC.RagdollUseAltPositioning = true -- Try setting this to true if the ragdoll positioning is buggy

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC
NPC.IdleSounds = "ZBaseHunter.Idle"

NPC.HearDistMult = 2 -- Hearing distance multiplier when this addon is enabled: https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseHunter.HearSound"

NPC.ForceAvoidDanger = true -- Force this NPC to avoid dangers such as grenades
NPC.SeeDangerSounds = "ZBaseHunter.SeeDanger" -- Sounds emitted when the NPC spots a danger, such as a flaming barrel

NPC.FootStepSounds = "ZBaseHunter.Step"
NPC.LostEnemySound = "NPC_Hunter.FlankAnnounce"

NPC.DodgeAnimations = {
    Left = "dodge_w",
    Right = "dodge_e",
}

function NPC:CustomInitialize()
    self:AddAnimationEvent("dodge_w", 5, 100)
    self:AddAnimationEvent("dodge_e", 5, 100)
end

-- Your hook for handling custom defined LUA animation events
-- Add new animation events by calling:
-- self:AddAnimationEvent("your_animation", your_frame, your_event_id),
-- in CustomInitialize
function NPC:HandleLUAAnimationEvent(seq, ev)
    -- Dodge voice sound
    if (seq == "dodge_w" or seq == "dodge_e") && ev == 100 then
        self:EmitSound(self.SeeDangerSounds)
    end
end

function NPC:OnRangeThreatened( ent )
    -- Dodge AI when being threatened by range attack

    local Center = self:WorldSpaceCenter()
    local TraceRight = util.TraceLine({
        start = self:WorldSpaceCenter(),
        endpos = self:WorldSpaceCenter()+self:GetRight()*200,
        mask = MASK_NPCSOLID,
        filter = self,
    })
    local TraceLeft = util.TraceLine({
        start = self:WorldSpaceCenter(),
        endpos = self:WorldSpaceCenter()-self:GetRight()*200,
        mask = MASK_NPCSOLID,
        filter = self,
    })

    -- Play left/right dodge anim randomly if not blocked

    if math.random(1, 2) == 1 && !TraceRight.Hit then
        -- Right dodge
        self:PlayAnimation(self.DodgeAnimations.Right, false, {face=ent, speedMult=1.2, duration=1})

    elseif !TraceLeft.Hit then
        -- Left dodge
        self:PlayAnimation(self.DodgeAnimations.Left, false, {face=ent, speedMult=1.2, duration=1})

    end
end

function NPC:OnPlayAnimationFailed( seq )
    -- Death animation failed so do a death sound manually
    if self:DoingDeathAnimation() then
        self:EmitSound("NPC_Hunter.Death")
    end
end

-- Death animation code
function NPC:DeathAnimation_Animation()
    -- This is to prevent another death sound from playing when the hunter
    -- officially dies after the animation
    self.MuteDefaultVoice = true
    
    return self:PlayAnimation(table.Random(self.DeathAnimations), false, {
        speedMult=1,
        face=false,
        duration=0.75,
        noTransitions = true,
        freezeForever = true,
        onFinishFunc = function() 
            self:InduceDeath() 
        end
    })
end