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


            ent:SetZBaseFaction(!ent.IsZBaseNPC && faction)
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

        print(ply, "test")
        
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