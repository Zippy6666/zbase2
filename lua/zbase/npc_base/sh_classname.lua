local NPC = ZBaseNPCs["npc_zbase"]
local ENT = FindMetaTable("Entity")

ZBASE_SkipClassNameWrapper = false

-- A wrapper that returns the CustomClass instead of the class if it has one
ENT.GetClass = conv.wrapFunc("ZBASE_ClassOverride", ENT.GetClass, function( self )
    if self:GetNWBool("IsZBaseNPC", false)==true && self:GetNWString("ZBASE_CustomClass", "")!="" && !ZBASE_SkipClassNameWrapper then
        return self:GetNWString("ZBASE_CustomClass", nil)
    end
end)

if SERVER then
    function NPC:ApplyCustomClassName(clsname)
        if ZBCVAR.CustomClass:GetBool() then
            self:SetNWString("ZBASE_CustomClass", clsname)
            -- self:SetKeyValue("classname", clsname) -- this doesn't work any more because rubat rubatted
        end
    end
end
