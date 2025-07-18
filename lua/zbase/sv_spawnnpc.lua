-- Mostly borrowed gmod source code!

ZBaseNPCCount 		= 0

-- A little hacky function to help prevent spawning props partially inside walls
-- Maybe it should use physics object bounds, not OBB, and use physics object bounds to initial position too
local function fixupProp( ply, ent, hitpos, mins, maxs )
	local entPos = ent:GetPos()
	local endposD = ent:LocalToWorld( mins )
	local tr_down = util.TraceLine( {
		start = entPos,
		endpos = endposD,
		filter = { ent, ply }
	} )

	local endposU = ent:LocalToWorld( maxs )
	local tr_up = util.TraceLine( {
		start = entPos,
		endpos = endposU,
		filter = { ent, ply }
	} )

	-- Both traces hit meaning we are probably inside a wall on both sides, do nothing
	if ( tr_up.Hit && tr_down.Hit ) then return end

	if ( tr_down.Hit ) then ent:SetPos( entPos + ( tr_down.HitPos - endposD ) ) end
	if ( tr_up.Hit ) then ent:SetPos( entPos + ( tr_up.HitPos - endposU ) ) end
end

local function TryFixPropPosition( ply, ent, hitpos )
	fixupProp( ply, ent, hitpos, Vector( ent:OBBMins().x, 0, 0 ), Vector( ent:OBBMaxs().x, 0, 0 ) )
	fixupProp( ply, ent, hitpos, Vector( 0, ent:OBBMins().y, 0 ), Vector( 0, ent:OBBMaxs().y, 0 ) )
	fixupProp( ply, ent, hitpos, Vector( 0, 0, ent:OBBMins().z ), Vector( 0, 0, ent:OBBMaxs().z ) )
end

