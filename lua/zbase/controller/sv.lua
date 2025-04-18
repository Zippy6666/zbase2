util.AddNetworkString("ZBASE_Ctrlr_SlotBindPress")
util.AddNetworkString("ZBASE_Ctrlr_SetNameOnClient")
util.AddNetworkString("ZBASE_Ctrlr_UpdateNPCHealth")

local NPC           = FindMetaTable("NPC")
local developer     = GetConVar("developer")
local colDeb        = Color(0, 255, 0, 255)
local vecFarDown    = Vector(0,0,-10000)

local nextBind = {
    [IN_ATTACK]     = IN_ATTACK2,
    [IN_ATTACK2]    = "slot1",
    ["slot1"]       = "slot2",
    ["slot2"]       = "slot3",
    ["slot3"]       = "slot4",
    ["slot4"]       = "slot5",
    ["slot5"]       = "slot6",
    ["slot6"]       = "slot7",
    ["slot7"]       = "slot8",
    ["slot8"]       = "slot9"
}

local bindNames = {
    [IN_ATTACK]     = "PRIMARY KEY", 
    [IN_ATTACK2]    = "SECONDARY KEY",
    [IN_RELOAD]     = "RELOAD KEY",
    [IN_GRENADE1]   = "GRENADE1 KEY",
    ["slot1"]       = "SLOT 1",
    ["slot2"]       = "SLOT 2",
    ["slot3"]       = "SLOT 3",
    ["slot4"]       = "SLOT 4",
    ["slot5"]       = "SLOT 5",
    ["slot6"]       = "SLOT 6",
    ["slot7"]       = "SLOT 7",
    ["slot8"]       = "SLOT 8",
    ["slot9"]       = "SLOT 9"
}

local jumpPowerStats = {
    [HULL_TINY]         = 100,
    [HULL_WIDE_SHORT]   = 200,
    [HULL_HUMAN]        = 200,
    [HULL_WIDE_HUMAN]   = 300,
    [HULL_MEDIUM_TALL]  = 750,
    [HULL_LARGE]        = 750
}

ZBASE_CONTROLLER    = ZBASE_CONTROLLER or {}

--[[
=======================================================================================================
        START CONTROL
=======================================================================================================
]]--

