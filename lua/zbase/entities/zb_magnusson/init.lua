local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.ItemDrops = {
    ["weapon_striderbuster"] = {chance=2, max=1}
}

NPC.BaseGrenadeAttack = true -- Use ZBase grenade attack system
NPC.ThrowGrenadeChance_Visible = 2 -- 1/x chance that it throws a grenade when the enemy is visible
NPC.ThrowGrenadeChance_Occluded = 2 -- 1/x chance that it throws a grenade when the enemy is not visible
NPC.GrenadeCoolDown = {3, 6} -- {min, max}
NPC.GrenadeAttackAnimations = {"throw1"} -- Grenade throw animation
NPC.GrenadeEntityClass = {"weapon_striderbuster"} -- The type of grenade(s) to throw, can be anything. Randomized.
NPC.GrenadeReleaseTime = 0.85 -- Time until grenade leaves the hand
NPC.GrenadeAttachment = "anim_attachment_LH" -- The attachment to spawn the grenade on
NPC.GrenadeMaxSpin = 1000 -- The amount to spin the grenade measured in spin units or something idfk


-- Sounds (Use sound scripts to alter pitch and level and such!)
NPC.AlertSounds = "ZBaseMagnusson.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "" -- Sounds emitted while there is no enemy
NPC.Idle_HasEnemy_Sounds = "" -- Sounds emitted while there is an enemy
NPC.PainSounds = "" -- Sounds emitted on hurt
NPC.DeathSounds = "ZBaseMagnusson.Die" -- Sounds emitted on death
NPC.KilledEnemySounds = "ZBaseMagnusson.KillEnemy" -- Sounds emitted when the NPC kills an enemy


NPC.LostEnemySounds = "" -- Sounds emitted when the enemy is lost
NPC.SeeDangerSounds = "ZBaseMagnusson.SeeDanger" -- Sounds emitted when the NPC spots a danger, such as a flaming barrel
NPC.SeeGrenadeSounds = "" -- Sounds emitted when the NPC spots a grenade
NPC.AllyDeathSounds = "ZBaseMagnusson.AllyDeath" -- Sounds emitted when an ally dies
NPC.OnMeleeSounds = "" -- Sounds emitted when the NPC does its melee attack
NPC.OnRangeSounds = "" -- Sounds emitted when the NPC does its range attack
NPC.OnReloadSounds = "" -- Sounds emitted when the NPC reloads


-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseMagnusson.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseMagnusson.Answer" -- Dialogue answers, emitted when the NPC is spoken to


-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseMagnusson.HearDanger"


    -- The velocity to apply to the grenade
function NPC:GrenadeVelocity()
    local StartPos = self:GrenadeSpawnPos()
    local EndPos = self:GetEnemyLastSeenPos()

    local UpAmount = math.Clamp(EndPos.z - StartPos.z, 150, 10000)

    return ( (EndPos - StartPos)+Vector(0, 0, UpAmount) )*1.5
end


    -- Called a tick after an entity owned by this NPC is created
    -- Very useful for replacing a combine's grenades or a hunter's flechettes or something of that nature
function NPC:OnGrenadeSpawned( grenade )

    grenade:EmitSound("Weapon_StriderBuster.Ping")

end


