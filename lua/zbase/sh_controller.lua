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


-- function NPC:Controller_Move( pos )

--     -- Move to pos
--     local tr = util.TraceLine({
--         start = self:WorldSpaceCenter(),
--         endpos = pos,
--         mask = MASK_SOLID,
--         filter = self,
--     })
--     dest = tr.HitPos+tr.HitNormal*15
--     self.CurrentControlDest = (self.CurrentControlDest && Lerp(0.33, self.CurrentControlDest, dest)) or dest
--     self:SetLastPosition( self.CurrentControlDest )
--     self:SetSchedule(SCHED_FORCED_GO)

--     -- Decide movement act
--     if !self.MovementOverrideActive then
--         self:SetMovementActivity(self.ZBPlyController:KeyDown(IN_SPEED) && ACT_RUN or ACT_WALK)
--     end

-- end


-- function NPC:Controller_ButtonDown(ply, btn)
-- end


-- function NPC:Controller_KeyPress(ply, key)
-- end


-- function NPC:ControllerThink()
--     local ply = self.ZBPlyController


--     local camEnt = ply:GetNWEntity("ZBCtrlSysCamEnt", NULL)
--     if !IsValid(camEnt) then return end


--     -- Camera tracer
--     local eyeangs = ply:EyeAngles()
--     local forward = eyeangs:Forward()
--     local right = eyeangs:Right()
--     local camViewPos = camEnt:GetPos()
--     local camTrace = util.TraceLine({
--         start = camViewPos,
--         endpos = camViewPos+forward*100000,
--         mask = MASK_VISIBLE_AND_NPCS,
--         filter = self,
--     })


--     -- The controller "target"
--     if IsValid(self.ZBControlTarget) then

--         -- Position target at cursor
--         self.ZBControlTarget:SetPos(camTrace.HitPos+camTrace.HitNormal*5)

--         -- Be enemy to target
--         if !IsValid(self:GetEnemy()) then
--             self:AddEntityRelationship(self.ZBControlTarget, D_HT, 0)
--             self:UpdateEnemyMemory(self.ZBControlTarget, camTrace.HitPos+camTrace.HitNormal*5)
--             self:SetEnemy(self.ZBControlTarget)
--             self:SetUnforgettable( self.ZBControlTarget )
--         end

--     end


--     -- Decide move direction
--     local moveDir = Vector(0, 0, 0)
--     if ply:KeyDown(IN_FORWARD) then
--         moveDir = moveDir + Vector(forward.x, forward.y, 0):GetNormalized()
--     end
--     if ply:KeyDown(IN_BACK) then
--         moveDir = moveDir - Vector(forward.x, forward.y, 0):GetNormalized()
--     end
--     if ply:KeyDown(IN_MOVELEFT) then
--         moveDir = moveDir - Vector(right.x, right.y, 0):GetNormalized()
--     end
--     if ply:KeyDown(IN_MOVERIGHT) then
--         moveDir = moveDir + Vector(right.x, right.y, 0):GetNormalized()
--     end
--     moveDir = moveDir:GetNormalized() -- Normalize the accumulated movement direction


--     -- Move
--     self:Controller_Move(self:WorldSpaceCenter() + moveDir * self:OBBMaxs().x*20)

-- end


ZBCtrlSys = {}


if CLIENT then
    hook.Add("CalcView", "ZBCtrlSys", function(ply, pos, ang, fov, znear, zfar)
        local camEnt = ply:GetNWEntity("ZBCtrlSysCamEnt", NULL)


        if IsValid(camEnt) then

            -- local _, modelmaxs = camEnt:GetModelBounds()
            local forward = ang:Forward()
            local camViewPos = camEnt:GetPos()+camEnt:GetUp()*90 - ( forward * 200 )


            -- local camTrace = util.TraceLine({
            --     start = camViewPos,
            --     endpos = camViewPos+forward*100000,
            --     mask = MASK_VISIBLE,
            -- })



            -- debugoverlay.Axis(camTrace.HitPos, angle_zero, 50, 0.1)


            return {
                origin = camViewPos,
                angles = ang,
                fov = fov,
                drawviewer = true,
            }

        end
    end)
