local zbase_tool_faction = CreateClientConVar("zbase_tool_faction", "", false, true)

TOOL.AddToMenu = true
TOOL.Category = "NPC"

local toolname = "Faction"
TOOL.Name = toolname
TOOL.Description = "Change the ZBase faction of any entity."

local help = "Left-click: Change the ZBase faction of the target entity."
if CLIENT then
    language.Add("tool.zbase_faction.name", TOOL.Name)
    language.Add("tool.zbase_faction.desc", TOOL.Description)
    language.Add("tool.zbase_faction.0", help)
end

function TOOL:LeftClick( trace )
    local ent = trace.Entity
    local own = self:GetOwner()
    if !IsValid(own) then return end

    if IsValid(ent) && !ent:IsWorld() then
        ZBaseSetFaction(ent, own:GetInfo("zbase_tool_faction"), own)
    end

    return false
end

function TOOL:RightClick( trace )
    local own = self:GetOwner()
    if !IsValid(own) then return end

    return false
end

function TOOL:Reload( trace )
end

if CLIENT then
    function TOOL.BuildCPanel(panel)
        panel:Help(help)
        
        LocalPlayer().ZBaseToolFactionCombox = 
            panel:ComboBox("Faction", "zbase_tool_faction")

        ZBaseListFactions()
    end
end

