
    // Useful globals

--[[
======================================================================================================================================================
                                           ENUMS
======================================================================================================================================================
--]]


ZBASE_SNPCTYPE_WALK = 1
ZBASE_SNPCTYPE_FLY = 2
ZBASE_SNPCTYPE_STATIONARY = 3
ZBASE_SNPCTYPE_VEHICLE = 4
ZBASE_SNPCTYPE_PHYSICS = 5


ZBASE_CANTREACHENEMY_HIDE = 1
ZBASE_CANTREACHENEMY_FACE = 2


ZBASE_TOOCLOSEBEHAVIOUR_NONE = 0
ZBASE_TOOCLOSEBEHAVIOUR_FACE = 1
ZBASE_TOOCLOSEBEHAVIOUR_BACK = 2


--[[
======================================================================================================================================================
                                           "ESSENTIAL" FUNCTIONS
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


--[[
======================================================================================================================================================
                                           UTIL
======================================================================================================================================================
--]]


    -- Change the zbase faction for an entity
    -- Always use this function if you want to do so
function ZBaseSetFaction( ent, newFaction )
    ent.ZBaseFaction = newFaction or ent.ZBaseStartFaction

    for _, v in ipairs(ZBaseNPCInstances) do
        v:UpdateRelationships()
    end
end


    -- Gets the zbase function of an entity
function ZBaseGetFaction( ent )
    return ent.ZBaseFaction
end


    -- Change how two entities feel about each other
    -- https://wiki.facepunch.com/gmod/Enums/D
function ZBaseSetRelationship( ent1, ent2, rel )
    ent1:ZBASE_SetMutualRelationship( ent2, rel )
end


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


    -- Changes a category's icon from that stupid blue monkey to whatever you like
    -- Example:
    -- ZBaseSetCategoryIcon( "Combine", "icon16/female.png" )
    -- You probably want to run this in a hook like initialize
    -- Feminist combine xddddd
function ZBaseSetCategoryIcon( category, path )
    if SERVER then return end
    ZBaseCategoryImages[category] = path
end


    -- Spawn a ZBase NPC
    -- 'class' - The ZBase NPC class, example: 'zb_combine_soldier'
    -- 'pos' - The position to spawn it on (optional, will be Vector(0,0,0) otherwise)
    -- 'normal' - The normal to spawn it on (optional)
    -- 'weapon_class' The weapon class to equip the npc with (optional), set to "default" to make it use its default weapons
local up = Vector(0, 0, 1)
function ZBaseSpawnZBaseNPC( class, pos, normal, weapon_class)

    if !SERVER then return NULL end


    if !ZBaseNPCs[class] then return NULL end


    if weapon_class=="default" then

        local weps = ZBaseNPCs[class].Weapons

        if !table.IsEmpty(weps) then
            weapon_class = table.Random(weps)
        end
         
    end


    local NPC = ZBaseInternalSpawnNPC( nil, pos, normal or up, class, weapon_class, nil, true )
    if !IsValid(NPC) then
        ErrorNoHaltWithStack("No such NPC found: '", class, "'\n")
    else
        return NPC
    end


end


--[[
======================================================================================================================================================
                                           ZBaseMove
======================================================================================================================================================
--]]


if SERVER then

    -- ZBaseMove locals, ignore...
    local MoveConstant = 300
    local DistUntilSwitchWayPointSq = (MoveConstant*0.5)^2
    local DownVec = Vector(0, 0, -10000)
    local shouldJump_DownVec = Vector(0, 0, -100) -- If we are this high up, try to jump
    local jumpUpVec = Vector(0, 0, 400)
    local AIDisabled = GetConVar("ai_disabled")
    local MaxJumpDist = 500
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
        pos = downtr.HitPos+downtr.HitNormal*15

        npc.ZBaseMove_ID = identifier
        npc.ZBaseMove_WaypointPos = pos -- Temporary
        npc.ZBaseMove_CanGroundMove = false

        debugoverlay.Text(npc:WorldSpaceCenter(), "Starting ZBaseMove '"..(identifier or "*any*").."'")

        hook.Add("Tick", hookID, function()
            if NextMoveTick > CurTime() then return end

            if !IsValid(npc) or pos:DistToSqr(npc:GetPos()) <= 10000 or ZBaseMoveTimeOut < CurTime() then
                hook.Remove("Tick", hookID)
                
                if IsValid(npc) then
                    debugoverlay.Text(npc:WorldSpaceCenter(), "ZBaseMove finished")
                    npc.ZBaseMove_ID = nil
                end


                return
            end

            if AIDisabled:GetBool() or bit.band(npc:GetFlags(), EFL_NO_THINK_FUNCTION )==EFL_NO_THINK_FUNCTION then
                return
            end

            local npc_pos = npc:WorldSpaceCenter()
            local InWayPointDist = npc_pos:DistToSqr(npc.ZBaseMove_WaypointPos) < DistUntilSwitchWayPointSq
            local onGround = npc:IsOnGround()
            local shouldJump = !npc.ZBaseMove_CanGroundMove && onGround && bit.band(npc:CapabilitiesGet(), CAP_MOVE_JUMP) == CAP_MOVE_JUMP
            local moveNrm = (FirstIter or InWayPointDist or shouldJump) && (pos - npc_pos):GetNormalized()

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
                debugoverlay.Axis(pos, angle_zero, 50)

                npc:SetLastPosition(waypointPos)

                local npcState = npc:GetNPCState()
                if npcState == NPC_STATE_ALERT or npcState == NPC_STATE_COMBAT then
                    npc:SetSchedule(SCHED_FORCED_GO_RUN)
                else
                    npc:SetSchedule(SCHED_FORCED_GO)
                end

                npc:CONV_TempVar("ZBaseMove_CanGroundMove", true, 1.8)
                FirstIter = false

            end

            
            if shouldJump then

                if npc_pos:DistToSqr(pos) <= MaxJumpDist then
                    ZBaseMoveJump(npc, pos)
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
        local npc_pos = npc:WorldSpaceCenter()
        local moveNrm = (pos - npc_pos)

        npc:MoveJumpStart(moveNrm+jumpUpVec)
        npc:CONV_TempVar("ZBaseMove_JustJumped", true, 0.5)

        if npc.IsZBaseNPC then
            local hookID = "ZBaseMoveJump:"..tostring(npc)
            local function afterLandFunc()
                npc:SetLastPosition(pos)
                npc:SetSchedule(SCHED_FORCED_GO_RUN)
            end

            hook.Add("Tick", hookID, function()

                if !IsValid(npc) then
                    hook.Remove("Tick", hookID)
                    return
                end

                if !npc.ZBaseMove_JustJumped && npc.ZBaseMove_IsJumping && npc:OnGround() then
                    npc:InternalPlayAnimation(ACT_LAND, nil, 1, SCHED_SCENE_GENERIC, pos, nil, true, nil, false, false, false, {skipReset=true, onFinishFunc=afterLandFunc})
                    npc.ZBaseMove_IsJumping = false
                end

            end)

            npc:InternalPlayAnimation(ACT_GLIDE, 5, 1, SCHED_SCENE_GENERIC, pos, nil, true, nil, false, false, false, {skipReset=true, onFinishFunc=onFinishFunc})
            npc.ZBaseMove_IsJumping = true
        end
    end


    -- Stop ZBaseMove for this NPC
    -- 'npc' - The NPC in question
    -- 'identifier' Optional, only stop the move if it has this identifier
    function ZBaseMoveEnd( npc, identifier )
        if identifier && identifier != npc.ZBaseMove_ID then
            return
        end

        local hookID = "ZBaseMove:"..tostring(npc)
        debugoverlay.Text(npc:WorldSpaceCenter()+npc:GetUp()*25, "Ending ZBaseMove '"..(identifier or "*any*").."'")
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
                                           CONVINIENT FUNCTIONS
======================================================================================================================================================
--]]


    -- A quick way to add sounds that have attributes appropriate for a human voice
function ZBaseCreateVoiceSounds( name, tbl )
    sound.Add( {
        name = name,
        channel = CHAN_VOICE,
        volume = 0.5,
        level = 90,
        pitch = {95, 105},
        sound = tbl,
    } )
end