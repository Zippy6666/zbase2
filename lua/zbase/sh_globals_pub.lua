-- Useful globals

local up = Vector(0, 0, 1)

--[[
======================================================================================================================================================
                                           ENUMS / CONSTANTS
======================================================================================================================================================
--]]

-- SNPC types
ZBASE_SNPCTYPE_WALK = 1
ZBASE_SNPCTYPE_FLY = 2

-- SNPC behaviours when enemy can't be reached
ZBASE_CANTREACHENEMY_HIDE = 1
ZBASE_CANTREACHENEMY_FACE = 2

-- SNPC behaviours when enemy is too close
ZBASE_TOOCLOSEBEHAVIOUR_NONE = 0
ZBASE_TOOCLOSEBEHAVIOUR_FACE = 1
ZBASE_TOOCLOSEBEHAVIOUR_BACK = 2

-- Default sight distance
ZBASE_DEFAULT_SIGHT_DIST = 4096

--[[
======================================================================================================================================================
                                           UTILITIES
======================================================================================================================================================
--]]

-- Should be at the top of your NPC file, like this:
-- local NPC = FindZBaseTable(debug.getinfo(1, 'S'))
function FindZBaseTable(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split-1]

    if name == "zbase" then
        name = "npc_zbase"
    end 
    
    return ZBaseNPCs[name]
end 

-- Should be at the top of your NPC's behaviour file if you have any, like this:
-- local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))
function FindZBaseBehaviourTable(debuginfo)
    if SERVER then
        return FindZBaseTable(debuginfo).Behaviours
    end
end 

-- Changes a category's icon to whatever you like
-- You probably want to run this in a hook like initialize
function ZBaseSetCategoryIcon( category, path )
    if SERVER then return end
    ZBaseCategoryImages[category] = path
end 

-- Clamps a direction in a view cone of a certain angle
-- Can be used to prevent NPCs from firing bullets out of their ass for example
function ZBaseClampDirection(nrm, nrmForward, flMaxDeg)
    flMaxRad = math.rad(flMaxDeg) -- Convert degrees to radians for dot product comparison

    -- Calculate dot product (cosine of angle between vectors)
    local flDot = nrm:Dot(nrmForward)

    -- If angle is already within limits, return original direction
    if flDot >= math.cos(flMaxRad) then
        return nrm
    end

    -- Calculate rejection of 'nrm' perpendicular to 'nrmForward'
    local flProjection = nrm:Dot(nrmForward)
    local vRejection = nrm - (nrmForward * flProjection)
    vRejection:Normalize()

    -- Construct new direction at the maximum allowed angle
    local flClampedDot = math.cos(flMaxRad)
    local flClampedSin = math.sin(flMaxRad)
    local vClampedDir = (nrmForward * flClampedDot) + (vRejection * flClampedSin)

    return vClampedDir:GetNormalized()
end

--[[
======================================================================================================================================================
                                           NPCS / RELATIONSHIPS
======================================================================================================================================================
--]]

-- Spawn a ZBase NPC
-- 'class' - The ZBase NPC class, example: 'zb_combine_soldier'
-- 'pos' - The position to spawn it on (optional, will be Vector(0,0,0) otherwise)
-- 'normal' - The normal to spawn it on (optional)
-- 'weapon_class' The weapon class to equip the npc with (optional), set to "default" to make it use its default weapons
-- 'spawn_flags' - (optional) The spawnflags to start with instead of the default SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK, and SF_NPC_LONG_RANGE
function ZBaseSpawnZBaseNPC( class, pos, normal, weapon_class, spawn_flags)
    if !SERVER then return NULL end 

    if !ZBaseNPCs[class] then return NULL end 

    if weapon_class=="default" then

        local weps = ZBaseNPCs[class].Weapons

        if !table.IsEmpty(weps) then
            weapon_class = table.Random(weps)
        end
         
    end 

    local NPC = ZBaseInternalSpawnNPC( nil, pos, normal or up, class, weapon_class, spawn_flags, true, false )
    if !IsValid(NPC) then
        ErrorNoHaltWithStack("No such NPC found: '", class, "'\n")
    else
        return NPC
    end 
