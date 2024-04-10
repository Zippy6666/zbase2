--[[
======================================================================================================================================================
                                           INIT POST ENTITY
======================================================================================================================================================
--]]


hook.Add("InitPostEntity", "ZBaseReplaceFuncsServer", function()

    -- Override functions
    timer.Simple(0.5, function()
        include("zbase/sh_override_functions.lua")
    end)


    -- Follow halo table
    if CLIENT then


        LocalPlayer().ZBaseFollowHaloEnts = LocalPlayer().ZBaseFollowHaloEnts or {}


        -- Cool message
        if ZBCVAR.StartMsg:GetBool() then
            local wepCol = LocalPlayer():GetWeaponColor()
            local col = Color(255*wepCol.r, 255*wepCol.g, 255*wepCol.b)
            chat.AddText(col, "ZBase is running on this server! Github link: https://github.com/Zippy6666/zbase2 (this message can be disabled in the ZBase options tab).")
        end

    end


    -- Precache zbase ents
    if SERVER && ZBCVAR.Precache:GetBool() then
        ZBasePrecacheEnts()
    end

end)

--[[
======================================================================================================================================================
                                           ENTITY CREATION
======================================================================================================================================================
--]]


hook.Add("OnEntityCreated", "ZBASE", function( ent )

    -- ZBase init stuff when NOT SPAWNED FROM MENU
    if SERVER then
        timer.Simple(0, function()
            if !IsValid(ent) then return end
            
            local zbaseClass = ent:GetKeyValues().parentname
            local ZBaseNPCTable = ZBaseNPCs[ zbaseClass ]
            
            if ZBaseNPCTable then
                ZBaseInitialize( ent, ZBaseNPCTable, zbaseClass, nil, false, false, true )
            end
        end)
    end


    -- When a entity owned by a zbase NPC is created
    if SERVER then
        timer.Simple(0, function()
            if !IsValid(ent) then return end

            local own = ent:GetOwner()
            if IsValid(own) && own.IsZBaseNPC then
                own:OnOwnedEntCreated( ent )

                if own.Patch_CreateEnt then
                    own:Patch_CreateEnt( ent )
                end
            end
        end)
    end


    -- When any NPC is created
    -- Give zbase faction
    if SERVER && ent:IsNPC() && ent:GetClass() != "npc_bullseye" && !ent.IsZBaseNavigator then
        function ent:ZBaseRelSetup()
            table.insert(ZBaseRelationshipEnts, ent)
            ZBaseSetFaction(ent, !ent.IsZBaseNPC && ZBaseFactionTranslation[ent:Classify()])
            ent:CallOnRemove("ZBaseRelationshipEntsRemove", function() table.RemoveByValue(ZBaseRelationshipEnts, ent) end)
        end

        ent:CallNextTick( "ZBaseRelSetup" )
    end

end)


hook.Add("PlayerSpawnedNPC", "ZBASE", function(ply, ent)

    -- Relationship override for NPCs
    if ply.ZBaseNPCFactionOverride && ply.ZBaseNPCFactionOverride != "" then

        timer.Simple(0, function()
            if !IsValid(ent) or !IsValid(ply) then return end
            if !ent.IsZBaseNPC then return end

            ZBaseSetFaction( ent, ply.ZBaseNPCFactionOverride )
        end)

    end


    -- Fix NPCs offset when spawned from the regular spawn menu
    timer.Simple(0, function()
        if !ent.IsZBaseNPC then return end
        if !IsValid(ent) or !IsValid(ply) then return end


        local offset = (ent.SNPCType == ZBASE_SNPCTYPE_FLY && ent.Fly_DistanceFromGround) or ent.Offset


        if isnumber(offset) then
            ent:SetPos( ent:GetPos()+Vector(0, 0, offset) )
        end
    end)

end)


    -- Override code for spawning zbase npcs from regular spawn menu
