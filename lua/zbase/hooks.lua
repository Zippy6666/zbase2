--[[
======================================================================================================================================================
                                           INIT POST ENTITY
======================================================================================================================================================
--]]


hook.Add("InitPostEntity", "ZBaseReplaceFuncsServer", function()

    -- Override functions
    timer.Simple(0.5, function()
        AddCSLuaFile("zbase/override_functions.lua")
        include("zbase/override_functions.lua")
    end)

end)


--[[
======================================================================================================================================================
                                           ENTITY CREATED
======================================================================================================================================================
--]]


hook.Add("OnEntityCreated", "ZBASE", function( ent ) 
    -- ZBase init stuff when not spawned from menu
    if SERVER then
        timer.Simple(0, function()
            if !IsValid(ent) then return end

            
            local zbaseClass = ent:GetKeyValues().parentname
            local zbaseNPCTable = ZBaseNPCs[ zbaseClass ]
            if zbaseNPCTable then
                ZBaseInitialize(ent, zbaseNPCTable, zbaseClass, false)
            end
        end)
    end


    -- OnOwnedEntCreated
    if SERVER then
        timer.Simple(0, function()
            if !IsValid(ent) then return end

            local own = ent:GetOwner()
            if IsValid(own) && own.IsZBaseNPC then
                own:OnOwnedEntCreated( ent )
            end
        end)
    end


    -- Relationship stuff
    if SERVER && ent:IsNPC() && ent:GetClass() != "npc_bullseye" && !ent.IsZBaseNavigator then
        timer.Simple(0, function()
            if !IsValid(ent) then return end


            local FactionTranslation = {
                [CLASS_COMBINE] = "combine",
                [CLASS_COMBINE_GUNSHIP] = "combine",
                [CLASS_MANHACK] = "combine",
                [CLASS_METROPOLICE] = "combine",
                [CLASS_MILITARY] = "combine",
                [CLASS_SCANNER] = "combine",
                [CLASS_STALKER] = "combine",
                [CLASS_PROTOSNIPER] = "combine",
                [CLASS_COMBINE_HUNTER] = "combine",
                [CLASS_HACKED_ROLLERMINE] = "ally",
                [CLASS_HUMAN_PASSIVE] = "ally",
                [CLASS_VORTIGAUNT] = "ally",
                [CLASS_PLAYER] = "ally",
                [CLASS_PLAYER_ALLY] = "ally",
                [CLASS_PLAYER_ALLY_VITAL] = "ally",
                [CLASS_CITIZEN_PASSIVE] = "ally",
                [CLASS_CITIZEN_REBEL] = "ally",
                [CLASS_BARNACLE] = "xen",
                [CLASS_ALIEN_MILITARY] = "xen",
                [CLASS_ALIEN_MONSTER] = "xen",
                [CLASS_ALIEN_PREDATOR] = "xen",
                [CLASS_MACHINE] = "hecu",
                [CLASS_HUMAN_MILITARY] = "hecu",
                [CLASS_HEADCRAB] = "zombie",
                [CLASS_ZOMBIE] = "zombie",
                [CLASS_ALIEN_PREY] = "zombie",
                [CLASS_ANTLION] = "antlion",
                [CLASS_EARTH_FAUNA] = "neutral",
            }


            local faction = FactionTranslation[ent:Classify()]


            table.insert(ZBaseRelationshipEnts, ent)
            ent:CallOnRemove("ZBaseRelationshipEntsRemove", function() table.RemoveByValue(ZBaseRelationshipEnts, ent) end)


            ZBaseSetFaction(ent, !ent.IsZBaseNPC && faction)
        end)
    end
end)


--[[
======================================================================================================================================================
                                           THINK/TICK
======================================================================================================================================================
--]]


local NextThink = CurTime()
local NextBehaviourThink = CurTime()


