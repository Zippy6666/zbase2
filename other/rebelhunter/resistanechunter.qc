// Created by Crowbar 0.71

$modelname "zippy/ResistanceHunter.mdl"

$model "hunter" "Hunter_Reference.smd" {

	flexfile "hunter_01.vta" 
	{
		defaultflex frame 0
		flex "lower_lid" frame 1
		flex "lower_lid" frame 2
		flex "lower_lid" frame 3
		flex "lower_lid" frame 4
		flex "upper_lid" frame 5
		flex "upper_lid" frame 6
		flex "upper_lid" frame 7
		flex "upper_lid" frame 8
	}

	flexcontroller eyelid range 0 1 "upper_lid_closer"
	flexcontroller eyelid range 0 1 "lower_lid_closer"

	%lower_lid = lower_lid_closer
	%upper_lid = upper_lid_closer
}

$lod 15
{
	replacemodel "Hunter_Reference.smd" "Hunter_Reference_lod1.smd"
	replacebone "MiniStrider.r_toe_bone" "MiniStrider.r_foot_bone"
	replacebone "MiniStrider.bck_toe_bone" "MiniStrider.bck_foot_bone"
	facial
}
$lod 30
{
	replacemodel "Hunter_Reference.smd" "Hunter_Reference_lod2.smd"
	replacebone "MiniStrider.r_toe_bone" "MiniStrider.r_foot_bone"
	replacebone "MiniStrider.bck_toe_bone" "MiniStrider.bck_foot_bone"
	facial
}
$lod 45
{
	replacemodel "Hunter_Reference.smd" "Hunter_Reference_lod3.smd"
	replacebone "MiniStrider.r_toe_bone" "MiniStrider.r_foot_bone"
	replacebone "MiniStrider.bck_toe_bone" "MiniStrider.bck_foot_bone"
	replacebone "MiniStrider.r_antenna2" "MiniStrider.r_antenna1"
	replacebone "MiniStrider.antennaSpike1" "MiniStrider.antennaRaise"
	replacebone "MiniStrider.antennaSpike2" "MiniStrider.antennaRaise"
	replacebone "MiniStrider.l_antenna2" "MiniStrider.l_antenna1"
	facial
}
$lod 60
{
	replacemodel "Hunter_Reference.smd" "Hunter_Reference_lod4.smd"
	replacebone "MiniStrider.low_eye_bone" "MiniStrider.low_stalk_bone"
	replacebone "MiniStrider.bottomEyeClose" "MiniStrider.low_eye_bone"
	replacebone "MiniStrider.top_eye_bone" "MiniStrider.top_stalk_bone"
	replacebone "MiniStrider.topEyeClose" "MiniStrider.top_eye_bone"
	replacebone "MiniStrider.r_toe_bone" "MiniStrider.r_foot_bone"
	replacebone "MiniStrider.bck_toe_bone" "MiniStrider.bck_foot_bone"
	replacebone "MiniStrider.l_claw" "MiniStrider.l_toe"
	replacebone "MiniStrider.bck_claw" "MiniStrider.bck_toe"
	replacebone "MiniStrider.r_claw" "MiniStrider.r_toe"
	replacebone "MiniStrider.r_antenna2" "MiniStrider.r_antenna1"
	replacebone "MiniStrider.antennaSpike1" "MiniStrider.antennaRaise"
	replacebone "MiniStrider.antennaSpike2" "MiniStrider.antennaRaise"
	replacebone "MiniStrider.l_antenna2" "MiniStrider.l_antenna1"
	facial
}
$lod 100
{
	replacemodel "Hunter_Reference.smd" "Hunter_Reference_lod5.smd"
	replacebone "MiniStrider.bottomEyeClose" "MiniStrider.low_eye_bone"
	replacebone "MiniStrider.topEyeClose" "MiniStrider.top_eye_bone"
	replacebone "MiniStrider.r_claw2" "MiniStrider.r_claw1"
	replacebone "MiniStrider.r_toe" "MiniStrider.r_foot_bone"
	replacebone "MiniStrider.l_antenna1" "MiniStrider.body_joint"
	replacebone "MiniStrider.antennaRaise" "MiniStrider.antennaBase"
	replacebone "MiniStrider.bck_toe" "MiniStrider.bck_foot_bone"
	replacebone "MiniStrider.r_toe_bone" "MiniStrider.r_foot_bone"
	replacebone "MiniStrider.l_claw2" "MiniStrider.l_claw1"
	replacebone "MiniStrider.l_claw3" "MiniStrider.l_claw2"
	replacebone "MiniStrider.l_claw4" "MiniStrider.l_claw3"
	replacebone "MiniStrider.l_toe" "MiniStrider.l_foot_bone"
	replacebone "MiniStrider.r_antenna1" "MiniStrider.body_joint"
	replacebone "MiniStrider.r_claw5" "MiniStrider.r_claw2"
	replacebone "MiniStrider.r_claw4" "MiniStrider.r_claw5"
	replacebone "MiniStrider.bck_toe_bone" "MiniStrider.bck_foot_bone"
	replacebone "MiniStrider.l_claw" "MiniStrider.l_toe"
	replacebone "MiniStrider.bck_claw" "MiniStrider.bck_toe"
	replacebone "MiniStrider.r_claw" "MiniStrider.r_toe"
	replacebone "MiniStrider.r_antenna2" "MiniStrider.r_antenna1"
	replacebone "MiniStrider.antennaSpike1" "MiniStrider.antennaRaise"
	replacebone "MiniStrider.antennaSpike2" "MiniStrider.antennaRaise"
	replacebone "MiniStrider.l_antenna2" "MiniStrider.l_antenna1"
	facial
}
$shadowlod
{
	replacemodel "Hunter_Reference.smd" "Hunter_Reference_lod6.smd"
	replacebone "MiniStrider.bottomEyeClose" "MiniStrider.low_eye_bone"
	replacebone "MiniStrider.topEyeClose" "MiniStrider.top_eye_bone"
	replacebone "MiniStrider.r_claw2" "MiniStrider.r_claw1"
	replacebone "MiniStrider.r_toe" "MiniStrider.r_foot_bone"
	replacebone "MiniStrider.l_antenna1" "MiniStrider.body_joint"
	replacebone "MiniStrider.antennaRaise" "MiniStrider.antennaBase"
	replacebone "MiniStrider.bck_toe" "MiniStrider.bck_foot_bone"
	replacebone "MiniStrider.r_toe_bone" "MiniStrider.r_foot_bone"
	replacebone "MiniStrider.l_claw2" "MiniStrider.l_claw1"
	replacebone "MiniStrider.l_claw3" "MiniStrider.l_claw2"
	replacebone "MiniStrider.l_claw4" "MiniStrider.l_claw3"
	replacebone "MiniStrider.l_toe" "MiniStrider.l_foot_bone"
	replacebone "MiniStrider.r_antenna1" "MiniStrider.body_joint"
	replacebone "MiniStrider.r_claw5" "MiniStrider.r_claw2"
	replacebone "MiniStrider.r_claw4" "MiniStrider.r_claw5"
	replacebone "MiniStrider.bck_toe_bone" "MiniStrider.bck_foot_bone"
	replacebone "MiniStrider.l_claw" "MiniStrider.l_toe"
	replacebone "MiniStrider.bck_claw" "MiniStrider.bck_toe"
	replacebone "MiniStrider.r_claw" "MiniStrider.r_toe"
	replacebone "MiniStrider.r_antenna2" "MiniStrider.r_antenna1"
	replacebone "MiniStrider.antennaSpike1" "MiniStrider.antennaRaise"
	replacebone "MiniStrider.antennaSpike2" "MiniStrider.antennaRaise"
	replacebone "MiniStrider.l_antenna2" "MiniStrider.l_antenna1"
	nofacial
}

