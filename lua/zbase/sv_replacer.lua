util.AddNetworkString("zbase_camp_replace_reload")


local CurrentReplaceList = {}
local filename = "zbase_campaign_replace.json"
local loadMSG = "Loaded '"..filename.."'! See details in the console."
local failMSG = "Failed to load '"..filename.."', likely due to invalid syntax!"


local defaultReplace = {
    npc_combine_s = { zb_combine_soldier=1, zb_combine_elite=3, zb_combine_nova_prospekt=2 },
    npc_metropolice = { zb_metropolice=1, zb_metropolice_elite=2 },
    npc_zombie = { zb_zombie=1, zb_fastzombie=2, zb_poisonzombie=4, zb_zombine=3 },
    npc_zombine = {zb_zombine=1},
    npc_fastzombie = {zb_fastzombie=1},
    npc_antlion = { zb_antlion=1, zb_antlion_spitter=2 },
    npc_citizen = {
        zb_human_civilian=2,
        zb_human_refugee=1,
        zb_human_rebel=2,
        zb_human_medic=3,
        zb_human_rebel_f=2,
        zb_human_medic_f=3,
    }
}



local function CreateFile()
    -- No file exists, create a new basic one
    if !file.Exists(filename, "DATA") then
        file.Write( filename, util.TableToJSON(defaultReplace, true) )
    end
end



local function zbase_camp_replace_reload()

    -- Create the file if it doesn't exist
    CreateFile()

    local tbl = util.JSONToTable( file.Read(filename, "DATA") )
    if tbl then
        table.CopyFromTo( tbl, CurrentReplaceList )
        MsgN(loadMSG)
        PrintTable(CurrentReplaceList)
        return true
    else
        MsgN(failMSG)
        return false
    end

end




net.Receive("zbase_camp_replace_reload", function()
    
    local success = zbase_camp_replace_reload()
    if success then
        PrintMessage(HUD_PRINTTALK, loadMSG)
    else
        PrintMessage(HUD_PRINTTALK, failMSG)
    end

end)



    -- Tick delayed OnEntityCreated
hook.Add("OnEntityCreated", "ZBaseReplaceSys", function( ent ) conv.callNextTick( function()

    if !ZBCVAR.CampaignReplace:GetBool() then return end
    if !IsValid(ent) then return end
    if ent.IsZBaseNPC then return end -- Don't replace ZBase NPCs with ZBase NPCs!


    -- Chance based NPC replace
    local _ReplaceData = CurrentReplaceList[ent:GetClass()]
    if _ReplaceData then

        -- Make a copy of the replace data table
        local data = table.Copy(_ReplaceData)


        -- Do the lottery
        -- Pick a random float from 0 - chance for each zbase class
        -- The smallest one wins, and becomes the one to replace the npc
        local lowestVal
        local ZBCls
        for zb_cls, chance in pairs(data) do
            local rand =  math.Rand(0, chance)
            if !lowestVal or rand<lowestVal then
                lowestVal = rand
                ZBCls = zb_cls
            end
        end
        if ZBCls then
            ZBaseNPCCopy(ent, ZBCls)
        end

    end

end) end)



zbase_camp_replace_reload()