end

-- Change the ZBASE faction for an entity
-- Always use this function if you want to do so
function ZBaseSetFaction( ent, newFaction )
    ent.ZBaseFaction = newFaction or ent.ZBaseStartFaction

    for _, v in ipairs(ZBaseNPCInstances) do
        v:UpdateRelationships()
    end
end 

-- Gets the ZBASE faction of an entity
function ZBaseGetFaction( ent )
    return ent.ZBaseFaction
end 

-- Change how two entities feel about each other
-- https://wiki.facepunch.com/gmod/Enums/D
function ZBaseSetRelationship( ent1, ent2, rel )
    ent1:ZBASE_SetMutualRelationship( ent2, rel )
end 

--[[
======================================================================================================================================================
                                           FX / EFFECTS / VISUALS
======================================================================================================================================================
--]]

-- Used to add glowing eyes to models
-- 'identifier' - A unique identifier for this particular eye
-- 'model' - The model that should have the eye
-- 'skin' - Which skin should have the eye, set to false to use all skins
function ZBaseAddGlowingEye(identifier, model, skin, bone, offset, scale, color)
    if !ZBaseGlowingEyes[model] then
        ZBaseGlowingEyes[model] = {}
    end 

    local Eye = {}
    Eye.skin = skin
    Eye.bone = bone
    Eye.offset = offset
    Eye.scale = scale
    Eye.color = color

    ZBaseGlowingEyes[model][identifier] = Eye
end 

-- Emit a flash of light
-- 'col' needs to be a string
-- 'dur' stands for duration and is optional
-- ZBase muzzle light option must be enabled!
function ZBaseMuzzleLight( pos, bright, dist, col, dur )
    if !ZBCVAR.MuzzleLight:GetBool() then return end 
    dur = dur or 0.05

    local muzzleLight1 = ents.Create("env_projectedtexture")
    local muzzleLight2 = ents.Create("env_projectedtexture")

    if IsValid(muzzleLight1) && IsValid(muzzleLight2) then
        bright = math.Rand(bright*0.1, bright)

        for k, muzzleLight in ipairs({muzzleLight1, muzzleLight2}) do
            local ang = k == 1 && Angle(0, 90, 0) or Angle(0, 270, 0)
            muzzleLight:SetPos(pos)
            muzzleLight:SetAngles(ang)
            muzzleLight:SetKeyValue("enableshadows", 0)
            muzzleLight:SetKeyValue("lightcolor", col) 
            muzzleLight:SetKeyValue("farz", dist) 
            muzzleLight:SetKeyValue("nearz", 1)
            muzzleLight:SetKeyValue("lightfov", 179.99) 
            muzzleLight:SetKeyValue("lightstrength", bright)
            muzzleLight:Spawn()
            muzzleLight:Activate()
            SafeRemoveEntityDelayed(muzzleLight, dur)
        end
    end
end

