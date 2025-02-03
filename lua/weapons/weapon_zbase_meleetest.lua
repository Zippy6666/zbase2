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
SWEP.NPCOnly = true -- Should only NPCs be able to use this weapon?
SWEP.Spawnable = false -- Whether or not this weapon can be obtained through the spawn menu.
SWEP.AdminOnly = false -- If spawnable, this variable determines whether only administrators can use the button in the spawn menu.
SWEP.Category = "ZBase Tests" -- The spawn menu category that this weapon resides in.


SWEP.PrintName = "Dummy Melee" -- The name of the SWEP displayed in the spawn menu.
SWEP.Author = "Zippy" -- The SWEP's author.


SWEP.WorldModel = Model( "models/weapons/w_crowbar.mdl" ) -- Relative path to the SWEP's world model.
SWEP.ViewModel = Model( "models/weapons/c_crowbar.mdl" ) -- Relative path to the SWEP's view model.


SWEP.AutoSwitchFrom = true -- Whether this weapon can be autoswitched away from when the player runs out of ammo in this weapon or picks up another weapon or ammo
SWEP.AutoSwitchTo = true -- Whether this weapon can be autoswitched to when the player runs out of ammo in their current weapon or they pick this weapon up
SWEP.Weight = 5 -- Determines the priority of the weapon when autoswitching. The weapon being autoswitched from will attempt to switch to a weapon with the same weight that has ammo, but if none exists, it will prioritise higher weight weapons.


SWEP.m_WeaponDeploySpeed = 1 -- The deploy speed multiplier. This does not change the internal deployment speed.
SWEP.BobScale = 1 -- The scale of the viewmodel bob (viewmodel movement from left to right when walking around)
SWEP.SwayScale = 1 -- The scale of the viewmodel sway (viewmodel position lerp when looking around).


SWEP.Slot = 0 -- Slot in the weapon selection menu, starts with 0
SWEP.SlotPos = 10 -- Position in the slot, should be in the range 0-128


--[[
==================================================================================================
                                    NPC HANDLING: Melee weapon
==================================================================================================
--]]



SWEP.NPCIsMeleeWep = true -- Should the NPC treat the weapon as a melee weapon?
SWEP.NPCMeleeWep_Damage = {10, 10} -- Melee weapon damage {min, max}
SWEP.NPCMeleeWep_DamageType = DMG_CLUB -- Melee weapon damage type
SWEP.NPCMeleeWep_HitSound = "Flesh.BulletImpact" -- Sound when the melee weapon hits an entity
SWEP.NPCMeleeWep_DamageAngle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
SWEP.NPCMeleeWep_DamageDist = 100 -- Melee weapon damage reach distance



-- https://wiki.facepunch.com/gmod/Hold_Types
-- Will fall back on other holdtype if the NPC doesn't have supporting animations
SWEP.NPCHoldType =  "passive"


--[[
==================================================================================================
                            INIT
==================================================================================================
--]]


	-- On weapon created
function SWEP:Init()
	self:SetHoldType( "passive" )
end


--[[
==================================================================================================
                            PRIMARY ATTACK
==================================================================================================
--]]


	-- Called when an NPC primary attacks
	-- Return true to disable default
function SWEP:NPCPrimaryAttack()
	-- return true
end


	-- Called when the weapon does its melee damage code
function SWEP:OnNPCMeleeWeaponDamage( hurtEnts )
end


	-- Called when a player primary attacks
	-- Return true to disable default
function SWEP:OnPrimaryAttack()
	return true
end