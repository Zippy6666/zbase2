include("shared.lua")
util.AddNetworkString("ZBASE_CreateSpawner")

ENT.strZBaseClsName =  ""
ENT.ply = NULL

function ENT:Initialize()
    if !isstring(self.strZBaseClsName) or self.strZBaseClsName == "" then
        error("Spawner has no ZBase NPC to spawn...")
    end

    local tblZBaseNPC = ZBaseNPCs[self.strZBaseClsName]
    if !tblZBaseNPC then
        error("Spawner could not find NPC '"..self.strZBaseClsName.."'...")
    end

    local bModelFound = false
    if istable(tblZBaseNPC.Models) && isstring(tblZBaseNPC.Models[1]) then
        -- ZBase NPC has predefined model
        self:SetModel(tblZBaseNPC.Models[1])
        bModelFound = true
    
    elseif isstring(tblZBaseNPC.Class) then
        -- Find entity by base HL2 NPC

        local entToTakeMdlFrom = ents.Create(tblZBaseNPC.Class)
        
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

    self:SetMaterial("models/wireframe")
    self:DrawShadow(false)
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:AddEFlags(EFL_DONTBLOCKLOS)

    if IsValid(self.ply) then
        undo.Create("ZBase NPC Spawner")
            undo.AddEntity(self)
            undo.SetPlayer(self.ply)
        undo.Finish()
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
    entSpawner.strZBaseClsName = strZBaseClsName
    entSpawner.ply = ply
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