-- Backwards compatability.

local NPC               = ZBaseNPCs["npc_zbase"]
local ai_disabled       = GetConVar("ai_disabled")

--[[
==================================================================================================
                OLD ZBASE WEAPON SYSTEM
==================================================================================================
--]]

local AIWantsToShoot_ACT_Blacklist = {
    [ACT_JUMP]              = true,
    [ACT_GLIDE]             = true,
    [ACT_LAND]              = true,
    [ACT_SIGNAL1]           = true,
    [ACT_SIGNAL2]           = true,
    [ACT_SIGNAL3]           = true,
    [ACT_SIGNAL_ADVANCE]    = true,
    [ACT_SIGNAL_FORWARD]    = true,
    [ACT_SIGNAL_GROUP]      = true,
    [ACT_SIGNAL_HALT]       = true,
    [ACT_SIGNAL_LEFT]       = true,
    [ACT_SIGNAL_RIGHT]      = true,
    [ACT_SIGNAL_TAKECOVER]  = true,
}
local AIWantsToShoot_SCHED_Blacklist = {
    [SCHED_RELOAD]          = true,
    [SCHED_HIDE_AND_RELOAD] = true,
    [SCHED_SCENE_GENERIC]   = true,
}

NPC.ZBWepSys_NextCheckIsFacingEne = 0

function NPC:ZBWepSys_AIWantsToShoot()
    if ai_disabled:GetBool() then return false end
    if !self.EnemyVisible then return false end
    if AIWantsToShoot_ACT_Blacklist[self:GetActivity()] then return false end

    -- Check has appropriate schedule
    local sched = self:GetCurrentSchedule()
    if AIWantsToShoot_SCHED_Blacklist[sched] 
        || (self.Patch_AIWantsToShoot_SCHED_Blacklist 
            && self.Patch_AIWantsToShoot_SCHED_Blacklist[sched]) then
        return false
    end

    local ene = self:GetEnemy()

    -- More performance friendly is facing check
    if self.ZBWepSys_NextCheckIsFacingEne < CurTime() then
        self.ZBWepSys_Stored_FacingEne = self:IsFacing(ene)
        self.ZBWepSys_NextCheckIsFacingEne = CurTime()+0.7
    end

    if !self.ZBWepSys_Stored_FacingEne then return false end

    return true
end

local shootACTNeedles = {
    "_AIM",
    "RANGE_ATTACK",
    "ANGRY_PISTOL",
    "ANGRY_SMG1",
    "ANGRY_AR2",
    "ANGRY_RPG",
    "ANGRY_SHOTGUN",
}
function NPC:ZBWepSys_HasShootAnim()
    local seq, moveSeq = self:GetSequence(), self:GetMovementSequence()
    local strMoveAct, strAct = self:GetSequenceActivityName(seq), self:GetSequenceActivityName(moveSeq)
    for _, needle in ipairs(shootACTNeedles) do
        if string.find(strAct, needle) || string.find(strMoveAct, needle) then
            return true
        end
    end
    local seqAct, moveSeqAct = self:GetSequenceActivity(seq), self:GetSequenceActivity(moveSeq)
    if self.ExtraFireWeaponActivities[seqAct] || self.ExtraFireWeaponActivities[moveSeqAct] then
        return true
    end
    return false
end

function NPC:ZBWepSys_WantsToShoot()
    return !self.DoingPlayAnim
    && self:ShouldFireWeapon() -- User defined function
    && (self.ZBASE_bControllerShoot || self:ZBWepSys_AIWantsToShoot())
end

function NPC:ZBWepSys_CanFireWeapon()
    return self:ZBWepSys_WantsToShoot()
    && self:ZBWepSys_HasShootAnim()
    && !self.ComballAttacking
end

--[[
==================================================================================================
                OLD BECOME RAGDOLL FUNCTION
==================================================================================================
--]]

function NPC:BecomeRagdoll( dmg, hit_gr, keep_corpse )
    -- Do nothing
end