function ZBASE_CONTROLLER:StartControlling( ply, npc )
    -- Valid checks
    if ply.ZBASE_Controller_Prevent then return end
    if npc.ZBASE_IsPlyControlled then return end
    if IsValid(ply.ZBASE_ControlledNPC) then return end

    -- This type of NPC cannot be controlled
    if !IsValid(npc) or !npc:IsNPC() or npc.IsVJBaseSNPC then
        conv.sendGModHint(ply, "Cannot control this entity!", 1, 2)
        return
    end

    -- Is guarding, cannot be controlled
    if npc.ZBase_Guard then
        conv.sendGModHint(ply, "NPCs with Guard Mode cannot be controlled!", 1, 2)
        return
    end

    -- Reset these vars
    -- These are checks that make sure that
    -- the routine for stopping NPC control isn't
    -- called multiple times
    npc.ZBASE_Controller_HasCleanedUp = nil
    ply.ZBASE_Controller_HasCleanedUp = nil

    -- Give player controller weapon if they don't already have it
    local wep = ply:GetWeapon("weapon_zb_controller")
    if !IsValid(wep) then
        wep = ply:Give("weapon_zb_controller")
    end
    if IsValid(wep) then
        ply:SetActiveWeapon(wep)
    end

    -- Define target entity that follows the player's cursor
    npc.ZBASE_ControlTarget = ents.Create("npc_bullseye")
    npc.ZBASE_ControlTarget:SetPos( npc:WorldSpaceCenter() )
    npc.ZBASE_ControlTarget:SetNotSolid(true)
    npc.ZBASE_ControlTarget:SetHealth(math.huge)
    npc.ZBASE_ControlTarget:Spawn()
    npc.ZBASE_ControlTarget:Activate()
    npc.ZBASE_ControlTarget:SetModel("models/props_junk/TrafficCone001a.mdl")
    npc.ZBASE_ControlTarget:SetNoDraw(false)
    if !developer:GetBool() then npc.ZBASE_ControlTarget:SetModelScale(0,0) end
    npc:SetNWEntity("ZBASE_ControlTarget", npc.ZBASE_ControlTarget)

    -- If target for some reason is removed
    -- Stop controlling to prevent undefined behavior
    npc.ZBASE_ControlTarget:CallOnRemove("ZBASE_Controller_Stop", function()
        self:StopControlling(ply, npc)
    end)

    -- Remove NPCs current enemies
    npc:SetEnemy(nil)
    npc:ClearEnemyMemory()

    -- Disable jump capability for NPC
    -- Jumping will be controlled manually by the player
    npc.ZBASE_HadJumpCap = npc:CONV_HasCapability(CAP_MOVE_JUMP)
    npc:CapabilitiesRemove(CAP_MOVE_JUMP)

    -- NPC hooks/vars
    npc:CONV_AddHook("Think", npc.ZBASE_ControllerThink, "ZBASE_Controller_Think")
    npc:CONV_AddHook("EntityTakeDamage", function(_, trgt, dmg)
        net.Start("ZBASE_Ctrlr_UpdateNPCHealth")
        net.WriteUInt(npc:Health(), 16)
        net.Send(ply)
    end, "ZBASE_Controller_UpdateHealth")
    npc.ZBASE_IsPlyControlled   = true
    npc.ZBASE_PlyController     = ply
    if npc.IsZBaseNPC then
        npc.bControllerBlock  = true -- Prevents ZBase NPCs from doing built in attacks
    end
    npc:CallOnRemove("ZBASE_Controller_Stop", function()
        self:StopControlling(ply, npc)
    end)

    -- Player variables
    ply.ZBASE_ControlledNPC = npc
    ply.ZBASE_LastMoveType = ply:GetMoveType()
    ply.ZBASE_HPBeforeControl = ply:Health()
    ply.ZBASE_MaxHPBeforeControl = ply:GetMaxHealth()
    ply.ZBASE_ControllerCamUp = 0
    ply.ZBASE_ControllerCamRight = 0
    ply.ZBASE_ControllerZoomDist = ply.ZBASE_ControllerZoomDist or 0
    ply:SetNoTarget(true)
    ply:SetMoveType(MOVETYPE_NONE)
    ply:SetNotSolid(true)
    ply:SetNoDraw(true)
    ply.ZBASE_Controller_wepLast = ply:GetActiveWeapon()
    ply:Flashlight(false)
    ply:AllowFlashlight(false)
    ply:CONV_AddHook("EntityTakeDamage", function(_, trgt, dmg)
        if trgt == ply then
            return true
        end
    end, "ZBASE_Controller_PlyGodMode")
    ply:SetNWEntity("ZBASE_ControllerCamEnt", npc)

    -- Initialize controls for attacks
    npc:ZBASE_Controller_InitAttacks()

    -- Give NPC its name on client so that it can be shown on the hud
    net.Start("ZBASE_Ctrlr_SetNameOnClient")
    net.WriteString( hook.Run("GetDeathNoticeEntityName", npc) )
    net.Send(ply)

    -- Also give the lastest most updated health
    net.Start("ZBASE_Ctrlr_UpdateNPCHealth")
    net.WriteUInt(npc:Health(), 16)
    net.Send(ply)

    conv.sendGModHint(ply, "Press your NOCLIP key to stop controlling.", 3, 4)
end

--[[
=======================================================================================================
        MOVEMENT
=======================================================================================================
]]--

-- Move NPC to pos
function NPC:ZBASE_Controller_Move( pos )
    local tr = util.TraceLine({
        start = self:WorldSpaceCenter(),
        endpos = pos,
        mask = MASK_SOLID,
        filter = {self, self.ZBASE_PlyController},
    })

    -- Calculate current dest
    dest = tr.HitPos+tr.HitNormal*35
    self.ZBASE_CurCtrlDest = (self.ZBASE_CurCtrlDest && Lerp(0.33, self.ZBASE_CurCtrlDest, dest)) or dest

    if self.IsZBaseNPC && self.SNPCType == ZBASE_SNPCTYPE_FLY then
        -- Is ZBASE flyer, do special move
        self:AerialCalcGoal(dest)

    else
        local ply = self.ZBASE_PlyController
        local bInSpeedDown = ply:KeyDown(IN_SPEED)

        self:SetLastPosition( self.ZBASE_CurCtrlDest )
        self:SetSchedule(bInSpeedDown && SCHED_FORCED_GO_RUN or SCHED_FORCED_GO)
        self:CONV_TempVar("bControllerMoving", true, 0.2)

        ply.ZBASE_Controller_LastMoveWasSprint = bInSpeedDown
    end
