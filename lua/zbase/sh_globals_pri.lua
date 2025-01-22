// You probably don't want to use these globals

ZBaseFactionTranslation = SERVER && {
    [CLASS_COMBINE_GUNSHIP] = "combine",
    [CLASS_MANHACK] = "combine",
    [CLASS_METROPOLICE] = "combine",
    [CLASS_MILITARY] = "combine",
    [CLASS_SCANNER] = "combine",
    [CLASS_STALKER] = "combine",
    [CLASS_PROTOSNIPER] = "combine",
    [CLASS_COMBINE_HUNTER] = "combine",
    [CLASS_COMBINE] = "combine",
    [CLASS_HACKED_ROLLERMINE] = "ally",
    [CLASS_HUMAN_PASSIVE] = "ally",
    [CLASS_VORTIGAUNT] = "ally",
    [CLASS_PLAYER] = "ally",
    [CLASS_PLAYER_ALLY_VITAL] = "ally",
    [CLASS_CITIZEN_PASSIVE] = "ally",
    [CLASS_CITIZEN_REBEL] = "ally",
    [CLASS_PLAYER_ALLY] = "ally",
    [CLASS_BARNACLE] = "xen",
    [CLASS_ALIEN_MILITARY] = "xen",
    [CLASS_ALIEN_PREDATOR] = "xen",
    [CLASS_ALIEN_MONSTER] = "xen",
    [CLASS_MACHINE] = "hecu",
    [CLASS_HUMAN_MILITARY] = "hecu",
    [CLASS_HEADCRAB] = "zombie",
    [CLASS_ALIEN_PREY] = "zombie",
    [CLASS_ZOMBIE] = "zombie",
    [CLASS_ANTLION] = "antlion",
    [CLASS_EARTH_FAUNA] = "neutral",
} or nil


ZBaseFactionTranslation_Flipped = SERVER and {
    combine = CLASS_COMBINE,
    ally = CLASS_PLAYER_ALLY,
    xen = CLASS_ALIEN_MONSTER,
    hecu = CLASS_HUMAN_MILITARY,
    zombie = CLASS_ZOMBIE,
    antlion = CLASS_ANTLION,
    neutral = CLASS_EARTH_FAUNA,
} or nil


ZBaseVJFactionTranslation = {
    ["combine"] = "CLASS_COMBINE",
    ["zombie"] = "CLASS_ZOMBIE",
    ["antlion"] = "CLASS_ANTLION",
    ["ally"] = "CLASS_PLAYER_ALLY",
    ["xen"] = "CLASS_XEN",
    ["hecu"] = "CLASS_UNITED_STATES",
    ["blackops"] = "CLASS_BLACKOPS",
    ["racex"] = "CLASS_RACE_X",
    ["clonecop"] = "CLASS_AIDEN",
    ["snark"] = "CLASS_SNARK",
}
ZBaseVJFactionTranslation_Flipped = table.Flip(ZBaseVJFactionTranslation)


ZBASE_MENU_REPLACEMENTS = {
    ["zb_human_civilian"] = "npc_citizen",
    ["zb_antlion"] = "npc_antlion",
    ["zb_combine_soldier"] = "npc_combine_s",
    ["zb_zombine"] = "npc_zombine",
    ["zb_fastzombie"] = "npc_fastzombie",
    ["zb_human_medic"] = "Medic",
    ["zb_stalker"] = "npc_stalker",
    ["zb_kleiner"] = "npc_kleiner",
    ["zb_zombie"] = "npc_zombie",
    ["zb_human_rebel"] = "Rebel",
    ["zb_poisonzombie"] = "npc_poisonzombie",
    ["zb_metropolice"] = "npc_metropolice",
    ["zb_combine_elite"] = "CombineElite",
    ["zb_combine_nova_prospekt"] = "CombinePrison",
    ["zb_hunter"] = "npc_hunter",
    ["zb_vortigaunt"] = "npc_vortigaunt",
    ["zb_human_refugee"] = "Refugee",
    ["zb_odessa"]     = "npc_odessa",
    ["zb_magnusson"] = "npc_magnusson",
    ["zb_dog"] = "npc_dog",
    ["zb_uriah"] = "VortigauntUriah",
}
ZBASE_MENU_REPLACEMENTS_FLIPPED = table.Flip( table.Copy(ZBASE_MENU_REPLACEMENTS) )


--[[
======================================================================================================================================================
                                           NPC PATCHES
======================================================================================================================================================
--]]


function ZBasePatchNPCClass(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split]
    local split2 = string.Split(name, ".")
    return split2[1]
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
        [-1] = "No schedule",
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
    return ( (ent.GetCurrentCustomSched && ent:GetCurrentCustomSched() )
    or ZBaseEngineSchedName(ent:GetCurrentSchedule()) )
    or "custom "..ent:GetClass().." schedule ("..tostring(ent:GetCurrentSchedule()..")")
end


--[[
======================================================================================================================================================
                                           NPC Copy System
======================================================================================================================================================
--]]

