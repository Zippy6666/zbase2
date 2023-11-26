// Created by Crowbar 0.71

$modelname "zippy/MortarSynth.mdl"

$bodygroup "Body"
{
	studio "MortarSynth_Reference.smd"
}


$surfaceprop "alienflesh"

$contents "solid"

$illumposition -0.003 -11.44 -8.9

$cdmaterials "models\mortarsynth\"


$attachment "rightarm" "RArm Tip Bone" 0 0 0 rotate 0 0 0
$attachment "leftarm" "LArm Tip Bone" 0 0 0 rotate 0 0 0
$attachment "tentacle" "LTentacle Curve" 0 0 0 rotate 0 0 0
$attachment "catapult" "LShoulder Bone Base" 27.00 12.00 -18.00 rotate -0 135 -180


$cbox 0 0 0 0 0 0

$bbox -43.397 -27.996 -32.887 66.278 27.99 15.087

$controller 0 "Root Bone" ZR 0 360

$definebone "Root Bone" "" 0 0 0 0 89.999982 89.999982 0 0 0 0 0 0
$definebone "LTentacle Bone Base" "Root Bone" -23.56369 -1.016819 1.247537 -89.999982 -89.999982 0 0 0 0 0 0 0
$definebone "Text01" "LTentacle Bone Base" -0.224368 -1.936674 -0.034306 0 0 0 0 0 0 0 0 0
$definebone "Text02" "Text01" 0 -6.308491 1.33304 3.675008 89.999982 0 0 0 0 0 0 0
$definebone "Text03" "Text02" -5.226755 0 -0.48863 -9.973534 0 0 0 0 0 0 0 0
$definebone "Text05" "Text03" -4.492261 0 -0.217024 -5.070963 0 0 0 0 0 0 0 0
$definebone "Text06" "Text05" -4.097043 0 -0.084409 -2.004665 0 0 0 0 0 0 0 0
$definebone "Text07" "Text06" -3.908822 0 -0.004274 0.232907 0 0 0 0 0 0 0 0
$definebone "Text08" "Text07" -3.46909 0 0.053962 2.099203 0 0 0 0 0 0 0 0
$definebone "Text09" "Text08" -3.226493 0 0.098008 3.803638 0 0 0 0 0 0 0 0
$definebone "Text10" "Text09" -2.986445 0 0.132293 5.394512 0 0 0 0 0 0 0 0
$definebone "Text11" "Text10" -2.730964 0 0.152568 6.673354 0 0 0 0 0 0 0 0
$definebone "Text12" "Text11" -2.712409 0 0.188132 8.155081 0 0 0 0 0 0 0 0
$definebone "LTentacle Curve" "LTentacle Bone Base" -0.224369 -37.738541 -0.197675 0.088446 90.000016 90.000016 0 0 0 0 0 0
$definebone "RTentacle Bone Base" "Root Bone" -23.56369 -1.016819 -0.975783 -89.999982 -89.999982 0 0 0 0 0 0 0
$definebone "Text04" "RTentacle Bone Base" -0.224368 -1.995568 -0.034538 0 0 0 0 0 0 0 0 0
$definebone "Text14" "Text04" -0.020774 -6.073229 1.34772 4.111659 89.665842 -0.01461 0 0 0 0 0 0
$definebone "Text15" "Text14" -4.960851 -0.022336 -0.481246 -10.41047 0.286078 -0.002922 0 0 0 0 0 0
$definebone "Text16" "Text15" -4.264716 -0.005519 -0.214685 -5.316704 0.209302 0.002235 0 0 0 0 0 0
$definebone "Text17" "Text16" -3.923115 0.003231 -0.080392 -2.040473 0.170169 0.010829 0 0 0 0 0 0
$definebone "Text18" "Text17" -3.796063 0.009086 0.001879 0.317649 0.150172 0.020455 0 0 0 0 0 0
$definebone "Text19" "Text18" -3.432445 0.012806 0.060651 2.184862 0.126853 0.028075 0 0 0 0 0 0
$definebone "Text20" "Text19" -3.265689 0.015572 0.104125 3.754367 0.114878 0.036154 0 0 0 0 0 0
$definebone "Text21" "Text20" -3.104328 0.01759 0.136294 5.06094 0.104336 0.043144 0 0 0 0 0 0
$definebone "Text22" "Text21" -2.921209 0.018872 0.153029 5.936935 0.092934 0.047498 0 0 0 0 0 0
$definebone "Text23" "Text22" -2.984406 0.021243 0.183955 6.896009 0.088923 0.053514 0 0 0 0 0 0
$definebone "LArm Bone Base" "Root Bone" -5.438781 -16.364336 21.465328 0 0 0 0 0 0 0 0 0
$definebone "LArm Tip Bone" "LArm Bone Base" -45.148304 -13.454095 1.305043 0 0 0 0 0 0 0 0 0
$definebone "RArm Bone Base" "Root Bone" -5.438781 -16.364336 -21.635715 0 0 0 0 0 0 0 0 0
$definebone "RArm Tip Bone" "RArm Bone Base" -45.148304 -13.454098 -1.551583 0 0 0 0 0 0 0 0 0
$definebone "Propultion Bone Base" "Root Bone" 0.549018 -9.110427 0 0 0 0 0 0 0 0 0 0
$definebone "LShoulder Bone Base" "Root Bone" -5.438782 -4.002079 18.188931 0 0 0 0 0 0 0 0 0
$definebone "Eye Bone Base" "Root Bone" -10.367574 4.499585 0.052506 0 0 0 0 0 0 0 0 0
$definebone "RGrabber Bone Base" "Root Bone" -4.009332 -8.685399 -9.091248 1.034304 4.356771 -4.78987 0 0 0 0 0 0
$definebone "RGrabber Elbow Bone" "RGrabber Bone Base" -6.542341 9.75334 2.728961 2.361274 -21.237025 0.228209 0 0 0 0 0 0
$definebone "RGrabber Hand Bone" "RGrabber Elbow Bone" 0.325406 -7.209937 -3.585417 0 -0.000002 0 0 0 0 0 0 0
$definebone "RGrabber Finger1 Bone" "RGrabber Hand Bone" 0 -0.964557 0.641092 -5.036185 -0.611692 17.407091 0 0 0 0 0 0
$definebone "RGrabber Finger2 Bone" "RGrabber Hand Bone" 0 -0.257924 -0.959465 3.505471 -0.482662 -12.109634 0 0 0 0 0 0
$definebone "LGrabber Bone Base" "Root Bone" -4.009333 -8.685399 8.963658 0.582125 4.291569 11.64233 0 0 0 0 0 0
$definebone "LGrabber Elbow Bone" "LGrabber Bone Base" -6.542339 9.753339 -2.768892 2.200445 -21.685021 -1.310526 0 0 0 0 0 0
$definebone "LGrabber Hand Bone" "LGrabber Elbow Bone" 0.325405 -7.209935 3.595273 0.000001 -0.000001 0 0 0 0 0 0 0
$definebone "LGrabber Finger2 Bone" "LGrabber Hand Bone" 0.000001 -0.257924 0.984738 0.719292 0.417398 10.068417 0 0 0 0 0 0
$definebone "LGrabber Finger1 Bone" "LGrabber Hand Bone" 0.000001 -0.964556 -0.679071 -1.526301 -0.422672 -19.229896 0 0 0 0 0 0


