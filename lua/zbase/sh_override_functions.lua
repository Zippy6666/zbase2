local ENT = FindMetaTable("Entity")


--[[
======================================================================================================================================================
                                           SERVER
======================================================================================================================================================
--]]


if SERVER then

    local SpawnNPC = Spawn_NPC

    

    function Spawn_NPC( ply, NPCClassName, WeaponName, tr, ... )
        if ZBaseNPCs[NPCClassName] then
            return Spawn_ZBaseNPC( ply, NPCClassName, WeaponName, tr, ... )
        else
            return SpawnNPC( ply, NPCClassName, WeaponName, tr, ... )
        end
    end

end


--[[
======================================================================================================================================================
                                           SHARED
======================================================================================================================================================
--]]


local listGet = list.Get
local emitSound = ENT.EmitSound
ZBase_EmitSoundCall = false


function list:Get()
    if !ZBase_JustReloadedSpawnmenu && self == "NPC" then
        -- Add ZBase NPCs to NPC list

        local ZBaseTableAdd = {}
        for k, v in pairs(ZBaseSpawnMenuNPCList) do
            local ZBaseNPC = table.Copy(v)

            ZBaseNPC.Name = ZBaseNPC.Name
            ZBaseNPC.Category = "[ZBase] "..ZBaseNPC.Category
            ZBaseNPC.KeyValues = {parentname=k}
            ZBaseTableAdd[k] = ZBaseNPC
        end

        local t = table.Merge(listGet(self), ZBaseTableAdd)

        return t
    end

    return listGet(self)
end


function ENT:EmitSound( snd, ... )
    local IsZBaseNPC = self:GetNWBool("IsZBaseNPC")
	if IsZBaseNPC && snd == "" then return end
    if !IsValid(self) then return end


    if IsZBaseNPC && self.CancelConversation then
        self:CancelConversation()
    end


	ZBase_EmitSoundCall = true
	local v = emitSound(self, snd, ...)
	ZBase_EmitSoundCall = false


	return v
end


--[[
======================================================================================================================================================
                                           CLIENT
======================================================================================================================================================
--]]


if CLIENT then
end