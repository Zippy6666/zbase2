local BEHAVIOUR = FindZBaseBehaviourTable(debug.getinfo(1,'S'))


/*
    -- In this file you can add custom NPC behaviours



------------------------------------------------------------------------=#

        -- Example --

BEHAVIOUR.SayWhat = {

    MustHaveEnemy = false, -- Should it only run the behaviour if it has an enemy? 
    MustNotHaveEnemy = false, --  Don't run the behaviour if the NPC doesn't have an enemy
    MustHaveVisibleEnemy = false -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = false -- Only run the behaviour if the NPC is facing its enemy

}
------------------------------------------------------------------------=#
-- Return true to allow the behaviour to run, otherwise return false
function BEHAVIOUR.SayWhat:ShouldDoBehaviour( self )
    return true
end
------------------------------------------------------------------------=#
-- Called before running the behaviour
-- Return a number to suppress and delay the behaviour by said number (in seconds)
function BEHAVIOUR.SayWhat:Delay( self )
end
------------------------------------------------------------------------=#
-- Called continiously as long as it should do the behaviour 
-- Write whatever the NPC is going to do here
-- Call ZBaseDelayBehaviour( seconds ) to delay the behaviour (cooldown)
function BEHAVIOUR.SayWhat:Run( self )
    PrintMessage(HUD_PRINTTALK, "WHAT")
    ZBaseDelayBehaviour( 3 )
end
------------------------------------------------------------------------=#
*/


------------------------------------------------------------------------=#
local function UseCustomSounds( _, self )
    if self:GetNPCState() == NPC_STATE_DEAD then return false end
    return self.UseCustomSounds
end

local function DelaySpeech( _, self )

    local squad = self:GetKeyValues().squadname
    if ZBaseSpeakingSquads[squad] then print("delay...") return math.Rand(2, 4) end

end
------------------------------------------------------------------------=#


BEHAVIOUR.Patrol = {
    MustNotHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
}
BEHAVIOUR.FactionCallForHelp = {
    MustHaveEnemy = true, -- Should it only run the behaviour if it has an enemy? 
}
BEHAVIOUR.SecondaryFire = {
    MustFaceEnemy = true,
    MustHaveVisibleEnemy = true,
}


BEHAVIOUR.DoIdleSound = {
    MustNotHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
    --ShouldDoBehaviour=UseCustomSounds,
    Delay=DelaySpeech,
}
BEHAVIOUR.DoIdleEnemySound = {
    MustHaveEnemy = true, --  Don't run the behaviour if the NPC doesn't have an enemy
    ShouldDoBehaviour=UseCustomSounds,
    Delay=DelaySpeech,
}


------------------------------------------------------------------------=#
function BEHAVIOUR.FactionCallForHelp:ShouldDoBehaviour( self )
    return self.CallForHelp!=false && self.ZBaseFaction != "none"
end
------------------------------------------------------------------------=#
function BEHAVIOUR.FactionCallForHelp:Run( self )
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), self.CallForHelpDistance)) do

        if !v:IsNPC() then continue end
        if v == self then continue end
        if v.ZBaseFaction == "none" then continue end
        if IsValid(v:GetEnemy()) then continue end -- Ally already busy with an enemy

        if v.ZBaseFaction == self.ZBaseFaction then
            local ene = self:GetEnemy()
            v:UpdateEnemyMemory(ene, ene:GetPos())
            v:AlertSound()
        end

    end

    ZBaseDelayBehaviour(math.Rand(2, 3.5))
end
------------------------------------------------------------------------=#




------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:ShouldDoBehaviour( self )
    return self.CanPatrol
end
------------------------------------------------------------------------=#
function BEHAVIOUR.Patrol:Run( self )
    self:SetSchedule(SCHED_PATROL_WALK)
    ZBaseDelayBehaviour(math.random(8, 15))
end

------------------------------------------------------------------------=#


------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleSound:ShouldDoBehaviour( self )
    if self.IdleSound_OnlyNearAllies then
        self.IdleSound_CurrentNearestAlly = self:GetNearestAlly(200)
        return IsValid(self.IdleSound_CurrentNearestAlly)
    end

    return UseCustomSounds(_, self)
end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleSound:Run( self )

    ZBase_DontSpeakOverThisSound = true
    self:EmitSound(self.IdleSounds)
    ZBase_DontSpeakOverThisSound = false
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSoundCooldown))

    -- Face each other as if they are talking
    if math.random(1, self.IdleSound_FaceAllyChance)==1 && IsValid(self.IdleSound_CurrentNearestAlly) then
        self:SetTarget(self.IdleSound_CurrentNearestAlly)
        self:SetSchedule(SCHED_TARGET_FACE)
        self.IdleSound_CurrentNearestAlly:SetTarget(self)
        self.IdleSound_CurrentNearestAlly:SetSchedule(SCHED_TARGET_FACE)
    end
