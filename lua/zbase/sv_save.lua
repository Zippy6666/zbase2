if !SERVER then return end

-- utility functions
local function VectorToTable(vector)
    return {x = vector.x, y = vector.y, z = vector.z}
end
local function AngleToTable(angle)
    return {p = angle.p, y = angle.y, r = angle.r}
end
local function GetBodygroups(ent)
    local bodygroups = {}

    for _, bodygroup in ipairs(ent:GetBodyGroups()) do
        bodygroups[bodygroup.id] = ent:GetBodygroup(bodygroup.id)
    end

    return bodygroups
end

-- store zbase npcs as table
local function GetZBaseNPCData()
    local npcs = {}

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) && ent.IsZBaseNPC && ent.NPCName then 
            npcs[#npcs + 1] = {
                class = ent.NPCName,
                position = VectorToTable(ent:GetPos()),
                angles = AngleToTable(ent:GetAngles()),
                bodygroups = GetBodygroups(ent),
                skin = ent:GetSkin(),
                equipment = ent.Equipment,
                spawnflags = ent.SpawnFlags,
            }
        end
    end

    return npcs
end

local function AddZBaseNPCsSaveData(saveData)
    local npcs = GetZBaseNPCData()
    if #npcs == 0 then
        MsgN("[ZBase Save] No z-base NPCs found; no custom save data was written.")
        return saveData
    end

    -- version tracking just in case
    saveData.ZBase = {version = 1, npcs = npcs}
    MsgN("[ZBase Save] Wrote " .. #npcs .. " z-base NPC(s) into the Garry's Mod save.")
    return saveData
end

-- save formatting done by gmod natively, drawn from garrysmod/lua/includes/gmsave.lua & garrysmod/gamemodes/sandbox/gamemode/save_load.lua
local function FormatSaveData(savedata)
    savedata = util.Decompress(savedata)
    if (!isstring(savedata)) then
        MsgN("[ZBase Save] Invalid or empty string save data")
        return
    end

    -- Strip off anything before the start char..
	local startchar = string.find( savedata, "\2" )
	if ( startchar != nil ) then
		savedata = string.sub( savedata, startchar )
	end

	-- Strip off anything after the end char..
	savedata = savedata:reverse()
	local startchar = string.find( savedata, "\1" )
	if ( startchar != nil ) then
		savedata = string.sub( savedata, startchar )
	end
	savedata = savedata:reverse()

    savedata = util.JSONToTable( savedata )
    if (!istable(savedata) || !istable(savedata.ZBase) || !istable(savedata.ZBase.npcs)) then
        MsgN("[ZBase Save] Invalid or empty JSON save data")
        return
    end

    return savedata
end

-- manual "hook" that overwrites original gmsave function
-- jfl this is pretty bad but no alternative, as hook for saving is TODO/not implemented rn in internal gmsave.lua
-- don't think it will break other addons w/ same save mechanism, bc recursive gmsave.SaveMap stack
    -- eg zbase gmsave.SaveMap overwrite -> calls other base gmsave.SaveMap overwrite -> ... -> calls original gmsave.SaveMap
function HookSaveFunction()
    if not gmsave then
        return
    end

    local originalSaveFn = gmsave.SaveMap
    function gmsave.SaveMap(ply)
        -- Call the original function and capture the return data
        -- ref https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/gmsave.lua#L87
        local data = originalSaveFn(ply)

        -- unfortunate computations, but after original SaveMap function parses to JSON, we need to unparse to cleanly edit from lua
        -- yes, you could just directly edit the SaveMap function, but I don't want to disrupt the above recursive save stack process w other addons
        -- no need for any special formatting, as we know know it was just cleanly formatted in the original function
        data = util.JSONToTable(data)

        -- add special zbase table to save data (like how is done for player)
        data = AddZBaseNPCsSaveData(data)

        -- finally, return parsed JSON w new zbase data
        return util.TableToJSON(data)
    end
end
HookSaveFunction()

-- hook for loading save already exists in gmsave.lua and cleanly passes savedata, so we can just use that and process savedata specifically for zbase
-- we use integrated load hook to get cleanly passed saveData upon loading (garrysmod/gamemodes/sandbox/gamemode/save_load.lua L91)
hook.Add("LoadGModSave", "ZBase_LoadNPCs", function(savedata, mapname, maptime)
    -- applies native gmod formatting done to savedata in load functions
    savedata = FormatSaveData( savedata )
    if savedata == nil then return end
    
    local restored = 0
    -- replicate gmsave.LoadMap loading entities process in "PostCleanupMap" hook, w small delay (garrysmod/lua/includes/gmsave.lua L87)
    -- potential problem: if the LoadGModSave hook somehow significantly delays between firing for gmod's save_load.lua and firing for zbase,
    -- there's an off chance the cleanup finishes before the PostCleanupMap hook here is added. This is quite unlikely though, because cleanup can take a while
    -- and thus any delay between the two LoadGModSave hooks will be minute compared to the delay from cleanup (?) 
    hook.Add( "PostCleanupMap", "ZBase_SafeLoadSave", function()
        hook.Remove( "PostCleanupMap", "ZBase_SafeLoadSave" )
        -- Gmod's native gmsave.lua has a 0.5s delay @L58 for safety before spawning NPCs from savedata via duplicator, I used 0.75s here just in case
        timer.Simple( 0.75, function()
            for _, npcData in ipairs(savedata.ZBase.npcs) do
                -- basic checks for stability
                local classData = ZBaseNPCs[npcData.class]
                if !classData || !istable(npcData.position) || !istable(npcData.angles) then
                    MsgN("[ZBase Save] Skipped invalid NPC entry for class '" .. tostring(npcData.class) .. "'.")
                else
                    local position = Vector(npcData.position.x, npcData.position.y, npcData.position.z)
                    local ent = ZBaseInternalSpawnNPC(
                        nil,
                        position,
                        vector_up,
                        npcData.class,
                        npcData.equipment,
                        npcData.spawnflags,
                        true,
                        false
                    )

                    if !IsValid(ent) then
                        MsgN("[ZBase Save] Failed to restore class '" .. npcData.class .. "'.")
                        continue
                    end

                    -- The normal spawn path applies offsets; restore the exact saved transform afterward
                    ent:SetPos(position)
                    ent:SetAngles(Angle(npcData.angles.p, npcData.angles.y, npcData.angles.r))
                    if isnumber(npcData.skin) then ent:SetSkin(npcData.skin) end

                    -- apply bodygroups
                    for bodygroupID, value in pairs(npcData.bodygroups or {}) do
                        ent:SetBodygroup(tonumber(bodygroupID), value)
                    end

                    restored = restored + 1
                end
            end

            MsgN("[ZBase Save] Restored " .. restored .. " z-base NPC(s) from the Garry's Mod save.")
        end)
    end)
end)