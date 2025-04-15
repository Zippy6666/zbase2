--[[
==================================================================================================
                                    PLAYER CONTROL SYSTEM
    >> Control Priority Sys <<
    First two controls are left and right click, the rest are gonna be 1, 2, 3, 4, 5, and so on.
    1. Use weapon
    2. Fire secondary
    3. Range attack
    4. Melee attack
    5. Grenade attack
    6. User defined attacks
    7. "Free attack"
==================================================================================================
--]]

util.AddNetworkString("ZBASE_ControllerUpdateZoomOnServer")

local NPC           = FindMetaTable("NPC")
local developer     = GetConVar("developer")
local colDeb        = Color(0, 255, 0, 255)
local vecFarDown    = Vector(0,0,-10000)

local jumpPowerStats = {
    [HULL_TINY]         = 100,
    [HULL_WIDE_SHORT]   = 200,
    [HULL_HUMAN]        = 200,
    [HULL_WIDE_HUMAN]   = 300,
    [HULL_MEDIUM_TALL]  = 750,
    [HULL_LARGE]        = 750
}

ZBASE_CONTROLLER    = ZBASE_CONTROLLER or {}

function ZBASE_CONTROLLER:StartControlling( ply, npc )
    if npc.ZBASE_IsPlyControlled then return end
    if IsValid(ply.ZBASE_ControlledNPC) then return end

    if !IsValid(npc) or !npc:IsNPC() or npc.IsVJBaseSNPC then
        conv.sendGModHint(ply, "Cannot control this entity!", 1, 2)
        return
    end

    if npc.ZBase_Guard then
        conv.sendGModHint(ply, "NPCs with Guard Mode cannot be controlled!", 1, 2)
        return
    end

    local wep = ply:GetWeapon("weapon_zb_controller")
    if !IsValid(wep) then
        wep = ply:Give("weapon_zb_controller")
    end
    if IsValid(wep) then
        ply:SetActiveWeapon(wep)
    end

    npc.ZBASE_IsPlyControlled = true
    npc.ZBASE_PlyController  =  ply

    -- Only target the target which will follow the players cursor
    npc.ZBASE_ControlTarget = ents.Create("npc_bullseye")
    npc.ZBASE_ControlTarget:SetPos( npc:WorldSpaceCenter() )
    npc.ZBASE_ControlTarget:SetNotSolid(true)
    npc.ZBASE_ControlTarget:SetHealth(math.huge)
    npc.ZBASE_ControlTarget:Spawn()
    npc.ZBASE_ControlTarget:Activate()

    if developer:GetBool() then
        npc.ZBASE_ControlTarget:SetModel("models/props_combine/breenbust.mdl")
        npc.ZBASE_ControlTarget:SetMaterial("models/wireframe")
        npc.ZBASE_ControlTarget:SetNoDraw(false)
        npc.ZBASE_ControlTarget:DrawShadow(false)
    end

    npc:SetEnemy(nil)
    npc:ClearEnemyMemory()

    -- npc.ZBASE_ViewEnt = ents.Create("zb_temporary_ent")
    -- npc.ZBASE_ViewEnt.ShouldRemain = true
    -- npc.ZBASE_ViewEnt:SetPos( npc:GetPos() )
    -- npc.ZBASE_ViewEnt:SetAngles(npc:GetAngles())
    -- npc.ZBASE_ViewEnt:SetParent(npc)
    -- npc.ZBASE_ViewEnt:SetNoDraw(true)
    -- npc.ZBASE_ViewEnt:Spawn()

    -- npc:DeleteOnRemove(npc.ZBASE_ViewEnt)
    ply:SetNW2Entity("ZBASE_ControllerCamEnt", npc)

    -- Disable jump capability for NPC
    npc.ZBASE_HadJumpCap = npc:CONV_HasCapability(CAP_MOVE_JUMP)
    npc:CapabilitiesRemove(CAP_MOVE_JUMP)

    -- Player variables
    ply.ZBASE_ControlledNPC = npc
    ply.ZBASE_LastMoveType = ply:GetMoveType()
    ply.ZBASE_HPBeforeControl = ply:Health()
    ply.ZBASE_MaxHPBeforeControl = ply:GetMaxHealth()
    ply:SetNoTarget(true)
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply:SetNotSolid(true)
    ply:SetNoDraw(true)
    ply.ZBASE_Controller_wepLast = ply:GetActiveWeapon()
    ply:Flashlight(false)
    ply:AllowFlashlight(false)

    npc:CONV_AddHook("Think", npc.ZBASE_ControllerThink, "ZBASE_Controller_Think")
    ply:CONV_AddHook("EntityTakeDamage", function() return true end, "ZBASE_Controller_PlyGodMode")

    -- If the NPC is removed the controlling should also stop
    npc:CallOnRemove("StopControllingZB", function()
        self:StopControlling(ply, npc)
    end)

    conv.sendGModHint(ply, "Press your NOCLIP key to stop controlling.", 3, 2)
end

function NPC:ZBASE_Controller_Move( pos )
    -- Move to pos
    local tr = util.TraceLine({
        start = self:WorldSpaceCenter(),
        endpos = pos,
        mask = MASK_SOLID,
        filter = {self, self.ZBASE_PlyController},
    })
    dest = tr.HitPos+tr.HitNormal*35
    self.ZBASE_CurCtrlDest = (self.ZBASE_CurCtrlDest && Lerp(0.33, self.ZBASE_CurCtrlDest, dest)) or dest

    if self.IsZBaseNPC && self.SNPCType == ZBASE_SNPCTYPE_FLY then
        self:AerialCalcGoal(dest)
    else
        self:SetLastPosition( self.ZBASE_CurCtrlDest )
        self:SetSchedule(self.ZBASE_PlyController:KeyDown(IN_SPEED) && SCHED_FORCED_GO_RUN or SCHED_FORCED_GO)
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

