-------------------------------------------------------------------------------------------------------------------------=#

    ███████╗██████╗░░█████╗░░██████╗███████╗
    ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝
    ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░
    ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░
    ███████╗██████╦╝██║░░██║██████╔╝███████╗
    ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝
        
    █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█
    █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█
    ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█

-------------------------------------------------------------------------------------------------------------------------=#


                -- BUGS --
        -- Squad error
		-- Circular include error thingy


                -- CURRENT --
		-- External PlayAnimation
			-- Secondary fire as PlayAnimation
		-- Melee animation events
		-- Make some NPCs melee more somehow (vorts and metrocops for example)
		-- BOOLET DEFLECTIONnnn
        -- Make range attack code


			-- TODO (ranked by priority) --
		-- 1. Make sure it has all the essential things
				-- More sounds
					-- LostEnemySounds
					-- SeeDangerSounds
					-- SeeGrenadeSounds
					-- HearDangerSounds
					-- AllyDeathSounds
					-- OnMeleeSounds
					-- OnRangeSounds
					-- OnReloadSounds
					-- + Stop sounds on death
				-- Range attack code
				-- Damage scaling system (like vj immunity, but scale)
				-- Jump system
				-- Hearing system
		-- 2. Aerial base
		-- 3. Controller
		-- 4. Spawning utilities
		-- 5. Bodygroup system
		-- 6. Submaterial system
		-- 7. Custom blood system
				--White blood decals for hunters
		-- 8. More menu options
			-- Behavior tick speed



        -- FINAL --
    -- Make sure all NPCs have their full potential
    -- Make more user friendly with comments and shit, more error handling maybe, update comments for NPC examples, dummy git
    -- Make sure everything works
	-- Make sure it works in multiplayer
	-- Make sure ZBase handles all npc classes well (especially zombies!!)
	-- Make sure it works as intended with vj
    -- Compatible with my other addons
    -- Copyright stuff


        -- GOOD STUFF --
    -- https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/game/server/ai_basenpc.cpp
    -- https://github.com/Facepunch/garrysmod/tree/9bbd7c8af0dda5bed88e3f09fbdf5d4be7e012f2

-------------------------------------------------------------------------------------------------------------------------=#

// Global Savedata for npc
//
// This should be an exact copy of the var's in the header.  Fields
// that aren't save/restored are commented out

