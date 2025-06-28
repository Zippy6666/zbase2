-- This is an experimental component

local NPC           = ZBaseNPCs["npc_zbase"]

function NPC:GetEngineClass()
    if CLIENT then
        ZBASE_SkipClassNameWrapper = true
        local cls = self:GetClass()
        ZBASE_SkipClassNameWrapper = false
        
        return cls
    end

    return self.EngineClass
end

if SERVER then
    function NPC:ApplyCustomClassName(clsname)
        if ZBCVAR.CustomClass:GetBool() then
            self:SetNWString("ZBASE_CustomClass", clsname)
            self:SetKeyValue("classname", clsname)
        end
    end
end

if CLIENT then
    local ENT           = FindMetaTable("Entity")

    ZBASE_SkipClassNameWrapper = false

    -- A wrapper that returns the CustomClass instead of the class if it has one
    ENT.GetClass = conv.wrapFunc("ZBASE_ClassOverrideCL", ENT.GetClass, function( self )
        if self:GetNWBool("IsZBaseNPC", false)==true && self:GetNWString("ZBASE_CustomClass", "")!="" && !ZBASE_SkipClassNameWrapper then
            return self:GetNWString("CustomClass", nil)
        end
    end)
end