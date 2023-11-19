local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))

------------------------------------------------------------------------------------=#
hook.Add("OnEntityCreated", my_cls.."_zbaseenhanced", function( NPC ) timer.Simple(0.1, function()
    if !IsValid(NPC) or NPC:GetClass() != my_cls or !NPC.IsZBaseNPC then
        return
    end



    ------------------------------------------------------------------------------------=#
    -- function NPC:ZBaseEnhancedThink()
    -- end
    ------------------------------------------------------------------------------------=#

end) end)
------------------------------------------------------------------------------------=#