hook.Add("PlayerSpawnNPC", "ZBASE", function(ply, npc_type, wep_cls)
    npc_type = string.Right(npc_type, #npc_type-6)
    local zb_npc_tbl = ZBaseNPCs[npc_type]
    if zb_npc_tbl then 
    
        Spawn_ZBaseNPC(ply, npc_type, wep_cls, ply:GetEyeTrace())
        return false

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
    -- local startT = SysTime()

    if NextThink < CurTime() then
        for _, zbaseNPC in ipairs(ZBaseNPCInstances_NonScripted) do

            zbaseNPC:ZBaseThink()


            if zbaseNPC.Patch_Think then
                zbaseNPC:Patch_Think()
            end

        end

        NextThink = CurTime()+0.1
    


        -- if SERVER then
        --     PrintMessage(HUD_PRINTTALK, "Think time: "..math.Round(SysTime()-startT, 3))
        -- end

    end



    -- Behaviour tick
    -- local startT = SysTime()

    if !GetConVar("ai_disabled"):GetBool()
    && NextBehaviourThink < CurTime() then

        for k, func in ipairs(ZBaseBehaviourTimerFuncs) do
            local entValid = func()

            if !entValid then
                table.remove(ZBaseBehaviourTimerFuncs, k)
            end
        end

        NextBehaviourThink = CurTime() + 0.4


        -- if SERVER then
        --     PrintMessage(HUD_PRINTTALK, "Behaviour time: "..math.Round(SysTime()-startT, 3))
        -- end

    end


    for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
        zbaseNPC:FrameTick()
    end
    
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
            v:ZBaseUpdateRelationships()
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

end


--[[
======================================================================================================================================================
                                           DAMAGE
======================================================================================================================================================
--]]


hook.Add("EntityTakeDamage", "ZBASE", function( ent, dmg )

    local attacker = dmg:GetAttacker()
    local infl = dmg:GetInflictor()
    local infl_own = IsValid(infl) && infl:GetOwner()


    -- NPCs with ZBaseNPCCopy_DullState should not be able to take damage, nor should they be able to deal damage
    if ent.ZBaseNPCCopy_DullState or attacker.ZBaseNPCCopy_DullState or infl.ZBaseNPCCopy_DullState then
        dmg:SetDamage(0)
        return true
    end


    -- Attacker is ZBase NPC, run DealDamage
    -- TODO: register if it was an owned ent that did the damage
    local zbase_attacker = IsValid(attacker) && attacker.IsZBaseNPC && attacker
    if zbase_attacker then
        zbase_attacker:DealDamage( dmg, ent )
        if zbase_attacker.Patch_DealDamage then
            zbase_attacker:Patch_DealDamage( dmg, ent )
        end
    end


    -- Victim is ZBase NPC
    if ent.IsZBaseNPC then

        local value = ent:OnEntityTakeDamage( dmg )


        if value != nil then
            return value
        end

    end


    -- Handle combine balls fired by ZBase NPCs
    if IsValid(attacker.ZBaseComballOwner) then

        dmg:SetAttacker(attacker.ZBaseComballOwner)


        if (ent:IsNPC() or ent:IsNextBot()) then

            -- Explotano
            if ent:GetClass() == "npc_hunter"
            or ent:GetClass() == "npc_strider" then
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

        end


        attacker = attacker.ZBaseComballOwner

    end
end)


hook.Add("PostEntityTakeDamage", "ZBASE", function( ent, dmg )
    if ent.IsZBaseNPC then
        ent:OnPostEntityTakeDamage( dmg )
    end
end)


local function ScaleDamage( ent, hit_gr, dmg )
    local attacker = dmg:GetAttacker()

    if ent.IsZBaseNPC then
        ent:OnScaleDamage( dmg, hit_gr )
    end
end


hook.Add("ScaleNPCDamage", "ZBASE", ScaleDamage)
hook.Add("ScalePlayerDamage", "ZBASE", ScaleDamage)


--[[
======================================================================================================================================================
                                           BULLETS
======================================================================================================================================================
--]]


ZBaseReflectedBullet = false


local grabbing_bullet_backup_data = false


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


    return true

end)



--[[
======================================================================================================================================================
                                           SOUNDS
======================================================================================================================================================
--]]


local NPCFootstepSubStr = {
    ["npc_combine_s"] = "npc/combine_soldier/gear",
    ["npc_metropolice"] = "npc/metropolice/gear",
    ["npc_vortigaunt"] = "npc/vort/vort_foot",
    ["npc_zombie"] = "npc/zombie/foot",
    ["npc_poisonzombie"] = "_foot1.wav",
    ["npc_fastzombie"] = "npc/fast_zombie/foot",
    ["npc_headcrab_black"] = "npc/headcrab_poison/ph_step",
    ["npc_headcrab_poison"] = "npc/headcrab_poison/ph_step",
    ["npc_antlion"] = "npc/antlion/foot",
    ["npc_antlionguard"] = "npc/antlion_guard/foot",
    ["npc_zombine"] = "npc/combine_soldier/gear",
}


hook.Add("EntityEmitSound", "ZBASE", function( data )

    -- Silence navigator
    if data.Entity.IsZBaseNavigator then
        return false
    end


    -- Silence "dull state" NPCs
    if IsValid(data.Entity) && data.Entity:GetNWBool("ZBaseNPCCopy_DullState") then
        return false
    end


    if !IsValid(data.Entity) then return end
    if !data.Entity:GetNWBool("IsZBaseNPC") then return end


    local StepSubStr = NPCFootstepSubStr[data.Entity:GetClass()]
    local IsEngineFootStep = !ZBase_EmitSoundCall && ((StepSubStr && string.find(data.SoundName, StepSubStr))
    or string.find(data.SoundName, "footstep"))


    if IsEngineFootStep then
        if SERVER then
            data.Entity:EngineFootStep()
        end

        return false
    end


    if SERVER then
        local value = data.Entity:OnEmitSound( data )
        if value != nil then
            return value
        end
    end


    if value != nil then
        return value
    end

end)


--[[
======================================================================================================================================================
                                           GLOWING EYES
======================================================================================================================================================
--]]


if SERVER then

    util.AddNetworkString("ZBaseAddGlowEyes")
    util.AddNetworkString("ZBaseAddGlowEyes_Success")

end


ZBaseEntsWithGlowingEyes = ZBaseEntsWithGlowingEyes or {}
ZBaseGlowingEyes = {}


local mat = Material( "effects/blueflare1" )


if CLIENT then

    net.Receive("ZBaseAddGlowEyes", function()

        local Ent = net.ReadEntity()
        local Eyes = net.ReadTable()
        

        if IsValid(Ent) then

            Ent.GlowEyes = table.Copy(Eyes)

            table.insert(ZBaseEntsWithGlowingEyes, Ent)

            Ent:CallOnRemove("RemoveEntsWithGlowingEyes", function() table.RemoveByValue(ZBaseEntsWithGlowingEyes, Ent) end)

            net.Start("ZBaseAddGlowEyes_Success")
            net.WriteEntity(Ent)
            net.SendToServer()

        end

    end)

end


if SERVER then
    net.Receive("ZBaseAddGlowEyes_Success", function( _, ply )

        if !ply.NPCsWithGlowEyes then ply.NPCsWithGlowEyes = {} end


        local Ent = net.ReadEntity()


        if IsValid(Ent) then
            ply.NPCsWithGlowEyes[Ent:EntIndex()] = true
    

            Ent:CallOnRemove("NPCsWithGlowEyesRemove"..ply:EntIndex(), function()
                if ply.NPCsWithGlowEyes then
                    ply.NPCsWithGlowEyes[Ent:EntIndex()] = nil
                end
            end)
        end

    end)
end



hook.Add( "PostDrawEffects", "ZBaseGlowingEyes", function()

    if !ZBCVAR.GlowingEyes:GetBool() then return end

    for _, ent in ipairs(ZBaseEntsWithGlowingEyes) do

        if !ent.GlowEyes then continue end
        if ent:GetNoDraw() then continue end

        
        for id, eye in pairs(ent.GlowEyes) do


            if eye.skin != false && ent:GetSkin() != eye.skin then continue end

            local matrix = ent:GetBoneMatrix(eye.bone or 0)
            if matrix then

                local BonePos = matrix:GetTranslation()
                local BoneAng = matrix:GetAngles()
                local pos = BonePos + BoneAng:Forward()*eye.offset.x + BoneAng:Right()*eye.offset.y + BoneAng:Up()*eye.offset.z

                cam.Start3D()
                    render.SetMaterial(mat)
                    render.DrawSprite( pos, eye.scale, eye.scale, eye.color)
                cam.End3D()

            end

        end

    end

end)


--[[
======================================================================================================================================================
                                           ZBASE NPC FOLLOW PLAYER
======================================================================================================================================================
--]]

if SERVER then

    util.AddNetworkString("ZBaseSetFollowHalo")
    util.AddNetworkString("ZBaseRemoveFollowHalo")


    hook.Add( "KeyPress", "ZBaseFollow", function( ply, key )
        if key == IN_USE then
            local tr = ply:GetEyeTrace()
            local ent = tr.Entity


            if ent.PlayerToFollow == ply then
                ent:StopFollowingCurrentPlayer()
            elseif IsValid(ent) && ent.IsZBaseNPC && ent:CanStartFollowPlayers() then
                ent:StartFollowingPlayer(ply)
            end
        end
    end)

end


if CLIENT then
    local mat = Material("effects/blueflare1")


    hook.Add( "RenderScreenspaceEffects", "ZBaseEffects", function()
        local tbl = LocalPlayer().ZBaseFollowHaloEnts
        if tbl then
            for _, v in ipairs(tbl) do
                cam.Start3D()
                    local tr = util.TraceLine({
                        start = v:GetPos()+Vector(0, 0, 50),
                        endpos = v:GetPos()-Vector(0, 0, 400),
                        mask = MASK_NPCWORLDSTATIC,
                    })
                    if tr.Hit then
                        local wepCol = LocalPlayer():GetWeaponColor()
                        local alpha = 60*(1.5+math.sin(CurTime()*3))
                        local col = Color(alpha*wepCol.r, alpha*wepCol.g, alpha*wepCol.b)
                        
                        render.SetMaterial( mat )
                        render.DrawQuadEasy( tr.HitPos+Vector(0, 0, 1), Vector(0, 0, 1), 75, 75, col, ( CurTime() * 75 ) % 360 )
                    end
                cam.End3D()
            end
        end
    end)


    net.Receive("ZBaseSetFollowHalo", function()
        local ent = net.ReadEntity()
        local wepCol = LocalPlayer():GetWeaponColor()
        if !IsValid(ent) then return end

        table.insert(LocalPlayer().ZBaseFollowHaloEnts, ent)
        ent:CallOnRemove("RemoveFromZBaseHaloEnts", function() table.RemoveByValue(LocalPlayer().ZBaseFollowHaloEnts, ent) end)

        chat.AddText(Color(wepCol.r*255, wepCol.g*255, wepCol.b*255), ent:GetNWBool("ZBaseName").." started following you.")


        surface.PlaySound( "buttons/button16.wav" )
    end)


    net.Receive("ZBaseRemoveFollowHalo", function()
        local ent = net.ReadEntity()
        if !IsValid(ent) then return end

        table.RemoveByValue(LocalPlayer().ZBaseFollowHaloEnts, ent)

        surface.PlaySound( "buttons/button16.wav" )
    end)
end


--[[
======================================================================================================================================================
                                           OTHER
======================================================================================================================================================
--]]


hook.Add("OnNPCKilled", "ZBASE", function( npc, attacker, infl)

    if npc.IsZBaseNPC && npc.Dead then return end


    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( npc )
    end

    
    for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
        zbaseNPC:MarkEnemyAsDead(npc, 2)
    end


    if npc.IsZBaseNPC then
        npc:OnDeath( attacker, infl, npc:LastDMGINFO() or DamageInfo(), npc.LastHitGroup )
    end

end)



hook.Add("PlayerDeath", "ZBASE", function( ply, _, attacker )
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( ply )
    end

    for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
        zbaseNPC:MarkEnemyAsDead(ply, 2)
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
    local ZBaseNPCTable = ZBaseNPCs[ zbaseClass ]

    if ZBaseNPCTable then

        ent.ZBaseInitialized = false
        ZBaseInitialize( ent, ZBaseNPCTable, zbaseClass, nil, false, false, true )

    end

end)


-- Add zbase sweps to npc weapon menu if we should
ZBaseNPCWeps = ZBaseNPCWeps or {}
hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )

	if swep.IsZBaseWeapon && class!="weapon_zbase" && swep.NPCSpawnable then
		list.Add( "NPCUsableWeapons", { class = class, title = "[ZBase] "..swep.PrintName } )
        table.insert(ZBaseNPCWeps, class)
	end

