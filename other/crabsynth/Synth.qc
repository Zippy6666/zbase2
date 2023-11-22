$modelname zippy/Synth.mdl

$body studio "synth_reference.smd"
$cdmaterials	"models\synth"
$surfaceprop "Strider"

$sequence idle01 "idle01" {
	ACT_IDLE 1
	loop
	fadein 0.2
	fadeout 0.2
	node "idle"
}

$sequence idleshake01 "idleshake01" {
	ACT_IDLE 1
	loop
	fadein 0.2
	fadeout 0.2
	node "idle"
}

$sequence alert01 "alert01" {
	ACT_IDLE_ANGRY 1
	loop
	fadein 0.2
	fadeout 0.2
	node "idle"
}

$sequence attack1 "attack01" {
	fadein 0.2
	fadeout 0.2
	{ event AE_NPC_SWISHSOUND 27 "" }
	node "idle"
}

$sequence attack2 "attack_ft01" {
	fadein 0.2
	fadeout 0.2
	{ event AE_NPC_SWISHSOUND 26 "" }
	node "idle"
}

$sequence attack3 "runbash" {
	fadein 0.2
	fadeout 0.2
	fps 20
	ACT_MELEE_ATTACK2 1
	walkframe 25 LX LY
	{ event AE_NPC_SWISHSOUND 15 "" }
	node "idle"
}

$sequence attack4 "run_headthrow" {
	fadein 0.2
	fadeout 0.2
	fps 20
	ACT_MELEE_ATTACK2 1
	walkframe 25 LX LY
	{ event AE_NPC_SWISHSOUND 15 "" }
	node "idle"
}

$sequence bodythrow "bodythrow01" {
	fadein 0.2
	fadeout 0.2
	fps 20
	walkframe 115 LX LY
	node "idle"
}

$sequence run01 "run01" {
	fps 25
	loop 
	ACT_RUN 1
	walkframe 18 LX LY
	fadein 0.2
	fadeout 0.2
	node "idle"
}

$sequence walk01 "walk01_gunup" {
	fps 30
	loop 
	ACT_WALK 1
	walkframe 60 LX LY
	fadein 0.2
	fadeout 0.2
	node "idle"
}

$sequence charge_start "charge01" {
	fps 30
	fadein 0.2
	fadeout 0.2
	walkframe 98 LX LY
	frame 0 36
	transition idle charge
}

$sequence charge_loop "chargeloop" {
	fps 30
	fadein 0.2
	fadeout 0.2
	walkframe 15 LX LY
	loop
	ACT_SPECIAL_ATTACK1 1
	node "charge"
}

$sequence charge_end "chargeend" {
	fps 25
	fadein 0.2
	fadeout 0.2
	transition charge idle
}

$sequence range_start "fire01" {
	fps 30
	fadein 0.2
	fadeout 0.2
	frame 0 70
	transition idle range
}

$sequence range_loop "fire01" {
	fps 30
	fadein 0.2
	fadeout 0.2
	loop
	ACT_RANGE_ATTACK1 1
	frame 70 78
	node "range"
	{ event 2042  0 "" }
	{ event 2042  1 "" }
	{ event 2042  2 "" }
	{ event 2042  3 "" }
	{ event 2042  4 "" }
	{ event 2042  5 "" }
	{ event 2042  6 "" }
	{ event 2042  7 "" }
	{ event 2042  8 "" }
}

$sequence range_end "fire01" {
	fps 30
	fadein 0.2
	fadeout 0.2
	transition range idle
	frame 78 141
}

$collisionjoints crabrag.smd {

	$mass 5000.0
	$inertia 1.00
	$damping 1.00
	$rotdamping 1.00
	$rootbone "bip02"

	$jointconstrain "bip02 spine1" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 spine1" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 spine1" z limit -15.00 15.00 0.00

	$jointconstrain "bip02 l upperarm" x limit -48.00 41.00 0.00
	$jointconstrain "bip02 l upperarm" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 l upperarm" z limit 0.00 0.00 0.00

	$jointconstrain "bip02 l forearm" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 l forearm" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 l forearm" z limit 0.00 0.00 0.00

	$jointconstrain "bip02 r upperarm" x limit -61.00 46.00 0.00
	$jointconstrain "bip02 r upperarm" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 r upperarm" z limit 0.00 0.00 0.00

	$jointconstrain "bip02 r thigh" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 r thigh" y limit 0.00 30.00 0.00
	$jointconstrain "bip02 r thigh" z limit -21.00 41.00 0.00

	$jointconstrain "bip02 r calf" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 r calf" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 r calf" z limit 0.00 15.00 0.00

	$jointconstrain "bip02 r horselink" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 r horselink" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 r horselink" z limit 0.00 0.00 0.00

	$jointconstrain "bip02 l thigh" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 l thigh" y limit -30.00 0.00 0.00
	$jointconstrain "bip02 l thigh" z limit -39.00 28.00 0.00

	$jointconstrain "bip02 l calf" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 l calf" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 l calf" z limit 0.00 15.00 0.00

	$jointconstrain "bip02 l horselink" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 l horselink" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 l horselink" z limit 0.00 0.00 0.00

	$jointconstrain "bip02 r forearm" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 r forearm" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 r forearm" z limit 0.00 0.00 0.00
}
$sequence ragdoll 		"synth_reference.smd" 		FPS 30 		activity ACT_DIERAGDOLL 1


