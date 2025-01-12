-- Internal code, do not use

AddCSLuaFile()


ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Temporary Entity"
ENT.Spawnable = false


function ENT:Initialize()

    if SERVER && !self.ShouldRemain then
        self:Remove()
    end

    self:SetModelScale(0, 0)

end