// The 32 below is a guess until further is known about the format.
$animblocksize 32

$bonesaveframe "Root Bone" position rotation
$bonesaveframe "LTentacle Bone Base" rotation
$bonesaveframe "Text01" rotation
$bonesaveframe "Text02" position rotation
$bonesaveframe "Text03" rotation
$bonesaveframe "Text05" rotation
$bonesaveframe "Text06" rotation
$bonesaveframe "Text07" rotation
$bonesaveframe "Text08" position rotation
$bonesaveframe "Text09" position rotation
$bonesaveframe "Text10" position rotation
$bonesaveframe "Text11" rotation
$bonesaveframe "Text12" rotation
$bonesaveframe "LTentacle Curve" rotation
$bonesaveframe "RTentacle Bone Base" rotation
$bonesaveframe "Text04" rotation
$bonesaveframe "Text14" position rotation
$bonesaveframe "Text15" rotation
$bonesaveframe "Text16" rotation
$bonesaveframe "Text17" rotation
$bonesaveframe "Text18" rotation
$bonesaveframe "Text19" rotation
$bonesaveframe "Text20" rotation
$bonesaveframe "Text21" position rotation
$bonesaveframe "Text22" position rotation
$bonesaveframe "Text23" rotation
$bonesaveframe "LArm Bone Base" rotation
$bonesaveframe "LArm Tip Bone" rotation
$bonesaveframe "RArm Bone Base" rotation
$bonesaveframe "RArm Tip Bone" rotation
$bonesaveframe "Propultion Bone Base" rotation
$bonesaveframe "LShoulder Bone Base" rotation
$bonesaveframe "Eye Bone Base" rotation
$bonesaveframe "RGrabber Bone Base" rotation
$bonesaveframe "RGrabber Elbow Bone" rotation
$bonesaveframe "RGrabber Hand Bone" rotation
$bonesaveframe "RGrabber Finger1 Bone" rotation
$bonesaveframe "RGrabber Finger2 Bone" rotation
$bonesaveframe "LGrabber Bone Base" rotation
$bonesaveframe "LGrabber Elbow Bone" rotation
$bonesaveframe "LGrabber Hand Bone" rotation
$bonesaveframe "LGrabber Finger2 Bone" rotation
$bonesaveframe "LGrabber Finger1 Bone" rotation

