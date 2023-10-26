local NPC = FindZBaseTable(debug.getinfo(1,'S'))

------------------------------------=#
function NPC:CustomInitialize()

end
------------------------------------=#
function NPC:CustomThink()

end
------------------------------------=#
function NPC:CustomTakeDamage( dmg )
    return true
end
------------------------------------=#
function NPC:DealDamage( ent, dmg )
    return true
end
------------------------------------=#