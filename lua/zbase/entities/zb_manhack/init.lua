local NPC       = FindZBaseTable(debug.getinfo(1,'S'))
local green     = Color(75, 255, 0)
local orange    = Color(255, 175, 0)

NPC.StartHealth = 35
NPC.ZBaseStartFaction = "combine"
NPC.BloodColor = BLOOD_COLOR_MECH

-- Internal manhack variable
-- Makes it faster
NPC.m_fEnginePowerScale = 2

function NPC:CustomInitialize()
    -- Green light by default
    self:ChangeLightColor(green)
end

function NPC:ChangeLightColor(color)
    -- Change color of light
    for _, child in ipairs(self:GetChildren()) do 
        if child:GetClass()=="env_sprite" then
            child:SetColor(color)
        end
    end
end

-- Called when the NPC's enemy is updated
-- 'enemy' - The new enemy, or nil if the enemy was lost
function NPC:EnemyStatus( enemy )
    if enemy == nil then
        -- Lost enemy, turn light green
        self:ChangeLightColor(green)
    else
        -- New enemy, orange light
        self:EmitSound("NPC_FloorTurret.Alarm")
        self:CONV_TimerSimple(0.5, function() self:StopSound("NPC_FloorTurret.Alarm") end)
        self:ChangeLightColor(orange)
    end
end

-- Disable footsteps
function NPC:FootStepTimer()
end

function NPC:CustomTakeDamage( dmginfo, HitGroup )
    -- Damage force lowered overall
    dmginfo:SetDamageForce(dmginfo:GetDamageForce()*0.25)
end

function NPC:ShouldGib( dmginfo, hit_gr )
    -- "Gentle" explosion on gib
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(self:WorldSpaceCenter())
    explosion:SetKeyValue("spawnflags", bit.bor(1, 64, 256))
    explosion:Spawn()
    explosion:Fire("Explode")
    explosion:Remove()
    return true
end

function NPC:OnRemove()
    -- Stop alert sound 
    self:StopSound("NPC_FloorTurret.Alarm")
end