-- Create a muzzle flash effect from the entity at attachment 'att_num'
-- 'iFlags' = 1 -> Nrm muzzle flash
-- 'iFlags' = 5 -> AR2 muzzle flash
-- 'iFlags' = 7 -> Big muzzle flash
function ZBaseMuzzleFlash(ent, iFlags, att_num)
    if IsValid(ent) then
		local bAR2 = 	( (iFlags == 5) or false )
		local bLarge = 	( (iFlags == 7) or false )

		if bAR2 && (ZBCVAR.AR2Muzzle:GetString()=="mmod") then
			ParticleEffectAttach("hl2mmod_muzzleflash_npc_ar2", PATTACH_POINT_FOLLOW, ent, att_num)
		elseif !bAR2 && ZBCVAR.Muzzle:GetString() == "mmod" then
			ParticleEffectAttach(bLarge && "hl2mmod_muzzleflash_npc_shotgun" or "hl2mmod_muzzleflash_npc_pistol", PATTACH_POINT_FOLLOW, ent, att_num)
		elseif !bAR2 && ZBCVAR.Muzzle:GetString() == "black_mesa" then
			ParticleEffectAttach(bLarge && "" or "", PATTACH_POINT_FOLLOW, ent, att_num)
		else
			local effectdata = EffectData()
			effectdata:SetFlags(iFlags)
			effectdata:SetEntity(ent)
			util.Effect( "MuzzleFlash", effectdata, true, true )
		end

		-- Dynamic light
		local att = ent:GetAttachment(att_num)
		local col = iFlags==5 && "75 175 255" or "255 175 75"
		ZBaseMuzzleLight( att.Pos, 1.5, 256, col )
	end
end

--[[
======================================================================================================================================================
                                           ZBASE MOVE
======================================================================================================================================================
--]]

