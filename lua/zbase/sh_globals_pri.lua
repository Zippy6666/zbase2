
    // You probably don't want to use these

--[[
======================================================================================================================================================
                                           WEAPON
======================================================================================================================================================
--]]



function ZBase_InitWeaponSystem( npc, wep )

    local EngineWep = wep
    local Decoy = ents.Create("base_gmodentity")


    Decoy:SetModel(wep:GetModel())
    Decoy:SetPos(npc:GetPos())
    Decoy:SetParent(npc)
    Decoy:AddEffects(EF_BONEMERGE)
    Decoy:SetOwner(npc)
    -- Decoy:SetNoDraw(true)
    Decoy.MaxAmmo = wep:GetMaxClip1()
    Decoy.CurAmmo = Decoy.MaxAmmo
    Decoy.NextPrimary = CurTime()
    Decoy.AmmoType = wep:GetPrimaryAmmoType()
    Decoy.WepName = wep.PrintName
    Decoy.Weight = wep:GetWeight()
    Decoy.LastShootT = CurTime()


    Decoy.AllowsAutoSwitchFrom = function() return false end
    Decoy.AllowsAutoSwitchTo = function() return false end
    Decoy.Clip1 = function() return Decoy.CurAmmo end
    Decoy.Clip2 = function() return 0 end
    Decoy.DefaultReload = function( act ) end
    Decoy.GetActivity = function() return npc:GetActivity() end
    Decoy.GetDeploySpeed = function() return 1 end
    Decoy.GetHoldType = function() return npc:ZBNWepSys_GetAnimsWep():GetHoldType() end
    Decoy.GetMaxClip1 = function() return Decoy.MaxAmmo end
    Decoy.GetMaxClip2 = function() return 0 end
    Decoy.GetNextPrimaryFire = function() return Decoy.NextPrimary end
    Decoy.GetNextSecondaryFire = function() return CurTime()+1 end
    Decoy.GetPrimaryAmmoType = function() return Decoy.AmmoType end
    Decoy.GetPrintName = function() return Decoy.WepName or "Weapon" end
    Decoy.GetSecondaryAmmoType = function() return -1 end
    Decoy.GetSlot = function() return 1 end
    Decoy.GetSlotPos = function() return 1 end
    Decoy.GetWeaponViewModel = function() return Decoy:GetModel() end
    Decoy.GetWeaponWorldModel = function() return Decoy:GetModel() end
    Decoy.GetWeight = function() return Decoy.Weight end
    Decoy.HasAmmo = function() return Decoy.Ammo > 0 end
    Decoy.IsCarriedByLocalPlayer = function() return false end
    Decoy.IsScripted = function() return true end
    Decoy.IsWeaponVisible = function() return false end
    Decoy.LastShootTime = function() return Decoy.LastShootT end
    Decoy.SetClip1 = function( ammo ) Decoy.Ammo=ammo end
    Decoy.SetHoldType = function( name ) npc:ZBNWepSys_GetAnimsWep():SetHoldType(name) end
    Decoy.SetLastShootTime = function( time ) Decoy.LastShootT = time end


    Decoy.SendWeaponAnim = function( act ) end
    Decoy.SetActivity = function( act ) end
    Decoy.SetDeploySpeed = function( speed ) end
    Decoy.SetNextPrimaryFire = function( time ) end
    Decoy.SetNextSecondaryFire = function( time ) end
    Decoy.SetClip2 = function( ammo ) end
    Decoy.CallOnClient = function( functionName, arguments ) end


    Decoy:Spawn()


    for varname, var in pairs(wep:GetTable()) do
        Decoy[varname] = var
    end


    npc:DropWeapon()



    EngineWep.IsZBaseEngineWeapon = true
    EngineWep:SetPos(Decoy:GetPos())
    EngineWep:SetParent(Decoy)
    EngineWep:AddEffects(EF_BONEMERGE)
    -- EngineWep:SetParent(Decoy)


    return Decoy, EngineWep

end



--[[
======================================================================================================================================================
                                           SCHEDULE
======================================================================================================================================================
--]]



