// Created by Crowbar 0.71

$modelname "zippy/gibs/mortarsynth_gib_03.mdl"

$bodygroup "body"
{
	studio "gib_exhaust.smd"
}


$surfaceprop "alienflesh"

$contents "solid"

$illumposition -51.536 -0.321 61.035

$cdmaterials "models\mortarsynth\"

$cbox 0 0 0 0 0 0

$bbox -4.594 -10.446 -5.177 5.792 10.554 4.595

$definebone "Root Bone" "" 0 0 0 0 89.999982 89.999982 0 0 0 0 0 0


$sequence "idle01" {
	"mortarsynth_gib_03_anims\idle01.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 15
	loop
}

$collisionmodel "mortarsynth_gib_03_physics.smd"
{
	$mass 5
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
