// Created by Crowbar 0.71

$modelname "zippy/gibs/mortarsynth_gib_04.mdl"

$bodygroup "body"
{
	studio "gib_leftclaw.smd"
}


$surfaceprop "alienflesh"

$contents "solid"

$illumposition -51.536 -0.321 61.035

$cdmaterials "models\mortarsynth\"

$cbox 0 0 0 0 0 0

$bbox -18.315 -3.769 -1.747 14.738 1.749 7.113

$definebone "Root Bone" "" 0 0 0 0 89.999982 89.999982 0 0 0 0 0 0


$sequence "idle01" {
	"mortarsynth_gib_04_anims\idle01.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 15
	loop
}

$collisionmodel "mortarsynth_gib_04_physics.smd"
{
	$mass 25
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
