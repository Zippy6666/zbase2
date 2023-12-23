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


    hook.Add("Think", self, function()
        self:Think2()
    end)

end


-- The sequal to think is finally here
function SWEP:Think2()

    local own = self:GetOwner()
    if !IsValid(own) then return end


    self.WorldModel = Model( self:GetNWString("WorldModel") )


    if CLIENT then
        -- local VMatrix = self:GetBoneMatrix(  )
        -- local pos, ang = VMatrix:GetTranslation(), VMatrix:GetAngles()
        -- self:SetPos(pos)
    end
    --self:FollowBone(own, )


end


function SWEP:OnRemove()
    hook.Remove("Think", self)
end