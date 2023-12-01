local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))
ZBaseEnhancementTable[my_cls] = function( NPC )
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedInit()

        self.ProhibitCustomEScheds = true
        self.AllowedCustomEScheds = {
            [202] = true,
            [219] = true,
            [205] = true,
            [207] = true,
            [203] = true,
            [214] = true,
            [133] = true,
        }

        self:Fire("DisableSquadShootDelay")
    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedThink()
    end
    --]]============================================================================================================]]
end