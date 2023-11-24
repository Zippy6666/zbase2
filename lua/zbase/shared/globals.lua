AddCSLuaFile()


if !ZBaseNPCs then
    ZBaseNPCs = {}
    ZBaseNPCInstances = {}
    ZBaseNPCInstances_NonScripted = {}
    ZBaseBehaviourTimerFuncs = {}
    ZBase_NonZBaseNPCs = {}
    ZBaseSpawnMenuNPCList = {}
    ZBaseSpeakingSquads = {}
    ZBaseEnhancementTable = {}
end


if SERVER then
    ZBaseForbiddenFaceScheds = {
        [SCHED_ALERT_FACE]	= true,
        [SCHED_ALERT_FACE_BESTSOUND]	= true,
        [SCHED_COMBAT_FACE] 	= true,
        [SCHED_FEAR_FACE] 	= true,	
        [SCHED_SCRIPTED_FACE] 	= true,	
        [SCHED_TARGET_FACE]	= true,
    }
end







---------------------------------------------------------------------------------------------------------------------=#
function ZBaseEnhancementNPCClass(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split]
    local split2 = string.Split(name, ".")
    return split2[1]
end
---------------------------------------------------------------------------------------------------------------------=#
function ZBaseListFactions( _, ply )
    if SERVER then
        local factions = {none=true, neutral=true, ally=true}

        for k, v in pairs(ZBaseNPCs) do
            if v.ZBaseStartFaction then
                factions[v.ZBaseStartFaction] = true
            end
        end

        net.Start("ZBaseListFactions")
        net.WriteTable(factions)
        net.Send(ply)
    end

    if CLIENT then
        net.Start("ZBase_GetFactionsFromServer")
        net.SendToServer()
    end
end
---------------------------------------------------------------------------------------------------------------------=#
if SERVER then
    util.AddNetworkString("ZBaseListFactions")
    util.AddNetworkString("ZBase_GetFactionsFromServer")
    net.Receive("ZBase_GetFactionsFromServer", ZBaseListFactions)
end
---------------------------------------------------------------------------------------------------------------------=#