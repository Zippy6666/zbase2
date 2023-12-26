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
    end

end)


--[[
======================================================================================================================================================
                                           ENTITY CREATED: WEAPON STUFF
======================================================================================================================================================
--]]


-- local function BasicPrimaryAttack( wep )

--     local effectdata = EffectData()
--     effectdata:SetFlags(wep.ZB_MuzzleFlashFlags or 1)
--     effectdata:SetEntity(wep)
--     util.Effect( "MuzzleFlash", effectdata )


--     local att = wep:GetAttachment(wep:LookupAttachment("1"))
--     if att && wep.ZB_ShellEject then
--         local effectdata = EffectData()
--         effectdata:SetEntity(wep)
--         effectdata:SetOrigin(att.Pos)
--         effectdata:SetAngles(att.Ang)
--         util.Effect( wep.ZB_ShellEject, effectdata )
--     end


--     wep:FireBullets({
--         Attacker = wep:GetOwner(),
--         Inflictor = wep,
--         Damage = wep.ZB_Primary or 2,
--         AmmoType = wep.ZB_Ammo,
--         Src = wep:GetOwner():GetShootPos(),
--         Dir = wep:GetOwner():GetAimVector(),
--         Spread = Vector(wep.ZB_Spread or 0.025, wep.ZB_Spread or 0.025),
--         Tracer = 2,
--         Num = wep.ZB_NumShots or 1,
--     })

--     wep:EmitSound(wep.ZB_FireSnd)

-- end


-- local HL2Weapon_SWEPTable = {
--     ["weapon_smg1"] = {
--         PrimaryAttack = BasicPrimaryAttack,
--         GetNPCBurstSettings = function() return 6, 8 end,
--         GetNPCRestTimes = function() return 1, 1.5 end,
--         ZB_Damage = 2,
--         ZB_Ammo = "smg1",
--         ZB_ShellEject = "ShellEject",
--         ZB_FireSnd = "Weapon_SMG1.NPC_Single",
--     }
-- }


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

                if own.ZBaseEnhancedCreateEnt then
                    own:ZBaseEnhancedCreateEnt( ent )
                end
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



    -- Make hl2 weapons into sweps or something idk what to call this
    -- local cls = ent:GetClass()

    -- if HL2Weapon_SWEPTable[cls] then
    --     for varname, var in pairs(HL2Weapon_SWEPTable[cls]) do
    --         ent[varname] = var
    --     end
    -- end
end)


--[[
======================================================================================================================================================
                                           THINK/TICK
======================================================================================================================================================
--]]


local NextThink = CurTime()
local NextBehaviourThink = CurTime()


hook.Add("Tick", "ZBASE", function()
    if ZBCVAR.NoThink:GetBool() then return end

    
    -- Think for NPCs that aren't scripted
    if NextThink < CurTime() then
        for _, zbaseNPC in ipairs(ZBaseNPCInstances_NonScripted) do

            zbaseNPC:ZBaseThink()


            if zbaseNPC.ZBaseEnhancedThink then
                zbaseNPC:ZBaseEnhancedThink()
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


    hook.Add("PlayerSpawnedNPC", "ZBASE", function(ply, ent)
        if ply.ZBaseNPCFactionOverride && ply.ZBaseNPCFactionOverride != "" then
            timer.Simple(0, function()
                if !IsValid(ent) or !IsValid(ply) then return end
                if !ent.IsZBaseNPC then return end

                ZBaseSetFaction( ent, ply.ZBaseNPCFactionOverride )
            end)
        end
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


    -- Attacker is ZBase NPC
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:DealDamage( dmg, ent )


        if attacker.ZBaseEnhancedDealDamage then
            attacker:ZBaseEnhancedDealDamage( dmg, ent )
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


        -- Set to 15 damage if it shouldn't use "full" damage
        if (!ZBCVAR.FullHL2WepDMG_NPC:GetBool() && (ent:IsNPC() or ent:IsNextBot()))
        or (!ZBCVAR.FullHL2WepDMG_PLY:GetBool() && ent:IsPlayer()) then

            dmg:SetDamage(15)

        elseif (ZBCVAR.FullHL2WepDMG_NPC:GetBool() && (ent:IsNPC() or ent:IsNextBot())) then
            -- NPC comball full damage


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


    
    -- if ent.IsZBaseNPC then
    --     -- Boost accuracy for some weapons --
    --     local wep = ent:GetActiveWeapon()
    --     local ene = ent:GetEnemy()

    --     if IsValid(wep) && IsValid(ene) && ZBaseWeaponAccuracyBoost[wep:GetClass()] then
    --         local sprd = (5 - ent:GetCurrentWeaponProficiency())/ZBaseWeaponAccuracyBoost[wep:GetClass()]
    --         data.Spread = Vector(sprd, sprd)
    --         data.Dir = (ene:WorldSpaceCenter() - ent:GetShootPos()):GetNormalized()
    --     end
    -- end
    

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
    -- stfu navigator slave mf, you have no right to speak
    if data.Entity.IsZBaseNavigator then
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


if !ZBaseEntsWithGlowingEyes then
    ZBaseEntsWithGlowingEyes = {}
end


ZBaseGlowingEyes = {}


if CLIENT then
    net.Receive("ZBaseAddGlowEyes", function()
        local Ent = net.ReadEntity()
        local Eyes = net.ReadTable()
        
        
        -- print("ZBaseAddGlowEyes", LocalPlayer())
        

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
            
            -- print("ZBaseAddGlowEyes_Success", ply, Ent, "SUCCESS")

            Ent:CallOnRemove("NPCsWithGlowEyesRemove"..ply:EntIndex(), function()
                if ply.NPCsWithGlowEyes then
                    ply.NPCsWithGlowEyes[Ent:EntIndex()] = nil
                end
            end)
        end
    end)
end


local mat = Material( "effects/blueflare1" )
hook.Add( "RenderScreenspaceEffects", "ZBaseGlowingEyes", function()
    if !ZBCVAR.GlowingEyes:GetBool() then return end

    for _, ent in ipairs(ZBaseEntsWithGlowingEyes) do
        if !ent.GlowEyes then continue end
        if ent:GetNoDraw() then continue end

        
        for _, eye in ipairs(ent.GlowEyes) do
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
        if ( key == IN_USE ) then
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
        for _, v in ipairs(LocalPlayer().ZBaseFollowHaloEnts) do
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

	if swep.IsZBaseWeapon && class!="weapon_zbase" && swep.NPCSpawnable then
		list.Add( "NPCUsableWeapons", { class = class, title = "[ZBase] "..swep.PrintName } )
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


    if wep.IsZBaseEngineWeapon then
        return false
    end

end)


-- Disable client ragdolls
hook.Add("CreateClientsideRagdoll", "ZBaseNoRag", function(ent, rag)
	if ent:GetNWBool("IsZBaseNPC") then
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