function ZBaseInitialize( NPC, NPCData, Class, Equipment, wasSpawnedOnCeiling, bDropToFloor, skipSpawnAndActivate, SpawnFlagsSaved )
	if NPC.ZBaseInitialized then return end
	NPC.ZBaseInitialized = true

        -- This npc's table
    for k, v in pairs(ZBaseNPCs[Class]) do
        NPC[k] = v
    end
    
	-- "Patches"
	local patchFunc = ZBasePatchTable[NPCData.Class]
	if patchFunc then
		patchFunc(NPC)
	end

    -- Decide model
    local model = istable(NPCData.Models) && table.Random(NPCData.Models)
    if model then
		NPC.SpawnModel = model
    end

	--
	-- Does this NPC have a specified material? If so, use it.
	--
	if ( NPCData.Material ) then
		NPC:SetMaterial( NPCData.Material )
	end

	-- Keyvalues
	if istable(NPCData.KeyValues) then
		for k, v in pairs( NPCData.KeyValues ) do
			NPC:SetKeyValue( k, v )
		end
	end
	
	--
	-- Spawn Flags
	--
	local SpawnFlags = !NPC.Patch_DontApplyDefaultFlags && bit.bor( SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK, SF_NPC_LONG_RANGE ) or SpawnFlagsSaved or 0
	if istable(NPCData.SpawnFlagTbl) then
		for _, v in ipairs(NPCData.SpawnFlagTbl) do
			SpawnFlags = bit.bor( SpawnFlags, v )
		end
	end

	NPC:SetKeyValue( "spawnflags", SpawnFlags )
	NPC.SpawnFlags = SpawnFlags

    -- Set skin
    if NPCData.Skins then
        local mySkin = table.Random( NPCData.Skins )
        
        if mySkin then
            NPC:SetSkin( mySkin )
        end
    end

	--
	-- What weapon this NPC should be carrying
	--
	-- Check if this is a valid weapon from the list, or the user is trying to fool us.
	local valid = false
	for _, v in pairs( list.Get( "NPCUsableWeapons" ) ) do
		if ( v.class == Equipment ) then valid = true break end
	end
	for _, v in pairs( NPCData.Weapons or {} ) do
		if ( v == Equipment ) then valid = true break end
	end
	if Equipment == "zbase_random_weapon" then
		local randTBL = table.Copy(ZBaseNPCWeps)
		table.Add(randTBL, {
			"weapon_zb_ar2",
			"weapon_zb_357",
			"weapon_zb_crossbow",
			"weapon_zb_crowbar",
			"weapon_zb_pistol",
			"weapon_zb_rpg",
			"weapon_zb_shotgun",
			"weapon_zb_smg1",
			"weapon_zb_stunstick",
			"weapon_zb_alyxgun",
			"weapon_zb_annabelle",
			"weapon_zb_357_hl1",
			"weapon_zb_glock_hl1",
			"weapon_zb_shotgun_hl1"
		})

		for i, wclass in ipairs( table.Copy(randTBL) ) do
			if string.find(ZBCVAR.RandWepBlackList:GetString(), wclass) then
				table.RemoveByValue(randTBL, wclass)
			end
		end

		local randWep = randTBL[math.random(1, #randTBL)]

		if randWep then
			Equipment = randWep
		else
			PrintMessage(HUD_PRINTTALK, "Unable to randomize weapons...")
		end

		NPC:SetKeyValue( "additionalequipment", Equipment )
		NPC.Equipment = Equipment
	elseif Equipment && Equipment != "none" && valid then
		NPC:SetKeyValue( "additionalequipment", Equipment )
		NPC.Equipment = Equipment
	end

    -- Ceiling and floor functions
	if ( wasSpawnedOnCeiling && isfunction( NPCData.OnCeiling ) ) then
		NPCData.OnCeiling( NPC )
	elseif ( wasSpawnedOnFloor && isfunction( NPCData.OnFloor ) ) then
		NPCData.OnFloor( NPC )
	end

	-- Allow special case for duplicator stuff
	if ( isfunction( NPCData.OnDuplicated ) ) then
		NPC.OnDuplicated = NPCData.OnDuplicated
	end

		-- Store name and table like the usual spawn menu spawn system in GMOD
	NPC.NPCName = Class
	NPC.NPCTable = NPCData
	NPC.EngineClass = NPCData.Class
	NPC._wasSpawnedOnCeiling = wasSpawnedOnCeiling

	-- Pre-spawn
	if NPC.Patch_PreSpawn then
		NPC:Patch_PreSpawn()
	end
	NPC:PreSpawn()

	-- Spawn and activate
	if !skipSpawnAndActivate then
		NPC.ZBase_Spawned = true
		NPC:Spawn()
		NPC:Activate()

		-- Spawn effect
		local ed = EffectData()
		ed:SetEntity( NPC )
		util.Effect( "zbasespawn", ed, true, true )
	end

	-- Body groups
	if ( NPCData.BodyGroups ) then
		for k, v in pairs( NPCData.BodyGroups ) do
			NPC:SetBodygroup( k, v )
		end
	end

	-- Init
	if !skipSpawnAndActivate then
		ZBaseAfterSpawn(NPC, Class, bDropToFloor)
	end

	return NPC
end

function ZBaseAfterSpawn( NPC, Class, bDropToFloor )
    -- "Register"
    table.insert(ZBaseNPCInstances, NPC)
	ZBaseNPCCount = ZBaseNPCCount + 1
	NPC:CallOnRemove("ZBaseNPCInstancesRemove", function()
		table.RemoveByValue(ZBaseNPCInstances, NPC)
		ZBaseNPCCount = ZBaseNPCCount - 1
	end)

	-- Register as non-scripted if npc is such
	if !NPC.IsZBase_SNPC then
		table.insert(ZBaseNPCInstances_NonScripted, NPC)
		NPC:CallOnRemove("ZBaseNPCInstances_NonScripted_Remove", function() table.RemoveByValue(ZBaseNPCInstances_NonScripted, NPC) end)
	end

	if NPC.Patch_Init then
		NPC.Patch_Init( NPC )
	end
	NPC:ZBaseInit()

	-- Store my class for dupe data
	duplicator.StoreEntityModifier( NPC, "ZBaseNPCDupeApplyStuff", {Class} )

	-- Make sure I always spawn with my engine class when duped
	-- not my custom ZBase one
	-- If i should have a custom class
	-- it will be applied after I am pasted anyway
	function NPC:PreEntityCopy()
		self.PreDupeClassName = self:GetClass()
		self:SetKeyValue("classname", self:GetEngineClass())
		
		self:CONV_CallNextTick(function()
			self:SetKeyValue("classname", self.PreDupeClassName)
			self.PreDupeClassName = nil
		end)
	end

	-- Drop to floor
	if ( bDropToFloor ) then
		NPC:DropToFloor()
	end

	NPC.ZBase_Spawned = true
end

-- Apply stuff after duped
duplicator.RegisterEntityModifier( "ZBaseNPCDupeApplyStuff", function(ply, ent, data)
    local ZBaseClass = data[1]
    local ZBaseNPCTable = ZBaseNPCs[ ZBaseClass ]
	local EngineClass = ZBaseNPCTable.Class

	-- Apparently, entities can be duped but their classes can change
	-- Easy animation tool for example, does this when you select
	-- "Make Animatable" through the context menu
	-- We don't want any special ZBase shenanigans on the entity
	-- in this case, so return
	if ent:GetClass() != EngineClass then
		return
	end

    if ZBaseNPCTable then
		local Equipment, wasSpawnedOnCeiling, bDropToFloor = false, false, true

        ent.ZBaseInitialized = false -- So that it can be initialized again
        ent.IsDupeSpawnedZBaseNPC = true

        ZBaseInitialize( ent, ZBaseNPCTable, ZBaseClass, Equipment, wasSpawnedOnCeiling, bDropToFloor )
    end
end)

function ZBaseInternalSpawnNPC( ply, Position, Normal, Class, Equipment, SpawnFlagsSaved, NoDropToFloor, skipSpawnAndActivate )
	local NPCList = ZBaseSpawnMenuNPCList
	local NPCData = ZBaseSpawnMenuNPCList[ Class ]

	-- Don't let them spawn this entity if it isn't in our NPC Spawn list.
	-- We don't want them spawning any entity they like!
	if ( !NPCData ) then return end

	local isAdmin = ( IsValid( ply ) && ply:IsAdmin() ) or game.SinglePlayer()
	if ( NPCData.AdminOnly && !isAdmin ) then return end

	--
	-- This NPC has to be spawned on a ceiling (Barnacle) or a floor (Turrets)
	--
	local bDropToFloor = false
	local wasSpawnedOnCeiling = false
	local wasSpawnedOnFloor = false
	if ( NPCData.OnCeiling or NPCData.OnFloor ) then
		local isOnCeiling	= Vector( 0, 0, -1 ):Dot( Normal ) >= 0.95
		local isOnFloor		= Vector( 0, 0,  1 ):Dot( Normal ) >= 0.95

		-- Not on ceiling, and we can't be on floor
		if ( !isOnCeiling && !NPCData.OnFloor ) then return end

		-- Not on floor, and we can't be on ceiling
		if ( !isOnFloor && !NPCData.OnCeiling ) then return end

		-- We can be on either, and we are on neither
		if ( !isOnFloor && !isOnCeiling ) then return end

		wasSpawnedOnCeiling = isOnCeiling
		wasSpawnedOnFloor = isOnFloor
	else
		bDropToFloor = true
	end

	if ( NPCData.NoDrop or NoDropToFloor ) then bDropToFloor = false end

	-- Create NPC
	local NPC = ents.Create( NPCData.Class )

	-- Not valid
	if !IsValid( NPC ) or !NPC.SetSchedule or (NPC:IsScripted() && NPC:GetClass()!="npc_zbase_snpc") then
		SafeRemoveEntity(NPC)
		PrintMessage(HUD_PRINTTALK, "This ZBase NPC does not have a valid class!")
		return
	end

	--
	-- Set Position if any
	--
	if Position then
		NPC:SetPos( Position + Normal * (NPCData.Offset or 32) )

		if isnumber(NPCData.Offset) then
			bDropToFloor = false
		end

		-- Rotate to face player (expected behaviour)
		local Angles = Angle( 0, 0, 0 )
		if ( IsValid( ply ) ) then
			Angles = ply:GetAngles()
		end

		Angles.pitch = 0
		Angles.roll = 0
		Angles.yaw = Angles.yaw + 180
		if ( NPCData.Rotate ) then Angles = Angles + NPCData.Rotate end
		NPC:SetAngles( Angles )
	end

	NPC.ZBase_PlayerWhoSpawnedMe = ply
	NPC:SetCreator(ply)

	return ZBaseInitialize( NPC, NPCData, Class, Equipment, wasSpawnedOnCeiling, bDropToFloor, skipSpawnAndActivate, SpawnFlagsSaved )
end

function Spawn_ZBaseNPC( ply, NPCClassName, WeaponName, tr )
	-- We don't support this command from dedicated server console
	if ( !IsValid( ply ) ) then return end

	if ( !NPCClassName ) then return end

	-- Give the gamemode an opportunity to deny spawning
	ZBase_PlayerSpawnNPCHookCall = true
	if ( !gamemode.Call( "PlayerSpawnNPC", ply, NPCClassName, WeaponName ) ) then return end
	ZBase_PlayerSpawnNPCHookCall = nil
	
	if ( !tr ) then
		local vStart = ply:GetShootPos()
		local vForward = ply:GetAimVector()

		tr = util.TraceLine( {
			start = vStart,
			endpos = vStart + ( vForward * 2048 ),
			filter = ply
		} )
	end

	-- Create the NPC if you can.
	local SpawnedNPC = ZBaseInternalSpawnNPC( ply, tr.HitPos, tr.HitNormal, NPCClassName, WeaponName )
	if ( !IsValid( SpawnedNPC ) ) then return end

	TryFixPropPosition( ply, SpawnedNPC, tr.HitPos )

	-- Give the gamemode an opportunity to do whatever
	if ( IsValid( ply ) ) then
		gamemode.Call( "PlayerSpawnedNPC", ply, SpawnedNPC )
	end

	-- See if we can find a nice name for this NPC..
	local NPCList = list.Get( "NPC" )
	local NiceName = nil
	if ( NPCList[ NPCClassName ] ) then
		NiceName = NPCList[ NPCClassName ].Name
	end

	-- Add to undo list
	undo.Create( "NPC" )
		undo.SetPlayer( ply )
		undo.AddEntity( SpawnedNPC )
		if ( NiceName ) then
			undo.SetCustomUndoText( "Undone " .. NiceName )
		end
	undo.Finish( "NPC (" .. tostring( NPCClassName ) .. ")" )

	-- And cleanup
	ply:AddCleanup( "npcs", SpawnedNPC )

	ply:SendLua( "achievements.SpawnedNPC()" )
end

concommand.Add( "zbase_spawnnpc", function( ply, cmd, args )
    Spawn_ZBaseNPC( ply, args[ 1 ], args[ 2 ] )
end)