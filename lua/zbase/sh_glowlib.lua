ZBASE_GLOW_LIB_INITIALIZED = ZBASE_GLOW_LIB_INITIALIZED or false


local function Init()
    if !GlowLib then return end


    --[[
    ======================================================================================================================================================
                                            DEFAULT NPCS
    ======================================================================================================================================================
    --]]

    GlowLib:Define("models/zippy/elitepolice.mdl", {
        Position = function(self, ent)
            local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
            return attachmentData.Pos
        end,
        Attachment = "eyes",
        Color = {
            [0] = Color(255, 155, 0),
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
        OnInitialize = function(self, ent, sprite)
            local attachment = ent:LookupAttachment("bottom_eye")
            local attachmentData = ent:GetAttachment(attachment)
            local glow_eyes = ent:GetGlowingEyes()

            local glowCol = self.Color[ent:GetSkin()] or self.Color[0] or color_white

            local glowColCustom = self.CustomColor and isfunction(self.CustomColor) and self:CustomColor(ent, glowCol)
            if ( glowColCustom != nil ) then
                glowCol = self:CustomColor(ent, glowCol)
            end

            local sprite = ents.Create("env_sprite")
            sprite:SetPos(attachmentData.Pos + attachmentData.Ang:Forward() * -4)
            sprite:SetParent(ent, attachment or 0)
            sprite:SetNW2String("GlowEyeName", "GlowLib_Eye_" .. ent:EntIndex())
            sprite:SetNW2String("GlowLib_Eye_Count", #glow_eyes + 1)

            sprite:SetKeyValue("model", "sprites/light_glow02.vmt")
            sprite:SetColor(glowCol)

            sprite:SetKeyValue("rendermode", "9")
            sprite:SetKeyValue("HDRColorScale", "0.5")
            sprite:SetKeyValue("scale", "0.3")

            sprite:SetNW2Bool("bIsGlowLib", true)
            sprite:Spawn()
            sprite:Activate()

            ent:DeleteOnRemove(sprite)
        end,
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
            [0] = Color(0, 140, 255),
        },
    })

    GlowLib:Define("models/myt/zbase_echo1_combine.mdl", {
        Position = function(self, ent)
            local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
            return attachmentData.Pos
        end,
        Attachment = "eyes",
        Color = {
            [0] = Color(255, 200, 0),
            [1] = Color(255, 75, 0),
            [2] = Color(255, 30, 0),
        },
    })

    GlowLib:Define("models/myt/zbase_wallhammer_combine.mdl", {
        Position = function(self, ent)
            local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
            return attachmentData.Pos
        end,
        Attachment = "eyes",
        Color = {
            [0] = Color(0, 30, 255),
            [1] = Color(255, 30, 0),
        },
    })
end

hook.Add("Initialize", "ZBaseGlowLib", function()
    Init()
    ZBASE_GLOW_LIB_INITIALIZED = true
end)


if ZBASE_GLOW_LIB_INITIALIZED then
    Init()
end



