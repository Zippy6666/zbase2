local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.Models = {"models/characters/hostage_04.mdl"}


NPC.StartHealth = 60 -- Max health


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "none"


--]]==============================================================================================]]
function NPC:CustomInitialize()

end
--]]==============================================================================================]]