$surfaceprop "hunter"

$contents "solid"

$illumposition -0.817 5.764 52.093

$eyeposition 0 0 80

$mostlyopaque

$cdmaterials "models\MiniStrider\"

$attachment "left foot" "MiniStrider.l_foot_bone" 0 0 0 rotate 0 0 0
$attachment "right foot" "MiniStrider.r_foot_bone" 0 0 0 rotate 0 0 0
$attachment "back foot" "MiniStrider.bck_foot_bone" 0 0 0 rotate 0 0 0
$attachment "bottom_eye" "MiniStrider.low_eye_bone" 10 0 0 rotate 0 0 0
$attachment "top_eye" "MiniStrider.top_eye_bone" 10 0 0 rotate 0 0 0
$attachment "MiniGunBase" "MiniStrider.top_stalk_bone" 0 0 0 rotate 0 0 0
$attachment "rightclaw" "MiniStrider.r_claw4" 0 0 0 rotate 0 0 0
$attachment "MiniGunBase" "MiniStrider.top_stalk_bone" 0 0 0 rotate 0 0 0
$attachment "head_center" "MiniStrider.body_joint" 0 0 0 rotate 0 0 0
$attachment "head_radius_measure" "MiniStrider.body_joint" 0 -14 0 rotate 0 0 0
$attachment "left_toe" "MiniStrider.l_toe" 5 5 0 rotate 0 -45 90
$attachment "right_toe" "MiniStrider.r_toe" 5 5 0 rotate 0 -45 90
$attachment "back_toe" "MiniStrider.bck_toe" 7 -2 0 rotate 0 -135 90

