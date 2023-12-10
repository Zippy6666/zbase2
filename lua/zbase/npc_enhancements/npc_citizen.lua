local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))
ZBaseEnhancementTable[my_cls] = function( NPC )
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedInit()

    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedThink()
        -- Fix rockets not being fired at players --
        local wep = self:GetActiveWeapon()
        local ene = self:GetEnemy()


        if IsValid(ene) && ene:IsPlayer() && IsValid(wep) && wep:GetClass()=="weapon_rpg" && self:GetCurrentSchedule()==SCHED_STANDOFF then
            local start = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos
            local vel = (ene:WorldSpaceCenter() - start):GetNormalized()*500
            local rocket = ents.Create("rpg_missile")
            rocket:SetPos(start)
            rocket:SetOwner(self)
            rocket:SetVelocity(vel+Vector(0,0,100))
            rocket:SetAngles(vel:Angle())
            rocket:Spawn()
            rocket:SetSaveValue("m_flDamage", ZBCVAR.FullHL2WepDMG_PLY:GetBool()&&150 or 70)

            self:PlayAnimation("shoot_rpg", true, {duration=2, noTransitions=true})


            wep:EmitSound("Weapon_RPG.Single")
    

            local effectdata = EffectData()
            effectdata:SetFlags(7)
            effectdata:SetEntity(wep)
            util.Effect( "MuzzleFlash", effectdata )
        end
        ------------------------------------------=#


        -- Fix medics trying to heal players when they are enemies --
        if IsValid(ene) && ene:IsPlayer() then
            self:SetSaveValue("m_flPlayerHealTime", 5)
        end
    end
    --]]============================================================================================================]]
end