function ZBaseEngineSchedName( sched )
    -- Might miss a few schedules
    -- Might be slightly inaccurate
    local schednames = {
        [5] = 'SCHED_ALERT_FACE', --	5	Idle stance and face ideal yaw angles.
        [6] = 'SCHED_ALERT_FACE_BESTSOUND', --	6	
        [7] = 'SCHED_ALERT_REACT_TO_COMBAT_SOUND', --	7	
        [8] = 'SCHED_ALERT_SCAN', --	8	Rotate 180 degrees and back to check for enemies.
        [9] = 'SCHED_ALERT_STAND', --	9	Remain idle until an enemy is heard or found.
        [10] = 'SCHED_ALERT_WALK', --	10	Walk until an enemy is heard or found.
        [52] = 'SCHED_AMBUSH', --	52	Remain idle until provoked or an enemy is found.
        [48] = 'SCHED_ARM_WEAPON', --	48	Performs ACT_ARM.
        [24] = 'SCHED_BACK_AWAY_FROM_ENEMY', --	24	Back away from enemy. If not possible to back away then go behind enemy.
        [26] = 'SCHED_BACK_AWAY_FROM_SAVE_POSITION', --	26	Requires valid enemy, backs away from SaveValue: m_vSavePosition
        [23] = 'SCHED_BIG_FLINCH', --	23	Heavy damage was taken for the first time in a while.
        [17] = 'SCHED_CHASE_ENEMY', --	17	Begin chasing an enemy.
        [18] = 'SCHED_CHASE_ENEMY_FAILED', --	18	Failed to chase enemy.
        [12] = 'SCHED_COMBAT_FACE', --	12	Face current enemy.
        [75] = 'SCHED_COMBAT_PATROL', --	75	Will walk around patrolling an area until an enemy is found.
        [15] = 'SCHED_COMBAT_STAND', --	15	
        [13] = 'SCHED_COMBAT_SWEEP', --	13	
        [16] = 'SCHED_COMBAT_WALK', --	16	
        [40] = 'SCHED_COWER', --	40	When not moving, will perform ACT_COWER.
        [53] = 'SCHED_DIE', --	53	Regular NPC death.
        [54] = 'SCHED_DIE_RAGDOLL', --	54
        [79] = 'SCHED_DROPSHIP_DUSTOFF', --	79	
        [84] = 'SCHED_DUCK_DODGE', --	84	Preform Ducking animation. (Only works with npc_alyx)
        [35] = 'SCHED_ESTABLISH_LINE_OF_FIRE', --	35	Search for a place to shoot current enemy.
        [36] = 'SCHED_ESTABLISH_LINE_OF_FIRE_FALLBACK', --	36	Fallback from an established line of fire.
        [81] = 'SCHED_FAIL', --	81	Failed doing current schedule.
        [38] = 'SCHED_FAIL_ESTABLISH_LINE_OF_FIRE', --	38	Failed to establish a line of fire.
        [82] = 'SCHED_FAIL_NOSTOP', --	82	
        [31] = 'SCHED_FAIL_TAKE_COVER', --	31	Failed to take cover.
        [78] = 'SCHED_FALL_TO_GROUND', --	78	Fall to ground when in the air.
        [14] = 'SCHED_FEAR_FACE', --	14	Will express fear face. (Only works on NPCs with expressions)
        [29] = 'SCHED_FLEE_FROM_BEST_SOUND', --	29	
        [80] = 'SCHED_FLINCH_PHYSICS', --	80	Plays ACT_FLINCH_PHYSICS.
        [71] = 'SCHED_FORCED_GO', --	71	Force walk to SaveValue: m_vecLastPosition (debug).
        [72] = 'SCHED_FORCED_GO_RUN', --	72	Force run to SaveValue: m_vecLastPosition (debug).
        [66] = 'SCHED_GET_HEALTHKIT', --	66	Pick up item if within a radius of 5 units.
        [50] = 'SCHED_HIDE_AND_RELOAD', --	50	Take cover and reload weapon.
        [1] = 'SCHED_IDLE_STAND', --	1	Idle stance
        [2] = 'SCHED_IDLE_WALK', --	2	Walk to position.
        [3] = 'SCHED_IDLE_WANDER', --	3	Walk to random position within a radius of 200 units.
        [85] = 'SCHED_INTERACTION_MOVE_TO_PARTNER', --	85	
        [86] = 'SCHED_INTERACTION_WAIT_FOR_PARTNER', --	86	
        [11] = 'SCHED_INVESTIGATE_SOUND', --	11	
        [41] = 'SCHED_MELEE_ATTACK1', --	41	
        [42] = 'SCHED_MELEE_ATTACK2', --	42	
        [68] = 'SCHED_MOVE_AWAY', --	68	Move away from player.
        [70] = 'SCHED_MOVE_AWAY_END', --	70	Stop moving and continue enemy scan.
        [69] = 'SCHED_MOVE_AWAY_FAIL', --	69	Failed to move away; stop moving.
        [25] = 'SCHED_MOVE_AWAY_FROM_ENEMY', --	25	Move away from enemy while facing it and checking for new enemies.
        [34] = 'SCHED_MOVE_TO_WEAPON_RANGE', --	34	Move to the range the weapon is preferably used at.
        [63] = 'SCHED_NEW_WEAPON', --	63	Pick up a new weapon if within a radius of 5 units.
        [64] = 'SCHED_NEW_WEAPON_CHEAT', --	64	Fail safe: Create the weapon that the NPC went to pick up if it was removed during pick up schedule.
        [0] = 'SCHED_NONE', --	0	No schedule is being performed.
        [73] = 'SCHED_NPC_FREEZE', --	73	Prevents movement until COND.NPC_UNFREEZE(68) is set.
        [76] = 'SCHED_PATROL_RUN', --	76	Run to random position and stop if enemy is heard or found.
        [74] = 'SCHED_PATROL_WALK', --	74	Walk to random position and stop if enemy is heard or found.
        [37] = 'SCHED_PRE_FAIL_ESTABLISH_LINE_OF_FIRE', --	37	
        [43] = 'SCHED_RANGE_ATTACK1', --	43	
        [44] = 'SCHED_RANGE_ATTACK2', --	44	
        [51] = 'SCHED_RELOAD', --	51	Stop moving and reload until danger is heard.
        [32] = 'SCHED_RUN_FROM_ENEMY', --	32	Retreat from the established enemy.
        [33] = 'SCHED_RUN_FROM_ENEMY_FALLBACK', --	33	
        [83] = 'SCHED_RUN_FROM_ENEMY_MOB', --	83	
        [77] = 'SCHED_RUN_RANDOM', --	77	Run to random position within a radius of 500 units.
        [62] = 'SCHED_SCENE_GENERIC', --	62	
        [59] = 'SCHED_SCRIPTED_CUSTOM_MOVE', --	59	
        [61] = 'SCHED_SCRIPTED_FACE', --	61	
        [58] = 'SCHED_SCRIPTED_RUN', --	58	
        [60] = 'SCHED_SCRIPTED_WAIT', --	60	
        [57] = 'SCHED_SCRIPTED_WALK', --	57	
        [39] = 'SCHED_SHOOT_ENEMY_COVER', --	39	Shoot cover that the enemy is behind.
        [87] = 'SCHED_SLEEP', --	87	Sets the NPC to a sleep-like state.
        [22] = 'SCHED_SMALL_FLINCH', --	22	
        [45] = 'SCHED_SPECIAL_ATTACK1', --	45	
        [46] = 'SCHED_SPECIAL_ATTACK2', --	46	
        [47] = 'SCHED_STANDOFF', --	47	
        [65] = 'SCHED_SWITCH_TO_PENDING_WEAPON', --	65	
        [28] = 'SCHED_TAKE_COVER_FROM_BEST_SOUND', --	28	
        [27] = 'SCHED_TAKE_COVER_FROM_ENEMY', --	27	Take cover from current enemy.
        [30] = 'SCHED_TAKE_COVER_FROM_ORIGIN', --	30	Flee from SaveValue: vLastKnownLocation
        [21] = 'SCHED_TARGET_CHASE', --	21	Chase set NPC target.
        [20] = 'SCHED_TARGET_FACE', --	20	Face NPC target.
        [19] = 'SCHED_VICTORY_DANCE', --	19	Human victory dance.
        [55] = 'SCHED_WAIT_FOR_SCRIPT', --	55	
        [67] = 'SCHED_WAIT_FOR_SPEAK_FINISH', --	67	
        [4] = 'SCHED_WAKE_ANGRY', --	4	Spot an enemy and go from an idle state to combat state.
    }
    return schednames[sched]
end


function ZBaseESchedID( name )
    return ai.GetScheduleID(name)-1000000000
end


function ZBaseSchedDebug( ent )
    local ent = (IsValid(ent.Navigator) && !ZBCVAR.ShowNavigator:GetBool() && ent.Navigator.MoveConfirmed && ent.Navigator) or ent

    return ( (ent.GetCurrentCustomSched && ent:GetCurrentCustomSched()) or ZBaseEngineSchedName(ent:GetCurrentSchedule()) )
    or (ent.AllowedCustomEScheds && ent.AllowedCustomEScheds[ent:GetCurrentSchedule()]) or "schedule "..tostring(ent:GetCurrentSchedule())
end




--[[
======================================================================================================================================================
                                           OTHER
======================================================================================================================================================
--]]


function ZBaseRoughRadius( ent )
    return math.abs(ent:GetRotatedAABB(ent:OBBMins(),ent:OBBMaxs()).x)*2
end


function ZBaseRndTblRange( tbl )
    return math.Rand(tbl[1], tbl[2])
end