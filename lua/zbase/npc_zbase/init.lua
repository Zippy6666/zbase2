local NPC = FindZBaseTable(debug.getinfo(1,'S'))


-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {}


    -- Functions you can change --

---------------------------------------------------------------------------------------------------------------------=#
    -- Called when the NPC is created --
function NPC:CustomInitialize() end
---------------------------------------------------------------------------------------------------------------------=#
    -- Called every tick --
function NPC:CustomThink() end
---------------------------------------------------------------------------------------------------------------------=#
    -- On NPC hurt, return true to prevent damage --
function NPC:CustomTakeDamage( dmginfo ) end
---------------------------------------------------------------------------------------------------------------------=#
    -- Called when the NPC hurts an entity, return true to prevent damage --
function NPC:DealDamage( victimEnt, dmginfo ) end
---------------------------------------------------------------------------------------------------------------------=#




