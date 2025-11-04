--[[
======================================================================================================================================================
                                        RETAIL
======================================================================================================================================================
--]]

GlowLib:Define("models/zippy/elitepolice.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(255, 155, 0, 170),
    },
})

GlowLib:Define("models/zippy/mortarsynth.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("tentacle"))
        return attachmentData.Pos-attachmentData.Ang:Forward()*-45-attachmentData.Ang:Right()*7
    end,
    Size = 0.6,
    Attachment = "tentacle",
    Color = {
        [0] = Color(0, 75, 255),
    },
})

GlowLib:Define("models/zippy/synth.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("vent"))
        return attachmentData.Pos-attachmentData.Ang:Forward()*-35-attachmentData.Ang:Right()*0
    end,
    Size = 1.2,
    Attachment = "vent",
    Color = {
        [0] = Color(0, 75, 255),
    },
})

GlowLib:Define("models/zippy/resistancehunter.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("top_eye"))
        return attachmentData.Pos + attachmentData.Ang:Forward() * -4
    end,
    Attachment = "top_eye",
    Color = {
        [0] = Color(255, 155, 0),
    },
    Size = 0.4,
    OnInitialize = function(self, ent, sprite)
        local glow_color = self.Color[ent:GetSkin()] or self.Color[0] or color_white

        local glowColCustom = self.CustomColor and isfunction(self.CustomColor) and self:CustomColor(ent, glowCol)
        if ( glowColCustom != nil ) then
            glow_color = self:CustomColor(ent, glowCol)
        end

        local attach = ent:LookupAttachment("bottom_eye")
        local attachmentData = ent:GetAttachment(attach)
        if ( !attachmentData ) then return end

        if ( SERVER ) then
            local sprite = GlowLib:CreateSprite(ent, {
                Color = glow_color,
                Attachment = "bottom_eye",
                Position = attachmentData.Pos + attachmentData.Ang:Forward() * -4,
                Size = 0.4,
            })
        end
    end,
})

GlowLib:Define("models/zippy/combine_medic.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(40, 130, 0, 170)
    },
})

--[[
======================================================================================================================================================
                                        COMBINE NPC RESEARCH
======================================================================================================================================================
--]]

GlowLib:Define("models/myt/zbase_advisor_combine.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos+attachmentData.Ang:Forward()*3+attachmentData.Ang:Up()*2
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(0, 100, 210, 170),
    },
})

GlowLib:Define("models/myt/zbase_echo1_combine.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(40, 130, 0, 170),
        [1] = Color(190, 145, 0, 170),
        [2] = Color(155, 40, 0, 170)
    },
})

GlowLib:Define("models/myt/zbase_wallhammer_combine.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(0, 100, 210, 170),
        [1] = Color(140, 25, 0, 170),
        [2] = Color(190, 145, 0, 170),
    },
})