end)


-- Don't pickup some zbase weapons
hook.Add("PlayerCanPickupWeapon", "ZBASE", function( ply, wep )
    
	if wep.IsZBaseWeapon && wep.NPCOnly then
        
        if !wep.Pickup_GaveAmmo then
		    ply:GiveAmmo(wep:GetMaxClip1(), wep:GetPrimaryAmmoType())
            wep.Pickup_GaveAmmo = true
        end

		wep:Remove()
        
		return false
	end

end)


-- Disable client ragdolls
hook.Add("CreateClientsideRagdoll", "ZBaseNoRag", function(ent, rag)
	if ent:GetNWBool("IsZBaseNPC") or ent:GetNWBool("ZBaseNPCCopy_DullState") then
		rag:Remove()
	end
end)


-- Disable default server ragdolls
hook.Add("CreateEntityRagdoll", "ZBaseNoRag", function(ent, rag)
    if ent.IsZBaseNPC && !rag.IsZBaseRag then
        rag:Remove()
    end
end)


-- Player trying to shoot NPC
hook.Add( "KeyPress", "ZBASE", function( ply, key )
    if !SERVER then return end



    local wep = ply:GetActiveWeapon()


    if IsValid(wep) &&
    ( (wep:Clip1() > 0 && key == IN_ATTACK) or (wep:Clip2() > 0 && key == IN_ATTACK2)
    or (wep:GetClass()=="weapon_smg1" && ply:GetAmmoCount("SMG1_Grenade")>0 && key == IN_ATTACK2)
    or (wep:GetClass()=="weapon_ar2" && ply:GetAmmoCount("AR2AltFire")>0 && key == IN_ATTACK2)
    or (wep:GetClass()=="weapon_rpg" && ply:GetAmmoCount("RPG_Round")>0 && key == IN_ATTACK) ) then

        local tr = ply:GetEyeTrace()
        local ent = (tr.Entity.IsZBaseNPC && tr.Entity)


        if IsValid(ent) then
            ent:RangeThreatened(ply)
        end

    end
end)