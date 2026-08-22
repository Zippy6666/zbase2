if !SERVER then return end

local SaveDirectory = "zbase/saves/"

local function SaveIDToFileName(saveID)
    if !isstring(saveID) || saveID == "" then return end

    -- Keep the save identifier usable as a DATA filename.
    saveID = string.gsub(saveID, "[^%w_.-]", "_")
    return SaveDirectory .. game.GetMap() .. "/" .. saveID .. ".json"
end

local function VectorToTable(vector)
    return {x = vector.x, y = vector.y, z = vector.z}
end

local function AngleToTable(angle)
    return {p = angle.p, y = angle.y, r = angle.r}
end

local function TableToVector(vector)
    return Vector(vector.x, vector.y, vector.z)
end

local function TableToAngle(angle)
    return Angle(angle.p, angle.y, angle.r)
end

local function GetBodygroups(ent)
    local bodygroups = {}

    for _, bodygroup in ipairs(ent:GetBodyGroups()) do
        bodygroups[bodygroup.id] = ent:GetBodygroup(bodygroup.id)
    end

    return bodygroups
end

local function GetZBaseNPCData()
    local npcs = {}

    for _, ent in ipairs(ents.GetAll()) do
        if !IsValid(ent) || !ent.IsZBaseNPC || !ent.NPCName then continue end

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

    return npcs
end

local function SaveZBaseNPCs(saveID)
    local fileName = SaveIDToFileName(saveID)
    if !fileName then
        MsgN("[ZBase Save] Could not save: Garry's Mod supplied no save ID.")
        return
    end

    local npcs = GetZBaseNPCData()
    if #npcs == 0 then
        if file.Exists(fileName, "DATA") then file.Delete(fileName) end
        MsgN("[ZBase Save] No z-base NPCs found; no JSON was created for '" .. saveID .. "'.")
        return
    end

    file.CreateDir(SaveDirectory .. game.GetMap())
    file.Write(fileName, util.TableToJSON({version = 1, npcs = npcs}, true))
    MsgN("[ZBase Save] Saved " .. #npcs .. " z-base NPC(s) for '" .. saveID .. "' to " .. fileName .. ".")
end

local function RestoreZBaseNPCs(saveID)
    local fileName = SaveIDToFileName(saveID)
    if !fileName || !file.Exists(fileName, "DATA") then
        MsgN("[ZBase Save] No z-base JSON found for '" .. tostring(saveID) .. "'.")
        return
    end

    local data = util.JSONToTable(file.Read(fileName, "DATA"))
    if !istable(data) || !istable(data.npcs) then
        MsgN("[ZBase Save] Invalid z-base JSON for '" .. tostring(saveID) .. "'.")
        return
    end

    local restored = 0
    for _, npcData in ipairs(data.npcs) do
        local classData = ZBaseNPCs[npcData.class]
        if !classData || !istable(npcData.position) || !istable(npcData.angles) then
            MsgN("[ZBase Save] Skipped invalid NPC entry for class '" .. tostring(npcData.class) .. "'.")
            continue
        end

        local ent = ZBaseInternalSpawnNPC(
            nil,
            TableToVector(npcData.position),
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

        -- The normal spawn path applies offsets; restore the exact saved transform afterward.
        ent:SetPos(TableToVector(npcData.position))
        ent:SetAngles(TableToAngle(npcData.angles))
        if isnumber(npcData.skin) then ent:SetSkin(npcData.skin) end

        for bodygroupID, value in pairs(npcData.bodygroups or {}) do
            ent:SetBodygroup(tonumber(bodygroupID), value)
        end

        restored = restored + 1
    end

    MsgN("[ZBase Save] Restored " .. restored .. " z-base NPC(s) for '" .. tostring(saveID) .. "'.")
end

hook.Add("OnSave", "ZBase_SaveNPCs", SaveZBaseNPCs)
hook.Add("OnRestore", "ZBase_RestoreNPCs", RestoreZBaseNPCs)