end




if SERVER then
    function ZBCtrlSys:StartControlling( ply, npc )

        npc.IsZBPlyControlled = true
        npc.ZBPlyController  =  ply


        -- Only target the target which will follow the players cursor
        npc.ZBControlTarget = ents.Create("npc_bullseye")
        npc.ZBControlTarget:SetPos( npc:WorldSpaceCenter() )
        npc.ZBControlTarget:SetNotSolid(true)
        npc.ZBControlTarget:SetHealth(math.huge)
        npc.ZBControlTarget:Spawn()
        npc.ZBControlTarget:Activate()
        npc:ClearEnemyMemory()
        self:UpdateRelationShips()


        -- Setup camera
        npc.ZBViewEnt = ents.Create("base_gmodentity")
        npc.ZBViewEnt:SetPos( npc:GetPos() )
        npc.ZBViewEnt:SetAngles(npc:GetAngles())
        npc.ZBViewEnt:SetParent(npc)
        npc.ZBViewEnt:SetNoDraw(true)
        npc.ZBViewEnt:Spawn()
        npc:DeleteOnRemove(npc.ZBViewEnt)
        ply:SetNWEntity("ZBCtrlSysCamEnt", npc)


        -- Disable jump capability for NPC
        npc.ZBHadJumpCap = npc:HasCapability(CAP_MOVE_JUMP)
        npc:CapabilitiesRemove(CAP_MOVE_JUMP)

        
        -- Player variables
        ply.ZBControlledNPC = npc
        ply.ZBLastMoveType = ply:GetMoveType()
        ply.ZBLastNoTarget = bit.band(ply:GetFlags(), FL_NOTARGET)==FL_NOTARGET
        ply:SetNoTarget(true)
        ply:SetMoveType(MOVETYPE_NONE)
        

        -- Undo stops controlling
        undo.Create("ZBase Control")
        undo.SetPlayer(ply)
        undo.AddFunction(function() self:StopControlling( ply, npc ) end)
        undo.SetCustomUndoText( "Stopped Controlling ".. npc.Name )
        undo.Finish()


        -- If the NPC is removed the controlling should also stop
        npc:CallOnRemove("StopControllingZB", function()
            self:StopControlling(ply, npc)
        end)


        -- WIP message
        ply:PrintMessage(HUD_PRINTTALK, "Warning: The ZBase controller is still WIP!")

    end


    function ZBCtrlSys:StopControlling( ply, npc )

        if IsValid(npc) then

            if npc.ZBHadJumpCap then
                npc:CapabilitiesAdd(CAP_MOVE_JUMP)
            end

            -- npc:SetSaveValue( "m_flFieldOfView", npc.FieldOfView )
            npc.IsZBPlyControlled  = false
            npc.ZBPlyController  = nil
            ply.ZBControlledNPC = nil
            npc.ZBHadJumpCap = nil

            SafeRemoveEntity(npc.ZBViewEnt)
            SafeRemoveEntity(npc.ZBControlTarget)


        end


        if IsValid(ply) then
            ply:SetNWEntity("ZBCtrlSysCamEnt", NULL)
            ply:SetMoveType(ply.ZBLastMoveType)
            ply:SetNoTarget(ply.ZBLastNoTarget)
        end

        
        self:UpdateRelationShips()

    end


    function ZBCtrlSys:UpdateRelationShips()
        for _, v in ipairs(ZBaseNPCInstances) do
            v:UpdateRelationships()
        end
    end


    hook.Add("PlayerButtonDown", "ZBCtrlSys", function(ply, btn)
        if IsValid(ply.ZBControlledNPC) then
            ply.ZBControlledNPC:Controller_ButtonDown(ply, btn)
        end
    end)


    hook.Add("KeyPress", "ZBCtrlSys", function(ply, key)
        if IsValid(ply.ZBControlledNPC) then
            ply.ZBControlledNPC:Controller_KeyPress(ply, key)
        end
    end)

end