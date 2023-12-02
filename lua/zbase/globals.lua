--[[
======================================================================================================================================================
                                           ENUMS
======================================================================================================================================================
--]]


ZBASE_SNPCTYPE_WALK = 1
ZBASE_SNPCTYPE_FLY = 2
ZBASE_SNPCTYPE_STATIONARY = 3
ZBASE_SNPCTYPE_VEHICLE = 4
ZBASE_SNPCTYPE_PHYSICS = 5


ZBASE_CANTREACHENEMY_HIDE = 1
ZBASE_CANTREACHENEMY_FACE = 2


ZBASE_TOOCLOSEBEHAVIOUR_NONE = 0
ZBASE_TOOCLOSEBEHAVIOUR_FACE = 1
ZBASE_TOOCLOSEBEHAVIOUR_BACK = 2


--[[
======================================================================================================================================================
                                           ESSENTIAL FUNCTIONS
======================================================================================================================================================
--]]


function FindZBaseTable(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split-1]
    return ZBaseNPCs[name]
end


function FindZBaseBehaviourTable(debuginfo)
    if SERVER then
        return FindZBaseTable(debuginfo).Behaviours
    end
end


--[[
======================================================================================================================================================
                                           UTIL FUNCTIONS
======================================================================================================================================================
--]]


function ZBaseSetFaction( ent, newFaction )
    ent.ZBaseFaction = newFaction or ent.ZBaseStartFaction

    for _, v in ipairs(ZBaseRelationshipEnts) do
        v:Relationships()
    end
end


function ZBaseAddGlowingEye(model, skin, bone, offset, scale, color)
    if !ZBaseGlowingEyes[model] then ZBaseGlowingEyes[model] = {} end

    local Eye = {}
    Eye.skin = skin
    Eye.bone = bone
    Eye.offset = offset
    Eye.scale = scale
    Eye.color = color

    table.insert(ZBaseGlowingEyes[model], Eye)
end


function ZBaseBleed( ent, pos, ang )
    if !SERVER then return end
    if !ent:IsNPC() && !ent.IsZBaseGib then return end


    local bloodcol = (ent.IsZBaseGib && ent.BloodColor) or ent:GetBloodColor()


    local distFromSelf = ent:GetPos():DistToSqr(pos)
    if distFromSelf > (math.max(ent:OBBMaxs().x, ent:OBBMaxs().z)*1.5)^2 then
        pos = ent:WorldSpaceCenter()+VectorRand()*15
    end


    if bloodcol==BLOOD_COLOR_MECH then
        local spark = ents.Create("env_spark")
        spark:SetKeyValue("spawnflags", 256)
        spark:SetKeyValue("TrailLength", 1)
        spark:SetKeyValue("Magnitude", 1)
        spark:SetPos(pos)
        spark:SetAngles(ang && -ang or AngleRand())
        spark:Spawn()
        spark:Activate()
        spark:Fire("SparkOnce")
        SafeRemoveEntityDelayed(spark, 0.1)
    else
        local BloodEffects = {
            [BLOOD_COLOR_RED] = "blood_impact_red_01",
            [BLOOD_COLOR_ANTLION] = "blood_impact_antlion_01",
            [BLOOD_COLOR_ANTLION_WORKER] = "blood_impact_antlion_worker_01",
            [BLOOD_COLOR_GREEN] = "blood_impact_green_01",
            [BLOOD_COLOR_ZOMBIE] = "blood_impact_zombie_01",
            [BLOOD_COLOR_YELLOW] = "blood_impact_yellow_01",
        }
        local effect = BloodEffects[bloodcol]


        if effect then
            ParticleEffect(effect, pos, ang or AngleRand())
        end
    end


    if ent.IsZBaseGib or ent.IsZBaseNPC then
        ent:CustomBleed( pos, (ang && ang:Forward()) or VectorRand(), false )
    end
end


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


--[[
======================================================================================================================================================
                                           CONVINIENT FUNCTIONS
======================================================================================================================================================
--]]


function ZBaseCreateVoiceSounds( name, tbl )
    sound.Add( {
        name = name,
        channel = CHAN_VOICE,
        volume = 0.5,
        level = 90,
        pitch = {95, 105},
        sound = tbl,
    } )
end


function ZBaseRndTblRange( tbl )
    return math.Rand(tbl[1], tbl[2])
end