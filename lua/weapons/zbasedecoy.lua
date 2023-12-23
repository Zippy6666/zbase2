AddCSLuaFile()


--[[
==================================================================================================
                                           GENERAL
==================================================================================================
--]]


SWEP.PrintName = "ZBase Decoy"
SWEP.Author = "Zippy"
SWEP.Spawnable = false


SWEP.IsZBaseDecoyWep = true


function SWEP:Initialize()
    self.ModelsPrecached = {}
end


function SWEP:Think()
    self.WorldModel = Model( self:GetNWString("WorldModel") )
    print(self.WorldModel)
end