local Developer = GetConVar("developer")


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
            local wepCol = LocalPlayer():GetWeaponColor():ToColor()
            chat.AddText(wepCol, "ZBase is running on this server! Github link: https://github.com/Zippy6666/zbase2 (this message can be disabled in the ZBase options tab).")
        end

    end


    -- Precache zbase ents
    -- if SERVER && ZBCVAR.Precache:GetBool() then
    --     ZBasePrecacheEnts()
    -- end

end)

--[[
======================================================================================================================================================
                                           ENTITY CREATION
======================================================================================================================================================
--]]

if SERVER then

    hook.Add("OnEntityCreated", "ZBASE", function( ent )
        conv.callNextTick(function()
            if !IsValid(ent) then return end


            -- ZBase init stuff when NOT SPAWNED FROM MENU
            -- (also when not spawned from a dupe)
            -- Uses parentname to determine if it is a zbase npc
            -- Uses the "copy system"
            local zbaseClass = ent:GetKeyValues().parentname
            if ZBaseNPCs[zbaseClass] && !ent.IsDupeSpawnedZBaseNPC then
                ZBaseNPCCopy( ent, zbaseClass, true )
            end


            -- When a entity owned by a ZBase NPC is created
            local own = ent:GetOwner()
            if IsValid(own) && own.IsZBaseNPC then
                own:OnOwnedEntCreated( ent )

                if own.Patch_CreateEnt then
                    own:Patch_CreateEnt( ent )
                end
            end
        end)

        conv.callAfterTicks(2, function()

            if !IsValid(ent) then return end

            -- Give ZBASE faction and start using
            local shouldUseRelSys = ZBaseShouldUseRelationshipSys(ent)
            if shouldUseRelSys then

                if Developer:GetBool() then
                    MsgN("adding ", ent, " to ZBASE relationship system...")
                end

                -- Very important!
                table.InsertEntity(ZBaseRelationshipEnts, ent)

                -- If a ZBASE NPC, apply the supplied start faction, or the override chosen by the player
                -- If a different NPC, find a fitting ZBASE faction to apply
                if ent.IsZBaseNPC or ent.ForceSetZBaseFaction then

                    local PlayerFactionOverride = IsValid(ent.ZBase_PlayerWhoSpawnedMe) && ent.ZBase_PlayerWhoSpawnedMe.ZBaseNPCFactionOverride
                    ZBaseSetFaction(ent, PlayerFactionOverride or nil)

                else

                    ZBaseSetFaction(ent, ZBaseFactionTranslation[ent.m_iClass or ent:Classify()])

                end
            end
        
        end)
    end)
end


    -- Override code for spawning zbase npcs from regular spawn menu