$cbox 0 0 0 0 0 0

$bbox -43.398 -46.031 -1.047 31.869 44.398 105.234

$hboxset "default"
$hbox 0 "MiniStrider.body_joint" -15.28 -17.18 -14.64 15.28 17.809999 19.370001
$hbox 0 "MiniStrider.bck_leg1_bone" -6.28 -11.73 -5.61 22.110001 5.62 5.15
$hbox 0 "MiniStrider.bck_leg2_bone" -1.47 -8.02 -5.15 21.280001 4.7 3.55
$hbox 0 "MiniStrider.bck_leg3_jnt" -2.81 -5.58 -4.44 39.380001 4.06 3.46
$hbox 0 "MiniStrider.bck_foot_bone" -1.5 -4.48 -3.61 21.5 2.1 2.03
$hbox 0 "MiniStrider.l_leg1_bone" -7.73 -5.22 -6.25 21.370001 9.12 3.55
$hbox 0 "MiniStrider.l_leg2_bone" -2.1 -8.04 -6.42 25.530001 7.09 3.46
$hbox 0 "MiniStrider.l_leg3_bone" -2.09 -2.76 -4.13 38.07 5.65 4.47
$hbox 0 "MiniStrider.l_foot_bone" -1.5 -2.63 -2.99 21.5 4.29 2.83
$hbox 0 "MiniStrider.r_leg1_bone" -7.25 -4.28 -3.61 22.049999 9.64 6.18
$hbox 0 "MiniStrider.r_leg2_bone" -0.32 -3.64 -4.01 21.26 6.75 5.72
$hbox 0 "MiniStrider.r_leg3_bone" -2.9 -2.7 -5.65 38.18 6.94 2.58
$hbox 0 "MiniStrider.r_foot_bone" -1.5 -3.11 -2.63 21.5 3.34 2.99
$hbox 0 "MiniStrider.antennaRaise" -2.25 -0.1 -2.3 2.21 17.23 2.32

