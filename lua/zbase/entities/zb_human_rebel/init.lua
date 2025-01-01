local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.StartHealth = 50 -- Max health


NPC.SpawnFlagTbl = {SF_CITIZEN_RANDOM_HEAD_MALE, SF_CITIZEN_AMMORESUPPLIER}


NPC.CanSecondaryAttack = true -- Can use weapon secondary attacks


NPC.BaseGrenadeAttack = true -- Use ZBase grenade attack system
NPC.ThrowGrenadeChance_Visible = 4 -- 1/x chance that it throws a grenade when the enemy is visible
NPC.ThrowGrenadeChance_Occluded = 2 -- 1/x chance that it throws a grenade when the enemy is not visible
NPC.GrenadeCoolDown = {4, 8} -- {min, max}
NPC.GrenadeAttackAnimations = {"throw1"} -- Grenade throw animation
NPC.GrenadeEntityClass = "npc_grenade_frag" -- The grenade to throw, can be anything, like a fucking cat or somthing
NPC.GrenadeReleaseTime = 0.75 -- Time until grenade leaves the hand
NPC.GrenadeAttachment = "anim_attachment_LH" -- The attachment to spawn the grenade on
NPC.GrenadeMaxSpin = 1000 -- The amount to spin the grenade measured in spin units or something idfk


NPC.ZBaseStartFaction = "ally" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"


NPC.CanPatrol = true -- Use base patrol behaviour
NPC.KeyValues = {citizentype = CT_REBEL} -- Keyvalues
NPC.HasArmor = {
    [HITGROUP_CHEST] = true,
}


NPC.MeleeAttackAnimations = {"meleeattack01"}




function NPC:CustomInitialize()
end


function NPC:GrenadeAnimation()
    self:PlayAnimation(table.Random(self.GrenadeAttackAnimations), true, {speedMult=1.5})
end

