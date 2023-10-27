if ZBaseReplaceFuncDone then return end
ZBaseReplaceFuncDone = true

local ENT = FindMetaTable("Entity")

-----------------------------------------------------------=#
if SERVER then
    local emitSound = ENT.EmitSound
    -----------------------------------------------------------=#
    hook.Add("InitPostEntity", "InitPostEntity", function() timer.Simple(0.5, function()
        local OnNPCKilled = GAMEMODE.OnNPCKilled

        function GAMEMODE:OnNPCKilled( npc, ... )
            if npc.IsZBaseNPC then
                npc:EmitSound(npc.DeathSounds)
            end

            return OnNPCKilled(self, npc, ...)
        end

    end) end)
    -----------------------------------------------------------=#
    function ENT:EmitSound( snd, ... )

        if self.IsZBaseNPC && snd == "" then return end

        ZBase_EmitSoundCall = true
        local v = emitSound(self, snd, ...)
        ZBase_EmitSoundCall = false

        return v

    end
    -----------------------------------------------------------=#
end
-----------------------------------------------------------=#
if CLIENT then
end
-----------------------------------------------------------=#