BEGIN_DATADESC( CAI_BaseNPC )

	//								m_pSchedule  (reacquired on restore)
	DEFINE_EMBEDDED( m_ScheduleState ),
	DEFINE_FIELD( m_IdealSchedule,				FIELD_INTEGER ), // handled specially but left in for "virtual" schedules
	DEFINE_FIELD( m_failSchedule,				FIELD_INTEGER ), // handled specially but left in for "virtual" schedules
	DEFINE_FIELD( m_bUsingStandardThinkTime,	FIELD_BOOLEAN ),
	DEFINE_FIELD( m_flLastRealThinkTime,		FIELD_TIME ),
	//								m_iFrameBlocked (not saved)
	//								m_bInChoreo (not saved)
	//								m_bDoPostRestoreRefindPath (not saved)
	//								gm_flTimeLastSpawn (static)
	//								gm_nSpawnedThisFrame (static)
	//								m_Conditions (custom save)
	//								m_CustomInterruptConditions (custom save)
	//								m_ConditionsPreIgnore (custom save)
	//								m_InverseIgnoreConditions (custom save)
	//								m_poseAim_Pitch (not saved; recomputed on restore)
	//								m_poseAim_Yaw (not saved; recomputed on restore)
	//								m_poseMove_Yaw (not saved; recomputed on restore)
	DEFINE_FIELD( m_flTimePingEffect,			FIELD_TIME ),
	DEFINE_FIELD( m_bForceConditionsGather,		FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bConditionsGathered,		FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bSkippedChooseEnemy,		FIELD_BOOLEAN ),
	DEFINE_FIELD( m_NPCState,					FIELD_INTEGER ),
	DEFINE_FIELD( m_IdealNPCState,				FIELD_INTEGER ),
	DEFINE_FIELD( m_flLastStateChangeTime,		FIELD_TIME ),
	DEFINE_FIELD( m_Efficiency,					FIELD_INTEGER ),
	DEFINE_FIELD( m_MoveEfficiency,				FIELD_INTEGER ),
	DEFINE_FIELD( m_flNextDecisionTime,			FIELD_TIME ),
	DEFINE_KEYFIELD( m_SleepState,				FIELD_INTEGER, "sleepstate" ),
	DEFINE_FIELD( m_SleepFlags,					FIELD_INTEGER ),
	DEFINE_KEYFIELD( m_flWakeRadius, FIELD_FLOAT, "wakeradius" ),
	DEFINE_KEYFIELD( m_bWakeSquad, FIELD_BOOLEAN, "wakesquad" ),
	DEFINE_FIELD( m_nWakeTick, FIELD_TICK ),
	
	DEFINE_CUSTOM_FIELD( m_Activity,				ActivityDataOps() ),
	DEFINE_CUSTOM_FIELD( m_translatedActivity,		ActivityDataOps() ),
	DEFINE_CUSTOM_FIELD( m_IdealActivity,			ActivityDataOps() ),
	DEFINE_CUSTOM_FIELD( m_IdealTranslatedActivity,	ActivityDataOps() ),
	DEFINE_CUSTOM_FIELD( m_IdealWeaponActivity,		ActivityDataOps() ),

	DEFINE_FIELD( m_nIdealSequence,				FIELD_INTEGER ),
	DEFINE_EMBEDDEDBYREF( m_pSenses ),
	DEFINE_EMBEDDEDBYREF( m_pLockedBestSound ),
  	DEFINE_FIELD( m_hEnemy,						FIELD_EHANDLE ),
	DEFINE_FIELD( m_flTimeEnemyAcquired,		FIELD_TIME ),
	DEFINE_FIELD( m_hTargetEnt,					FIELD_EHANDLE ),
	DEFINE_EMBEDDED( m_GiveUpOnDeadEnemyTimer ),
	DEFINE_EMBEDDED( m_FailChooseEnemyTimer ),
	DEFINE_FIELD( m_EnemiesSerialNumber,		FIELD_INTEGER ),
	DEFINE_FIELD( m_flAcceptableTimeSeenEnemy,	FIELD_TIME ),
	DEFINE_EMBEDDED( m_UpdateEnemyPosTimer ),
	//		m_flTimeAnyUpdateEnemyPos (static)
	DEFINE_FIELD( m_vecCommandGoal,				FIELD_VECTOR ),
	DEFINE_EMBEDDED( m_CommandMoveMonitor ),
	DEFINE_FIELD( m_flSoundWaitTime,			FIELD_TIME ),
	DEFINE_FIELD( m_nSoundPriority,				FIELD_INTEGER ),
	DEFINE_FIELD( m_flIgnoreDangerSoundsUntil,	FIELD_TIME ),
	DEFINE_FIELD( m_afCapability,				FIELD_INTEGER ),
	DEFINE_FIELD( m_flMoveWaitFinished,			FIELD_TIME ),
	DEFINE_FIELD( m_hOpeningDoor,				FIELD_EHANDLE ),
	DEFINE_EMBEDDEDBYREF( m_pNavigator ),
	DEFINE_EMBEDDEDBYREF( m_pLocalNavigator ),
	DEFINE_EMBEDDEDBYREF( m_pPathfinder ),
	DEFINE_EMBEDDEDBYREF( m_pMoveProbe ),
	DEFINE_EMBEDDEDBYREF( m_pMotor ),
	DEFINE_UTLVECTOR(m_UnreachableEnts,		FIELD_EMBEDDED),
	DEFINE_FIELD( m_hInteractionPartner,	FIELD_EHANDLE ),
	DEFINE_FIELD( m_hLastInteractionTestTarget,	FIELD_EHANDLE ),
	DEFINE_FIELD( m_hForcedInteractionPartner,	FIELD_EHANDLE ),
	DEFINE_FIELD( m_flForcedInteractionTimeout, FIELD_TIME ),
	DEFINE_FIELD( m_vecForcedWorldPosition,	FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_bCannotDieDuringInteraction, FIELD_BOOLEAN ),
	DEFINE_FIELD( m_iInteractionState,		FIELD_INTEGER ),
	DEFINE_FIELD( m_iInteractionPlaying,	FIELD_INTEGER ),
	DEFINE_UTLVECTOR(m_ScriptedInteractions,FIELD_EMBEDDED),
	DEFINE_FIELD( m_flInteractionYaw,		FIELD_FLOAT ),
	DEFINE_EMBEDDED( m_CheckOnGroundTimer ),
	DEFINE_FIELD( m_vDefaultEyeOffset,		FIELD_VECTOR ),
  	DEFINE_FIELD( m_flNextEyeLookTime,		FIELD_TIME ),
    DEFINE_FIELD( m_flEyeIntegRate,			FIELD_FLOAT ),
    DEFINE_FIELD( m_vEyeLookTarget,			FIELD_POSITION_VECTOR ),
    DEFINE_FIELD( m_vCurEyeTarget,			FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_hEyeLookTarget,			FIELD_EHANDLE ),
    DEFINE_FIELD( m_flHeadYaw,				FIELD_FLOAT ),
    DEFINE_FIELD( m_flHeadPitch,				FIELD_FLOAT ),
    DEFINE_FIELD( m_flOriginalYaw,			FIELD_FLOAT ),
	DEFINE_FIELD( m_bInAScript,				FIELD_BOOLEAN ),
    DEFINE_FIELD( m_scriptState,				FIELD_INTEGER ),
	DEFINE_FIELD( m_hCine,					FIELD_EHANDLE ),
	DEFINE_CUSTOM_FIELD( m_ScriptArrivalActivity,	ActivityDataOps() ),
	DEFINE_FIELD( m_strScriptArrivalSequence,	FIELD_STRING ),
	DEFINE_FIELD( m_flSceneTime,			FIELD_TIME ),
	DEFINE_FIELD( m_iszSceneCustomMoveSeq,	FIELD_STRING ),
	// 							m_pEnemies					Saved specially in ai_saverestore.cpp
	DEFINE_FIELD( m_afMemory,					FIELD_INTEGER ),
  	DEFINE_FIELD( m_hEnemyOccluder,			FIELD_EHANDLE ),
  	DEFINE_FIELD( m_flSumDamage,				FIELD_FLOAT ),
  	DEFINE_FIELD( m_flLastDamageTime,			FIELD_TIME ),
  	DEFINE_FIELD( m_flLastPlayerDamageTime,			FIELD_TIME ),
	DEFINE_FIELD( m_flLastSawPlayerTime,			FIELD_TIME ),
  	DEFINE_FIELD( m_flLastAttackTime,			FIELD_TIME ),
	DEFINE_FIELD( m_flLastEnemyTime,			FIELD_TIME ),
  	DEFINE_FIELD( m_flNextWeaponSearchTime,	FIELD_TIME ),
	DEFINE_FIELD( m_iszPendingWeapon,		FIELD_STRING ),
	DEFINE_KEYFIELD( m_bIgnoreUnseenEnemies, FIELD_BOOLEAN , "ignoreunseenenemies"),
	DEFINE_EMBEDDED( m_ShotRegulator ),
	DEFINE_FIELD( m_iDesiredWeaponState,	FIELD_INTEGER ),
	// 							m_pSquad					Saved specially in ai_saverestore.cpp
	DEFINE_KEYFIELD(m_SquadName,				FIELD_STRING, "squadname" ),
    DEFINE_FIELD( m_iMySquadSlot,				FIELD_INTEGER ),
	DEFINE_KEYFIELD( m_strHintGroup,			FIELD_STRING, "hintgroup" ),
	DEFINE_KEYFIELD( m_bHintGroupNavLimiting,	FIELD_BOOLEAN, "hintlimiting" ),
 	DEFINE_EMBEDDEDBYREF( m_pTacticalServices ),
 	DEFINE_FIELD( m_flWaitFinished,			FIELD_TIME ),
	DEFINE_FIELD( m_flNextFlinchTime,		FIELD_TIME ),
	DEFINE_FIELD( m_flNextDodgeTime,		FIELD_TIME ),
	DEFINE_EMBEDDED( m_MoveAndShootOverlay ),
	DEFINE_FIELD( m_vecLastPosition,			FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_vSavePosition,			FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_vInterruptSavePosition,		FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_pHintNode,				FIELD_EHANDLE),
	DEFINE_FIELD( m_cAmmoLoaded,				FIELD_INTEGER ),
    DEFINE_FIELD( m_flDistTooFar,				FIELD_FLOAT ),
	DEFINE_FIELD( m_hGoalEnt,					FIELD_EHANDLE ),
	DEFINE_FIELD( m_flTimeLastMovement,			FIELD_TIME ),
	DEFINE_KEYFIELD(m_spawnEquipment,			FIELD_STRING, "additionalequipment" ),
  	DEFINE_FIELD( m_fNoDamageDecal,			FIELD_BOOLEAN ),
  	DEFINE_FIELD( m_hStoredPathTarget,			FIELD_EHANDLE ),
	DEFINE_FIELD( m_vecStoredPathGoal,		FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_nStoredPathType,			FIELD_INTEGER ),
	DEFINE_FIELD( m_fStoredPathFlags,			FIELD_INTEGER ),
	DEFINE_FIELD( m_bDidDeathCleanup,			FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bCrouchDesired,				FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bForceCrouch,				FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bIsCrouching,				FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bPerformAvoidance,			FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bIsMoving,					FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bFadeCorpse,				FIELD_BOOLEAN ),
	DEFINE_FIELD( m_iDeathPose,					FIELD_INTEGER ),
	DEFINE_FIELD( m_iDeathFrame,				FIELD_INTEGER ),
	DEFINE_FIELD( m_bCheckContacts,				FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bSpeedModActive,			FIELD_BOOLEAN ),
	DEFINE_FIELD( m_iSpeedModRadius,			FIELD_INTEGER ),
	DEFINE_FIELD( m_iSpeedModSpeed,				FIELD_INTEGER ),
	DEFINE_FIELD( m_hEnemyFilter,				FIELD_EHANDLE ),
	DEFINE_KEYFIELD( m_iszEnemyFilterName,		FIELD_STRING, "enemyfilter" ),
	DEFINE_FIELD( m_bImportanRagdoll,			FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bPlayerAvoidState,			FIELD_BOOLEAN ),

	// Satisfy classcheck
	// DEFINE_FIELD( m_ScheduleHistory, CUtlVector < AIScheduleChoice_t > ),

	//							m_fIsUsingSmallHull			TODO -- This needs more consideration than simple save/load
	// 							m_failText					DEBUG
	// 							m_interruptText				DEBUG
	// 							m_failedSchedule			DEBUG
	// 							m_interuptSchedule			DEBUG
	// 							m_nDebugCurIndex			DEBUG

	// 							m_LastShootAccuracy			DEBUG
	// 							m_RecentShotAccuracy		DEBUG
	// 							m_TotalShots				DEBUG
	// 							m_TotalHits					DEBUG
	//							m_bSelected					DEBUG
	// 							m_TimeLastShotMark			DEBUG
	//							m_bDeferredNavigation


	// Outputs
	DEFINE_OUTPUT( m_OnDamaged,				"OnDamaged" ),
	DEFINE_OUTPUT( m_OnDeath,					"OnDeath" ),
	DEFINE_OUTPUT( m_OnHalfHealth,				"OnHalfHealth" ),
	DEFINE_OUTPUT( m_OnFoundEnemy,				"OnFoundEnemy" ),
	DEFINE_OUTPUT( m_OnLostEnemyLOS,			"OnLostEnemyLOS" ),
	DEFINE_OUTPUT( m_OnLostEnemy,				"OnLostEnemy" ),
	DEFINE_OUTPUT( m_OnFoundPlayer,			"OnFoundPlayer" ),
	DEFINE_OUTPUT( m_OnLostPlayerLOS,			"OnLostPlayerLOS" ),
	DEFINE_OUTPUT( m_OnLostPlayer,				"OnLostPlayer" ),
	DEFINE_OUTPUT( m_OnHearWorld,				"OnHearWorld" ),
	DEFINE_OUTPUT( m_OnHearPlayer,				"OnHearPlayer" ),
	DEFINE_OUTPUT( m_OnHearCombat,				"OnHearCombat" ),
	DEFINE_OUTPUT( m_OnDamagedByPlayer,		"OnDamagedByPlayer" ),
	DEFINE_OUTPUT( m_OnDamagedByPlayerSquad,	"OnDamagedByPlayerSquad" ),
	DEFINE_OUTPUT( m_OnDenyCommanderUse,		"OnDenyCommanderUse" ),
	DEFINE_OUTPUT( m_OnRappelTouchdown,			"OnRappelTouchdown" ),
	DEFINE_OUTPUT( m_OnWake,					"OnWake" ),
	DEFINE_OUTPUT( m_OnSleep,					"OnSleep" ),
	DEFINE_OUTPUT( m_OnForcedInteractionStarted,	"OnForcedInteractionStarted" ),
	DEFINE_OUTPUT( m_OnForcedInteractionAborted,	"OnForcedInteractionAborted" ),
	DEFINE_OUTPUT( m_OnForcedInteractionFinished,	"OnForcedInteractionFinished" ),

	// Inputs
	DEFINE_INPUTFUNC( FIELD_STRING, "SetRelationship", InputSetRelationship ),
	DEFINE_INPUTFUNC( FIELD_STRING, "SetEnemyFilter", InputSetEnemyFilter ),
	DEFINE_INPUTFUNC( FIELD_INTEGER, "SetHealth", InputSetHealth ),
	DEFINE_INPUTFUNC( FIELD_VOID, "BeginRappel", InputBeginRappel ),
	DEFINE_INPUTFUNC( FIELD_STRING, "SetSquad", InputSetSquad ),
	DEFINE_INPUTFUNC( FIELD_VOID, "Wake", InputWake ),
	DEFINE_INPUTFUNC( FIELD_STRING, "ForgetEntity", InputForgetEntity ),
	DEFINE_INPUTFUNC( FIELD_FLOAT, "IgnoreDangerSounds", InputIgnoreDangerSounds ),
	DEFINE_INPUTFUNC( FIELD_VOID, "Break", InputBreak ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"StartScripting",	InputStartScripting ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"StopScripting",	InputStopScripting ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"GagEnable",	InputGagEnable ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"GagDisable",	InputGagDisable ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"InsideTransition",	InputInsideTransition ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"OutsideTransition",	InputOutsideTransition ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"ActivateSpeedModifier", InputActivateSpeedModifier ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"DisableSpeedModifier", InputDisableSpeedModifier ),
	DEFINE_INPUTFUNC( FIELD_INTEGER, "SetSpeedModRadius", InputSetSpeedModifierRadius ),
	DEFINE_INPUTFUNC( FIELD_INTEGER, "SetSpeedModSpeed", InputSetSpeedModifierSpeed ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"HolsterWeapon", InputHolsterWeapon ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"HolsterAndDestroyWeapon", InputHolsterAndDestroyWeapon ),
	DEFINE_INPUTFUNC( FIELD_VOID,	"UnholsterWeapon", InputUnholsterWeapon ),
	DEFINE_INPUTFUNC( FIELD_STRING,	"ForceInteractionWithNPC", InputForceInteractionWithNPC ),
	DEFINE_INPUTFUNC( FIELD_STRING, "UpdateEnemyMemory", InputUpdateEnemyMemory ),

	// Function pointers
	DEFINE_USEFUNC( NPCUse ),
	DEFINE_THINKFUNC( CallNPCThink ),
	DEFINE_THINKFUNC( CorpseFallThink ),
	DEFINE_THINKFUNC( NPCInitThink ),

