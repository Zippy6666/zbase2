util.AddNetworkString("ZBaseInitEnt")


local ZBaseNextThink = CurTime()
local ZBaseWeaponDMGs = {
    ["weapon_pistol"] = {dmg=5, inflclass="bullet"},
    ["weapon_357"] = {dmg=40, inflclass="bullet"},
    ["weapon_ar2"] = {dmg=8, inflclass="bullet"},
    ["weapon_shotgun"] = {dmg=56, inflclass="bullet"},
    ["weapon_smg1"] = {dmg=4, inflclass="bullet"},
    ["weapon_rpg"] = {dmg=150, inflclass="rpg_missile"},
    ["weapon_crossbow"] = {dmg=100, inflclass="crossbow_bolt"},
    ["weapon_elitepolice_mp5k"] = {dmg=6, inflclass="bullet"},
}


---------------------------------------------------------------------------------------=#
hook.Add("InitPostEntity", "ZBaseReplaceFuncsServer", function() timer.Simple(0.5, function()
	local ENT = FindMetaTable("Entity")
	local emitSound = ENT.EmitSound
	local OnNPCKilled = GAMEMODE.OnNPCKilled
	local SpawnNPC = Spawn_NPC


	----------------------------------------------------------------------------------------------=#
	function GAMEMODE:OnNPCKilled( npc, attacker, ... )
		if IsValid(attacker) && attacker.IsZBaseNPC then
			attacker:OnKilledEnt( npc )
		end

		if npc.IsZBaseNPC then
            -- Death sound
			npc:EmitSound(npc.DeathSounds)
		end

		return OnNPCKilled(self, npc, ...)
	end
	----------------------------------------------------------------------------------------------=#
	function Spawn_NPC( ply, NPCClassName, WeaponName, tr, ... )
        if ZBaseNPCs[NPCClassName] then
            return Spawn_ZBaseNPC( ply, NPCClassName, WeaponName, tr, ... )
        else
		    return SpawnNPC( ply, NPCClassName, WeaponName, tr, ... )
        end
	end
	----------------------------------------------------------------------------------------------=#
	function ENT:EmitSound( snd, ... )

		if self.IsZBaseNPC && snd == "" then return end

		ZBase_EmitSoundCall = true
		local v = emitSound(self, snd, ...)
		ZBase_EmitSoundCall = false

		return v

	end
	----------------------------------------------------------------------------------------------=#
end) end)
---------------------------------------------------------------------------------------=#
hook.Add("OnEntityCreated", "ZBASE", function( ent ) timer.Simple(0, function()
        if !IsValid(ent) then return end

        if ent:IsNPC() then

            ent.ZBaseFaction = ZBaseFactionTranslation[ent:Classify()]
            table.insert(ZBase_NonZBaseNPCs, ent)
            ent:CallOnRemove("ZBase_RemoveFromNPCTable", function() table.RemoveByValue(ZBase_NonZBaseNPCs, ent) end)

        end

        local own = ent:GetOwner()

        if IsValid(own) && own.IsZBaseNPC then
            own:OnOwnedEntCreated( ent )
        end

        -- ZBase init stuff when not spawned from menu
        local zbaseClass = ent:GetKeyValues().parentname
        local zbaseNPCTable = ZBaseNPCs[ ent:GetKeyValues().parentname ]
        if zbaseNPCTable then
            ZBaseInitialize(ent, zbaseNPCTable, zbaseClass, false)
        end
end) end)
---------------------------------------------------------------------------------------=#
hook.Add("Think", "ZBASE", function()
    if ZBaseNextThink > CurTime() then return end

    for _, v in ipairs(ZBaseNPCInstances) do

        if !IsValid(v) then
            table.RemoveByValue(ZBaseNPCInstances, v)
            return
        end

        v:ZBaseThink()
        v:CustomThink()

    end

    ZBaseNextThink = CurTime()+0.1
end)
---------------------------------------------------------------------------------------=#
hook.Add("EntityTakeDamage", "ZBASE", function( ent, dmg )

    if ent.IsZBaseNPC then
        ent:OnHurt(dmg)
    end


    local attacker = dmg:GetAttacker()
    local infl = dmg:GetInflictor()


    -- if IsValid(attacker) then
    --     ent.ZBaseLastAttacker = attacker
    -- end

    if IsValid(attacker.ZBaseComballOwner) then

        dmg:SetAttacker(attacker.ZBaseComballOwner)

        if ent:GetClass() == "npc_hunter" or ent:GetClass() == "npc_strider" then

            attacker:Fire("Explode")

            if attacker.ZBaseComballOwner.ZBaseFaction != ent.ZBaseFaction
            or attacker.ZBaseComballOwner.ZBaseFaction == "none" then
                local dmg2 = DamageInfo()
                dmg2:SetDamage(ent:GetClass() == "npc_strider" && 100 or 1000)
                dmg2:SetDamageType(DMG_DISSOLVE)
                dmg2:SetAttacker(dmg:GetAttacker())
                ent:TakeDamageInfo(dmg2)
            end

        end

        attacker = attacker.ZBaseComballOwner

    end


    -- Don't hurt NPCs in same faction
    if attacker.IsZBaseNPC
    && ent.IsZBaseNPC
    && ent:HasCapability(CAP_FRIENDLY_DMG_IMMUNE)
    && attacker.ZBaseFaction == ent.ZBaseFaction
    && ent.ZBaseFaction != "none" then
        dmg:ScaleDamage(0)
        return true
    end


    if IsValid(attacker) && attacker.IsZBaseNPC then
    
        local r = attacker:DealDamage(ent, dmg)
        if r then
            return r
        end

        -- Proper damage values for hl2 weapons
        if ZBaseCvar_HL2WepDMG:GetBool() then
            local wep = attacker:GetActiveWeapon()

            if IsValid(infl) && IsValid(wep) then
                local dmgTbl = ZBaseWeaponDMGs[wep:GetClass()]

                if dmgTbl
                && ( (dmgTbl.inflclass=="bullet"&&dmg:IsBulletDamage()) or (dmgTbl.inflclass == infl:GetClass()) ) then
                    local dmgFinal = dmgTbl.dmg

                    if dmg:IsDamageType(DMG_BUCKSHOT) then
                        if attacker:WithinDistance(ent, 200) then
                            dmgFinal = math.random(40, 56)
                        elseif attacker:WithinDistance(ent, 400) then
                            dmgFinal = math.random(16, 40)
                        else
                            dmgFinal = math.random(8, 16)
                        end
                    end

                    dmg:SetDamage(dmgFinal)
                end
            end
        end

    end
end)
---------------------------------------------------------------------------------------=#
hook.Add("ScaleNPCDamage", "ZBASE", function( npc, hit_gr, dmg )
    if !npc.IsZBaseNPC then return end

    local r = npc:CustomTakeDamage(dmg, hit_gr)
    if r then
        return r
    end

    if npc.HasArmor[hit_gr] then
        local r = npc:HitArmor(dmg, hit_gr)
        if r then
            return r
        end
    end
end)
---------------------------------------------------------------------------------------=#
local SoundIndexes = {}
local ShuffledSoundTables = {}
---------------------------------------------------------------------------------------=#
local function RestartSoundCycle( sndTbl, data )
    SoundIndexes[data.OriginalSoundName] = 1

    local shuffle = table.Copy(sndTbl.sound)
    table.Shuffle(shuffle)
    ShuffledSoundTables[data.OriginalSoundName] = shuffle

    -- print("-----------------", data.OriginalSoundName, "-----------------")
    -- PrintTable(ShuffledSoundTables[data.OriginalSoundName])
    -- print("--------------------------------------------------")
