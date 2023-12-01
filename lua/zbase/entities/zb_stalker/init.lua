local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.StartHealth = 70 -- Max health


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "combine"


-- Stalker internal variables
NPC.m_iPlayerAggression = 1
NPC.m_eBeamPower = 2


--]]==============================================================================================]]
function NPC:CustomInitialize()
end
--]]==============================================================================================]]
function NPC:CustomThink()
end
--]]==============================================================================================]]