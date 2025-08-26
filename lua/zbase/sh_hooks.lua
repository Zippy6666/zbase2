local Developer             = GetConVar("developer")
ReloadedSpawnmenuRecently   = false

--[[
======================================================================================================================================================
                                           INIT POST ENTITY
======================================================================================================================================================
--]]

hook.Add("InitPostEntity", "ZBASE", function()
    -- Override functions
    timer.Simple(0.5, function()
        include("zbase/sh_override_functions.lua")
    end)

    -- Stuff ran on CLIENT post entity initialization
    if CLIENT then
        -- Follow halo table
        LocalPlayer().ZBaseFollowHaloEnts = LocalPlayer().ZBaseFollowHaloEnts or {}

        -- Add variable that checks if the spawn menu was recently reloaded
        local spawnmenu_reload = concommand.GetTable()["spawnmenu_reload"]
        concommand.Add("spawnmenu_reload", function(...)
            ReloadedSpawnmenuRecently = true
            spawnmenu_reload(...)
            timer.Simple(0.5, function()
                ReloadedSpawnmenuRecently = false
            end)
        end)

        -- Welcome screen
        if ZBCVAR.PopUp:GetBool() then
            local frame = vgui.Create("DFrame")
            frame:SetTitle("ZBASE")
            frame:SetSize(1400, 700)
            frame:Center()
            frame:MakePopup()
            frame:SetBackgroundBlur(true)

            local html = vgui.Create("DHTML", frame)
            html:Dock(TOP)
            html:SetHeight(600)

            -- Replace "YOUR_COLLECTION_ID" with your actual Workshop collection ID
            local workshopLink = "https://steamcommunity.com/sharedfiles/filedetails/?id=3390418473"
            html:OpenURL(workshopLink)

            local closeButton = vgui.Create("DButton", frame)
            closeButton:SetText("Close")
            closeButton:Dock(BOTTOM)
            closeButton:SetHeight(30)
            closeButton.DoClick = function()
                frame:Close()
            end

            frame.OnClose = function()
                notification.AddLegacy("You can disable the ZBase pop-up in the ZBase settings tab.", NOTIFY_HINT, 5)
                chat.AddText(Color(0, 200, 255), "You can disable the ZBase pop-up in the ZBase settings tab.")
            end
        end
    end
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
            -- Catch that
            local own = ent:GetOwner()
            if IsValid(own) && own.IsZBaseNPC then
                own:OnOwnedEntCreated( ent )

                if own.Patch_CreateEnt then
                    own:Patch_CreateEnt( ent )
                end
            end

            -- Same thing goes for a paranted entity
            local parent = ent:GetParent()
            if IsValid(parent) && parent.IsZBaseNPC then
                parent:OnParentedEntCreated( ent )
            end
        end)

        -- Two ticks after any NPC spawns..
        -- Run some ZBase faction logic
        conv.callAfterTicks(2, function()
            if !IsValid(ent) then return end

            -- Give ZBASE faction and start using
            local shouldUseRelSys = ZBaseShouldUseRelationshipSys(ent)
            if shouldUseRelSys then
                -- Very important!
                table.InsertEntity(ZBaseRelationshipEnts, ent)

                -- If a ZBASE NPC, apply the supplied start faction, or the override chosen by the player
                -- If a different NPC, find a fitting ZBASE faction to apply
                if ent.IsZBaseNPC or ent.ForceSetZBaseFaction then
                    local PlayerFactionOverride = IsValid(ent.ZBase_PlayerWhoSpawnedMe) && ent.ZBase_PlayerWhoSpawnedMe.ZBaseNPCFactionOverride
                    ZBaseSetFaction(ent, PlayerFactionOverride or nil)
                else
                    ZBaseSetFaction(ent,
                        ZBaseFactionTranslation[ent.m_iClass or ent:Classify()]
                    )
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
        -- if NextThink < CurTime() then
        --     for _, zbaseNPC in ipairs(ZBaseNPCInstances_NonScripted) do
        --         zbaseNPC:ZBaseThink()

        --         if zbaseNPC.Patch_Think then
        --             zbaseNPC:Patch_Think()
        --         end
        --     end

        --     NextThink = CurTime()+0.1
        -- end

        -- Behaviour tick
        if !GetConVar("ai_disabled"):GetBool()
        && NextBehaviourThink < CurTime() then
            for i = #ZBaseBehaviourTimerFuncs, 1, -1 do
                local func = ZBaseBehaviourTimerFuncs[i]
                local entValid = func()

                if not entValid then
                    table.remove(ZBaseBehaviourTimerFuncs, i)
                end
            end

            NextBehaviourThink = CurTime() + 0.4
        end

        for i = 1, #ZBaseNPCInstances do
            ZBaseNPCInstances[i]:FrameTick()
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
        ZBaseSetFaction(ply, faction, ply)

        for i = 1, #ZBaseNPCInstances do
            ZBaseNPCInstances[i]:UpdateRelationships()
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

hook.Add("EntityFireBullets", "ZBASE", function( ent, data )
    if SERVER && ent.IsZBaseNPC then
        local return_value = ent:OnFireBullet( data )
        if return_value == false then
            data.Num = 0
            data.Distance = 0
            return true
        elseif return_value == true then
            return true
        end
    end

    if SERVER && !ZBCVAR.PlayerHurtAllies:GetBool() && ZBaseNPCCount > 0 then
        local own = ent:GetOwner()
        local shooterPly = (own:IsPlayer() && own) or (ent:IsPlayer() && ent)

        if shooterPly then
            local tr = util.TraceLine({
                start = data.Src,
                endpos = data.Src+data.Dir*10000,
                mask = MASK_SHOT,
                filter = shooterPly,
            })

            if IsValid(tr.Entity) && tr.Entity.IsZBaseNPC && tr.Entity:Disposition(shooterPly) == D_LI then
                data.IgnoreEntity = tr.Entity
                data.Num = 0
                data.Distance = 0
                return true
            end
        end
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
        local IsEngineFootStep = !IsEmitSoundCall && ((StepSubStr && string.find(data.SoundName, StepSubStr)) or string.find(data.SoundName, "footstep"))
        if IsEngineFootStep then
            if SERVER then
                data.Entity:EngineFootStep()
            end

            return false
        end

        -- Mute default "engine" voice when we should
        local isVoiceSound = isnumber(data.SentenceIndex) or data.Channel == CHAN_VOICE
        if !IsEmitSoundCall && data.Entity.MuteDefaultVoice && isVoiceSound then
            return false
        end

        -- Mute default sounds if we should
        if !IsEmitSoundCall && data.Entity.MuteAllDefaultSoundEmittions then
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

ZBaseEntsWithGlowingEyes    = ZBaseEntsWithGlowingEyes or {}
ZBaseGlowingEyes            = {}
local mat                   = Material( "effects/blueflare1" )

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

    for i = 1, #ZBaseEntsWithGlowingEyes do
        local ent = ZBaseEntsWithGlowingEyes[i]
        if !istable(ent.GlowEyes) then continue end
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
    local mat           = Material("effects/blueflare1")
    local startoffset   = Vector(0, 0, 50)
    local endoffset     = Vector(0, 0, 400)
    local up            = Vector(0, 0, 1)

    hook.Add( "RenderScreenspaceEffects", "ZBaseFollowHalo", function()
        if !ZBCVAR.FollowHalo:GetBool() then return end
        local tbl = LocalPlayer().ZBaseFollowHaloEnts
        if tbl then
            for i = 1, #tbl do
                local v = tbl[i]
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

        local hadhalo = table.RemoveByValue(LocalPlayer().ZBaseFollowHaloEnts, ent)!=false

        table.InsertEntity(LocalPlayer().ZBaseFollowHaloEnts, ent)

        if !hadhalo then
            chat.AddText(wepCol, name.." started following you.")
            surface.PlaySound( "buttons/button16.wav" )
        end
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

if CLIENT then
    net.Receive("ZBaseClientRagdoll", function()
        local ent = net.ReadEntity() if !IsValid(ent) then return end
        ent:BecomeRagdollOnClient()
    end)
end

-- Client ragdolls
hook.Add("CreateClientsideRagdoll", "ZBaseRagHook", function(ent, rag)
    -- No ragdolls for "dull state" npcs
	if ent:GetNWBool("ZBaseNPCCopy_DullState") then
		rag:Remove()
        return
	end

    -- ZBase NPC...
    if ent:GetNWBool("IsZBaseNPC") then
        -- Copy submaterials
        for k, v in ipairs(ent:GetMaterials()) do
            rag:SetSubMaterial(k-1, ent:GetSubMaterial(k - 1))
        end

        for i = 1, #ent:GetMaterials() do
            rag:SetSubMaterial(i-1, ent:GetSubMaterial(i - 1))
        end
    end
end)

-- Server ragdolls
ZBaseRagdolls = ZBaseRagdolls or {}
local ai_serverragdolls = GetConVar("ai_serverragdolls")
hook.Add("CreateEntityRagdoll", "ZBaseRagHook", function(ent, rag)
    -- Is ZBase NPC..
    if ent.IsZBaseNPC then
        -- Copy submaterials
        for k, v in ipairs(ent:GetMaterials()) do
            rag:SetSubMaterial(k-1, ent:GetSubMaterial(k - 1))
        end

        local dmg = ent:LastDMGINFO() -- Get last damage info

        -- Run "custom on death" now, even if the ragdoll may be invalid
        -- Create basic damage info if none was stored
        if !dmg then
            local basicdmg = DamageInfo()
            basicdmg:SetDamageForce(vector_up)
            basicdmg:SetDamagePosition(ent:GetPos())
            basicdmg:SetInflictor(ent)
            basicdmg:SetAttacker(ent)
            basicdmg:SetDamageType(DMG_GENERIC)
        end
        ent:CustomOnDeath(dmg or basicdmg, ent.ZBLastHitGr or HITGROUP_GENERIC, rag)

        -- Remove ragdoll if undesired by the user
        -- or if the NPC was gibbed by ZBase
        if !ent.HasDeathRagdoll or ent.ZBase_WasGibbedOnDeath then
            rag:Remove()
            return
        end

        if !ai_serverragdolls:GetBool() then
            -- ZBase ragdoll with keep corpses off

            -- Nocollide
            rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

            -- Put in ragdoll table
            table.insert(ZBaseRagdolls, rag)

            -- Remove one ragdoll if there are too many
            if #ZBaseRagdolls > ZBCVAR.MaxRagdolls:GetInt() then

                local ragToRemove = ZBaseRagdolls[1]
                table.remove(ZBaseRagdolls, 1)
                ragToRemove:Remove()

            end

            -- Remove ragdoll after delay if that is active
            if ZBCVAR.RemoveRagdollTime:GetBool() then
                SafeRemoveEntityDelayed(rag, ZBCVAR.RemoveRagdollTime:GetInt())
            end

            -- Remove from table on ragdoll removed
            rag:CallOnRemove("ZBase_RemoveFromRagdollTable", function()
                table.RemoveByValue(ZBaseRagdolls, rag)
            end)

            -- Remove from undo/cleanup lists
            undo.ReplaceEntity( rag, NULL )
            cleanup.ReplaceEntity( rag, NULL )
        end
    end
end)

--[[
======================================================================================================================================================
                                           EVENTS
======================================================================================================================================================
--]]

hook.Add( "KeyPress", "ZBaseUse", function( ply, key )
    if !IsValid(ply) then return end


    local tr = ply:GetEyeTrace()
    local ent = tr.Entity


    if key == IN_USE && IsValid(ent) && ent.IsZBaseNPC && ent:ZBaseDist(ply, {within=200}) then

        if !ent.Patch_UseEngineFollow or ( ent.Patch_UseEngineFollow && !ent:Patch_UseEngineFollow() ) then
            -- Start/stop following
            if !IsValid(ent.PlayerToFollow) && ent:CanStartFollowPlayers() then
                ent:StartFollowingPlayer(ply)
            elseif ent.PlayerToFollow == ply then
                ent:StopFollowingCurrentPlayer()
            end
        end

        -- On NPC used
        if ( isfunction( ent.OnUse ) ) then
            ent:OnUse(ply)
        end

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

-- Don't pickup some ZBASE weapons
-- Give ammo instead
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
-- Make NPC aware of this
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

hook.Add("AcceptInput", "ZBASE", function(ent, input, activator, ent, value)
    -- Engine follow
    if game.SinglePlayer() && ZBaseNPCCount > 0 && ent==Entity(1) && input == "Use" then

        local entsInSphere = ents.FindInSphere(ent:GetShootPos(), 125)
        for i = 1, #entsInSphere do
            local v = entsInSphere[i]
            if v.Patch_UseEngineFollow && v:Patch_UseEngineFollow() then
                v:CONV_CallNextTick(function()
                    local squad = v:GetSquad()

                    if squad == "player_squad" then
                        v:StartFollowingPlayer(Entity(1), true, true)
                    else
                        v:StopFollowingCurrentPlayer(false, true)
                    end

                    conv.devPrint(v, " squad is '", (squad == "" && "empty string") or squad or "nothing", "'")
                end)
            end
        end
    end

    if ent.IsZBaseNPC then
        ent:CustomAcceptInput(input, activator, ent, value)
    end
end)

-- Reset settings code
if SERVER then
    concommand.Add("zbase_resetsettings", function(ply)
        if IsValid(ply) && ply:IsPlayer() && !ply:IsSuperAdmin() then return end

        for k, v in pairs(ZBCVAR or {}) do
            if !v.Revert then continue end -- Not a cvar?
            v:Revert()
        end
    end)
end


-- Add ZBASE SWEPS to npc weapon menu if we should
hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )
	if swep.IsZBaseWeapon && class!="weapon_zbase" && swep.NPCSpawnable then
		list.Add( "NPCUsableWeapons", { class = class, title = swep.PrintName } )
        table.insert(ZBaseNPCWeps, class)
	end
end)

--[[
======================================================================================================================================================
                                           DEATH STUFF
======================================================================================================================================================
--]]

-- ZBASE NPC Logic when an NPC dies
hook.Add("OnNPCKilled", "ZBASE", function( npc, attacker, infl)
    if npc.IsZBaseNPC && npc.Dead then return end

    -- Call on killed ent
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( npc )
    end

    -- Mark enemy as dead
    for i = 1, #ZBaseNPCInstances do
        ZBaseNPCInstances[i]:MarkEnemyAsDead(npc, 2)
    end

    -- On death
    if npc.IsZBaseNPC then
        npc:OnDeath( attacker, infl, npc:LastDMGINFO() or DamageInfo(), npc.ZBLastHitGr )
    end
end)

-- Find nearby ZBASE allies to player
local function FindNearestZBaseAllyToPly( ply, returntable )
    if returntable then -- Return the table of all nearby allies
        local allies = {}
        local entsInSphere = ents.FindInSphere(ply:GetPos(), 600)
        for i = 1, #entsInSphere do
            local v = entsInSphere[i]
            if !v.IsZBaseNPC then continue end
            if v.ZBaseFaction == "none" then continue end
            if v.ZBaseFaction != ply.ZBaseFaction then continue end
            table.insert(allies, v)
        end

        return allies
    end

    local mindist
    local ally
    local entsInSphere = ents.FindInSphere(ply:GetPos(), 600)
    for i = 1, #entsInSphere do
        local v = entsInSphere[i]
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

-- ZBASE NPC logic when a player dies
hook.Add("PlayerDeath", "ZBASE", function( ply, infl, attacker )
    if table.IsEmpty(ZBaseNPCInstances) then return end -- No ZBase NPCs, don't do any ZBase stuff on player death

    local allies = FindNearestZBaseAllyToPly(ply, true)
    for i = 1, #allies do
        local ally = allies[i]
        if IsValid(ally) && isfunction(ally.OnAllyDeath) && ally:Visible(ply) then
            ally:OnAllyDeath(ply)
        end
    end

    local ally = FindNearestZBaseAllyToPly(ply)
    if IsValid(ally) && ally:Visible(ply) then
        if isfunction(ally.OnAllyDeath) then
            ally:OnAllyDeath(ply)
        end

        if ally.AllyDeathSound_Chance && math.random(1, ally.AllyDeathSound_Chance) == 1 then
            local deathpos = ply:GetPos()
            ally:ImTheNearestAllyAndThisIsMyHonestReaction(deathpos)
        end
    end

    -- ZBase NPC killed player
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( ply )
    end

    -- Mark this player as dead for all ZBase NPCs
    for i = 1, #ZBaseNPCInstances do
        ZBaseNPCInstances[i]:MarkEnemyAsDead(ply, 2)
    end
end)