end
------------------------------------------------------------------------=#
function BEHAVIOUR.DoIdleEnemySound:Run( self )

    local snd = self.IdleSounds_HasEnemy
    local enemy = self:GetEnemy()

    -- if IsValid(enemy) && enemy != self.AlertSound_LastEnemy then
    --     snd = self.AlertSounds
    --     self.AlertSound_LastEnemy = enemy
    -- end

    ZBase_DontSpeakOverThisSound = true
    self:EmitSound(snd)
    ZBase_DontSpeakOverThisSound = false
    ZBaseDelayBehaviour(ZBaseRndTblRange(self.IdleSounds_HasEnemyCooldown))

end
------------------------------------------------------------------------=#

-- Secondary fire

local SecondaryFireWeapons = {
    ["weapon_ar2"] = {dist=4000, mindist=100},
    ["weapon_smg1"] = {dist=1500, mindist=250},
}

------------------------------------------------------------------------=#
function SecondaryFireWeapons.weapon_ar2:Func( self, wep, enemy )

    local seq = self:LookupSequence("shootar2alt")
    if seq != -1 then
        self:ResetIdealActivity(self:GetSequenceActivity(seq))
    else
        wep:EmitSound("Weapon_CombineGuard.Special1")
    end

    timer.Simple(0.75, function()
        if IsValid(self) && IsValid(wep) && IsValid(enemy) then
            local startPos = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos

            local ball_launcher = ents.Create( "point_combine_ball_launcher" )
            ball_launcher:SetAngles( (enemy:WorldSpaceCenter() - startPos):Angle() )
            ball_launcher:SetPos( startPos )
            ball_launcher:SetKeyValue( "minspeed",1200 )
            ball_launcher:SetKeyValue( "maxspeed", 1200 )
            ball_launcher:SetKeyValue( "ballradius", "10" )
            ball_launcher:SetKeyValue( "ballcount", "1" )
            ball_launcher:SetKeyValue( "maxballbounces", "100" )
            ball_launcher:Spawn()
            ball_launcher:Activate()
            ball_launcher:Fire( "LaunchBall" )
            ball_launcher:Fire("kill","",0)
            timer.Simple(0.01, function()
                if IsValid(self) then
                    for _, ball in ipairs(ents.FindInSphere(self:GetPos(), 100)) do
                        if ball:GetClass() == "prop_combine_ball" then

                            ball:SetOwner(self)
                            ball.ZBaseComballOwner = self

                            timer.Simple(math.Rand(4, 6), function()
                                if IsValid(ball) then
                                    ball:Fire("Explode")
                                end
                            end)

                        end
                    end
                end
            end)
        
            local effectdata = EffectData()
            effectdata:SetFlags(5)
            effectdata:SetEntity(wep)
            util.Effect( "MuzzleFlash", effectdata, true, true )

            wep:EmitSound("Weapon_IRifle.Single")
        end
    end)

end
------------------------------------------------------------------------=#
function SecondaryFireWeapons.weapon_smg1:Func( self, wep, enemy )

    local startPos = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos
    local grenade = ents.Create("grenade_ar2")
    grenade:SetOwner(self)
    grenade:SetPos(startPos)
    grenade:Spawn()
    grenade:SetVelocity((enemy:GetPos() - startPos):GetNormalized()*1250 + Vector(0,0,200))
    grenade:SetLocalAngularVelocity(AngleRand())
    wep:EmitSound("Weapon_AR2.Double")

    local effectdata = EffectData()
    effectdata:SetFlags(7)
    effectdata:SetEntity(wep)
    util.Effect( "MuzzleFlash", effectdata, true, true )

end
------------------------------------------------------------------------=#
function BEHAVIOUR.SecondaryFire:ShouldDoBehaviour( self )
    local wep = self:GetActiveWeapon()

    if !IsValid(wep) then return false end

    local wepTbl = SecondaryFireWeapons[wep:GetClass()]
    if !wepTbl then return false end

    if self:GetActivity()!=ACT_RANGE_ATTACK1 then return false end

    return self:WithinDistance( self:GetEnemy(), wepTbl.dist, wepTbl.mindist )
end
------------------------------------------------------------------------=#
function BEHAVIOUR.SecondaryFire:Delay( self )

    if math.random(1, 3) != 1 then
        return math.Rand(4, 8)
    end

end
------------------------------------------------------------------------=#
function BEHAVIOUR.SecondaryFire:Run( self )
    local enemy = self:GetEnemy()
    local wep = self:GetActiveWeapon()
    SecondaryFireWeapons[wep:GetClass()]:Func( self, wep, enemy )
end
------------------------------------------------------------------------=#