local ENT = FindMetaTable("Entity")
local listGet = list.Get
local emitSound = ENT.EmitSound


IsEmitSoundCall = false


if SERVER then

    local SpawnNPC = Spawn_NPC

    function Spawn_NPC( ply, NPCClassName, WeaponName, tr, ... )
        if ZBaseNPCs[NPCClassName] then
            return Spawn_ZBaseNPC( ply, NPCClassName, WeaponName, tr, ... )
        else
            return SpawnNPC( ply, NPCClassName, WeaponName, tr, ... )
        end
    end

    -- Workaround when trying to spawn zbase npcs from ents.Create...
    ents.Create = conv.wrapFunc( "ZBaseEntsCreateWrapper", ents.Create, function( entClass )
        if !scripted_ents.GetStored(entClass) && ZBaseNPCs[entClass] then
            local ply = NULL
            local Position
            local Normal
            local Class = entClass
            local Equipment
            local SpawnFlagsSaved
            local NoDropToFloor
            local skipSpawnAndActivate = true

            local zbnpc = ZBaseInternalSpawnNPC( ply, Position, Normal, Class, Equipment, SpawnFlagsSaved, NoDropToFloor, skipSpawnAndActivate )

            return zbnpc
        end
    end)

    ENT.Spawn = conv.wrapFunc( "ZBaseSpawnWrapper", ENT.Spawn, nil, function( _, self )
        if !self.IsZBaseNPC then
            return
        end

        if self.ZBase_Spawned then
            return
        end

        ZBaseAfterSpawn( self, self.NPCName, false )
    end)

end



-- Add ZBase NPCs to NPC list
function list.Get( Type )
    if !ReloadedSpawnmenuRecently && Type == "NPC" then

        local ZBaseTableAdd = {}
        for k, v in pairs(ZBaseSpawnMenuNPCList) do
            local ZBaseNPC = table.Copy(v)

            ZBaseNPC.Name = ZBaseNPC.Name
            ZBaseNPC.Category = "[ZBase] "..(ZBaseNPC.Category or "Other")
            ZBaseNPC.KeyValues = {parentname=k}
            ZBaseTableAdd[k] = ZBaseNPC
        end

        local t = table.Merge(listGet(Type), ZBaseTableAdd)

        return t
    end

    return listGet(Type)
end


function ENT:EmitSound( snd, ... )
	IsEmitSoundCall = true
	emitSound(self, snd, ...)
	IsEmitSoundCall = false
end