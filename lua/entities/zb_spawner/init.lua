include("shared.lua")
util.AddNetworkString("ZBASE_CreateSpawner")

local ai_disabled               = GetConVar("ai_disabled")
local zbase_spawner_cooldown    = ZBCVAR.SpawnerCooldown
local vecTrStartOffset          = Vector(0, 0, 30)
local vecTrDown                 = Vector(0, 0, 10000)

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
        end

        undo.Create("NPC Spawner")
            undo.AddEntity(self)
            undo.SetPlayer(self.ply)
        undo.Finish()
    end
end

function ENT:spawnMyNPC()
    local vecStart  = self:GetPos()+vecTrStartOffset
    local tr        = util.TraceLine({
        start   = vecStart,
        endpos  = vecStart - vecTrDown,
        mask    = MASK_NPCWORLDSTATIC
    })

    self.npcSpawned = ents.Create(self.strZBaseClsName)
    if !IsValid(self.npcSpawned) then
        self:Remove()
        error("Spawner failed!")
    end

    self.npcSpawned:SetPos(tr.HitPos + tr.HitNormal*5)
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

function ENT:Think()
    if !IsValid(self.npcSpawned) && !table.IsEmpty(self.tblZBaseNPC) && ai_disabled:GetBool() == false then
        
        if self.fNextSpawnT < CurTime() then
            self:spawnMyNPC()
        end

    else
        self.fNextSpawnT = CurTime()+zbase_spawner_cooldown:GetFloat()
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