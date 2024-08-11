local NPC = FindZBaseTable(debug.getinfo(1,'S'))

function NPC:CustomInitialize()
    local Light = self:GetChildren()[1]
    Light:Fire("HideSprite")
end