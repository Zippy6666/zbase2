local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))
ZBaseEnhancementTable[my_cls] = function( NPC )
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedInit()

        self.m_fIsHeadless = true
        self:SetBodygroup(1, 0)

        if self:GetClass()=="npc_poisonzombie" then
            self.m_nCrabCount = 0
            self:SetBodygroup(2, 0)
            self:SetBodygroup(3, 0)
            self:SetBodygroup(4, 0)
            self:SetBodygroup(5, 0)
            self:SetSaveValue("m_bCrabs", {false, false, false})
        end

    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedThink()
    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedCreateEnt( ent )
    end
    --]]============================================================================================================]]
end
ZBaseEnhancementTable["npc_fastzombie"] = ZBaseEnhancementTable[my_cls]
ZBaseEnhancementTable["npc_poisonzombie"] = ZBaseEnhancementTable[my_cls]
ZBaseEnhancementTable["npc_zombine"] = ZBaseEnhancementTable[my_cls]