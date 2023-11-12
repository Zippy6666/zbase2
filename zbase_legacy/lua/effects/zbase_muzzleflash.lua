local muzzleMaterials = {
    "effects/muzzleflash1",
    "effects/muzzleflash2",
    "effects/muzzleflash3",
    "effects/muzzleflash4",
}

local ar2Materials = {
    "effects/combinemuzzle1",
    "effects/combinemuzzle2",
}

local MUZZLE_DEFAULT = 1
local MUZZLE_AR2 = 2
local MUZZLE_SHOTGUN = 3

--------------------------------------------------------------------------=#
function EFFECT:Init(data)
    local pos = data:GetStart()
    local ent = data:GetEntity()
    local ang = data:GetAngles()
    local normal = ang:Forward()
    local flags = data:GetFlags()
    local emitter = ParticleEmitter(pos, false)

    -- Smoke
    local smokeCol = flags==MUZZLE_AR2 && Color(0, 50, 50) or Color(125, 125, 125)
    local function smoke()
        for i = 1, 10 do
            local smoke = emitter:Add("particle/particle_smokegrenade", pos)
            smoke:SetVelocity( ang:Forward()*math.Rand(300,400) )
            smoke:SetDieTime(math.Rand(0, 0.2))
            smoke:SetStartAlpha(125)
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(0)
            smoke:SetEndSize(10)
            smoke:SetAirResistance(100)
            smoke:SetRollDelta(math.Rand(0.25,0.5))
            smoke:SetColor(smokeCol.r, smokeCol.g, smokeCol.b)
        end
    end
    local function shotgunSmoke()
        for i = 1, 15 do
            local smoke = emitter:Add("particle/particle_smokegrenade", pos)
            smoke:SetVelocity( ang:Forward()*math.Rand(100,400) )
            smoke:SetDieTime(math.Rand(0, 0.4))
            smoke:SetStartAlpha(125)
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(0)
            smoke:SetEndSize(12)
            smoke:SetAirResistance(100)
            smoke:SetRollDelta(math.Rand(0.25,0.5))
            smoke:SetColor(smokeCol.r, smokeCol.g, smokeCol.b)
        end
    end
    if flags==MUZZLE_SHOTGUN then
        shotgunSmoke()
    else
        smoke()
    end

    -- The meat of the effect
    local mats = flags==MUZZLE_AR2 && ar2Materials or muzzleMaterials
    local baseSize = flags==MUZZLE_SHOTGUN && 15 or 10
    for i = 1, flags==MUZZLE_SHOTGUN && 5 or 4 do
        local fire = emitter:Add(table.Random(mats), pos+normal*(i*10))
        fire:SetDieTime(math.Rand(0, 0.1))
        fire:SetStartAlpha(math.Rand(100, 255))
        fire:SetEndAlpha(50)
        fire:SetStartSize((baseSize - i*2)*1.5)
        fire:SetEndSize((baseSize - i*2)*1.5)
    end

    -- Dynamic light
    local col = flags==MUZZLE_AR2 && Color(35, 255, 255) or Color(255, 115, 40)
	local dynlight = DynamicLight( ent:EntIndex() )
	if ( dynlight ) then
		dynlight.pos = pos
		dynlight.r = col.r
		dynlight.g = col.g
		dynlight.b = col.b
		dynlight.brightness = 1.5
		dynlight.Size = 256
        dynlight.Fade = 2000
		dynlight.DieTime = CurTime() + 0.1
	end

    -- Extra glow
    local flash = emitter:Add("effects/yellowflare", pos+normal*20)
    flash:SetDieTime(math.Rand(0, 0.1))
    flash:SetStartSize(math.Rand(60,80))
    flash:SetEndSize(0)
    flash:SetStartAlpha(flags==MUZZLE_SHOTGUN && 42 or 32)
    flash:SetEndAlpha(0)
    flash:SetRoll(math.Rand(0, 2*math.pi))
    flash:SetColor(col.r, col.g, col.b)

    emitter:Finish()
end
--------------------------------------------------------------------------=#
function EFFECT:Think() return false end
--------------------------------------------------------------------------=#
function EFFECT:Render() end
--------------------------------------------------------------------------=#