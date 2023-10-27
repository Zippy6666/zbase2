AddCSLuaFile()

-------------------------------------------------------------------------------------------------------------------------=#
function IsZBaseNPC(ent)
    if SERVER then
        local parentname = ent:GetKeyValues().parentname
        return string.StartWith(parentname, "zbase_")
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
function FindZBaseTable(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split-1]
    return ZBaseNPCs[name]
end
-------------------------------------------------------------------------------------------------------------------------=#