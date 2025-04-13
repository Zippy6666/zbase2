AddCSLuaFile()

SWEP.Base           = "weapon_base"
SWEP.PrintName      = "NPC Controller"
SWEP.Author         = "Zippy"
SWEP.Spawnable      = true
SWEP.Category       = "Other"
SWEP.WorldModel     = Model( "models/weapons/w_slam.mdl" )
SWEP.ViewModelFOV   = 55

SWEP.Primary.Ammo           = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Secondary.Ammo         = -1
SWEP.Secondary.DefaultClip  = -1

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