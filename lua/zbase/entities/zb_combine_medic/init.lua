local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/zippy/combine_medic.mdl"}
NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.SpawnFlagTbl = {SF_CITIZEN_MEDIC}

NPC.StartHealth = 45 -- Max health
NPC.MoveSpeedMultiplier = 1.35

-- Grenade/wep handling
NPC.MinShootDistance = 0 -- Minimum distance the NPC will fire its weapon from
NPC.MaxShootDistance = 5000 -- Maximum distance the NPC can fire its weapon from
NPC.CanSecondaryAttack = false -- Can use weapon secondary attacks
NPC.BaseGrenadeAttack = false -- Use ZBase grenade attack system

-- Items to drop on death
-- ["item_class_name"] = {chance=1/x, max=x}
NPC.ItemDrops = {
    ["item_healthkit"] = {chance=2, max=1}, 
}
NPC.ItemDrops_TotalMax = 1 -- The NPC can never drop more than this many items

NPC.MuteDefaultVoice = true
NPC.DeathSounds = "ZBaseCombineMedic.Death" -- Sounds emitted on death
NPC.PainSounds = "ZBaseCombineMedic.Pain" -- Sounds emitted on hurt

function NPC:CustomThink()
    -- Only heal player if they are friendly to us
    local ene = self:GetEnemy()
    local eneIsPly = IsValid(ene) && ene:IsPlayer()
    if eneIsPly && self.CanHeal then
        self:Fire("SetMedicOff")
        self.CanHeal = nil
    elseif !eneIsPly && !self.CanHeal then
        self:Fire("SetMedicOn")
        self.CanHeal = true
    end
end