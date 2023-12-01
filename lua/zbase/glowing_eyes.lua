local EntsWithGlowingEyes = {}
ZBaseGlowingEyes = {
    ["models/combine_soldier.mdl"] = {
        [1] = {
            offset = Vector(4.5, 5, 2),
            scale = 8,
            colors = {
                [0] = Color(0, 50, 255),
                [1] = Color(155, 20, 0),
            },
        },
        [2] = {
            offset = Vector(4.5, 5, -2),
            scale = 8,
            colors = {
                [0] = Color(0, 50, 255),
                [1] = Color(155, 20, 0),
            },
        },
    },


    ["models/zippy/elitepolice.mdl"] = {
        [1] = {
            offset = Vector(3.8, 7, 1.9),
            scale = 7,
            colors = {
                [0] = Color(255, 155, 0),
            },
        },
        [2] = {
            offset = Vector(3.8, 7, -1.9),
            scale = 7,
            colors = {
                [0] = Color(255, 155, 0),
            },
        },
    },
}



--[[
======================================================================================================================================================
                                           NPC SPAWNED
======================================================================================================================================================
--]]


net.Receive("ZBaseGlowEyes", function()
    local ent = net.ReadEntity()
    local bone_to_use = net.ReadInt(8)
    
    ent.GlowEyesBone = bone_to_use
    
    if ZBaseGlowingEyes[ent:GetModel()] then
        table.insert(EntsWithGlowingEyes, ent)
        ent:CallOnRemove("RemoveEntsWithGlowingEyes", function() table.RemoveByValue(EntsWithGlowingEyes, ent) end)
    end

    print(ent:GetModel())
end)


--[[
======================================================================================================================================================
                                           RENDER
======================================================================================================================================================
--]]


local mat = Material( "effects/blueflare1" )
hook.Add( "RenderScreenspaceEffects", "ZBaseGlowingEyes", function()

    for _, ent in ipairs(EntsWithGlowingEyes) do
        local Eyes = ZBaseGlowingEyes[ent:GetModel()]
        if !Eyes then continue end
        
        -- local tr = util.TraceLine({
        --     start = LocalPlayer():GetPos(),
        --     endpos = ent:GetPos(),
        --     mask = MASK_VISIBLE,
        -- })

        -- if tr.Hit then continue end

        for _, eye in ipairs(Eyes) do

            cam.Start3D()
                local BonePos, BoneAng = ent:GetBonePosition( ent.GlowEyesBone )
                local pos = BonePos + BoneAng:Forward()*eye.offset.x + BoneAng:Right()*eye.offset.y + BoneAng:Up()*eye.offset.z

                render.SetMaterial(mat)
                render.DrawSprite( pos, eye.scale, eye.scale, eye.colors[ent:GetSkin()])
            cam.End3D()

        end
    end

end )