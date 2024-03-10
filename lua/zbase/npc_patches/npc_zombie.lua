local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))


ZBasePatchTable[my_cls] = function( NPC )
    
    -- No headcrabs
    function NPC:ZBaseEnhancedInit()
        self:SetSaveValue("m_fIsHeadless", true)
        self:SetBodygroup(1, 0)

        if self:GetClass()=="npc_poisonzombie" then
            self:SetSaveValue("m_nCrabCount", 0)
            self:SetBodygroup(2, 0)
            self:SetBodygroup(3, 0)
            self:SetBodygroup(4, 0)
            self:SetBodygroup(5, 0)
            self:SetSaveValue("m_bCrabs", {false, false, false})
        end
    end

end


-- Same for all other zombies
ZBasePatchTable["npc_fastzombie"] = ZBasePatchTable[my_cls]
ZBasePatchTable["npc_poisonzombie"] = ZBasePatchTable[my_cls]
ZBasePatchTable["npc_zombine"] = ZBasePatchTable[my_cls]