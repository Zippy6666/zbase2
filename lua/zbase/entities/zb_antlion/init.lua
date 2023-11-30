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


--]]==============================================================================================]]
function NPC:CustomInitialize()

end
--]]==============================================================================================]]