$sequence "idle" {
	"mortarsynth_anims\idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "walk" {
	"mortarsynth_anims\idle.smd"
	activity "ACT_WALK" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "run" {
	"mortarsynth_anims\idle.smd"
	activity "ACT_RUN" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_Forward" {
	"mortarsynth_anims\Mortar_Forward.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_Back" {
	"mortarsynth_anims\Mortar_Back.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_Flinch_Left" {
	"mortarsynth_anims\Mortar_Flinch_Left.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_Flinch_Right" {
	"mortarsynth_anims\Mortar_Flinch_Right.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_Flinch_Front" {
	"mortarsynth_anims\Mortar_Flinch_Front.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_Flinch_Back" {
	"mortarsynth_anims\Mortar_Flinch_Back.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_BigFlinch_Left" {
	"mortarsynth_anims\Mortar_BigFlinch_Left.smd"
	activity "ACT_MSYNTH_FLINCH_LEFT" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_BigFlinch_Right" {
	"mortarsynth_anims\Mortar_BigFlinch_Right.smd"
	activity "ACT_MSYNTH_FLINCH_RIGHT" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_BigFlinch_Front" {
	"mortarsynth_anims\Mortar_BigFlinch_Front.smd"
	activity "ACT_MSYNTH_FLINCH_FRONT" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_BigFlinch_Back" {
	"mortarsynth_anims\Mortar_BigFlinch_Back.smd"
	activity "ACT_MSYNTH_FLINCH_BACK" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_Shoot" {
	"mortarsynth_anims\Mortar_Shoot.smd"
	activity "ACT_RANGE_ATTACK1" 1
	{ event 1 8 "" }
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$sequence "Mortar_Shoot2Transition" {
	"mortarsynth_anims\Mortar_Forward.smd"
	fadein 0.2
	fadeout 0.2
	fps 45
	transition idle range2
}

$sequence "Mortar_Shoot2" {
	"mortarsynth_anims\Mortar_Flinch_Front.smd"
	activity "ACT_RANGE_ATTACK2" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	node range2
}

$sequence "Mortar_Corpse" {
	"mortarsynth_anims\Mortar_Corpse.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	node idle
}

$collisionmodel "mortphy.smd"
{
	$mass 70.0
}
