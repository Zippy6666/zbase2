local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 40 -- Max health
NPC.SpawnFlagTbl = {SF_CITIZEN_RANDOM_HEAD_MALE, SF_CITIZEN_AMMORESUPPLIER}
NPC.ZBaseStartFaction = "ally" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"

NPC.CanPatrol = true -- Use base patrol behaviour
NPC.KeyValues = {citizentype = CT_REFUGEE} -- Keyvalues

NPC.MeleeAttackAnimations = {"meleeattack01"}

function NPC:CustomPreSpawn()
    -- When we have SF_CITIZEN_AMMORESUPPLIER flag
    -- Pick a random type of ammo to resupply
    local AmmoSupplyTbl = {
        AR2 = 60,
        SMG1_Grenade = 1,
        SMG1 = 100,
        Pistol = 100,
        XBowBolt = 12,
        Buckshot = 15,
        RPG_Round = 3,
        Grenade = 5,
    }
    local v, k = table.Random(AmmoSupplyTbl)
    self:SetKeyValue("ammosupply", k)
    self:SetKeyValue("ammoamount", v)
end

function NPC:CustomThink()
    local ene = self:GetEnemy()
    local eneIsPly = IsValid(ene) && ene:IsPlayer()

    if eneIsPly && self.CanGiveAmmo then
        self:Fire("SetAmmoResupplierOff")
        self.CanGiveAmmo = nil
    elseif !eneIsPly && !self.CanGiveAmmo then
        self:Fire("SetAmmoResupplierOn")
        self.CanGiveAmmo = true
    end
end