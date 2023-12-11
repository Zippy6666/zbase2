local NPC = FindZBaseTable(debug.getinfo(1,'S'))


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "test"


NPC.NoWeapon_Scared = true -- Should it run away from the enemy if it doesn't have a weapon?