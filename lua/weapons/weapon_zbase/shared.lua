AddCSLuaFile()
include("sh_internal.lua")

-- You can use this weapon base for your swep to have better control over how NPCs handle it --
-- vv Make sure you do this vv --
-- SWEP.Base = "weapon_zbase"
-- SWEP.IsZBaseWeapon = true

--[[
==================================================================================================
                                           GENERAL
==================================================================================================
--]]

-- IMPORTANT: SHOULD be weapon_zbase for your swep!! (unless you know what you are doing)
-- The weapon's base script, relative to lua/weapons.
SWEP.Base = "weapon_base" -- Set to "weapon_zbase"
SWEP.IsZBaseWeapon = true -- Must exist in your swep
SWEP.NPCSpawnable = true -- Add to NPC weapon list

SWEP.Spawnable = false -- Whether or not this weapon can be obtained through the spawn menu.
SWEP.AdminOnly = false -- If spawnable, this variable determines whether only administrators can use the button in the spawn menu.
SWEP.Category = "ZBase" -- The spawn menu category that this weapon resides in.

SWEP.PrintName = "ZBase Weapon" -- The name of the SWEP displayed in the spawn menu.
SWEP.Author = "Zippy" -- The SWEP's author.

SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" ) -- Relative path to the SWEP's world model.
SWEP.ViewModel = Model( "models/weapons/c_smg1.mdl" ) -- Relative path to the SWEP's view model.

-- Custom world model options
SWEP.CustomWorldModel = {
    Active      = false,                        -- Needs to be true if you want to change things about the world model, such as positioning
    Bone        = "ValveBiped.Bip01_R_Hand",    -- The bone the model should be attached to, default is the right hand
    Offset      = Vector(0, 0, 0),              -- Position offset
    AngOffset   = Angle(0, 0, 0)                -- Angle offset
}

-- Makes the player models hands bonemerged onto the view model
-- The gamemode and view models must support this feature for it to work! You can find more information here: Using Viewmodel Hands
SWEP.UseHands = true

SWEP.ViewModelFlip = false -- Used primarily for Counter Strike: Source view models, this variable is used to flip them back to normal.
SWEP.ViewModelFlip1 = false -- Behaves similarly to ViewModelFlip, but for the second view model.
SWEP.ViewModelFlip2 = false -- Behaves similarly to ViewModelFlip, but for the third view model.
SWEP.ViewModelFOV = 62 -- The field of view percieved whilst wielding this SWEP.

SWEP.AutoSwitchFrom = true -- Whether this weapon can be autoswitched away from when the player runs out of ammo in this weapon or picks up another weapon or ammo
SWEP.AutoSwitchTo = true -- Whether this weapon can be autoswitched to when the player runs out of ammo in their current weapon or they pick this weapon up
SWEP.Weight = 5 -- Determines the priority of the weapon when autoswitching. The weapon being autoswitched from will attempt to switch to a weapon with the same weight that has ammo, but if none exists, it will prioritise higher weight weapons.

SWEP.m_WeaponDeploySpeed = 1 -- The deploy speed multiplier. This does not change the internal deployment speed.
SWEP.BobScale = 1 -- The scale of the viewmodel bob (viewmodel movement from left to right when walking around)
SWEP.SwayScale = 1 -- The scale of the viewmodel sway (viewmodel position lerp when looking around).
SWEP.m_bPlayPickupSound = true -- If set to false, the weapon will not play the weapon pick up sound when picked up.

SWEP.BounceWeaponIcon = true -- Should the weapon icon bounce in weapon selection?
SWEP.DrawAmmo = true -- Should we draw the default HL2 ammo counter?
SWEP.DrawCrosshair = false -- Should we draw the default crosshair?
SWEP.AccurateCrosshair = false -- Makes the default SWEP crosshair be positioned in 3D space where your aim actually is (like on Jeep), instead of simply sitting in the middle of the screen at all times

SWEP.Slot = 0 -- Slot in the weapon selection menu, starts with 0
SWEP.SlotPos = 10 -- Position in the slot, should be in the range 0-128

SWEP.DisableDuplicator = false -- Disable the ability for players to duplicate this SWEP

--[[
==================================================================================================
                                           BASIC PRIMARY ATTACK
==================================================================================================
--]]

SWEP.PrimaryShootSound = "Weapon_SMG1.NPC_Single" -- Shoot sound
SWEP.PrimarySpread = 0.02 -- Spread
SWEP.PrimaryDamage = 3 -- Damage

SWEP.Primary.DefaultClip = 30 -- How much a single magazine can hold.
SWEP.Primary.Ammo = "SMG1" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.TakeAmmoPerShot = 1 -- Ammo to take for each shot
SWEP.Primary.NumShots = 1 -- Number of bullets per shot
SWEP.Primary.Automatic = true -- If true makes the weapon shoot automatically as long as the player has primary attack button held down

SWEP.Primary.ShellEject = false -- Set to the name of an attachment to enable shell ejection
SWEP.Primary.ShellType = "ShellEject" -- https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.ShellAngOffset = Angle(0, 0, 0) -- Change the direction of the shell eject direction by this angle

SWEP.Primary.TracerName = "Tracer" -- The tracer effect https://wiki.facepunch.com/gmod/Default_Effects
SWEP.Primary.TracerChance = 3 -- 1 / x

