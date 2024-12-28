local NPC = FindZBaseTable(debug.getinfo(1,'S'))
local green = Color(75, 255, 0)
local orange = Color(255, 175, 0)


NPC.StartHealth = 35
NPC.ZBaseStartFaction = "combine"
NPC.BloodColor = BLOOD_COLOR_MECH


NPC.m_fEnginePowerScale = 2


function NPC:CustomInitialize()
    self:ChangeLightColor(green)
end



function NPC:ChangeLightColor(color)
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
        self:ChangeLightColor(green)
    else
        self:EmitSound("NPC_FloorTurret.Alarm")
        self:CONV_TimerSimple(0.5, function() self:StopSound("NPC_FloorTurret.Alarm") end)
        self:ChangeLightColor(orange)
    end
end


function NPC:FootStepTimer()
end


function NPC:CustomTakeDamage( dmginfo, HitGroup )
    local clubDMG = dmginfo:IsDamageType(DMG_CLUB)

    if dmginfo:IsBulletDamage() or clubDMG then
        dmginfo:ScaleDamage(0.68)
    end

    if dmginfo:GetDamage() >= 8 then
        dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), DMG_CLUB))
        self.PainSounds = "NPC_Manhack.Stunned"
    else
        dmginfo:SetDamageForce(dmginfo:GetDamageForce()*0.25)
        self.PainSounds = ""
    end
end


function NPC:ShouldGib( dmginfo, hit_gr )
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(self:WorldSpaceCenter())
    explosion:SetKeyValue("spawnflags", bit.bor(1, 64, 256))
    explosion:Spawn()
    explosion:Fire("Explode")
    explosion:Remove()
    return true
end


function NPC:OnRemove()
    self:StopSound("NPC_FloorTurret.Alarm")
end