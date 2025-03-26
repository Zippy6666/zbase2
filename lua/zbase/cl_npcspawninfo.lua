-- ZBaseShowSpawnInfoNPCs = ZBaseShowSpawnInfoNPCs or {}
-- local DisplayTime = 3


-- net.Receive("ZBaseOnNPCSpawnInfo", function()

--     local npc = net.ReadEntity()
--     if !IsValid(npc) then return end

--     npc:CONV_StoreInTable(ZBaseShowSpawnInfoNPCs)
--     npc:CONV_TimerSimple(DisplayTime, function()
--         table.RemoveByValue(ZBaseShowSpawnInfoNPCs, npc)
--     end)

-- end)


-- local textAngOffset = Angle(0, 90, 90)
-- hook.Add("PostDrawOpaqueRenderables", "Draw3DTextExample", function()

--     for _, npc in ipairs(ZBaseShowSpawnInfoNPCs) do

--         npc.ShowInfoPos = npc.ShowInfoPos or npc:GetPos()+npc:GetUp()*(npc:OBBMaxs().z+10)

--         -- Calculate the angle to face the player
--         local ang = (LocalPlayer():EyePos() - npc.ShowInfoPos):Angle()
--         ang:RotateAroundAxis(ang:Forward(), 90)
--         ang:RotateAroundAxis(ang:Right(), -90)

--         cam.Start3D2D(npc.ShowInfoPos, ang, 0.25)
--             -- Draw shadow for depth
--             draw.SimpleText(npc:GetClass(), "DermaLarge", 2, 2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
--             -- Draw main text
--             draw.SimpleText(npc:GetClass(), "DermaLarge", 0, 0, Color(29, 213, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--         cam.End3D2D()

--     end

-- end)