hook.Add("PlayerSpawnNPC", "ZBASE", function(ply, npc_type, wep_cls)

    if ZBase_PlayerSpawnNPCHookCall then
        return
    end
    
    local replace_cls = ZBCVAR.Replace:GetBool() && ZBASE_MENU_REPLACEMENTS_FLIPPED[npc_type]

    npc_type = replace_cls or string.Right(npc_type, #npc_type-6)
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

if SERVER then

    local NextThink = CurTime()
    local NextBehaviourThink = CurTime()


    hook.Add("Tick", "ZBASE", function()


        -- Regular think for non-scripted NPCs
        if NextThink < CurTime() then

            for _, zbaseNPC in ipairs(ZBaseNPCInstances_NonScripted) do

                zbaseNPC:ZBaseThink()

                if zbaseNPC.Patch_Think then
                    zbaseNPC:Patch_Think()
                end

            end

            NextThink = CurTime()+0.1

        end



        -- Behaviour tick
        if !GetConVar("ai_disabled"):GetBool()
        && NextBehaviourThink < CurTime() then

            for k, func in ipairs(ZBaseBehaviourTimerFuncs) do
                local entValid = func()

                if !entValid then
                    table.remove(ZBaseBehaviourTimerFuncs, k)
                end
            end

            NextBehaviourThink = CurTime() + 0.4

        end


        for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
            zbaseNPC:FrameTick()
        end

    end)

end

--[[
======================================================================================================================================================
                                           RELATIONSHIP STUFF
======================================================================================================================================================
--]]


if SERVER then

    util.AddNetworkString("ZBasePlayerFactionSwitch")
    util.AddNetworkString("ZBaseNPCFactionOverrideSwitch")


    net.Receive("ZBasePlayerFactionSwitch", function( _, ply )
        local faction = net.ReadString()
        ply.ZBaseFaction = faction

        for _, v in ipairs(ZBaseNPCInstances) do
            v:UpdateRelationships()
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
    local att_own = (IsValid(attacker) && attacker:GetOwner()) or NULL


    -- NPCs with ZBaseNPCCopy_DullState should not be able to take damage, nor should they be able to deal damage
    if ent.ZBaseNPCCopy_DullState or attacker.ZBaseNPCCopy_DullState or infl.ZBaseNPCCopy_DullState then
        dmg:SetDamage(0)
        return true
    end


    -- Attacker is ZBase NPC
    local zbase_attacker = IsValid(attacker) && attacker.IsZBaseNPC && attacker


    -- ZBase NPC is the owner of this attacker, maybe this attacker is a grenade
    if IsValid(att_own) && att_own.IsZBaseNPC then
        zbase_attacker = att_own
    end


    -- Run ZBase NPCs' DealDamage
    if zbase_attacker then
        zbase_attacker:DealDamage( dmg, ent )
        if zbase_attacker.Patch_DealDamage then
            zbase_attacker:Patch_DealDamage( dmg, ent )
        end
    end


    -- Victim is ZBase NPC
    if ent.IsZBaseNPC then

        -- Run OnEntityTakeDamage
        local value = ent:OnEntityTakeDamage( dmg )
        if value != nil then
            return value
        end

    end

end)


hook.Add("PostEntityTakeDamage", "ZBASE", function( ent, dmg )
    if ent.IsZBaseNPC then
        ent:OnPostEntityTakeDamage( dmg )
    end
end)


hook.Add("ScaleNPCDamage", "ZBASE", function ( npc, hit_gr, dmg )
    local attacker = dmg:GetAttacker()

    if npc.IsZBaseNPC then
        npc:OnScaleDamage( dmg, hit_gr )
    end
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
    if !IsValid(data.Entity) then return end


    -- Silence navigator
    if data.Entity.IsZBaseNavigator then
        return false
    end


    -- Silence "dull state" NPCs
    if IsValid(data.Entity) && data.Entity:GetNWBool("ZBaseNPCCopy_DullState") then
        return false
    end



    -- ZBase NPCs
    if data.Entity:GetNWBool("IsZBaseNPC") then
        -- Mute engine footsteps, and call EngineFootStep
        local StepSubStr = NPCFootstepSubStr[data.Entity:GetClass()]
        local IsEngineFootStep = !ZBase_EmitSoundCall && ((StepSubStr && string.find(data.SoundName, StepSubStr)) or string.find(data.SoundName, "footstep"))
        if IsEngineFootStep then
            if SERVER then
                data.Entity:EngineFootStep()
            end

            return false
        end

        -- On emit sound call
        if SERVER then
            local value = data.Entity:OnEmitSound( data )
            if value != nil then
                return value
            end
        end
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


end


if CLIENT then
    local mat = Material("effects/blueflare1")


    local startoffset = Vector(0, 0, 50)
    local endoffset = Vector(0, 0, 400)
    local up = Vector(0, 0, 1)
    hook.Add( "RenderScreenspaceEffects", "ZBaseEffects", function()
        local tbl = LocalPlayer().ZBaseFollowHaloEnts
        if tbl then
            for _, v in ipairs(tbl) do
                cam.Start3D()
                    local tr = util.TraceLine({
                        start = v:GetPos()+startoffset,
                        endpos = v:GetPos()-endoffset,
                        mask = MASK_NPCWORLDSTATIC,
                    })
                    if tr.Hit then
                        local wepCol = LocalPlayer():GetWeaponColor():ToColor()

                        render.SetMaterial( mat )
                        render.DrawQuadEasy( tr.HitPos+tr.HitNormal*1.5, up, 60, 60, wepCol, ( CurTime() * 75 ) % 360 )
                    end
                cam.End3D()
            end
        end
    end)


    net.Receive("ZBaseSetFollowHalo", function()
        local ent = net.ReadEntity()
        local wepCol = LocalPlayer():GetWeaponColor():ToColor()
        local name = net.ReadString()
        if !IsValid(ent) then return end

        table.InsertEntity(LocalPlayer().ZBaseFollowHaloEnts, ent)

        chat.AddText(wepCol, name.." started following you.")
        surface.PlaySound( "buttons/button16.wav" )
    end)


    net.Receive("ZBaseRemoveFollowHalo", function()
        local ent = net.ReadEntity()
        local wepCol = LocalPlayer():GetWeaponColor():ToColor()
        local name = net.ReadString()
        if !IsValid(ent) then return end

        table.RemoveByValue(LocalPlayer().ZBaseFollowHaloEnts, ent)

        chat.AddText(wepCol, name.." stopped following you.")
        surface.PlaySound( "buttons/button16.wav" )
    end)
end

--[[
======================================================================================================================================================
                                           Ragdolls
======================================================================================================================================================
--]]

if SERVER then
    util.AddNetworkString("ZBaseClientRagdoll")
end

-- Client ragdolls
hook.Add("CreateClientsideRagdoll", "ZBaseRagHook", function(ent, rag)

	if ent:GetNWBool("ZBaseNPCCopy_DullState") then
		rag:Remove()
        return
	end

    if ent:GetNWBool("IsZBaseNPC") then

        if ent:GetShouldServerRagdoll() then
            rag:Remove()
            return
        end

        -- Set submaterials to ragdoll if any
        if istable(ent.SubMaterials) then
            for k, v in pairs(ent.SubMaterials) do
                rag:SetSubMaterial(k, v)
            end
        end

    end

end)
net.Receive("ZBaseClientRagdoll", function(...)
    ZBaseClientRagdoll(net.ReadEntity)
end)


-- Disable default server ragdolls
hook.Add("CreateEntityRagdoll", "ZBaseRagHook", function(ent, rag)
    if ent.IsZBaseNPC && !rag.IsZBaseRag then
        rag:Remove()
    end
end)


--[[
======================================================================================================================================================
                                           OTHER
======================================================================================================================================================
--]]


hook.Add( "KeyPress", "ZBaseUse", function( ply, key )
    if !IsValid(ply) then return end


    local tr = ply:GetEyeTrace()
    local ent = tr.Entity


    if key == IN_USE && IsValid(ent) && ent.IsZBaseNPC && ent:ZBaseDist(ply, {within=200}) then

        -- Start/stop following
        if !IsValid(ent.PlayerToFollow) && ent:CanStartFollowPlayers() then
            ent:StartFollowingPlayer(ply)
        elseif ent.PlayerToFollow == ply then
            ent:StopFollowingCurrentPlayer()
        end

        -- On NPC used
        if ( isfunction( ent.OnUse ) ) then
            ent:OnUse(ply)
        end

    end
end)



hook.Add("OnNPCKilled", "ZBASE", function( npc, attacker, infl)

    if npc.IsZBaseNPC && npc.Dead then return end


    -- Call on killed ent
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( npc )
    end


    -- Mark enemy as dead
    for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
        zbaseNPC:MarkEnemyAsDead(npc, 2)
    end


    -- On death
    if npc.IsZBaseNPC then
        npc:OnDeath( attacker, infl, npc:LastDMGINFO() or DamageInfo(), npc.ZBLastHitGr )
    end

end)


-- Find nearest zbase ally to player
local function FindNearestZBaseAllyToPly( ply ) 
    local mindist
    local ally

    for _, v in ipairs(ents.FindInSphere(ply:GetPos(), 600)) do
        if !v.IsZBaseNPC then continue end
        if v.ZBaseFaction == "none" then continue end
        if v.ZBaseFaction != ply.ZBaseFaction then continue end

        local dist = ply:GetPos():DistToSqr(v:GetPos())

        if !mindist or dist < mindist then
            mindist = dist
            ally = v
        end
    end

    return ally
end


hook.Add("PlayerDeath", "ZBASE", function( ply, infl, attacker )

    if table.IsEmpty(ZBaseNPCInstances) then return end -- No ZBase NPCs, don't do any ZBase stuff on player death


    local ally = FindNearestZBaseAllyToPly(ply) -- Find nearest zbase ally to player
    local deathpos = ply:GetPos()


    
    if IsValid(ally) && ally:Visible(ply) then
        if isfunction(ally.OnAllyDeath) then
            ally:OnAllyDeath(ply)
        end
    
        if ally.AllyDeathSound_Chance && math.random(1, ally.AllyDeathSound_Chance) == 1 then
            timer.Simple(0.5, function()
                if IsValid(ally) then
                    ally:EmitSound_Uninterupted(ally.AllyDeathSounds)
    
                    if ally.AllyDeathSounds != "" && ally:GetNPCState()==NPC_STATE_IDLE then
                        ally:FullReset()
                        ally:Face(deathpos, ally.InternalCurrentVoiceSoundDuration)
                    end
                end
            end)
        end
    end

    -- ZBase NPC killed player
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( ply )
    end

    -- Mark this player as dead for all ZBase NPCs
    for _, zbaseNPC in ipairs(ZBaseNPCInstances) do
        zbaseNPC:MarkEnemyAsDead(ply, 2)
    end

end)



-- Gravity gun punt for aerial ZBASE NPCs
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

        ent.ZBaseInitialized = false -- So that it can be initialized again
        ent.IsDupeSpawnedZBaseNPC = true

        local Equipment, wasSpawnedOnCeiling, bDropToFloor = false, false, true
        ZBaseInitialize( ent, ZBaseNPCTable, zbaseClass, Equipment, wasSpawnedOnCeiling, bDropToFloor )

    end

end)


-- Add zbase sweps to npc weapon menu if we should
hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )

	if swep.IsZBaseWeapon && class!="weapon_zbase" && swep.NPCSpawnable then
		list.Add( "NPCUsableWeapons", { class = class, title = "ZBASE: "..swep.PrintName.." ("..class..")" } )
        table.insert(ZBaseNPCWeps, class)
	end

end)


-- Don't pickup some zbase weapons
hook.Add("PlayerCanPickupWeapon", "ZBASE", function( ply, wep )

	if wep.IsZBaseWeapon && wep.NPCOnly then

        if !wep.Pickup_GaveAmmo then
		    ply:GiveAmmo(wep.Primary.DefaultClip, wep:GetPrimaryAmmoType())
            wep.Pickup_GaveAmmo = true
        end

		wep:Remove()

		return false
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