function NPC:ZBASE_Controller_ButtonDown(ply, btn)
    if !self.ZBASE_Controls then return end
end

function NPC:ZBASE_Controller_KeyPress(ply, key)
end

hook.Add("PlayerButtonDown", "ZBASE_CONTROLLER", function(ply, btn)
    if IsValid(ply.ZBASE_ControlledNPC) then
        ply.ZBASE_ControlledNPC:ZBASE_Controller_ButtonDown(ply, btn)
    end
end)

hook.Add("KeyPress", "ZBASE_CONTROLLER", function(ply, key)
    if IsValid(ply.ZBASE_ControlledNPC) then
        ply.ZBASE_ControlledNPC:ZBASE_Controller_KeyPress(ply, key)
    end
end)

hook.Add("PlayerInitialSpawn", "ZBASE_CONTROLLER", function(ply, bIsTransition)
    ply.ZBASE_ControllerZoomDist = 0
end)

net.Receive("ZBASE_ControllerUpdateZoomOnServer", function(_, ply)
    ply.ZBASE_ControllerZoomDist = net.ReadInt(11)
end)

-- function NPC:ZBASE_ControllerAddAttack(pressFunc, releaseFunc)
--     self.ZBASE_Controls = self.ZBASE_Controls or {}
--     self.ZBASE_ControlLastBind = self.ZBASE_ControlLastBind or IN_ATTACK
--     self.ZBASE_Controls[self.ZBASE_ControlLastBind] = {pressFunc=pressFunc, releaseFunc=releaseFunc}
--     self.ZBASE_ControlLastBind = nextBind[self.ZBASE_ControlLastBind]
-- end

function NPC:ZBASE_ControllerThink()
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
    ply:SetHealth(self:Health())
    ply:SetMaxHealth(self:GetMaxHealth())

    -- Vars
    local eyeangs   = ply:EyeAngles()
    local viewpos   = ZBASE_CONTROLLER:GetViewPos(ply)
    local forward   = eyeangs:Forward()
    local right     = eyeangs:Right()
    local up        = Vector(0, 0, 1)

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
            self.ZBASE_ControlTarget:SetPos(camTrace.HitPos+camTrace.HitNormal*5)
        end
    end
    
    -- Delay hearing so we are temporarily deaf while being controlled
    self.NextHearSound = CurTime()+1

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
    moveDir = moveDir:GetNormalized() -- Normalize the accumulated movement direction

    local moveVec = moveDir*(self:OBBMaxs().x+100)
    if self:IsOnGround() or self:CONV_HasCapability(CAP_MOVE_FLY) or self:GetNavType()==NAV_FLY then
        if ply:KeyDown(IN_JUMP) && self:SelectWeightedSequence(ACT_JUMP) != -1 && !self.ZBASE_Controller_JumpOnCooldown then
            self:ZBASE_Controller_Jump(moveDir)
        else
            -- Moving
            self:ZBASE_Controller_Move(self:WorldSpaceCenter()+moveVec)
        end
    end

    if moveDir:IsZero() then
        self:SetMoveYawLocked(true) -- Face same direction if not moving
    else
        self:CONV_TempVar("ZBASE_ControllerMoving", true, 0.1)
        self:SetMoveYawLocked(false)
    end

    if self.ZBASE_CurCtrlDest then
        debugoverlay.Sphere(self.ZBASE_CurCtrlDest, 10, 0.05, colDeb, true)
    end
end

-- Noclipping causes controlling to stop
hook.Add("PlayerNoClip", "ZBASE_CONTROLLER", function(ply, desiredState)
    if IsValid(ply.ZBASE_ControlledNPC) then
        ZBASE_CONTROLLER:StopControlling(ply, ply.ZBASE_ControlledNPC)
    end
    return true
end)

function ZBASE_CONTROLLER:StopControlling( ply, npc )
    if IsValid(npc) then
        if npc.ZBASE_HadJumpCap then
            npc:CapabilitiesAdd(CAP_MOVE_JUMP)
        end

        -- npc:SetSaveValue( "m_flFieldOfView", npc.FieldOfView )
        npc.ZBASE_IsPlyControlled  = false
        npc.ZBASE_PlyController  = nil
        npc.ZBASE_HadJumpCap = nil
        npc.ZBASE_Controls = nil
        npc:SetMoveYawLocked(false)

        -- SafeRemoveEntity(npc.ZBASE_ViewEnt)
        SafeRemoveEntity(npc.ZBASE_ControlTarget)

        npc:CONV_RemoveHook("Think", "ZBASE_Controller_Think")
    end
 
    if IsValid(ply) then
        ply:SetNW2Entity("ZBASE_ControllerCamEnt", NULL)
        ply:SetMoveType(MOVETYPE_WALK)
        ply:SetNoTarget(false)
        ply:SetNotSolid(false)
        ply:SetNoDraw(false)
        ply:SetHealth(ply.ZBASE_HPBeforeControl)
        ply:SetMaxHealth(ply.ZBASE_MaxHPBeforeControl)
        ply:AllowFlashlight(true)
        ply.ZBASE_ControlledNPC = nil
        ply:CONV_RemoveHook("Think", "ZBASE_Controller_PlyGodMode")
    end
end