hook.Add("Tick", "ZBASE", function()
    -- Think for NPCs that aren't scripted
    if NextThink < CurTime() then
        for _, v in ipairs(ZBaseNPCInstances_NonScripted) do
            v:ZBaseThink()

            if v.ZBaseEnhancedThink then
                v:ZBaseEnhancedThink()
            end
        end

        NextThink = CurTime()+0.1
    end
    --------------------------------------------------------=#


    -- Behaviour tick
    if !GetConVar("ai_disabled"):GetBool()
    && NextBehaviourThink < CurTime() then
        for k, func in ipairs(ZBaseBehaviourTimerFuncs) do
            local entValid = func()

            if !entValid then
                table.remove(ZBaseBehaviourTimerFuncs, k)
            end
        end

        NextBehaviourThink = CurTime() + 0.5
    end
    --------------------------------------------------------=#
end)


--[[
======================================================================================================================================================
                                           RELATIONSHIP STUFF
======================================================================================================================================================
--]]


if SERVER then
    util.AddNetworkString("ZBasePlayerFactionSwitch")
    util.AddNetworkString("ZBaseNPCFactionOverrideSwitch")


    if !ZBaseRelationshipEnts then
        ZBaseRelationshipEnts = {}
    end


    net.Receive("ZBasePlayerFactionSwitch", function( _, ply )
        local faction = net.ReadString()
        ply.ZBaseFaction = faction

        for _, v in ipairs(ZBaseRelationshipEnts) do
            v:Relationships()
        end
    end)


    net.Receive("ZBaseNPCFactionOverrideSwitch", function( _, ply )
        local faction = net.ReadString()
        
        if faction == "No Override" then
            ply.ZBaseNPCFactionOverride = nil
        else
            ply.ZBaseNPCFactionOverride = faction
        end
    end)


    hook.Add("PlayerInitialSpawn", "ZBASE", function( ply )
        ply.ZBaseFaction = "ally"
    end)


    hook.Add("PlayerSpawnedNPC", "ZBASE", function(ply, ent)
        if ply.ZBaseNPCFactionOverride && ply.ZBaseNPCFactionOverride != "" then
            timer.Simple(0, function()
                if !IsValid(ent) or !IsValid(ply) then return end
                if !ent.IsZBaseNPC then return end

                ent:SetZBaseFaction(ply.ZBaseNPCFactionOverride)
            end)
        end
    end)
end


--[[
======================================================================================================================================================
                                           DAMAGE
======================================================================================================================================================
--]]


local ZBaseWeaponDMGs = {
    ["weapon_rpg"] = {dmg=150, inflclass="rpg_missile"},
    ["weapon_crossbow"] = {dmg=100, inflclass="crossbow_bolt"},
}


hook.Add("EntityTakeDamage", "ZBASE", function( ent, dmg )
    local attacker = dmg:GetAttacker()
    local infl = dmg:GetInflictor()


    if ent.IsZBaseNPC then
        ent:OnEntityTakeDamage( dmg )
    end


    -- Blow up zbase combine balls
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


    -- Attacker is ZBase NPC
    if IsValid(attacker) && attacker.IsZBaseNPC then
        -- Don't hurt NPCs in same faction
        if ent.IsZBaseNPC
        && ent:HasCapability(CAP_FRIENDLY_DMG_IMMUNE)
        && attacker.ZBaseFaction == ent.ZBaseFaction
        && ent.ZBaseFaction != "none" then
            dmg:ScaleDamage(0)
            return true
        end


        local r = attacker:DealDamage(ent, dmg)
        if r then
            return r
        end


        -- Proper damage values for some hl2 weapons --
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
        ------------------------------------------------=#
    end
end)


hook.Add("PostEntityTakeDamage", "ZBASE", function( ent, dmg )
    if ent.IsZBaseNPC then
        ent:OnPostEntityTakeDamage( dmg )
    end
end)


hook.Add("ScaleNPCDamage", "ZBASE", function( npc, hit_gr, dmg )
    if npc.IsZBaseNPC then
        npc:OnScaleNPCDamage( dmg, hit_gr )
    end
end)



--[[
======================================================================================================================================================
                                           BULLETS
======================================================================================================================================================
--]]


ZBaseReflectedBullet = false


local grabbing_bullet_backup_data = false
local ZBaseWeaponAccuracyBoost = {
    ["weapon_shotgun"] = 30,
    ["weapon_smg1"] = 40,
    ["weapon_pistol"] = 50,
}