end

function NPC:ZBASE_Controller_Jump(dir)
    -- Antlion stuff
    local cls = self:GetClass()
    if cls == "npc_antlion" or cls == "npc_antlionworker" then
        local start = self:WorldSpaceCenter()+self:GetForward()*500
        local tr = util.TraceLine({
            start = start,
            endpos = start+vecFarDown,
            mask = MASK_NPCWORLDSTATIC
        })

        local tempent = ents.Create("zb_temporary_ent")
        tempent.ShouldRemain = true
        tempent:SetPos(tr.HitPos+tr.HitNormal*250)
        tempent:SetName("zbase_antlion_jump_target_for_"..self:EntIndex())
        tempent:SetNoDraw(true)
        tempent:Spawn()
        self:Fire("JumpAtTarget", "zbase_antlion_jump_target_for_"..self:EntIndex())
        SafeRemoveEntityDelayed(tempent, 0.1)
        return
    end

    local jumpPower = self:ZBASE_Controller_GetJumpStats()
    local jumpVec = dir*jumpPower
    ZBaseMoveJump(self, self:WorldSpaceCenter()+jumpVec+self:GetMoveVelocity())

    self:CONV_TempVar("ZBASE_Controller_JumpOnCooldown", true, 2)
end

function NPC:ZBASE_Controller_GetJumpStats()
    if self.Controller_JumpPower && self.Controller_JumpPower > 0 then return self.Controller_JumpPower end

    local jumpPower = jumpPowerStats[self:GetHullType()]

    if !jumpPower then
        return jumpPowerStats[HULL_HUMAN]
    end

    return jumpPower
end

--[[
=======================================================================================================
        CONTROLS
=======================================================================================================
]]--

function NPC:ZBASE_Controller_TargetBullseye(bShould)
    if bShould == true then
        -- Clear ene memory first
        self:SetEnemy(nil)
        self:ClearEnemyMemory()

        -- Ensure we hate cursor target bullseye thingy
        self:AddEntityRelationship(self.ZBASE_ControlTarget, D_HT, 0)

        -- Set to enemy
        self:UpdateEnemyMemory(self.ZBASE_ControlTarget, self.ZBASE_ControlTarget:GetPos())
    elseif bShould == false then
        -- Clear ene memory
        self:SetEnemy(nil)
        self:ClearEnemyMemory()
        self:SetNPCState(NPC_STATE_ALERT)

        -- Start liking bullseye target again
        self:AddEntityRelationship(self.ZBASE_ControlTarget, D_LI, 0)
    end
end