if SERVER then
    -- ZBaseMove locals, ignore...
    local MoveConstant = 300
    local DistUntilSwitchWayPointSq = (MoveConstant*0.5)^2
    local DownVec = Vector(0, 0, -10000)
    local shouldJump_DownVec = Vector(0, 0, -100) -- If we are this high up, try to jump
    local jumpUpVec = Vector(0, 0, 300)
    local AIDisabled = GetConVar("ai_disabled")
    local MaxJumpDist = 400
    local TimeOutTime = 5

    -- Move any NPC to the desired position, works even when there are no nodes!
    -- 'npc' - The NPC in question
    -- 'pos' - The position to move the NPC to
    -- 'identifier' Optional, a way to identify this move
    function ZBaseMove( npc, pos, identifier )
        local hookID = "ZBaseMove:"..tostring(npc)
        local ZBaseMoveTimeOut = CurTime()+TimeOutTime
        local NextMoveTick = CurTime()
        local FirstIter = true
        local downtr = util.TraceLine({
            start = pos,
            endpos =  pos + DownVec,
            mask = MASK_NPCWORLDSTATIC,
        })
        destination = downtr.HitPos+downtr.HitNormal*15

        npc.ZBaseMove_ID = identifier
        npc.ZBaseMove_WaypointPos = destination -- Temporary
        npc.ZBaseMove_CanGroundMove = false

        debugoverlay.Text(npc:WorldSpaceCenter(), "Starting ZBaseMove '"..(identifier or "*any*").."'")

        hook.Add("Tick", hookID, function()
            if NextMoveTick > CurTime() then return end
            if !IsValid(npc) or destination:DistToSqr(npc:GetPos()) <= 10000 or ZBaseMoveTimeOut < CurTime() then
                hook.Remove("Tick", hookID)
                
                if IsValid(npc) then
                    debugoverlay.Text(npc:WorldSpaceCenter(), "ZBaseMove finished")
                    npc.ZBaseMove_ID = nil
                end 

                return
            end 
                        -- Thinking disabled, don't run this
            if AIDisabled:GetBool() or bit.band(npc:GetFlags(), EFL_NO_THINK_FUNCTION )==EFL_NO_THINK_FUNCTION then
                return
            end 
                        -- Vars
            local npc_pos = npc:WorldSpaceCenter()
            local InWayPointDist = npc_pos:DistToSqr(npc.ZBaseMove_WaypointPos) < DistUntilSwitchWayPointSq
            local onGround = npc:IsOnGround()
            local shouldJump = ZBCVAR.MoreJumping:GetBool() && !npc.ZBaseMove_CanGroundMove && onGround && bit.band(npc:CapabilitiesGet(), CAP_MOVE_JUMP) == CAP_MOVE_JUMP
            local moveNrm = (FirstIter or InWayPointDist or shouldJump) && (destination - npc_pos):GetNormalized()
            local npcState = npc:GetNPCState()
            local shouldRunToDest = npcState == NPC_STATE_ALERT or npcState == NPC_STATE_COMBAT
            or IsValid(npc.PlayerToFollow) or npc:GetInternalVariable("m_bWasInPlayerSquad")


            -- Force move to next waypoint on our path to the destination
            if FirstIter or InWayPointDist then

                local tr = util.TraceLine({
                    start = npc_pos,
                    endpos =  npc_pos + moveNrm*MoveConstant,
                    filter = {npc},
                    mask = MASK_VISIBLE,
                })
                local waypointPos = tr.HitPos+tr.HitNormal*15
                npc.ZBaseMove_WaypointPos = waypointPos

                debugoverlay.Line(npc_pos, waypointPos, 0.3)
                debugoverlay.Axis(destination, angle_zero, 50)

                npc:SetLastPosition(waypointPos)

                if shouldRunToDest then
                    npc:SetSchedule(SCHED_FORCED_GO_RUN)
                else
                    npc:SetSchedule(SCHED_FORCED_GO)
                end 
                                FirstIter = false

            end 

            -- We are on the ground, and we are moving, so we should not need to jump...
            if onGround && npc:IsMoving() then
                npc:CONV_TempVar("ZBaseMove_CanGroundMove", true, 1.8)
            end 

            if shouldJump then

                if npc_pos:DistToSqr(destination) <= MaxJumpDist then
                    ZBaseMoveJump(npc, destination)
                else
                    ZBaseMoveJump(npc, npc_pos + moveNrm*MaxJumpDist)
                end 
                                npc:CONV_TempVar("ZBaseMove_CanGroundMove", true, 3) -- Assume we can ground move after this jump

            end 
            NextMoveTick = CurTime()+0.1
        end)
    end

    -- Make an NPC jump to the desired position
    -- 'npc' - The NPC in question
    -- 'pos' - The position to jump to
    function ZBaseMoveJump( npc, pos )
        local cls = npc:GetClass()
        local npc_pos = npc:WorldSpaceCenter()
        local moveNrm = (pos - npc_pos)
        
        npc:MoveJumpStart(moveNrm+jumpUpVec)
        npc:CONV_TempVar("ZBaseMove_JustJumped", true, 0.5)

        local hookID = "ZBaseMoveJump:"..tostring(npc)

        local function afterLandFunc()
            npc:SetLastPosition(pos)
            npc:SetSchedule(SCHED_FORCED_GO_RUN)
        end 
                local function startGlideFunc()
            if npc.IsZBaseNPC then
                npc:InternalPlayAnimation(ACT_GLIDE, 5, 1, SCHED_SCENE_GENERIC, pos, nil, true, nil, false, false, false, {dontStopZBaseMove=true, onFinishFunc=onFinishFunc})
            else
                npc:ZBASE_SimpleAnimation(ACT_GLIDE)
            end
        end 
                hook.Add("Tick", hookID, function()

            if !IsValid(npc) then
                hook.Remove("Tick", hookID)
                return
            end 
                        if !npc.ZBaseMove_JustJumped && npc.ZBaseMove_IsJumping && npc:OnGround() then
                if npc.IsZBaseNPC then
                    npc:InternalPlayAnimation(ACT_LAND, nil, 1, SCHED_SCENE_GENERIC, pos, nil, true, nil, false, false, false, {dontStopZBaseMove=true, onFinishFunc=afterLandFunc})
                else
                    npc:ZBASE_SimpleAnimation(ACT_LAND)
                end 
                                npc.ZBaseMove_IsJumping = false
            end 
                end)

        if npc.IsZBaseNPC then
            npc:InternalPlayAnimation(ACT_JUMP, nil, 1, SCHED_SCENE_GENERIC, pos, nil, true, nil, false, false, false, {dontStopZBaseMove=true, onFinishFunc=startGlideFunc})
        else
            npc:ZBASE_SimpleAnimation(ACT_JUMP)
        end
        npc.ZBaseMove_IsJumping = true
    end 

    -- Stop ZBaseMove for this NPC
    -- 'npc' - The NPC in question
    -- 'identifier' Optional, only stop the move if it has this identifier
    function ZBaseMoveEnd( npc, identifier )
        if identifier && identifier != npc.ZBaseMove_ID then
            return
        end 
                local hookID = "ZBaseMove:"..tostring(npc)
        hook.Remove("Tick", hookID)
        npc.ZBaseMove_ID = nil
    end 

    -- Checks if an NPC is doing ZBaseMove
    -- 'npc' - The NPC in question
    -- 'identifier' Optional, check if the current move has this identifier
    function ZBaseMoveIsActive( npc, identifier )
        if identifier && identifier != npc.ZBaseMove_ID then
            return
        end 
                local hookID = "ZBaseMove:"..tostring(npc)
        return hook.GetTable()["Tick"][hookID]!=nil
    end 