END_DATADESC()

BEGIN_SIMPLE_DATADESC( AIScheduleState_t )
	DEFINE_FIELD( iCurTask,				FIELD_INTEGER ),
	DEFINE_FIELD( fTaskStatus,			FIELD_INTEGER ),
	DEFINE_FIELD( timeStarted,			FIELD_TIME ),
	DEFINE_FIELD( timeCurTaskStarted,	FIELD_TIME ),
	DEFINE_FIELD( taskFailureCode,		FIELD_INTEGER ),
	DEFINE_FIELD( iTaskInterrupt,		FIELD_INTEGER ),
	DEFINE_FIELD( bTaskRanAutomovement,	FIELD_BOOLEAN ),
	DEFINE_FIELD( bTaskUpdatedYaw,		FIELD_BOOLEAN ),
	DEFINE_FIELD( bScheduleWasInterrupted, FIELD_BOOLEAN ),
END_DATADESC()


IMPLEMENT_SERVERCLASS_ST( CAI_BaseNPC, DT_AI_BaseNPC )
	SendPropInt( SENDINFO( m_lifeState ), 3, SPROP_UNSIGNED ),
	SendPropBool( SENDINFO( m_bPerformAvoidance ) ),
	SendPropBool( SENDINFO( m_bIsMoving ) ),
	SendPropBool( SENDINFO( m_bFadeCorpse ) ),
	SendPropInt( SENDINFO( m_iDeathPose ), ANIMATION_SEQUENCE_BITS ),
	SendPropInt( SENDINFO( m_iDeathFrame ), 5 ),
	SendPropBool( SENDINFO( m_bSpeedModActive ) ),
	SendPropInt( SENDINFO( m_iSpeedModRadius ) ),
	SendPropInt( SENDINFO( m_iSpeedModSpeed ) ),
	SendPropBool( SENDINFO( m_bImportanRagdoll ) ),
	SendPropFloat( SENDINFO( m_flTimePingEffect ) ),
