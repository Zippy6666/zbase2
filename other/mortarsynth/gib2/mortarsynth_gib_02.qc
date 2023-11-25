// Created by Crowbar 0.71

$modelname "zippy/gibs/mortarsynth_gib_02.mdl"

$bodygroup "body"
{
	studio "gib_tail.smd"
}


$surfaceprop "alienflesh"

$contents "solid"

$illumposition -51.536 -0.321 61.035

$cdmaterials "models\mortarsynth\"

$cbox 0 0 0 0 0 0

$bbox -20.201 -24.453 -10.465 32.65 24.48 10.26

$definebone "Root Bone" "" 0 0 0 0 89.999982 89.999982 0 0 0 0 0 0


$sequence "idle01" {
	"mortarsynth_gib_02_anims\idle01.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 15
	loop
}

$collisionmodel "mortarsynth_gib_02_physics.smd"
{
	$mass 7
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