-- 1 - Regular muzzleflash
-- 5 - Combine muzzleflash
-- 7 - Regular muzzle but bigger
SWEP.Primary.MuzzleFlashFlags = 1
SWEP.Primary.MuzzleFlash = true -- Should it have a muzzleflash?
SWEP.Primary.MuzzleFlashChance = 1 -- Should it have a muzzleflash?

--[[
==================================================================================================
                                           NPC HANDLING
==================================================================================================
--]]

SWEP.NPCOnly = true -- Should only NPCs be able to use this weapon?
SWEP.NPCCanPickUp = true -- Can NPCs pick up this weapon from the ground
SWEP.NPCBurstMin = 1 -- Minimum amount of bullets the NPC can fire when firing a burst
SWEP.NPCBurstMax = 1 -- Maximum amount of bullets the NPC can fire when firing a burst
SWEP.NPCFireRate = 1 -- Shoot delay in seconds
SWEP.NPCFireRestTimeMin = 1 -- Minimum amount of time the NPC rests between bursts in seconds
SWEP.NPCFireRestTimeMax = 1 -- Maximum amount of time the NPC rests between bursts in seconds
SWEP.NPCBulletSpreadMult = 1 -- Higher number = worse accuracy
SWEP.NPCReloadSound = "" -- Sound when the NPC reloads the gun
SWEP.NPCShootDistanceMult = 1 -- Multiply the NPCs shoot distance by this number with this weapon
SWEP.NPCCanBePickedUp = true -- Can NPCs pick up this weapon?

-- https://wiki.facepunch.com/gmod/Hold_Types
-- Will fall back on other holdtype if the NPC doesn't have supporting animations
SWEP.NPCHoldType =  "smg"

SWEP.ZBase_ActTranslateOverride = {} -- Override activities for ZBase NPCs: [ACT_OLD] = ACT_NEW

--[[
==================================================================================================
                                    NPC HANDLING: Melee weapon
==================================================================================================
--]]

SWEP.NPCIsMeleeWep = false -- Should the NPC treat the weapon as a melee weapon?
SWEP.NPCMeleeWep_Damage = {10, 10} -- Melee weapon damage {min, max}
SWEP.NPCMeleeWep_DamageType = DMG_CLUB -- Melee weapon damage type
SWEP.NPCMeleeWep_HitSound = "Flesh.BulletImpact" -- Sound when the melee weapon hits an entity
SWEP.NPCMeleeWep_DamageAngle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
SWEP.NPCMeleeWep_DamageDist = 100 -- Melee weapon damage reach distance

--[[
==================================================================================================
                            INIT/THINK
==================================================================================================
--]]

-- On weapon created
function SWEP:Init()
	self:SetHoldType( "smg" )
end

-- Called when the swep thinks. 
function SWEP:CustomThink()
end

-- Called when the SWEP should set up its Data Tables.
function SWEP:CustomSetupDataTables()
end

--[[
==================================================================================================
                            PRIMARY ATTACK
==================================================================================================
--]]

-- Called when an NPC primary attacks
-- Return true to disable default
function SWEP:NPCPrimaryAttack()
end

-- Called when the weapon does its melee damage code
function SWEP:OnNPCMeleeWeaponDamage( hurtEnts )
end

-- Called when a player primary attacks
-- Return true to disable default
function SWEP:OnPrimaryAttack()
end

--[[
==================================================================================================
                            SECONDARY
==================================================================================================
--]]

-- Return true to disable default
function SWEP:CustomSecondaryAttack()
end

--[[
==================================================================================================
                            EFFECTS
==================================================================================================
--]]

-- A convenience function to create shoot effects.
-- Return true to disable default
function SWEP:CustomShootEffects()
end

-- Called so the weapon can override the impact effects it makes.
-- Return true to disable default
function SWEP:CustomDoImpactEffect( tr, damageType )
end

--[[
==================================================================================================
                            EVENT TYPE STUFF
==================================================================================================
--]]

-- Called when another entity fires an event to this entity.
-- Return true to suppress
function SWEP:CustomAcceptInput( inputName, activator, called, data )
end

-- Called before firing animation events, such as muzzle flashes or shell ejections.
-- This will only be called serverside for 3000-range events, and clientside for 5000-range and other events.
-- Return true to suppress
function SWEP:CustomFireAnimationEvent( pos, ang, event, options, source )
	return true
end

-- Called when the engine sets a value for this scripted weapon.
-- Return true to suppress
function SWEP:CustomKeyValue( key, value )
end

--[[
==================================================================================================
                            CLIENT
==================================================================================================
--]]


if CLIENT then

	-- Called when we are about to draw the world model.
	-- Return true to disable default
	function SWEP:CustomDrawWorldModel( flags )
	end
	
	-- Called when we are about to draw the translucent world model.
	-- Return true to disable default
	function SWEP:CustomDrawWorldModelTranslucent( flags )
	end

end

--[[
==================================================================================================
                            OTHER
==================================================================================================
--]]

-- Activity translation
-- Only called for players and non-zbase npcs
function SWEP:CustomTranslateActivity( act )
end

-- Should this weapon be dropped when its owner dies?
-- The base will decide if you don't return anything
function SWEP:CustomShouldDropOnDie()
end

--[[
==================================================================================================
                            Removal
==================================================================================================
--]]

-- Called when the weapon is removed
function SWEP:CustomOnRemove()
end