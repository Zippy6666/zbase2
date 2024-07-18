AddCSLuaFile()


--[[
==================================================================================================
                                           GENERAL
==================================================================================================
--]]



-- IMPORTANT: SHOULD be weapon_zbase for your swep!! (unless you know what you are doing)
-- The weapon's base script, relative to lua/weapons.
SWEP.Base = "weapon_zbase" -- Set to "weapon_zbase"
SWEP.IsZBaseWeapon = true -- Must exist in your swep
SWEP.NPCSpawnable = true -- Add to NPC weapon list


SWEP.Spawnable = false -- Whether or not this weapon can be obtained through the spawn menu.
SWEP.AdminOnly = false -- If spawnable, this variable determines whether only administrators can use the button in the spawn menu.
SWEP.Category = "ZBase" -- The spawn menu category that this weapon resides in.


SWEP.PrintName = "Dummy Weapon" -- The name of the SWEP displayed in the spawn menu.
SWEP.Author = "Zippy" -- The SWEP's author.


SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" ) -- Relative path to the SWEP's world model.
SWEP.ViewModel = Model( "models/weapons/c_smg1.mdl" ) -- Relative path to the SWEP's view model.


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


SWEP.BounceWeaponIcon = true -- Should the weapon icon bounce in weapon selection?
SWEP.DrawAmmo = true -- Should we draw the default HL2 ammo counter?
SWEP.DrawCrosshair = false -- Should we draw the default crosshair?
SWEP.AccurateCrosshair = false -- Makes the default SWEP crosshair be positioned in 3D space where your aim actually is (like on Jeep), instead of simply sitting in the middle of the screen at all times


SWEP.Slot = 0 -- Slot in the weapon selection menu, starts with 0
SWEP.SlotPos = 10 -- Position in the slot, should be in the range 0-128


-- Makes the player models hands bonemerged onto the view model
-- The gamemode and view models must support this feature for it to work! You can find more information here: Using Viewmodel Hands
SWEP.UseHands = true


SWEP.DisableDuplicator = false -- Disable the ability for players to duplicate this SWEP
SWEP.ScriptedEntityType =  "weapon" -- Sets the spawnmenu content icon type for the entity, used by spawnmenu in the Sandbox-derived gamemodes.


SWEP.m_bPlayPickupSound = true -- If set to false, the weapon will not play the weapon pick up sound when picked up.



--[[
==================================================================================================
                                           BASIC PRIMARY ATTACK
==================================================================================================
--]]



SWEP.ClipSize = 30 -- The maximum amount of bullets one clip can hold. Setting it to -1 means weapon uses no clips, like a grenade or a rocket launch.
SWEP.Automatic = true -- If true makes the weapon shoot automatically as long as the player has primary attack button held down


SWEP.PrimaryShootSound = "Weapon_SMG1.NPC_Single" -- Shoot sound
SWEP.PrimarySpread = 0.02 -- Spread
SWEP.PrimaryDamage = 3 -- Damage


SWEP.Primary.DefaultClip = 30 -- Clipsize for NPCs
SWEP.Primary.Ammo = "SMG1" -- https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.TakeAmmoPerShot = 1 -- Ammo to take for each shot
SWEP.Primary.NumShots = 1 -- Number of bullets per shot


SWEP.Primary.ShellEject = false -- Set to the name of an attachment to enable shell ejection
SWEP.Primary.ShellType = "ShellEject" -- https://wiki.facepunch.com/gmod/Effects
SWEP.Primary.ShellAngOffset = Angle(0, 0, 0) -- Change the direction of the shell eject direction by this angle


SWEP.Primary.TracerName = "Tracer" -- The tracer effect https://wiki.facepunch.com/gmod/Effects
SWEP.Primary.TracerChance = 2 -- 1 / x


-- 1 - Regular muzzleflash
-- 5 - Combine muzzleflash
-- 7 - Regular muzzle but bigger
SWEP.Primary.MuzzleFlashFlags = 1
SWEP.Primary.MuzzleFlash = true -- Should it have a muzzleflash?


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


--[[
==================================================================================================
                            INIT
==================================================================================================
--]]


	-- On weapon created
function SWEP:Init()
	self:SetHoldType( "smg" )
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