end
---------------------------------------------------------------------------------------=#
hook.Add("EntityEmitSound", "ZBASE", function( data )

    if !IsValid(data.Entity) then return end

    
    if data.Entity.IsZBaseNPC then
        local altered = false


        -- Mute default "engine" voice
        if !ZBase_EmitSoundCall
        && SERVER
        && data.Entity.MuteDefaultVoice
        && (data.SoundName == "invalid.wav" or data.Channel == CHAN_VOICE) then
            return false
        end


            -- Avoid sound repitition --
        local sndTbl = sound.GetProperties(data.OriginalSoundName)

        if sndTbl && istable(sndTbl.sound) && table.Count(sndTbl.sound) > 1 && ZBase_EmitSoundCall then
            if !SoundIndexes[data.OriginalSoundName] then
                RestartSoundCycle(sndTbl, data)
            else
                if SoundIndexes[data.OriginalSoundName] == table.Count(sndTbl.sound) then
                    RestartSoundCycle(sndTbl, data)
                else
                    SoundIndexes[data.OriginalSoundName] = SoundIndexes[data.OriginalSoundName] + 1
                end
            end

            local snds = ShuffledSoundTables[data.OriginalSoundName]
            data.SoundName = snds[SoundIndexes[data.OriginalSoundName]]
            altered = true

            -- print(SoundIndexes[data.OriginalSoundName], data.SoundName)
        end
        -----------------------------------------------=#


        -- "OnEmitSound"
        local r = data.Entity:OnEmitSound(data)
        if isstring(r) then
            data.Entity:EmitSound(r)
            return false
        elseif r == false then
            return false
        end


        if altered then
            return true
        end
    end

end)
---------------------------------------------------------------------------------------=#
hook.Add("AcceptInput", "ZBASE", function( ent, input, activator, caller, value )
    if ent.IsZBaseNPC then
        local r = ent:CustomAcceptInput(input, activator, caller, value)
        if r == true then return true end
    end
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerInitialSpawn", "ZBASE", function( ply )
    ply.ZBaseFaction = "ally"
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerDeath", "ZBASE", function( ply, _, attacker )
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( ply )
    end
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerSpawnedNPC", "ZBASE", function(ply, ent)
    if ply.ZBaseNPCFactionOverride && ply.ZBaseNPCFactionOverride != "" then
        timer.Simple(0, function()
            if !IsValid(ent) or !IsValid(ply) then return end

            ent.ZBaseFaction = ply.ZBaseNPCFactionOverride
        end)
    end
end)
---------------------------------------------------------------------------------------------------------------------=#