function NPC:ZBASE_Controller_InitAttacks()
    local initmsg = "------------- Controls -------------"
    local ply = self.ZBASE_PlyController

    ply:PrintMessage(HUD_PRINTTALK, string.upper(initmsg))

    if self.IsZBaseNPC then
        -- Check for attacks here
        -- Also add a CustomControllerInitAttacks so that developers can add their own

        -- If ZBase NPC can use weapons
        if self:CONV_HasCapability(CAP_USE_WEAPONS) then
            -- Weapon attack
            self:ZBASE_ControllerAddAttack(
                function()
                    if self.ZBWepSys_PrimaryAmmo <= 0 then
                        ply:PrintMessage(HUD_PRINTTALK, "Out of ammo!")
                        ply:EmitSound("Weapon_Pistol.Empty")
                        return
                    end

                    self.ZBASE_bControllerShoot = true
                    self:ZBASE_Controller_TargetBullseye(true)
                end,

                function()
                    self.ZBASE_bControllerShoot = false
                    self:ZBASE_Controller_TargetBullseye(false)
                end,
            nil, "Fire Weapon")

            -- Secondary weapon attack
            if self.CanSecondaryAttack then
                self:ZBASE_ControllerAddAttack(
                    function()
                        self:ZBASE_Controller_TargetBullseye(true)

                        if self.AltCount <= 0 && self.AltCount != -1 then
                            ply:PrintMessage(HUD_PRINTTALK, "Out of secondary ammo!")
                            ply:EmitSound("Weapon_AR2.Empty")
                            return
                        end

                        self:CONV_TimerSimple(0.25, function() 
                            self:ControllerSecondaryAttack() 
                            self:ZBASE_Controller_TargetBullseye(false)
                        end)
                    end,
                nil, nil, "Secondary Weapon Attack (if any)")
            end

            -- Reload ability
            self:ZBASE_ControllerAddAttack(function()
                local wep = self:GetActiveWeapon()

                if !wep.IsZBaseWeapon then return end

                if self.ZBWepSys_PrimaryAmmo >= wep.Primary.DefaultClip then
                    return
                end

                self:SetSchedule(SCHED_RELOAD)
            end, nil, IN_RELOAD, "Reload")
        end

        -- Grenade attack control
        if self.BaseGrenadeAttack then
            self:ZBASE_ControllerAddAttack(function()
                if self.ZBASE_Ctrlr_Grenading then return end

                if self.GrenCount <= 0 then
                    ply:PrintMessage(HUD_PRINTTALK, "No grenades left!")
                    return
                end

                self.ZBASE_Ctrlr_Grenading = true

                self:ZBASE_Controller_TargetBullseye(true)

                self:CONV_TimerSimple(0.25, function()
                    self:ThrowGrenade()
                end)

                self:CONV_TimerSimple(2, function()
                    self:ZBASE_Controller_TargetBullseye(false)
                    self.ZBASE_Ctrlr_Grenading = nil
                end)
            end, 
            nil, IN_GRENADE1, "Throw Grenade")
        end
    end

    -- Lastly, add free attack
    self:ZBASE_ControllerAddAttack(
        function()
            self.ZBASE_Controller_FreeAttacking = true
            self.bControllerBlock = nil
            self:ZBASE_Controller_TargetBullseye(true)
        end,

        function()
            self.ZBASE_Controller_FreeAttacking = nil
            if self.IsZBaseNPC then self.bControllerBlock = true end
            self:ZBASE_Controller_TargetBullseye(false)
        end
    , nil, "Free Attack")

    self.ZBASE_ControlLastBind = nil -- Reset until next time controls are setup

    ply:PrintMessage(HUD_PRINTTALK, "------------------------------------------------------------")
end

function NPC:ZBASE_Controller_KeyPress(ply, key)
    if !self.ZBASE_Controls then return end
    if !self.ZBASE_Controls[key] then return end
    if !self.ZBASE_Controls[key].pressFunc then return end

    self.ZBASE_Controls[key].pressFunc()
end

function NPC:ZBASE_Controller_KeyRelease(ply, key)
    if !self.ZBASE_Controls then return end
    if !self.ZBASE_Controls[key] then return end
    if !self.ZBASE_Controls[key].releaseFunc then return end

    self.ZBASE_Controls[key].releaseFunc()
end

hook.Add("KeyPress", "ZBASE_CONTROLLER", function(ply, key)
    if IsValid(ply.ZBASE_ControlledNPC) then
        ply.ZBASE_ControlledNPC:ZBASE_Controller_KeyPress(ply, key)
    end
end)

hook.Add("KeyRelease", "ZBASE_CONTROLLER", function(ply, key)
    if IsValid(ply.ZBASE_ControlledNPC) then
        ply.ZBASE_ControlledNPC:ZBASE_Controller_KeyRelease(ply, key)
    end
end)

net.Receive("ZBASE_Ctrlr_SlotBindPress", function(_, ply)
    if !ply:IsAdmin() then return end

    local slotnum   = net.ReadUInt(4)
    local press     = net.ReadBool()
    local slot      = "slot"..slotnum

    if press == true then
        ply.ZBASE_ControlledNPC:ZBASE_Controller_KeyPress(ply, slot)
    else
        ply.ZBASE_ControlledNPC:ZBASE_Controller_KeyRelease(ply, slot)
    end
end)

