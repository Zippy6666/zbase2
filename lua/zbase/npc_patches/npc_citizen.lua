local my_cls                                    = ZBasePatchNPCClass(debug.getinfo(1,'S'))
local npc_citizen_auto_player_squad_allow_use   = GetConVar("npc_citizen_auto_player_squad_allow_use")

-- Set citizens follow when pressed E on
RunConsoleCommand("npc_citizen_auto_player_squad_allow_use", "1")

ZBasePatchTable[my_cls] = function( NPC )
    -- Pain sounds that can interrupt other prio voice sounds
    NPC.Patch_CanInterruptImportantVoiceSound = {
        ["npc_citizen.ow01"] = true,
        ["npc_citizen.ow02"] = true,
        ["npc_citizen.imhurt01"] = true,
        ["npc_citizen.imhurt02"] = true,
        ["npc_citizen.pain01"] = true,
        ["npc_citizen.pain02"] = true,
        ["npc_citizen.pain03"] = true,
        ["npc_citizen.pain04"] = true,
        ["npc_citizen.pain05"] = true,
        ["npc_citizen.pain06"] = true,
        ["npc_citizen.pain07"] = true,
        ["npc_citizen.pain08"] = true,
        ["npc_citizen.pain09"] = true,
        ["npc_citizen.myarm01"] = true,
        ["npc_citizen.myarm02"] = true,
        ["npc_citizen.myleg01"] = true,
        ["npc_citizen.myleg02"] = true,
        ["npc_citizen.mygut01"] = true,
        ["npc_citizen.mygut02"] = true,
        ["npc_citizen.hitingut01"] = true,
        ["npc_citizen.hitingut02"] = true,
    }    

    -- Return wheter or not to use engine follow sys
    -- As opposed to ZBASE one
    function NPC:Patch_UseEngineFollow()
        return game.SinglePlayer() && npc_citizen_auto_player_squad_allow_use:GetBool()
    end
    
end