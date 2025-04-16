local my_cls = ZBasePatchNPCClass(debug.getinfo(1,'S'))

ZBasePatchTable[my_cls] = function( NPC )
    -- No headcrabs by default
    function NPC:Patch_Init()
        self:SetSaveValue("m_fIsHeadless", true)
        self:SetBodygroup(1, 0)

        -- Poison zombie logic
        if self:GetClass()=="npc_poisonzombie" then
            self:SetSaveValue("m_nCrabCount", 0)

            for i = 2, 5 do
                self:SetBodygroup(i, 0)
            end

            self:SetSaveValue("m_bCrabs", {false, false, false})
        end
    end
end

-- Same for fast zombies and poison zombies
ZBasePatchTable["npc_fastzombie"] = ZBasePatchTable[my_cls]
ZBasePatchTable["npc_poisonzombie"] = ZBasePatchTable[my_cls]

ZBasePatchTable["npc_zombine"] = function( NPC )
    ZBasePatchTable[my_cls](NPC) -- Same features as zombies (no headcrabs by default)

    -- Allow zombines to die from their own grenades
    function NPC:Patch_OnSelfDamage( dmg )
        local infl = dmg:GetInflictor()
        if IsValid(infl) && infl:GetClass()=="npc_grenade_frag" && !infl.IsZBaseGrenade then
            return true
        end
    end
end