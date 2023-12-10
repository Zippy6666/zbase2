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


--]]==============================================================================================]]
function NPC:CustomInitialize()
    if ZBCVAR.ZombieHeadcrabs:GetBool() then
        self:Zombie_GiveHeadCrabs()
    end

    if ZBCVAR.ZombieRedBlood:GetBool() then
        self:SetBloodColor(BLOOD_COLOR_RED)
    end
end
--]]==============================================================================================]]