function NPC:ZBASE_ControllerAddAttack(pressFunc, releaseFunc, optionalBind, attackName)
    local ply = self.ZBASE_PlyController
    
    self.ZBASE_Controls = self.ZBASE_Controls or {}

    self.ZBASE_ControlLastBind = self.ZBASE_ControlLastBind or IN_ATTACK
    self.ZBASE_Controls[optionalBind or self.ZBASE_ControlLastBind] = {pressFunc=pressFunc, releaseFunc=releaseFunc}

    local bindName = bindNames[optionalBind or self.ZBASE_ControlLastBind] or "nil"
    ply:PrintMessage(
        HUD_PRINTTALK, 
        "["..bindName.."] "..attackName
    )

    if !optionalBind then
        self.ZBASE_ControlLastBind = nextBind[self.ZBASE_ControlLastBind]

        if self.ZBASE_ControlLastBind == nil then
            error("Cannot add any more controller attacks, limit reached!")
        end
    end
end

--[[
=======================================================================================================
        THINK
=======================================================================================================
]]--

function NPC:ZBASE_ControllerThink()
    if self.ZBASE_NextCtrlrThink && self.ZBASE_NextCtrlrThink > CurTime() then return end

    -- Checks
    local ply = self.ZBASE_PlyController
    if !IsValid(ply) then
        ZBASE_CONTROLLER:StopControlling(NULL, self)
        return
    end
    local wep = ply:GetActiveWeapon()
    if !IsValid(wep) or wep:GetClass() != "weapon_zb_controller" then
        ZBASE_CONTROLLER:StopControlling(ply, self)
        return
    end

    -- Position player at NPC
    ply:SetPos(self:GetPos())

    -- Mimic health
    -- ply:SetHealth(self:Health())
    -- ply:SetMaxHealth(self:GetMaxHealth())

    -- Vars
    local eyeangs   = ply:EyeAngles()
    local forward   = eyeangs:Forward()
    local right     = eyeangs:Right()
    local up        = Vector(0, 0, 1)
    local viewpos   = ZBASE_CONTROLLER:GetViewPos(ply, forward)
    local bForceMv  = true

    -- Camera tracer
    if viewpos then
        local tr = util.TraceLine({
            start = viewpos,
            endpos = viewpos+forward*100000,
            mask = MASK_VISIBLE_AND_NPCS,
            filter = self,
        })
        -- The controller "target"
        if IsValid(self.ZBASE_ControlTarget) then
            -- Position target at cursor
            self.ZBASE_ControlTarget:SetPos(tr.HitPos+tr.HitNormal*3)
        end
    end

    -- Delay hearing so we are temporarily deaf while being controlled
    self.NextHearSound = CurTime()+1

    if self.ZBASE_Controller_FreeAttacking then
        -- Don't mess with NPC movement
        -- Just let it do its own thing while
        -- free attacking
        bForceMv = false

        -- Give back move cap if any
        if self.ZBASE_CtrlrDetected_CAP_MOVE then
            self:CapabilitiesAdd(CAP_MOVE_GROUND)
            self.ZBASE_CtrlrDetected_CAP_MOVE = nil
        end
    end

    if bForceMv then
        -- Force the NPC to move like the player wants
        -- Also stand still if the player does not do anything

        -- Decide move direction
        local moveDir = Vector(0, 0, 0)
        if ply:KeyDown(IN_FORWARD) then
            moveDir = moveDir + Vector(forward.x, forward.y, 0):GetNormalized()
        end
        if ply:KeyDown(IN_BACK) then
            moveDir = moveDir - Vector(forward.x, forward.y, 0):GetNormalized()
        end
        if ply:KeyDown(IN_MOVELEFT) then
            moveDir = moveDir - Vector(right.x, right.y, 0):GetNormalized()
        end
        if ply:KeyDown(IN_MOVERIGHT) then
            moveDir = moveDir + Vector(right.x, right.y, 0):GetNormalized()
        end
        if ply:KeyDown(IN_JUMP) then
            moveDir = moveDir + up
        end
        if ply:KeyDown(IN_DUCK) then
            moveDir = moveDir - up
        end
        local bPlyWantToMoveNPC = !moveDir:IsZero()

        if bPlyWantToMoveNPC then
            moveDir = moveDir:GetNormalized() -- Normalize the accumulated movement direction

            if self.ZBASE_CtrlrDetected_CAP_MOVE then
                self:CapabilitiesAdd(CAP_MOVE_GROUND)
                self.ZBASE_CtrlrDetected_CAP_MOVE = nil
            end

            local destDist = self:OBBMaxs().x+200
            local moveVec = moveDir*destDist

            if self:IsOnGround() or self:CONV_HasCapability(CAP_MOVE_FLY) or self:GetNavType()==NAV_FLY then
                if ply:KeyDown(IN_JUMP) && self:SelectWeightedSequence(ACT_JUMP) != -1 && !self.ZBASE_Controller_JumpOnCooldown then
                    self:ZBASE_Controller_Jump(moveDir)
                else
                    -- Moving
                    self:ZBASE_Controller_Move(self:WorldSpaceCenter()+moveVec)
                end
            end
        else
            -- Be still when should not move

            if self:CONV_HasCapability(CAP_MOVE_GROUND) then
                -- Stopped moving so remove ground capabilities and clear goal etc
                self:CapabilitiesRemove(CAP_MOVE_GROUND)
                self.ZBASE_CtrlrDetected_CAP_MOVE = true
                self:ClearGoal()
                self:TaskComplete()
                self:ClearSchedule()
            end
        end
    end

    self.ZBASE_NextCtrlrThink = CurTime()+0.1
