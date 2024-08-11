local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {""}

function NPC:CustomInitialize()
    self:Zombie_GiveHeadCrabs(2)
end


function NPC:CustomOnOwnedEntCreated( ent )
    if ent:GetClass()=="npc_headcrab_poison" && !ent.IsZBaseNPC then

        -- New crab
        local customHeadcrab = ZBaseSpawnZBaseNPC("zb_antlion", ent:GetPos())
        customHeadcrab:SetAngles(ent:GetAngles())
        customHeadcrab:SetVelocity(ent:GetVelocity())
        customHeadcrab.ZBaseStartFaction = ZBaseGetFaction(self) -- Crab starts with same faction as me

        -- Remove old crab
        ent:Remove()

    end
end