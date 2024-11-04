local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.MuteAllDefaultSoundEmittions = true


NPC.ZBaseStartFaction = "ally"
NPC.ZBaseFactionsExtra = {
    ["combine"] = true,
}


function NPC:CustomInitialize()
end