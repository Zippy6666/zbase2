include("shared.lua")
util.AddNetworkString("ZBASE_CreateSpawner")

local ai_disabled               = GetConVar("ai_disabled")
local zbase_spawner_cooldown    = ZBCVAR.SpawnerCooldown
local zbase_spawner_vis         = ZBCVAR.SpawnerVisibility
local zbase_spawner_mindist     = ZBCVAR.SpawnerDistance
local vecTrStartOffset          = Vector(0, 0, 30)
local vecTrDown                 = Vector(0, 0, 40)
local NOTIFY_HINT               = 3

ENT.strZBaseClsName     = ""
ENT.tblZBaseNPC         = {}
ENT.strZBaseFaction     = ""
ENT.ply                 = NULL 
ENT.npcSpawned          = NULL
ENT.fNextSpawnT       = CurTime()

function ENT:Initialize()
    if !isstring(self.strZBaseClsName) or self.strZBaseClsName == "" then
        error("Spawner has no ZBase NPC to spawn...")
    end

    self.tblZBaseNPC = ZBaseNPCs[self.strZBaseClsName]
    if !self.tblZBaseNPC then
        error("Spawner could not find NPC '"..self.strZBaseClsName.."'...")
    end

    conv.display3DText( self:GetPos() + self:GetUp() * 100, self.tblZBaseNPC.Name.. " Spawner", color_white, 0.25, 2, self.ply && {self.ply} or nil )

    local bModelFound = false
    if istable(self.tblZBaseNPC.Models) && isstring(self.tblZBaseNPC.Models[1]) then
        -- ZBase NPC has predefined model
        self:SetModel(self.tblZBaseNPC.Models[1])
        bModelFound = true
    
    elseif isstring(self.tblZBaseNPC.Class) then
        -- Find entity by base HL2 NPC

        local entToTakeMdlFrom = ents.Create(self.tblZBaseNPC.Class)
        
        if IsValid(entToTakeMdlFrom) then
            entToTakeMdlFrom:Spawn()
            self:SetModel(entToTakeMdlFrom:GetModel())
            entToTakeMdlFrom:Remove()
            bModelFound = true
        end
    end

    -- No model found, use cheaple
    if !bModelFound then
        self:SetModel("models/humans/group01/male_cheaple.mdl")
    end

    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetColor(Color(255, 255, 255, 175))
    self:DrawShadow(false)
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:AddEFlags(EFL_DONTBLOCKLOS)

    self.fNextSpawnT = CurTime()+zbase_spawner_cooldown:GetFloat()

    if IsValid(self.ply) then
        if isstring(self.ply.ZBaseNPCFactionOverride) then
            self.strZBaseFaction = self.ply.ZBaseNPCFactionOverride
            conv.display3DText( self:GetPos() + self:GetUp() * 95, "Faction: '"..self.strZBaseFaction.. "'", color_white, 0.25, 2, {self.ply} )
        end

        conv.sendGModHint(self.ply, 
        "Spawner created! Move it with the physics gun.",
        NOTIFY_HINT,
        5)

        undo.Create("NPC Spawner")
            undo.AddEntity(self)
            undo.SetPlayer(self.ply)
        undo.Finish()
    end
end

function ENT:vecSpawnPos()
    local vecStart  = self:GetPos()+vecTrStartOffset
    local tr        = util.TraceLine({
        start   = vecStart,
        endpos  = vecStart - vecTrDown,
        mask    = MASK_NPCWORLDSTATIC
    })

    local nrm = tr.HitNormal*5

    if tr.Hit && istable(self.tblZBaseNPC) && isnumber(self.tblZBaseNPC.Offset) then
        nrm = tr.HitNormal*self.tblZBaseNPC.Offset
    end

    if tr.Hit && istable(self.tblZBaseNPC) && self.tblZBaseNPC.SNPCType == ZBASE_SNPCTYPE_FLY && isnumber(self.tblZBaseNPC.Fly_DistanceFromGround) then
        nrm = tr.HitNormal*self.tblZBaseNPC.Fly_DistanceFromGround
    end

    return tr.HitPos + nrm
end

function ENT:spawnMyNPC()
    self.npcSpawned = ents.Create(self.strZBaseClsName)
    if !IsValid(self.npcSpawned) then
        self:Remove()
        error("Spawner failed!")
    end

    self.npcSpawned:SetPos(self:vecSpawnPos())
    self.npcSpawned:SetAngles(self:GetAngles())

    local tblWeapons = self.tblZBaseNPC.Weapons
    local strWeapon = ""
    if istable(tblWeapons) then
        strWeapon = tblWeapons[math.random(1, #tblWeapons)] or ""
    end
    if strWeapon != "" then
        self.npcSpawned:Give(strWeapon)
    end

    self:DeleteOnRemove(self.npcSpawned)
    self.npcSpawned:Spawn()
    
    if self.strZBaseFaction != "" then
        self.npcSpawned.ZBaseStartFaction = self.strZBaseFaction
    end
end

function ENT:bShouldSpawn()
    return !IsValid(self.npcSpawned) && !table.IsEmpty(self.tblZBaseNPC) && ai_disabled:GetBool() == false
end

function ENT:bSpawnLegalChecks()
    --[[
        Final checks to see if this spawn is legal
        If these don't pass, the spawner will go on cool down either way
    ]]--

    if zbase_spawner_vis:GetBool() == true && conv.playersSeePos( self:vecSpawnPos() ) then
        conv.devPrint("Spawner visible, skipping spawn")
        return false
    end

    if zbase_spawner_mindist:GetBool() == true then
        local iDistSqr      = zbase_spawner_mindist:GetInt()^2
        local vecSpawnPos   = self:vecSpawnPos()

        for _, ply in player.Iterator() do
            local iPlySqrDist = ply:GetPos():DistToSqr(vecSpawnPos)

            if iPlySqrDist < iDistSqr then
                conv.devPrint(ply, " too close for spawner to spawn")
                return false
            end
        end
    end

    return true
end

function ENT:Think()
    if self:bShouldSpawn() then
        local bTheTimeHasCome = self.fNextSpawnT < CurTime()

        if bTheTimeHasCome && self:bSpawnLegalChecks() == false then
            self.fNextSpawnT = CurTime()+zbase_spawner_cooldown:GetFloat()
            return
        end
            
        if bTheTimeHasCome then
            self:spawnMyNPC()
            return
        end

    else
        self.fNextSpawnT = CurTime()+zbase_spawner_cooldown:GetFloat()
        return
    end
end

net.Receive("ZBASE_CreateSpawner", function(_, ply)
    if !IsValid(ply) then return end
    if !ply:IsSuperAdmin() then return end
    
    local strZBaseClsName   = net.ReadString()
    local pos               = net.ReadVector()

    local entSpawner = ents.Create("zb_spawner")
    entSpawner:SetPos(pos)
    entSpawner:SetAngles( Angle(0, (ply:GetPos() - pos):Angle().yaw, 0) )
    entSpawner.strZBaseClsName      = strZBaseClsName
    entSpawner.ply                  = ply
    entSpawner:Spawn()
end)

hook.Add("PhysgunDrop", "ZBase_SpawnerNocollide", function(ply, ent)
    if ent:GetClass() != "zb_spawner" then return end

    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetNotSolid(false)
end)

hook.Add("OnPhysgunPickup", "ZBASE_SpawnerNocollide", function(ply, ent)
    if ent:GetClass() != "zb_spawner" then return end

    local vecStoredPos = ent:GetPos()
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetNotSolid(true)
    ent:SetPos(vecStoredPos)
end)