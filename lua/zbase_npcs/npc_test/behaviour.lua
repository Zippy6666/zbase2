local NPC = FindZBaseTable(debug.getinfo(1,'S'))
NPC.Behaviours = {}


---------------------------------------------------------------------------------------------------------------------=#


NPC.Behaviours.ScreamWhenOnFire = {}


---------------------------------------------------------------------------------------------------------------------=#
function NPC.Behaviours.ScreamWhenOnFire:ShouldDoBehaviour( self )
    return self:IsOnFire()
end
---------------------------------------------------------------------------------------------------------------------=#
function NPC.Behaviours.ScreamWhenOnFire:Run( self )
    PrintMessage(HUD_PRINTTALK, "AAAAAAAAAAAAAA")
end
---------------------------------------------------------------------------------------------------------------------=#