// $animblocksize 32

// $sequence alert01 "alert01" fps 30 ACT_STAND 1
// $sequence attack1 "attack01" fps 30 { event AE_NPC_SWISHSOUND 27 "" }
// $sequence attack2 "attack_ft01" fps 30 { event AE_NPC_SWISHSOUND 26 "" }
// $sequence fire01 "fire01" fps 30 ACT_RANGE_ATTACK1 1
// $sequence run_headthrow "run_headthrow" fps 30
// //$sequence runtrot "trot01" fps 30 loop

// $sequence runbash "runbash" fps 30  ACT_CHARGE_HITLEFT 1
// $sequence runthrow "run_headthrow" fps 30  ACT_CHARGE_HITRIGHT 1
// $sequence chargelswipe "chargeltswipe01" fps 30  ACT_CHARGE_HITLEFT 1
// $sequence chargerswipe "chargeltswipe01" fps 30  frame 42 68 ACT_CHARGE_HITRIGHT 1


// $sequence walk01_gunup "walk01_gunup" fps 30 loop  
// $sequence walkback01 "walkback01" fps 30 loop  ACT_STEP_BACK 1
// $sequence diesimple "alert01" fps 120 ACT_DIESIMPLE 1





// $sequence idleshake01 "idleshake01" {
// 	fps 30 ACT_IDLE 1 node "idle"



// 	fadein 0.2
// 	fadeout 0.2

// }



// // $sequence ltturn01 "ltturn01" {
// // 	fps 35 ACT_TURN_LEFT 1 fadein 0.2 fadeout 0.2


// // }

// // $sequence rtturn01 "rtturn01" {
// // 	fps 35 ACT_TURN_RIGHT 1 fadein 0.2 fadeout 0.2


// // }

// // Epic 9way walkin //
// $animation walk_S	"walkbackcyc01" fps 30  startloop 19 alignto "idle01" walkframe 44 LX LY
// $animation walk_SE	"walkback45rt01" fps 30  LY startloop 20 rotate 6.1 alignto "idle01" walkframe 44 LX LY
// $animation walk_E	"walkleft01" fps 30 LY alignto "idle01" walkframe 50 LX LY
// $animation walk_NE	"walk45ftrt01" fps 30  LY rotate -2.09 alignto "idle01" walkframe 60 LX LY
// $animation walk_N	"walk01_gunup" fps 30  alignto "idle01" walkframe 60 LX LY
// $animation walk_NW	"walk45ftlt01" fps 30  LY rotate 3.05 alignto "idle01" walkframe 60 LX LY
// $animation walk_W	"walkright01" fps 30 LY startloop 26 alignto "idle01" walkframe 50 LX LY
// $animation walk_SW	"walkback45lt01" fps 30  LY startloop 19 rotate -7.82 alignto "idle01" walkframe 44 LX LY
// $poseparameter "move_yaw" -180 180 loop 360
// $sequence walkall {
// 	walk_s walk_se walk_e walk_ne walk_n walk_nw walk_w walk_sw walk_s
// 	blendwidth 9
// 	blend move_yaw -180 180
// 	activity ACT_WALK 1
// 	fadein 0.2
// 	fadeout 0.2


// }

// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// $sequence chargeready "charge01" {
// 	fps 30 frame 0 16 
// 	ACT_CHARGE_START 1 
// 	alignto "idle01" 
// 	transition "idle" "precharge"
// }

// $sequence chargestart "charge01" {
// 	fps 30 frame 16 30  
// 	ACT_CHARGE_START_MOVE 1 
// 	alignto "idle01" 
// 	transition "precharge" "charge"
// 	}

// $sequence chargeloop "charge01" {
// 	fps 30 loop frame 30 42  
// 	// ACT_CHARGE_LOOP 1 
// 	alignto "idle01"
// 	node "charge"
// 	}

// $sequence chargestop "charge01" {
// 	fps 30 frame 54 67  
// 	ACT_CHARGE_MOVE_END 1 
// 	alignto "idle01"
// 	transition "charge" "postcharge"
// 	}

// $sequence chargeend "charge01" {
// 	fps 30 frame 67 93 
// 	ACT_CHARGE_END 1 
// 	alignto "idle01"
// 	transition "postcharge" "idle"
// 	}


// $sequence runtrot "trot01" fps 60 loop  ACT_CHARGE_LOOP 1
// $sequence chargefswipe "chargeltswipe01" fps 30  ACT_CHARGE_END 1

// $sequence bodythrow "bodythrow01" fps 30 ACT_BODY_THROW 1



