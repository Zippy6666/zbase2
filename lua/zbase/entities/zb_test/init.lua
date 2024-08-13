local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {}

NPC.ZBaseStartFaction = "combine"


function NPC:CustomInitialize()
    self:SetSkin(2)
    self.GonnaExplode = false
end


function NPC:CustomThink()
    if !self.GonnaExplode && self:SeeEne() && self:ZBaseDist(self:GetEnemy(), {within=300}) then
        self:SetSkin(2)
        self:SetSaveValue("m_bPowerDown", true)
        self.GonnaExplode = true
    end
end