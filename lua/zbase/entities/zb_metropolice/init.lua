local NPC = FindZBaseTable(debug.getinfo(1,'S'))

-- Spawn flags
local SF_METROPOLICE_ARREST_ENEMY   = 2097152
local SF_MANHACK_PACKED_UP          = 65536
local SF_MANHACK_CARRIED            = 524288

local ShouldHaveRadioSound  = {
    ["LostEnemySounds"] = true,
    ["OnReloadSounds"] = true,
    ["Dialogue_Question_Sounds"] = true,
    ["Dialogue_Answer_Sounds"] = true,
    ["AlertSounds"] = true,
    ["KilledEnemySounds"] = true,
    ["OnGrenadeSounds"] = true,
}

NPC.WeaponProficiency = WEAPON_PROFICIENCY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT

NPC.StartHealth = 40 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour
NPC.CanSecondaryAttack = false -- Can use weapon secondary attacks

NPC.ZBaseStartFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied, it set to "none", they won't be allied to anybody
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none"

NPC.HasArmor = {
    [HITGROUP_CHEST] = true,
}

NPC.BaseMeleeAttack = true
NPC.MeleeDamage_Delay = 0.5
NPC.MeleeAttackAnimations = { "Swing" }
NPC.MeleeWeaponAnimations = {"Swing"} -- Animations to use when attacking with a melee weapon

-- Items to drop on death
-- ["item_class_name"] = {chance=1/x, max=x}
NPC.ItemDrops = {
    ["item_healthvial"] = {chance=3, max=2} -- Example, a healthvial that has a 1/2 chance of spawning
}

NPC.KeyValues = {weapondrawn="1"}
NPC.SpawnFlagTbl = {SF_METROPOLICE_ARREST_ENEMY}

NPC.MuteDefaultVoice = false -- Mute all default voice sounds emitted by this NPC

NPC.AlertSounds = "ZBaseMetrocop.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.KilledEnemySounds = "ZBaseMetrocop.KillEnemy" -- Sounds emitted when the NPC kills an enemy

-- Dialogue sounds
-- The NPCs will face each other as if they are talking
NPC.Dialogue_Question_Sounds = "ZBaseMetrocop.Question" -- Dialogue questions, emitted when the NPC starts talking to another NPC
NPC.Dialogue_Answer_Sounds = "ZBaseMetrocop.Answer" -- Dialogue answers, emitted when the NPC is spoken to

-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseMetrocop.HearSound"

NPC.FootStepSounds = "ZBaseMetrocop.Step" -- Footstep sound

NPC.HasZBaseManhackThrow = true

function NPC:CustomInitialize()
    -- 50% chance to spawn with manhack
    local Manhacks = math.random(0, 1)
    self:SetSaveValue("m_iManhacks", Manhacks)
    self:SetBodygroup(1, Manhacks)
end

function NPC:CustomOnParentedEntCreated( ent )
    -- Replace manhack toss with ZBase Viscerator NPC

    if ent:GetClass() != "npc_manhack" then return end
    if ent.IsZBaseNPC then return end -- Don't do this for the replacing manhack...

    if IsValid(self) && self.HasZBaseManhackThrow then
        local spawnflags = bit.bor(SF_NPC_WAIT_FOR_SCRIPT, SF_MANHACK_PACKED_UP, SF_MANHACK_CARRIED)
        local zbasehack = ZBaseNPCCopy( ent, "zb_manhack", false, ZBaseGetFaction(self), spawnflags, false )
        local att = self:LookupAttachment("LHand")

        if IsValid(zbasehack) && att && att > 0 then
            zbasehack:SetParent(self, att)
            zbasehack:SetOwner(self)
            self:PlayAnimation("deploy") -- Force play deploy animation
            self:SetSaveValue("m_hManhack", zbasehack)
        end
    end
end

function NPC:CustomOnSoundEmitted( sndData, duration, sndVarName )
    -- Radio sound

    if ShouldHaveRadioSound[sndVarName] then
        self:EmitSound("npc/metropolice/vo/on"..math.random(1, 2)..".wav")

        timer.Simple(duration, function()
            if !IsValid(self) then return end
            self:EmitSound("npc/metropolice/vo/off"..math.random(1, 4)..".wav")
        end)
    end
end

function NPC:ShouldGlowEyes()
    -- Glow eyes if option is on
    
    return ZBCVAR.MetroCopGlowEyes:GetBool()
end