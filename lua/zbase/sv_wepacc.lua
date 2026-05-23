-- Weapon accuracy modifier for ZBase NPC and ZBase weapons

local BulletHookRanAccuracyCode = false

hook.Add("PreRegisterSWEP", "ZBASE_WeaponAccuracy", function(swep, class)
    if !swep.GetNPCBulletSpread then return end

    swep.GetNPCBulletSpread = conv.wrapFunc2( swep.GetNPCBulletSpread, nil, function(returnValues, wep)
        local mult = ZBCVAR.WepAccuracyMult:GetFloat()

        if mult == 1.0 then return end

        local own = wep:GetOwner()

        if wep.IsZBaseWeapon || own.IsZBaseNPC then
            return returnValues[1]/mult
        end
    end )
end)

hook.Add("EntityFireBullets", "ZBASE_WeaponAccuracy", function(ent, data)
    if BulletHookRanAccuracyCode then return end
    
    local wep = (isfunction(ent.GetActiveWeapon) && ent:GetActiveWeapon()) || NULL

    print(wep, ent)

    if ent.IsZBaseWeapon || ent.IsZBaseNPC || wep.IsZBaseWeapon || wep.IsZBaseNPC then
        data.Spread.x = data.Spread.x/ZBCVAR.WepAccuracyMult:GetFloat()
        data.Spread.y = data.Spread.y/ZBCVAR.WepAccuracyMult:GetFloat()
        
        BulletHookRanAccuracyCode = true
        hook.Run("EntityFireBullets", ent, data)
        BulletHookRanAccuracyCode = false

        print("ass123")

        return true
    end
end)