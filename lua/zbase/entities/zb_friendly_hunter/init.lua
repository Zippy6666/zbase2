local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.StartHealth = 310 -- Max health


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "ally"


NPC.SubMaterials = {
    [1] = "models/huntey/huntey_skin_basecolor",
    [2] = "models/huntey/huntey_armor_basecolor",
}



--]]==============================================================================================]]
function NPC:CustomInitialize()

end
--]]==============================================================================================]]
function NPC:CustomOnOwnedEntCreated( ent )
    if ent:GetClass() == "hunter_flechette" then

        local proj = ents.Create("crossbow_bolt")
        proj:SetPos(ent:GetPos())
        proj:SetAngles(ent:GetAngles())
        proj:SetOwner(self)
        proj:Spawn()
        proj:SetVelocity(ent:GetVelocity())

        ent:Remove()

    end
end
--]]==============================================================================================]]
function NPC:DealDamage( dmginfo, ent )
    local infl = dmginfo:GetInflictor()
    if IsValid(infl) && infl:GetClass() == "crossbow_bolt" then
        dmginfo:SetDamage(10)
    end
end
--]]==============================================================================================]]