end 

--[[
======================================================================================================================================================
                                           SOUNDS/SENTENCES
======================================================================================================================================================
--]]--[[
    -- ADD A SENTENCE - CODE EXAMPLE (RUN IN SHARED) --
    -- Sentences need to end with .SS as provided in the example! --

    ZBaseAddScriptedSentence({
        name 	= "SomeCoolSSName.SS",
        channel = CHAN_VOICE,
        volume 	= 1,
        level 	= 75,
        pitch 	= 100,
        flags 	= nil,
        dsp		= 0,
        caption	= { "<clr:0,100,255>[Combine Soldier: ", 2 }, -- https://developer.valvesoftware.com/wiki/Closed_Captions
        sound 	= { 

            "radio_on.wav",

            { "npc/combine_soldier/vo/callhotpoint.wav", "npc/combine_soldier/vo/affirmativewegothimnow.wav", "npc/combine_soldier/vo/containmentproceeding.wav" }, -- Will choose random random option.

            { dps = 55, caption = { "Call hot point, ", "Affirmative we got him now, ", "Containment proceeding, " } }, -- If present, it will detect settings for the previous table. You can put anything here to override the sound or add captions.

            "npc/combine_soldier/vo/eighteen.wav",

            { dps = 55, caption = { "eighteen " } },

            "npc/combine_soldier/vo/meters.wav",

            { dps = 55, caption = { "meters." } },

            "radio_off.wav",

        }
    })
]]
function ZBaseAddScriptedSentence(ssTab)
    if !istable(ssTab) || !ssTab['name'] then return end
    ZBaseScriptedSentences[ ssTab['name'] ] = ssTab 
end 

-- Show a caption text for the player
-- If the player (ply) is 'false', it will show to every player in the range
-- 'range' should be about equal to the sound level
function ZBaseAddCaption(ply, text, dur, range, pos)
	if (SERVER) then
        range = range || 75

		if isbool(ply) then

            for _, plyIter in player.Iterator() do
                if plyIter:GetPos():DistToSqr( pos ) <= ( range * 40 )^2 then
                    net.Start( "ZBaseAddCaption" )
                    net.WriteString( text || "" )
                    net.WriteFloat( dur || 1 )		
                    net.Send(plyIter)
                end
            end 
        		elseif ply:IsPlayer() then
            
            net.Start( "ZBaseAddCaption" )
            net.WriteString( text || "" )
            net.WriteFloat( dur || 1 )	
			net.Send( ply )
			
		end	
	elseif (CLIENT) then	
		gui.AddCaption( text, dur, false )
	end
end 

-- A quick way to add sounds that have attributes appropriate for a human voice
function ZBaseCreateVoiceSounds( name, tbl )
    sound.Add( {
        name = name,
        channel = CHAN_VOICE,
        volume = 0.5,
        level = 75,
        pitch = {95, 105},
        sound = tbl,
    } )
end 