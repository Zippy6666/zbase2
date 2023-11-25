// Created by Crowbar 0.71

$modelname "zippy/gibs/mortarsynth_gib_05.mdl"

$bodygroup "body"
{
	studio "gib_rightclaw.smd"
}


$surfaceprop "alienflesh"

$contents "solid"

$illumposition -51.536 -0.321 61.035

$cdmaterials "models\mortarsynth\"

$cbox 0 0 0 0 0 0

$bbox -14.349 -1.864 -2.403 18.704 3.66 6.451

$definebone "Root Bone" "" 0 0 0 0 89.999982 89.999982 0 0 0 0 0 0


$sequence "idle01" {
	"mortarsynth_gib_05_anims\idle01.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 15
	loop
}

$collisionmodel "mortarsynth_gib_05_physics.smd"
{
	$mass 6
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
