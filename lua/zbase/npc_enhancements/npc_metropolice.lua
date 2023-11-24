local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))
ZBaseEnhancementTable[my_cls] = function( NPC )
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedInit()

        -- Set model cuz metrocops need it done after spawn

        local MyModel = table.Random(self.NPCTable.Models)
        if MyModel then
            self:SetModel(MyModel)
        end

    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedThink()
    
    end
    --]]============================================================================================================]]
end