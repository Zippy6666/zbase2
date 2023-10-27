local NPC = FindZBaseTable(debug.getinfo(1,'S'))

---------------------------------------------------------------------------------------------------------------------=#
    -- On NPC hurt, return true to prevent damage --
function NPC:CustomTakeDamage( dmginfo )
    PrintTable(self:GetTable())
end
---------------------------------------------------------------------------------------------------------------------=#