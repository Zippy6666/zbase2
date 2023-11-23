$modelname zippy/Synth.mdl

$body studio "synth_reference.smd"
$cdmaterials	"models\synth"
$surfaceprop "Armorflesh"

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
	ACT_BIG_FLINCH 1
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
	ACT_TRANSITION 1
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
	$rotdamping 2.00
	$rootbone "bip02"

	$jointconstrain "bip02 spine1" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 spine1" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 spine1" z limit -15.00 15.00 0.00

	$jointconstrain "bip02 l upperarm" x limit -1.00 31.00 0.00
	$jointconstrain "bip02 l upperarm" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 l upperarm" z limit 0.00 0.00 0.00

	$jointconstrain "bip02 l forearm" x limit 0.00 0.00 0.00
	$jointconstrain "bip02 l forearm" y limit 0.00 0.00 0.00
	$jointconstrain "bip02 l forearm" z limit 0.00 21.00 0.00

	$jointconstrain "bip02 r upperarm" x limit -41.00 1.00 0.00
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
	$jointconstrain "bip02 r forearm" y limit -41.00 0.00 0.00
	$jointconstrain "bip02 r forearm" z limit 0.00 0.00 0.00

	$jointcollide "bip02 l upperarm" "bip02 l forearm"
	$jointcollide "bip02 r upperarm" "bip02 r forearm"
}
$sequence ragdoll 		"synth_reference.smd" 		FPS 30 		activity ACT_DIERAGDOLL 1

$attachment "muzzle" "Box05" -13.00 5.00 -0.00 rotate 0 180 180



