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


	--]]==========================================================================================]]
	function GAMEMODE:OnNPCKilled( npc, attacker, ... )
		if IsValid(attacker) && attacker.IsZBaseNPC then
			attacker:OnKilledEnt( npc )
		end

        
        for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
            zbaseNPC:MarkEnemyAsDead(npc, 2)
        end


		if npc.IsZBaseNPC then

            -- Stop sounds
            for _, v in ipairs(npc.SoundVarNames) do
                if !isstring(v) then return end
                npc:StopSound(npc:GetTable()[v])
            end


            -- Death sound
			npc:EmitSound(npc.DeathSounds)


            -- Ally death reaction
            local ally = npc:GetNearestAlly(600)
            local deathpos = npc:GetPos()
            if IsValid(ally) && ally:Visible(npc) then
                timer.Simple(0.5, function()
                    if IsValid(ally)
                    && ally.AllyDeathSound_Chance
                    && math.random(1, ally.AllyDeathSound_Chance) == 1 then
                        ally:EmitSound_Uninterupted(ally.AllyDeathSounds)

                        if ally.AllyDeathSounds != "" then
                            ally:FullReset()
                            ally:Face(deathpos, ally.InternalCurrentSoundDuration)
                        end
                    end
                end)
            end


            npc.Gibbed = npc:ShouldGib(npc.LastDMGINFO, npc.LastHitGroup)


            SafeRemoveEntityDelayed(npc, 0.15) -- Remove earlier
		end


		return OnNPCKilled(self, npc, ...)
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
                                           CLIENT
======================================================================================================================================================
--]]


if CLIENT then
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
end