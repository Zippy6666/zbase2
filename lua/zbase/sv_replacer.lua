-- Table of which NPCs should be replaced with who
-- NPC class -> ZBase Class
ZBaseReplaceTable = {
    ["npc_combine_s"] = "zb_myt_hecu_conscript",
}


    -- Tick delayed OnEntityCreated
hook.Add("OnEntityCreated", "ZBaseReplaceSys", function( ent ) conv.callNextTick( function()

    if !ZBCVAR.CampaignReplace:GetBool() then return end
    if !IsValid(ent) then return end
    if ent.IsZBaseNPC then return end -- Don't replace ZBase NPCs with ZBase NPCs!


    local ReplacementZBCls = ZBaseReplaceTable[ent:GetClass()]
    if ReplacementZBCls then
        ZBaseNPCCopy(ent, ReplacementZBCls)
    end

end) end)