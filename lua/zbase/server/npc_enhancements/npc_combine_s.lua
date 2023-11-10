local my_cls = ZBaseFileName(debug.getinfo(1,'S'))

------------------------------------------------------------------------------------=#
hook.Add("OnEntityCreated", my_cls.."_enhanced", function( NPC )
    if NPC:GetClass() != my_cls then return end

    print(NPC, NPC.IsZBaseNPC)

    -- self:GetInternalVariable("m_iMySquadSlot")

end)
------------------------------------------------------------------------------------=#