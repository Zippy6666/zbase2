local BEHAVIOUR = ZBaseNPCs["npc_zbase"].Behaviours

BEHAVIOUR.SecondaryFire = {
    MustHaveVisibleEnemy = true, -- Only run the behaviour if the NPC can see its enemy
    MustFaceEnemy = true, -- Only run the behaviour if the NPC is facing its enemy
}

local SecondaryFireWeapons = {
    ["weapon_ar2"] = {dist=4000, mindist=100},
    ["weapon_smg1"] = {dist=1500, mindist=250},
}

------------------------------------------------------------------------=#
function SecondaryFireWeapons.weapon_ar2:Func( self, wep, enemy )
    local seq = self:LookupSequence("shootar2alt")
    if seq != -1 then
        -- Has comball animation, play it
        self:PlayAnimation("shootar2alt", true)
    else
        -- Charge sound (would normally play in the comball anim)
        wep:EmitSound("Weapon_CombineGuard.Special1")
    end


    timer.Simple(0.75, function()
        if !(IsValid(self) && IsValid(wep) && IsValid(enemy)) then return end
        if self:GetNPCState() == NPC_STATE_DEAD then return end


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
            if IsValid(self)
            && self:GetNPCState() != NPC_STATE_DEAD then
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
    if !self.CanSecondaryAttack then return false end

    local wep = self:GetActiveWeapon()

    if !IsValid(wep) then return false end

    local wepTbl = SecondaryFireWeapons[wep:GetClass()]
    if !wepTbl then return false end

    if self:GetActivity()!=ACT_RANGE_ATTACK1 then return false end

    return self:WithinDistance( self:GetEnemy(), wepTbl.dist, wepTbl.mindist )
end
------------------------------------------------------------------------=#
function BEHAVIOUR.SecondaryFire:Delay( self )

    if math.random(1, 2) == 1 then
        return math.Rand(4, 8)
    end

end
------------------------------------------------------------------------=#
function BEHAVIOUR.SecondaryFire:Run( self )
    local enemy = self:GetEnemy()
    local wep = self:GetActiveWeapon()
    SecondaryFireWeapons[wep:GetClass()]:Func( self, wep, enemy )
    ZBaseDelayBehaviour(math.Rand(4, 8))
end
------------------------------------------------------------------------=#