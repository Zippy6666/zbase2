local ENT = FindMetaTable("Entity")


--[[
======================================================================================================================================================
                                           SERVER
======================================================================================================================================================
--]]


if SERVER then
	local emitSound = ENT.EmitSound
	local OnNPCKilled = GAMEMODE.OnNPCKilled
	local SpawnNPC = Spawn_NPC


	ZBase_EmitSoundCall = false


	--]]==========================================================================================]]
	function GAMEMODE:OnNPCKilled( npc, attacker, infl )
		if npc.IsZBaseNPC && npc.Dead then return end

	
		if IsValid(attacker) && attacker.IsZBaseNPC then
			attacker:OnKilledEnt( npc )
		end

        
        for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
            zbaseNPC:MarkEnemyAsDead(npc, 2)
        end


		if npc.IsZBaseNPC then
            npc:OnDeath( attacker, infl, npc.LastDMGINFO, npc.LastHitGroup )
		end


		return OnNPCKilled(self, npc, infl)
	end
	--]]==========================================================================================]]
	function Spawn_NPC( ply, NPCClassName, WeaponName, tr, ... )
        if ZBaseNPCs[NPCClassName] then
            return Spawn_ZBaseNPC( ply, NPCClassName, WeaponName, tr, ... )
        else
		    return SpawnNPC( ply, NPCClassName, WeaponName, tr, ... )
        end
	end
	--]]==========================================================================================]]
	function ENT:EmitSound( snd, ... )

		if self.IsZBaseNPC && snd == "" then return end

		ZBase_EmitSoundCall = true
		local v = emitSound(self, snd, ...)
		ZBase_EmitSoundCall = false

		return v

	end
	--]]==========================================================================================]]
end


--[[
======================================================================================================================================================
                                           SHARED
======================================================================================================================================================
--]]


local listGet = list.Get


function list:Get()
    if !ZBase_JustReloadedSpawnmenu && self == "NPC" then
        -- Add ZBase NPCs to NPC list

        local ZBaseTableAdd = {}
        for k, v in pairs(ZBaseSpawnMenuNPCList) do
            local ZBaseNPC = table.Copy(v)

            ZBaseNPC.Category = "ZBase"
            ZBaseNPC.KeyValues = {parentname=k}
            ZBaseTableAdd[k] = ZBaseNPC
        end

        local t = table.Merge(listGet(self), ZBaseTableAdd)

        return t
    end

    return listGet(self)
end


--[[
======================================================================================================================================================
                                           CLIENT
======================================================================================================================================================
--]]


if CLIENT then
end