local NPC = FindZBaseTable(debug.getinfo(1,'S'))


-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {
    "models/player/combine_soldier.mdl",
    "models/player/combine_soldier_prisonguard.mdl",
    "models/player/combine_super_soldier.mdl",
    "models/player/police.mdl",
}


NPC.StartHealth = 100 -- Max health


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "combine"