hook.Add("EntityFireBullets", "ZBASE", function( ent, data, ... )
    local data_backup = data
    if grabbing_bullet_backup_data then return end


    grabbing_bullet_backup_data = true
    hook.Run("EntityFireBullets", ent, data, ...)
    grabbing_bullet_backup_data = false


    data = data_backup


    -- On bullet hit
    if !ZBaseReflectedBullet then
        local callback = data.Callback
        data.Callback = function(callback_ent, tr, dmginfo, ...)

            if callback then
                callback(callback_ent, tr, dmginfo, ...)
            end

            if IsValid(tr.Entity) && tr.Entity.IsZBaseNPC then
                tr.Entity:OnBulletHit(ent, tr, dmginfo, data)
            end

        end
    end
    --------------------------------------------------=#


    -- Boost accuracy for some weapons --
    if ent.IsZBaseNPC then
        local wep = ent:GetActiveWeapon()
        local ene = ent:GetEnemy()

        if IsValid(wep) && IsValid(ene) && ZBaseWeaponAccuracyBoost[wep:GetClass()] then
            local sprd = (5 - ent:GetCurrentWeaponProficiency())/ZBaseWeaponAccuracyBoost[wep:GetClass()]
            data.Spread = Vector(sprd, sprd)
            data.Dir = (ene:WorldSpaceCenter() - ent:GetShootPos()):GetNormalized()
        end
    end
    --------------------------------------------------=#


    return true
end)



--[[
======================================================================================================================================================
                                           SOUNDS
======================================================================================================================================================
--]]


hook.Add("EntityEmitSound", "ZBASE", function( data )
    if !IsValid(data.Entity) then return end
    if !data.Entity.IsZBaseNPC then return end


    local value = data.Entity:OnEmitSound( data )


    if value != nil then
        return value
    end
end)


--[[
======================================================================================================================================================
                                           OTHER
======================================================================================================================================================
--]]


hook.Add("PlayerDeath", "ZBASE", function( ply, _, attacker )
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( ply )
    end

    for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
        zbaseNPC:MarkEnemyAsDead(ply, 2)
    end
end)


hook.Add("AcceptInput", "ZBASE", function( ent, input, activator, caller, value )
    if ent.IsZBaseNPC then
        local r = ent:CustomAcceptInput(input, activator, caller, value)
        if r == true then return true end
    end
end)


hook.Add("GravGunPunt", "ZBaseNPC", function( ply, ent )
    if ent.IsZBaseNPC && ent.SNPCType == ZBASE_SNPCTYPE_FLY && ent.Fly_GravGunPuntForceMult > 0 then
        local timerName = "ZBaseNPCPuntVel"..ent:EntIndex()
        local totalReps = 10
        local speed = 500*ent.Fly_GravGunPuntForceMult

        timer.Create(timerName, 0.1, totalReps, function()
            if !IsValid(ent) then return end

            local mult = ( speed - ((totalReps-timer.RepsLeft(timerName))/totalReps)*speed )
            ent:SetVelocity(ply:GetAimVector() * mult)
        end)

        return true
    end
end)


-- ZBase init stuff when spawned from dupe
duplicator.RegisterEntityModifier( "ZBaseNPCDupeApplyStuff", function(ply, ent, data)
    local zbaseClass = data[1]
    local zbaseNPCTable = ZBaseNPCs[ zbaseClass ]
    if zbaseNPCTable then
        ZBaseInitialize(ent, zbaseNPCTable, zbaseClass, false)
    end
end)


hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )
	if swep.IsZBaseWeapon && class!="weapon_zbase" then
		list.Add( "NPCUsableWeapons", { class = class, title = "[ZBase] "..swep.PrintName } )
	end
end)


-- Don't pickup some zbase weapons
hook.Add("PlayerCanPickupWeapon", "ZBASE", function( ply, wep )
	if wep.IsZBaseWeapon && wep.NPCOnly then
		ply:GiveAmmo(wep:GetMaxClip1(), wep:GetPrimaryAmmoType())
		wep:Remove()
		return false
	end
end)


hook.Add("CreateEntityRagdoll", "ZBaseNoRag", function(ent, rag)
    
end)


-- Disable client ragdolls
hook.Add("CreateClientsideRagdoll", "ZBaseNoRag", function(ent, rag)
	if ent:GetNWBool("IsZBaseNPC") then
		rag:Remove()
	end
end)