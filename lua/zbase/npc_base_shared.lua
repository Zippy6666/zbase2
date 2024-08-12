local NPC = FindZBaseTable(debug.getinfo(1, 'S'))


-- The NPC class
-- Can be any existing NPC in the game
-- If you want to make a human that can use weapons, you should probably use "npc_combine_s" or "npc_citizen" for example
-- Use "npc_zbase_snpc" if you want to create a brand new SNPC
NPC.Class = "npc_combine_s"


NPC.Name = "Base" -- Name of your NPC
NPC.Category = "Other" -- Category in the ZBase tab
NPC.Weapons = {} -- Example: {"weapon_rpg", "weapon_crowbar", "weapon_crossbow"}
NPC.Inherit = "npc_zbase" -- Inherit features from any existing zbase npc


--[[
==================================================================================================
                                DONT TOUCH ANYTHING BELOW HERE
==================================================================================================
--]]


if CLIENT then

    net.Receive("ZBaseNetworkSubmaterial", function()
        
        local idx, name, ent = net.ReadUInt(5), net.ReadString(), net.ReadEntity()
        if !IsValid(ent) then return end
        
        ent.SubMaterials = ent.SubMaterials or {}
        ent.SubMaterials[idx] = name

    end)


end
