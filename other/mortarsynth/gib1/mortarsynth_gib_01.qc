// Created by Crowbar 0.71

$modelname "zippy/gibs/mortarsynth_gib_01.mdl"

$bodygroup "body"
{
	studio "gib_body.smd"
}


$surfaceprop "alienflesh"

$contents "solid"

$illumposition -51.536 -0.321 61.035

$cdmaterials "models\mortarsynth\"

$cbox 0 0 0 0 0 0

$bbox -24.344 -27.732 -26.702 22.799 27.732 14.175

$controller 0 "Root Bone" ZR 0 360

$definebone "Root Bone" "" 0 0 0 0 89.999982 89.999982 0 0 0 0 0 0


$sequence "idle01" {
	"mortarsynth_gib_01_anims\idle01.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 15
	loop
}

$collisionmodel "mortarsynth_gib_01_physics.smd"
{
	$mass 50
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
