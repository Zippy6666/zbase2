AddCSLuaFile()

SWEP.Base           = "weapon_base"
SWEP.PrintName      = "NPC Controller"
SWEP.Author         = "Zippy"
SWEP.Spawnable      = false
SWEP.Instructions   = "Press PRIMARY KEY to control almost any NPC!"
SWEP.Category       = "Other"
SWEP.WorldModel = Model( "models/weapons/w_stunbaton.mdl" ) -- Relative path to the SWEP's world model.
SWEP.ViewModel = Model( "models/weapons/v_stunstick.mdl" ) -- Relative path to the SWEP's view model.
SWEP.ViewModelFOV   = 55

SWEP.Primary.Ammo           = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Secondary.Ammo         = -1
SWEP.Secondary.DefaultClip  = -1

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
    if SERVER then
        local own = self:GetOwner()

        if !own:IsPlayer() then return end

        local ply   = own
        local tr    = ply:GetEyeTrace()
        local npc   = tr.Entity

        if IsValid(npc) then
            ZBASE_CONTROLLER:StartControlling( ply, npc )
        end
    end
end

function SWEP:SecondaryAttack()
end