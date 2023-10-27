local NPC = FindZBaseTable(debug.getinfo(1,'S'))



-- Spawn with a random model from this table
-- Leave empty to use the default model for the NPC
NPC.Models = {}


/*
WEAPON_PROFICIENCY_POOR ||
WEAPON_PROFICIENCY_AVERAGE ||
WEAPON_PROFICIENCY_GOOD ||
WEAPON_PROFICIENCY_VERY_GOOD ||
WEAPON_PROFICIENCY_PERFECT
*/
NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD 


NPC.SightDistance = 7000 -- Sight distance
NPC.StartHealth = 100 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour


    -- Functions you can change --

---------------------------------------------------------------------------------------------------------------------=#
    -- Called when the NPC is created --
function NPC:CustomInitialize() end
---------------------------------------------------------------------------------------------------------------------=#
    -- Called every tick --
function NPC:CustomThink() end
---------------------------------------------------------------------------------------------------------------------=#
    -- On NPC hurt, return true to prevent damage --
function NPC:CustomTakeDamage( dmginfo, HitGroup ) end
---------------------------------------------------------------------------------------------------------------------=#
    -- Called when the NPC hurts an entity, return true to prevent damage --
function NPC:DealDamage( victimEnt, dmginfo ) end
---------------------------------------------------------------------------------------------------------------------=#






    -- DON'T TOUCH --

---------------------------------------------------------------------------------------------------------------------=#
function NPC:ZBaseInit()


    -- Model
    if !table.IsEmpty(self.Models) then
        self:SetModel(table.Random(self.Models))
    end


    -- Health
    if self.StartHealth then
        self:SetMaxHealth(self.StartHealth)
        self:SetHealth(self.StartHealth)
    end

    -- Sight distance
    self:SetMaxLookDistance(self.SightDistance or 7000)

    -- Weapon proficiency
    self:SetCurrentWeaponProficiency(self.WeaponProficiency)

    -- Behaviour init
    ZBaseBehaviourInit( self )


    -- Better position
    self:SetPos(self:GetPos()+Vector(0, 0, 20))


end
---------------------------------------------------------------------------------------------------------------------=#




