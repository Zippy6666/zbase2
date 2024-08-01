
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