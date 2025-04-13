--[[
==================================================================================================
                                    PLAYER CONTROL SYSTEM
    >> TODO <<
    - Space -> fly up, otherwise jump
    - Ctrl -> fly down
    - Control priority system
    - Some way to get control help, with hints i guess
    - Just make it feel good


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

local NPC           = FindMetaTable("NPC")
local developer     = GetConVar("developer")
local colDeb        = Color(0, 255, 0, 255)
ZBASE_CONTROLLER    = ZBASE_CONTROLLER or {}

function ZBASE_CONTROLLER:StartControlling( ply, npc )
    if npc.ZBase_Guard then
        conv.sendGModHint(ply, "NPCs with Guard Mode cannot be controlled!", 1, 2)
        return
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

    npc:ClearEnemyMemory()
    self:UpdateRel()

    -- Setup camera
    npc.ZBViewEnt = ents.Create("zb_temporary_ent")
    npc.ZBViewEnt.ShouldRemain = true
    npc.ZBViewEnt:SetPos( npc:GetPos() )
    npc.ZBViewEnt:SetAngles(npc:GetAngles())
    npc.ZBViewEnt:SetParent(npc)
    npc.ZBViewEnt:SetNoDraw(true)
    npc.ZBViewEnt:Spawn()

    npc:DeleteOnRemove(npc.ZBViewEnt)
    ply:SetNWEntity("ZBASE_CONTROLLERCamEnt", npc)

    -- Disable jump capability for NPC
    npc.ZBASE_HadJumpCap = npc:CONV_HasCapability(CAP_MOVE_JUMP)
    npc:CapabilitiesRemove(CAP_MOVE_JUMP)

    -- Player variables
    ply.ZBASE_ControlledNPC = npc
    ply.ZBASE_LastMoveType = ply:GetMoveType()
    ply:SetNoTarget(true)
    ply:SetMoveType(MOVETYPE_NONE)

    npc:CONV_AddHook("Think", npc.ZBASE_ControllerThink, "ZBASE_Controller_Think")
    
    -- Undo stops controlling
    undo.Create("ZBase Control")
    undo.SetPlayer(ply)
    undo.AddFunction(function() self:StopControlling( ply, npc ) end)
    undo.SetCustomUndoText( "Stopped Controlling ".. hook.Run("GetDeathNoticeEntityName", npc) )
    undo.Finish()

    -- If the NPC is removed the controlling should also stop
    npc:CallOnRemove("StopControllingZB", function()
        self:StopControlling(ply, npc)
    end)
end

function ZBASE_CONTROLLER:StopControlling( ply, npc )
    if IsValid(npc) then
        if npc.ZBASE_HadJumpCap then
            npc:CapabilitiesAdd(CAP_MOVE_JUMP)
        end

        -- npc:SetSaveValue( "m_flFieldOfView", npc.FieldOfView )
        npc.ZBASE_IsPlyControlled  = false
        npc.ZBASE_PlyController  = nil
        ply.ZBASE_ControlledNPC = nil
        npc.ZBASE_HadJumpCap = nil

        SafeRemoveEntity(npc.ZBViewEnt)
        SafeRemoveEntity(npc.ZBASE_ControlTarget)
    end

    if IsValid(ply) then
        ply:SetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)
        ply:SetMoveType(ply.ZBASE_LastMoveType)
        ply:SetNoTarget(false)
    end

    npc:CONV_RemoveHook("Think", "ZBASE_Controller_Think")

    self:UpdateRel()
end

function ZBASE_CONTROLLER:UpdateRel()
    for _, v in ipairs(ZBaseNPCInstances) do
        v:UpdateRelationships()
    end
end

hook.Add("PlayerButtonDown", "ZBASE_CONTROLLER", function(ply, btn)
    if IsValid(ply.ZBASE_ControlledNPC) then
        ply.ZBASE_ControlledNPC:Controller_ButtonDown(ply, btn)
    end
end)

hook.Add("KeyPress", "ZBASE_CONTROLLER", function(ply, key)
    if IsValid(ply.ZBASE_ControlledNPC) then
        ply.ZBASE_ControlledNPC:Controller_KeyPress(ply, key)
    end
end)

function NPC:ZBASE_Controller_Move( pos )
    -- Move to pos
    local tr = util.TraceLine({
        start = self:WorldSpaceCenter(),
        endpos = pos,
        mask = MASK_SOLID,
        filter = self,
    })
    dest = tr.HitPos+tr.HitNormal*35
    self.ZBASE_CurCtrlDest = (self.ZBASE_CurCtrlDest && Lerp(0.33, self.ZBASE_CurCtrlDest, dest)) or dest
    self:SetLastPosition( self.ZBASE_CurCtrlDest )
    self:SetSchedule(self.ZBASE_PlyController:KeyDown(IN_SPEED) && SCHED_FORCED_GO_RUN or SCHED_FORCED_GO)

    debugoverlay.Sphere(self.ZBASE_CurCtrlDest, 10, 0.05, colDeb, true)
end

function NPC:ZBASE_Controller_ButtonDown(ply, btn)
end

function NPC:ZBASE_Controller_KeyPress(ply, key)
end

function NPC:ZBASE_ControllerThink()
    local ply       = self.ZBASE_PlyController
    local eyeangs   = ply:EyeAngles()
    local forward   = eyeangs:Forward()
    local right     = eyeangs:Right()

    local camEnt = ply:GetNWEntity("ZBASE_CONTROLLERCamEnt", NULL)
    if !IsValid(camEnt) then return end

    -- Camera tracer
    -- local camViewPos = camEnt:GetPos()
    -- local camTrace = util.TraceLine({
    --     start = camViewPos,
    --     endpos = camViewPos+forward*100000,
    --     mask = MASK_VISIBLE_AND_NPCS,
    --     filter = self,
    -- })
    -- print(camTrace.Entity)
    -- -- The controller "target"
    -- if IsValid(self.ZBASE_ControlTarget) then
    --     -- Position target at cursor
    --     self.ZBASE_ControlTarget:SetPos(camTrace.HitPos+camTrace.HitNormal*5)

    --     -- Be enemy to target
    --     if !IsValid(self:GetEnemy()) then
    --         self:AddEntityRelationship(self.ZBASE_ControlTarget, D_HT, 0)
    --         self:UpdateEnemyMemory(self.ZBASE_ControlTarget, camTrace.HitPos+camTrace.HitNormal*5)
    --         self:SetEnemy(self.ZBASE_ControlTarget)
    --         self:SetUnforgettable( self.ZBASE_ControlTarget )
    --     end
    -- end

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
    moveDir = moveDir:GetNormalized() -- Normalize the accumulated movement direction

    -- Move
    self:ZBASE_Controller_Move(self:WorldSpaceCenter() + moveDir*(self:OBBMaxs().x+100))
end