if SERVER then
        -- "NPC copy" system, makes a zbase "NPC copy" of any type/class from any spawned NPC
    local invisCol = Color(255,255,255,0)
    local developer = GetConVar("developer")
    function ZBaseNPCCopy( npc, zbase_cls, dontAlterFaction, faction, spawnflags, removeCopyOnRemoved )

        -- Store the old NPCs squad and name
        local name = npc:GetName()
        local squad = npc:GetSquad()

        local npcWep = npc:GetActiveWeapon()
        local wepCls = IsValid(npcWep) && !table.IsEmpty(ZBaseNPCs[zbase_cls].Weapons) && npcWep:GetClass()


        -- New ZBase NPC
        local ZBaseNPC = ZBaseSpawnZBaseNPC( zbase_cls, nil, nil, wepCls or nil, spawnflags )
        ZBaseNPC.DontAutoSetSquad = true

        if !dontAlterFaction then
            ZBaseNPC.ZBaseStartFaction =  faction or ZBaseFactionTranslation[npc:Classify()]
        end

        ZBaseNPC:SetPos(npc:GetPos())
        ZBaseNPC:SetAngles(npc:GetAngles())
        ZBaseNPC:SetName(name)
        ZBaseNPC:SetSquad(squad)
        undo.ReplaceEntity(npc, ZBaseNPC)
        cleanup.ReplaceEntity(npc, ZBaseNPC)

        -- Position aerial npc up if stuck in ground
        local uppamt = ZBaseNPC:OBBMins().z*2
        local tr_aerial_fixer = util.TraceLine({
            start = npc:WorldSpaceCenter(),
            endpos = npc:WorldSpaceCenter()+Vector(0,0,uppamt),
        })
        if tr_aerial_fixer.Hit then
            -- MsgN("stuck, going", uppamt, "up")
            ZBaseNPC:SetPos(tr_aerial_fixer.HitPos+tr_aerial_fixer.HitNormal*(uppamt))
        end


        -- Set NPC into a "dull state"
        npc:SetModel("models/props_lab/huladoll.mdl")
        npc:SetName("")
        npc:SetSquad("")

        npc:AddEFlags(bit.bor(EFL_DONTBLOCKLOS, EFL_NO_THINK_FUNCTION))
        npc:AddFlags(FL_NOTARGET)

        npc:SetCollisionBounds(vector_origin, vector_origin)
        npc:SetMoveType(MOVETYPE_NONE)
        npc:SetSolid(SOLID_NONE)

        npc:CapabilitiesClear()
        npc:SetMaxLookDistance(1)

        if developer:GetBool() then
            npc:SetMaterial("models/wireframe")
        else
            npc:SetNoDraw(true)
            npc:SetRenderMode(RENDERMODE_TRANSCOLOR)
            npc:DrawShadow(false)
            npc:SetColor(invisCol)
        end

        for _, child in ipairs(npc:GetChildren()) do
            -- Remove manhack light, etc
            child:Remove()
        end

        npc:SetNWBool("ZBaseNPCCopy_DullState", true)
        npc.ZBaseNPCCopy_DullState = true


        if removeCopyOnRemoved then
            npc:CallOnRemove("RemoveZBaseNPC", function()
                SafeRemoveEntityDelayed(ZBaseNPC, 0)
            end)
        end
        

        ZBaseNPC:CallOnRemove("KillDullNPC", function()
            if IsValid(npc) then
                if !npc:GetNoDraw() then
                    npc:SetNoDraw(true)
                end

                npc:SetShouldServerRagdoll(false)
                npc:SetHealth(0)
                npc:SetNPCState(NPC_STATE_DEAD)
                npc:SetSchedule(SCHED_DIE_RAGDOLL)

                SafeRemoveEntityDelayed(npc, 2)
            end
        end)

        -- Remove "dull state" NPC's weapon if any
        if IsValid(npcWep) then
            npcWep:Remove()
        end

        return ZBaseNPC

    end
end


--[[
======================================================================================================================================================
                                           OTHER
======================================================================================================================================================
--]]



local SoundDurationCache = {}
function ZBaseSoundDuration( soundname )
    local dur = SoundDurationCache[soundname]
    if dur then
        return dur
    end

    local sounddur = SoundDuration( soundname )
    if sounddur then
        sounddur = math.Round( sounddur * 1000 ) / 1000
        SoundDurationCache[soundname] = sounddur
        return sounddur
    end		

    conv.devPrint(Color(255, 0, 0), "ZBaseSoundDuration: failed to get sound duration for '"..soundname.."'")
    return 0
end


function ZBaseRoughRadius( ent )
    return math.abs(ent:GetRotatedAABB(ent:OBBMins(),ent:OBBMaxs()).x)*2
end


function ZBaseRndTblRange( tbl )
    return math.Rand(tbl[1], tbl[2])
end

function ZBaseShouldUseRelationshipSys( ent )

    if !ent:IsNPC() then
        return false
    end

    local npc = ent
    local class =  string.lower( npc:GetClass() )

    if class=="bullseye_strider_focus" or class=="npc_bullseye" or class == "pill_puppet" or class == "generic_actor" then
        return false
    end

    if npc.IsZBaseNavigator then return false end
    if npc.ZBaseNPCCopy_DullState then return false end

    -- Used by NPC suppression system
    if npc.is_fake then return false end


    return true

end