$definebone "MiniStrider.body_joint" "" 0 -5.530837 80.085701 0 0 89.999982 0 0 0 0 0 0
$definebone "MiniStrider.bck_clav_bone" "MiniStrider.body_joint" 0 -0.820433 -10.212221 73.787394 89.999982 89.999982 0 0 0 0 0 0
$definebone "MiniStrider.bck_leg1_bone" "MiniStrider.bck_clav_bone" 8.188416 0.000839 0 -0.049504 -57.390139 -0.147307 0 0 0 0 0 0
$definebone "MiniStrider.bck_leg2_bone" "MiniStrider.bck_leg1_bone" 18.61832 -0.000003 0 0 -80.205101 0 0 0 0 0 0 0
$definebone "MiniStrider.bck_leg3_jnt" "MiniStrider.bck_leg2_bone" 17.382732 -0.000002 0 0 62.713281 0 0 0 0 0 0 0
$definebone "MiniStrider.bck_foot_bone" "MiniStrider.bck_leg3_jnt" 39.051609 -0.001758 0 0.13178 -21.918 0.082334 0 0 0 0 0 0
$definebone "MiniStrider.antennaBase" "MiniStrider.body_joint" 10.763915 3.664567 -9.977663 0 0 0 0 0 0 0 0 0
$definebone "MiniStrider.top_stalk_bone" "MiniStrider.body_joint" 0 3.914615 8.781766 -89.492718 -89.999927 -90.000037 0 0 0 0 0 0
$definebone "MiniStrider.l_mandible1" "MiniStrider.body_joint" 8.658621 -12.097049 4.288974 -79.131409 179.635546 44.973497 0 0 0 0 0 0
$definebone "MiniStrider.l_mandible2" "MiniStrider.l_mandible1" 13.571 -0.000003 -0.000003 -0.000002 -165.210323 0.000008 0 0 0 0 0 0
$definebone "MiniStrider.low_stalk_bone" "MiniStrider.body_joint" 0 -7.583104 8.7818 -89.492718 -89.999948 -90.000016 0 0 0 0 0 0
$definebone "MiniStrider.r_mandible1" "MiniStrider.body_joint" -8.658621 -12.097049 4.288974 -79.13143 0.364458 135.026501 0 0 0 0 0 0
$definebone "MiniStrider.l_clav" "MiniStrider.body_joint" 11.854924 0.100888 2.982334 -32.861133 15.034472 172.032016 0 0 0 0 0 0
$definebone "MiniStrider.l_leg1_bone" "MiniStrider.l_clav" 8.322444 -0.000006 0 5.25196 57.603001 12.877628 0 0 0 0 0 0
$definebone "MiniStrider.l_leg2_bone" "MiniStrider.l_leg1_bone" 19.099119 -0.000001 0.000002 -0.000004 76.74768 0 0 0 0 0 0 0
$definebone "MiniStrider.l_leg3_bone" "MiniStrider.l_leg2_bone" 17.933889 0.000001 0.000003 -0.000004 -63.833425 0.000008 0 0 0 0 0 0
$definebone "MiniStrider.l_foot_bone" "MiniStrider.l_leg3_bone" 36.999981 -0.000026 0.000006 5.715764 26.981187 -13.335592 0 0 0 0 0 0
$definebone "MiniStrider.r_claw1" "MiniStrider.body_joint" -3.034357 -12.528563 11.775891 35.821494 -88.290857 -75.526893 0 0 0 0 0 0
$definebone "MiniStrider.r_clav_bone" "MiniStrider.body_joint" -11.854924 0.100888 2.982334 -32.861136 150.490104 7.967954 0 0 0 0 0 0
$definebone "MiniStrider.r_leg1_bone" "MiniStrider.r_clav_bone" 8.322446 0 -0.000001 -8.943824 69.822121 -0.802429 0 0 0 0 0 0
$definebone "MiniStrider.r_leg2_bone" "MiniStrider.r_leg1_bone" 19.099125 0.000001 -0.000002 -0.000003 65.783014 0.000001 0 0 0 0 0 0
$definebone "MiniStrider.r_leg3_bone" "MiniStrider.r_leg2_bone" 17.933899 0.000007 0 0 -50.351772 0.000005 0 0 0 0 0 0
$definebone "MiniStrider.r_foot_bone" "MiniStrider.r_leg3_bone" 37.066978 -0.000004 -0.000005 1.694355 20.690036 -2.302819 0 0 0 0 0 0
$definebone "MiniStrider.l_claw1" "MiniStrider.body_joint" 3.034355 -12.528563 11.775893 10.360795 -73.524582 -90.481497 0 0 0 0 0 0
$definebone "MiniStrider.r_mandible2" "MiniStrider.r_mandible1" 13.571001 0.000002 -0.000002 0 -165.210323 0 0 0 0 0 0 0
$definebone "MiniStrider.low_eye_bone" "MiniStrider.low_stalk_bone" 5.118492 0.128587 0 0 -0.507263 0 0 0 0 0 0 0
$definebone "MiniStrider.bottomEyeClose" "MiniStrider.low_eye_bone" 4.959605 -0.000011 0 0 0 0 0 0 0 0 0 0
$definebone "MiniStrider.top_eye_bone" "MiniStrider.top_stalk_bone" 5.428003 0.125825 0 0 -0.507263 0 0 0 0 0 0 0
$definebone "MiniStrider.topEyeClose" "MiniStrider.top_eye_bone" 4.959603 -0.000003 0 0 0 0 0 0 0 0 0 0
$definebone "MiniStrider.r_claw2" "MiniStrider.r_claw1" 4.147598 -0.000002 0.000002 -0.000005 41.407496 0.000006 0 0 0 0 0 0
$definebone "MiniStrider.r_toe" "MiniStrider.r_foot_bone" 12.267107 1.617223 0.033486 -0.7714 -25.957202 -0.855001 0 0 0 0 0 0
$definebone "MiniStrider.l_antenna1" "MiniStrider.body_joint" 1.268668 -14.128865 8.619785 -76.922793 -114.357222 -66.585663 0 0 0 0 0 0
$definebone "MiniStrider.antennaRaise" "MiniStrider.antennaBase" 0 5.212817 -4.270623 0 0 -28.296437 0 0 0 0 0 0
$definebone "MiniStrider.bck_toe" "MiniStrider.bck_foot_bone" 13.274396 -2.006261 -0.375758 0 28.30997 0 0 0 0 0 0 0
$definebone "MiniStrider.r_toe_bone" "MiniStrider.r_foot_bone" 3.241391 1.883496 -0.070275 0.835544 175.220034 -0.096155 0 0 0 0 0 0
$definebone "MiniStrider.l_claw2" "MiniStrider.l_claw1" 4.147606 0 0.000002 0 72.379064 -0.000003 0 0 0 0 0 0
$definebone "MiniStrider.l_claw3" "MiniStrider.l_claw2" 11.653437 -0.000002 -0.000001 1.044731 -156.61841 -1.184711 0 0 0 0 0 0
$definebone "MiniStrider.l_claw4" "MiniStrider.l_claw3" 12.445004 -0.000003 0 1.566009 156.711806 -0.297184 0 0 0 0 0 0
$definebone "MiniStrider.l_toe" "MiniStrider.l_foot_bone" 13.944276 1.088283 0.402441 3.205357 -27.649682 5.306061 0 0 0 0 0 0
$definebone "MiniStrider.r_antenna1" "MiniStrider.body_joint" -1.29172 -14.128865 8.619785 -85.828389 -107.571736 -72.550611 0 0 0 0 0 0
$definebone "MiniStrider.r_claw5" "MiniStrider.r_claw2" 11.653431 0.000006 -0.000001 0.000006 -149.972677 -0.000002 0 0 0 0 0 0
$definebone "MiniStrider.r_claw4" "MiniStrider.r_claw5" 12.444998 -0.000001 -0.000002 -0.00001 155.623702 0.000007 0 0 0 0 0 0
$definebone "MiniStrider.bck_toe_bone" "MiniStrider.bck_foot_bone" 2.348412 -1.747239 0 0 -169.860794 0 0 0 0 0 0 0
$definebone "MiniStrider.l_claw" "MiniStrider.l_toe" 2.883075 1.698881 0.024615 3.086576 -178.579025 5.375889 0 0 0 0 0 0
$definebone "MiniStrider.bck_claw" "MiniStrider.bck_toe" 3.346875 -1.70209 0.085483 0 -174.690353 0 0 0 0 0 0 0
$definebone "MiniStrider.r_claw" "MiniStrider.r_toe" 4.912361 1.493325 0.046049 -0.785315 179.072096 -0.842376 0 0 0 0 0 0
$definebone "MiniStrider.r_antenna2" "MiniStrider.r_antenna1" 6.924 0.000005 0 0 49.201828 0.000001 0 0 0 0 0 0
$definebone "MiniStrider.antennaSpike1" "MiniStrider.antennaRaise" -0.333966 14.1612 -0.517991 0.574163 -24.39282 7.163005 0 0 0 0 0 0
$definebone "MiniStrider.antennaSpike2" "MiniStrider.antennaRaise" 0.174882 12.09151 -0.550255 0 9.386481 -0.000002 0 0 0 0 0 0
$definebone "MiniStrider.l_antenna2" "MiniStrider.l_antenna1" 6.923999 -0.000002 0 -6.801866 49.237013 -4.389719 0 0 0 0 0 0


