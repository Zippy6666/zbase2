local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 50 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour

NPC.ZBaseFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied

NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
}

NPC.m_iNumGrenades = 1
NPC.m_nKickDamage = 15
NPC.m_iTacticalVariant = 2

---------------------------------------------------------------------------------------------------------------------=#

    -- Called when the NPC is created --
function NPC:CustomInitialize()
    local att = self:GetAttachment(self:LookupAttachment("zipline"))
    self.Turret = ents.Create("npc_turret_floor")
    self.Turret:SetKeyValue("spawnflags", 64) -- Start inactive
    self.Turret:SetPos(att.Pos - Vector(0,0,45) - self:GetForward()*8)
    self.Turret:SetAngles(self:GetAngles() + Angle(0,90,8))
    self.Turret:SetParent(self, self:LookupAttachment("zipline"))
    self.Turret.ZBaseFaction = self.ZBaseFaction
    self.Turret:AddFlags(FL_NOTARGET)
    self.Turret:Spawn()
end
---------------------------------------------------------------------------------------------------------------------=#