END_SEND_TABLE()

//-------------------------------------

BEGIN_SIMPLE_DATADESC( UnreachableEnt_t )

	DEFINE_FIELD( hUnreachableEnt,			FIELD_EHANDLE	),
	DEFINE_FIELD( fExpireTime,				FIELD_TIME		),
	DEFINE_FIELD( vLocationWhenUnreachable,	FIELD_POSITION_VECTOR	),

END_DATADESC()

//-------------------------------------

BEGIN_SIMPLE_DATADESC( ScriptedNPCInteraction_Phases_t )
DEFINE_FIELD( iszSequence,					FIELD_STRING	),
DEFINE_FIELD( iActivity,					FIELD_INTEGER	),
END_DATADESC()

//-------------------------------------

BEGIN_SIMPLE_DATADESC( ScriptedNPCInteraction_t )
	DEFINE_FIELD( iszInteractionName,			FIELD_STRING	),
	DEFINE_FIELD( iFlags,						FIELD_INTEGER	),
	DEFINE_FIELD( iTriggerMethod,				FIELD_INTEGER	),
	DEFINE_FIELD( iLoopBreakTriggerMethod,		FIELD_INTEGER	),
	DEFINE_FIELD( vecRelativeOrigin,			FIELD_VECTOR	),
	DEFINE_FIELD( angRelativeAngles,			FIELD_VECTOR	),
	DEFINE_FIELD( vecRelativeVelocity,			FIELD_VECTOR	),
	DEFINE_FIELD( flDelay,						FIELD_FLOAT		),
	DEFINE_FIELD( flDistSqr,					FIELD_FLOAT		),
	DEFINE_FIELD( iszMyWeapon,					FIELD_STRING	),
	DEFINE_FIELD( iszTheirWeapon,				FIELD_STRING	),
	DEFINE_EMBEDDED_ARRAY( sPhases, SNPCINT_NUM_PHASES ),
	DEFINE_FIELD( matDesiredLocalToWorld,		FIELD_VMATRIX	),
	DEFINE_FIELD( bValidOnCurrentEnemy,			FIELD_BOOLEAN	),
	DEFINE_FIELD( flNextAttemptTime,			FIELD_TIME		),
END_DATADESC()