$poseparameter "aim_pitch" -90 90 loop 0
$poseparameter "aim_yaw" -90 90 loop 0
$poseparameter "move_yaw" -180 180 loop 360
$poseparameter "stagger_yaw" -180 180 loop 360

$ikchain "lfoot" "MiniStrider.l_foot_bone" knee 0 0 0
$ikchain "rfoot" "MiniStrider.r_foot_bone" knee 0 0 0
$ikchain "bfoot" "MiniStrider.bck_foot_bone" knee 0 0 0

$sequence "ragdoll" {
	"hunter_anims\ragdoll.smd"
	activity "ACT_DIERAGDOLL" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 1 1 target 0
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 1 1 target 1
	ikrule "bfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 1 1 target 2
}

$includemodel "Hunter_animations.mdl"

$collisionjoints "hunter_physics.smd"
{
	$mass 1000
	$inertia 0
	$damping 0.1
	$rotdamping 0.125
	$rootbone "MiniStrider.body_joint"

	$jointmassbias "MiniStrider.body_joint" 0.3

	$jointmassbias "MiniStrider.r_antenna2" 100
	$jointconstrain "MiniStrider.r_antenna2" x limit 0 0 0
	$jointconstrain "MiniStrider.r_antenna2" y limit 0 0 0
	$jointconstrain "MiniStrider.r_antenna2" z limit -60 120 0

	$jointmassbias "MiniStrider.r_claw5" 25
	$jointrotdamping "MiniStrider.r_claw5" 0.5
	$jointconstrain "MiniStrider.r_claw5" x limit 0 0 0
	$jointconstrain "MiniStrider.r_claw5" y limit 0 0 0
	$jointconstrain "MiniStrider.r_claw5" z limit 0 80 0

	$jointmassbias "MiniStrider.r_claw4" 10
	$jointconstrain "MiniStrider.r_claw4" x limit 0 0 0
	$jointconstrain "MiniStrider.r_claw4" y limit 0 0 0
	$jointconstrain "MiniStrider.r_claw4" z limit -110 0 0

	$jointmassbias "MiniStrider.l_claw3" 25
	$jointrotdamping "MiniStrider.l_claw3" 0.5
	$jointconstrain "MiniStrider.l_claw3" x limit 0 0 0
	$jointconstrain "MiniStrider.l_claw3" y limit 0 0 0
	$jointconstrain "MiniStrider.l_claw3" z limit 0 110 0

	$jointmassbias "MiniStrider.l_claw4" 10
	$jointconstrain "MiniStrider.l_claw4" x limit 0 0 0
	$jointconstrain "MiniStrider.l_claw4" y limit 0 0 0
	$jointconstrain "MiniStrider.l_claw4" z limit -110 0 0

	$jointmassbias "MiniStrider.r_mandible1" 10
	$jointconstrain "MiniStrider.r_mandible1" x limit 0 0 0
	$jointconstrain "MiniStrider.r_mandible1" y limit 0 0 0
	$jointconstrain "MiniStrider.r_mandible1" z limit 0 60 0

	$jointmassbias "MiniStrider.l_mandible1" 10
	$jointconstrain "MiniStrider.l_mandible1" x limit 0 0 0
	$jointconstrain "MiniStrider.l_mandible1" y limit 0 0 0
	$jointconstrain "MiniStrider.l_mandible1" z limit 0 60 0

	$jointmassbias "MiniStrider.r_leg1_bone" 1.25
	$jointconstrain "MiniStrider.r_leg1_bone" x limit -23 23 0
	$jointconstrain "MiniStrider.r_leg1_bone" y limit -35 35 0
	$jointconstrain "MiniStrider.r_leg1_bone" z limit -50 50 0

	$jointconstrain "MiniStrider.r_leg2_bone" x limit 0 0 0
	$jointconstrain "MiniStrider.r_leg2_bone" y limit 0 0 0
	$jointconstrain "MiniStrider.r_leg2_bone" z limit -75 30 0

	$jointconstrain "MiniStrider.r_leg3_bone" x limit 0 0 0
	$jointconstrain "MiniStrider.r_leg3_bone" y limit 0 0 0
	$jointconstrain "MiniStrider.r_leg3_bone" z limit -77 10 0

	$jointconstrain "MiniStrider.r_foot_bone" x limit 0 0 0
	$jointconstrain "MiniStrider.r_foot_bone" y limit 0 0 0
	$jointconstrain "MiniStrider.r_foot_bone" z limit -30 14 0

	$jointmassbias "MiniStrider.l_leg1_bone" 1.25
	$jointconstrain "MiniStrider.l_leg1_bone" x limit -23 23 0
	$jointconstrain "MiniStrider.l_leg1_bone" y limit -35 35 0
	$jointconstrain "MiniStrider.l_leg1_bone" z limit -50 55 0

	$jointconstrain "MiniStrider.l_leg2_bone" x limit 0 0 0
	$jointconstrain "MiniStrider.l_leg2_bone" y limit 0 0 0
	$jointconstrain "MiniStrider.l_leg2_bone" z limit -75 30 0

	$jointconstrain "MiniStrider.l_leg3_bone" x limit 0 0 0
	$jointconstrain "MiniStrider.l_leg3_bone" y limit 0 0 0
	$jointconstrain "MiniStrider.l_leg3_bone" z limit -77 10 0

	$jointconstrain "MiniStrider.l_foot_bone" x limit 0 0 0
	$jointconstrain "MiniStrider.l_foot_bone" y limit 0 0 0
	$jointconstrain "MiniStrider.l_foot_bone" z limit -30 14 0

	$jointmassbias "MiniStrider.low_stalk_bone" 5
	$jointrotdamping "MiniStrider.low_stalk_bone" 0.75
	$jointconstrain "MiniStrider.low_stalk_bone" x limit -20 20 1
	$jointconstrain "MiniStrider.low_stalk_bone" y limit -20 20 0.4
	$jointconstrain "MiniStrider.low_stalk_bone" z limit -30 30 0.4

	$jointmassbias "MiniStrider.top_stalk_bone" 5
	$jointrotdamping "MiniStrider.top_stalk_bone" 0.75
	$jointconstrain "MiniStrider.top_stalk_bone" x limit -20 20 1
	$jointconstrain "MiniStrider.top_stalk_bone" y limit -20 20 0.4
	$jointconstrain "MiniStrider.top_stalk_bone" z limit -30 30 0.4

	$jointconstrain "MiniStrider.bck_leg1_bone" x limit -23 23 0
	$jointconstrain "MiniStrider.bck_leg1_bone" y limit -35 35 0
	$jointconstrain "MiniStrider.bck_leg1_bone" z limit -50 75 0

	$jointconstrain "MiniStrider.bck_leg2_bone" x limit 0 0 0
	$jointconstrain "MiniStrider.bck_leg2_bone" y limit 0 0 0
	$jointconstrain "MiniStrider.bck_leg2_bone" z limit -40 80 0

	$jointconstrain "MiniStrider.bck_leg3_jnt" x limit 0 0 0
	$jointconstrain "MiniStrider.bck_leg3_jnt" y limit 0 0 0
	$jointconstrain "MiniStrider.bck_leg3_jnt" z limit -70 55 0

	$jointconstrain "MiniStrider.bck_foot_bone" x limit 0 0 0
	$jointconstrain "MiniStrider.bck_foot_bone" y limit 0 0 0
	$jointconstrain "MiniStrider.bck_foot_bone" z limit -30 14 0

	$jointmassbias "MiniStrider.l_antenna2" 100
	$jointconstrain "MiniStrider.l_antenna2" x limit 0 0 0
	$jointconstrain "MiniStrider.l_antenna2" y limit 0 0 0
	$jointconstrain "MiniStrider.l_antenna2" z limit -120 80 0

	$jointcollide "MiniStrider.r_leg3_bone" "MiniStrider.bck_leg3_jnt"
	$jointcollide "MiniStrider.r_leg3_bone" "MiniStrider.l_leg3_bone"
	$jointcollide "MiniStrider.r_leg2_bone" "MiniStrider.bck_leg2_bone"
	$jointcollide "MiniStrider.r_leg2_bone" "MiniStrider.l_leg2_bone"
	$jointcollide "MiniStrider.bck_leg2_bone" "MiniStrider.body_joint"
	$jointcollide "MiniStrider.l_leg2_bone" "MiniStrider.body_joint"
	$jointcollide "MiniStrider.l_leg1_bone" "MiniStrider.body_joint"
	$jointcollide "MiniStrider.r_leg2_bone" "MiniStrider.body_joint"
	$jointcollide "MiniStrider.r_leg1_bone" "MiniStrider.body_joint"
}
