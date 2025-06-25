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
        -- Set serverside classname keyvalue to something else
        self:SetKeyValue("classname", clsname)
    end
end

if CLIENT then
    local ENT           = FindMetaTable("Entity")

    ZBASE_SkipClassNameWrapper = false

    -- A wrapper that returns the ZBaseName instead of the class if it has one
    ENT.GetClass = conv.wrapFunc("ZBASE_ClassOverrideCL", ENT.GetClass, function( self )
        if self:GetNWString("ZBaseName", nil) && !ZBASE_SkipClassNameWrapper then
            return self:GetNWString("ZBaseName", nil)
        end
    end)
end