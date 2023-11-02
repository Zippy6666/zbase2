$modelname zippy/Synth.mdl

// whole body
$body studio "synth_reference.smd"
$cdmaterials	"models\zippy\synth"
$surfaceprop "Strider"

$animblocksize 32

$sequence alert01 "alert01" fps 30 ACT_STAND 1
$sequence attack1 "attack01" fps 30 ACT_MELEE_ATTACK1 1
$sequence attack2 "attack_ft01" fps 30 ACT_MELEE_ATTACK1 1
$sequence fire01 "fire01" fps 30 ACT_RANGE_ATTACK1 1
$sequence run_headthrow "run_headthrow" fps 30
//$sequence runtrot "trot01" fps 30 loop

$sequence runbash "runbash" fps 30  ACT_CHARGE_HITLEFT 1
$sequence runthrow "run_headthrow" fps 30  ACT_CHARGE_HITRIGHT 1
$sequence chargelswipe "chargeltswipe01" fps 30  ACT_CHARGE_HITLEFT 1
$sequence chargerswipe "chargeltswipe01" fps 30  frame 42 68 ACT_CHARGE_HITRIGHT 1

$sequence walk01 "walk01" fps 30 loop   LX LY
$sequence walk01_gunup "walk01_gunup" fps 30 loop  
$sequence walkback01 "walkback01" fps 30 loop  ACT_STEP_BACK 1
$sequence diesimple "alert01" fps 120 ACT_DIESIMPLE 1

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// IK shit //
// $ikchain "lfoot" "Bip02 L Foot"
// $ikchain "rfoot" "Bip02 R Foot"
// $ikchain "lhand" "Bip02 L Forearm"
// $ikchain "rhand" "Bip02 R Forearm"

$sequence idle01 "idle01" {

	fps 30 loop ACT_IDLE 1 node "idle"

	// ikrule lfoot footstep range 0 0 0 0 contact 0
	// ikrule rfoot footstep range 0 0 0 0 contact 0
	// ikrule lhand footstep range 0 0 0 0 contact 0
	// ikrule rhand footstep range 0 0 0 0 contact 0

	fadein 0.2
	fadeout 0.2

}
$sequence idleshake01 "idleshake01" {
	fps 30 ACT_IDLE 1 node "idle"

	// ikrule lfoot footstep range 0 0 0 0 contact 0
	// ikrule rfoot footstep range 0 0 0 0 contact 0
	// ikrule lhand footstep range 0 0 0 0 contact 0
	// ikrule rhand footstep range 0 0 0 0 contact 0

	fadein 0.2
	fadeout 0.2

}

$sequence run01 "run01" {
	fps 25 loop  ACT_RUN 4
	alignto "idle01"
	node "charge"
	walkframe 18 LX

	// ikrule lfoot footstep range 0 0 0 0 contact 0
	// ikrule rfoot footstep range 0 0 0 0 contact 0
	// ikrule lhand footstep range 0 0 0 0 contact 0
	// ikrule rhand footstep range 0 0 0 0 contact 0

	fadein 0.2
	fadeout 0.2
}

$sequence ltturn01 "ltturn01" {
	fps 35 ACT_TURN_LEFT 1 fadein 0.2 fadeout 0.2

	// ikrule lfoot footstep range 0 0 0 0 contact 0
	// ikrule rfoot footstep range 0 0 0 0 contact 0
	// ikrule lhand footstep range 0 0 0 0 contact 0
	// ikrule rhand footstep range 0 0 0 0 contact 0
}

$sequence rtturn01 "rtturn01" {
	fps 35 ACT_TURN_RIGHT 1 fadein 0.2 fadeout 0.2

	// ikrule lfoot footstep range 0 0 0 0 contact 0
	// ikrule rfoot footstep range 0 0 0 0 contact 0
	// ikrule lhand footstep range 0 0 0 0 contact 0
	// ikrule rhand footstep range 0 0 0 0 contact 0
}

// Epic 9way walkin //
$animation walk_S	"walkbackcyc01" fps 30  startloop 19 alignto "idle01" walkframe 44 LX LY
$animation walk_SE	"walkback45rt01" fps 30  LY startloop 20 rotate 6.1 alignto "idle01" walkframe 44 LX LY
$animation walk_E	"walkleft01" fps 30 LY alignto "idle01" walkframe 50 LX LY
$animation walk_NE	"walk45ftrt01" fps 30  LY rotate -2.09 alignto "idle01" walkframe 60 LX LY
$animation walk_N	"walk01_gunup" fps 30  alignto "idle01" walkframe 60 LX LY
$animation walk_NW	"walk45ftlt01" fps 30  LY rotate 3.05 alignto "idle01" walkframe 60 LX LY
$animation walk_W	"walkright01" fps 30 LY startloop 26 alignto "idle01" walkframe 50 LX LY
$animation walk_SW	"walkback45lt01" fps 30  LY startloop 19 rotate -7.82 alignto "idle01" walkframe 44 LX LY
$poseparameter "move_yaw" -180 180 loop 360
$sequence walkall {
	walk_s walk_se walk_e walk_ne walk_n walk_nw walk_w walk_sw walk_s
	blendwidth 9
	blend move_yaw -180 180
	activity ACT_WALK 1
	fadein 0.2
	fadeout 0.2

	// ikrule lfoot footstep range 0 0 0 0 contact 0
	// ikrule rfoot footstep range 0 0 0 0 contact 0
	// ikrule lhand footstep range 0 0 0 0 contact 0
	// ikrule rhand footstep range 0 0 0 0 contact 0
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

$sequence chargeready "charge01" {
	fps 30 frame 0 16 
	ACT_CHARGE_START 1 
	alignto "idle01" 
	transition "idle" "precharge"
}

$sequence chargestart "charge01" {
	fps 30 frame 16 30  
	ACT_CHARGE_START_MOVE 1 
	alignto "idle01" 
	transition "precharge" "charge"
	}

$sequence chargeloop "charge01" {
	fps 30 loop frame 30 42  
	// ACT_CHARGE_LOOP 1 
	alignto "idle01"
	node "charge"
	}

$sequence chargestop "charge01" {
	fps 30 frame 54 67  
	ACT_CHARGE_MOVE_END 1 
	alignto "idle01"
	transition "charge" "postcharge"
	}

$sequence chargeend "charge01" {
	fps 30 frame 67 93 
	ACT_CHARGE_END 1 
	alignto "idle01"
	transition "postcharge" "idle"
	}


$sequence runtrot "trot01" fps 60 loop  ACT_CHARGE_LOOP 1
$sequence chargefswipe "chargeltswipe01" fps 30  ACT_CHARGE_END 1

$sequence bodythrow "bodythrow01" fps 30 ACT_BODY_THROW 1



