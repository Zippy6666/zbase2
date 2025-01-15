local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))


local CitFollowWithUse = GetConVar("npc_citizen_auto_player_squad_allow_use")
RunConsoleCommand("npc_citizen_auto_player_squad_allow_use", "1")


ZBasePatchTable[my_cls] = function( NPC )

    function NPC:Patch_UseEngineFollow()
        return game.SinglePlayer() && CitFollowWithUse:GetBool()
    end
    
    function NPC:Patch_PreSpawn()
        self:Fire("RemoveFromPlayerSquad")
    end
    
end