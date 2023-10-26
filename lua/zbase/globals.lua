AddCSLuaFile()

-------------------------------------------------------------------------------------------------------------------------=#
function IsZBaseNPC(ent)
    local parentname = ent:GetKeyValues().parentname
    return string.StartWith(parentname, "zbase_")
end
-------------------------------------------------------------------------------------------------------------------------=#
function FindZBaseTable(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split-1]
    return ZBaseNPCs[name]
end
-------------------------------------------------------------------------------------------------------------------------=#