end

--[[
=======================================================================================================
        END CONTROLLING
=======================================================================================================
]]--

-- Noclipping causes controlling to stop
hook.Add("PlayerNoClip", "ZBASE_CONTROLLER", function(ply, desiredState)
    if IsValid(ply.ZBASE_ControlledNPC) then
        ZBASE_CONTROLLER:StopControlling(ply, ply.ZBASE_ControlledNPC)
    end
    return true
end)

function ZBASE_CONTROLLER:StopControlling( ply, npc )
    if IsValid(npc) && !npc.ZBASE_Controller_HasCleanedUp then
        if npc.ZBASE_HadJumpCap then
            npc:CapabilitiesAdd(CAP_MOVE_JUMP)
        end
        if npc.ZBASE_CtrlrDetected_CAP_MOVE then
            npc:CapabilitiesAdd(CAP_MOVE_GROUND)
            npc.ZBASE_CtrlrDetected_CAP_MOVE = nil
        end

        npc.ZBASE_IsPlyControlled  = nil
        npc.ZBASE_PlyController  = nil
        npc.ZBASE_HadJumpCap = nil
        npc.ZBASE_Controls = nil
        npc.ZBASE_Controller_FreeAttacking = nil
        npc.ZBASE_NextCtrlrThink = nil
        npc.bControllerBlock = nil
        npc:SetMoveYawLocked(false)
        npc:SetNWEntity("ZBASE_ControlTarget", NULL)

        SafeRemoveEntity(npc.ZBASE_ControlTarget)

        npc:CONV_RemoveHook("Think", "ZBASE_Controller_Think")
        npc:CONV_RemoveHook("EntityTakeDamage", "ZBASE_Controller_UpdateHealth")
        npc:RemoveCallOnRemove("ZBASE_Controller_Stop")

        if IsValid(npc.ZBASE_ControlTarget) then
            npc.ZBASE_ControlTarget:RemoveCallOnRemove("ZBASE_Controller_Stop")
        end

        npc.ZBASE_Controller_HasCleanedUp = true
    end
 
    if IsValid(ply) && !ply.ZBASE_Controller_HasCleanedUp then
        ply:SetNWEntity("ZBASE_ControllerCamEnt", NULL)
        ply:SetMoveType(MOVETYPE_WALK)
        ply:SetNoTarget(false)
        ply:SetNotSolid(false)
        ply:SetNoDraw(false)
        ply:SetHealth(ply.ZBASE_HPBeforeControl or 100)
        ply:SetMaxHealth(ply.ZBASE_MaxHPBeforeControl or 100)
        ply:AllowFlashlight(true)
        ply.ZBASE_ControlledNPC = nil
        ply:CONV_RemoveHook("EntityTakeDamage", "ZBASE_Controller_PlyGodMode")
        ply:CONV_TempVar("ZBASE_Controller_Prevent", true, 2)
        ply.ZBASE_Controller_HasCleanedUp = true
    end
end