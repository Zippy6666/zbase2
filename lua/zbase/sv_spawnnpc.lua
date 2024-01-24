
	// Mostly borrowed gmod source code!

	
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


function ZBaseInitialize( NPC, NPCData, Class, Equipment, isFirstSpawn, wasSpawnedOnCeiling, bDropToFloor )
	if NPC.ZBaseInitialized then return end
	NPC.ZBaseInitialized = true



        -- This npc's table
    for k, v in pairs(ZBaseNPCs[Class]) do
        NPC[k] = v
    end
    --------------------------------------------------------------=#




    -- Set model
    local model = istable(NPCData.Models) && table.Random(NPCData.Models)
    if model then
		NPC.SpawnModel = model
        NPC:SetModel(model)
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
	local SpawnFlags = bit.bor( SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK, SF_NPC_LONG_RANGE )

	if istable(NPCData.SpawnFlagTbl) then
		for _, v in ipairs(NPCData.SpawnFlagTbl) do
			SpawnFlags = bit.bor( SpawnFlags, v )
		end
	end

	-- if ( NPCData.TotalSpawnFlags ) then SpawnFlags = NPCData.TotalSpawnFlags end
	-- if ( SpawnFlagsSaved ) then SpawnFlags = SpawnFlagsSaved end

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
	if ( Equipment && Equipment != "none" && valid ) then
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

    -- Spawn
	NPC:BeforeSpawn( NPCData )



	if isFirstSpawn then

		print("ass")
	
		NPC:Spawn()
		NPC:Activate()

		local ed = EffectData()
		ed:SetEntity( NPC )
		util.Effect( "zbasespawn", ed, true, true )

	end


	NPC.NPCName = Class
	NPC.NPCTable = NPCData


	-- Store spawnmenu data for addons and stuff
	NPC._wasSpawnedOnCeiling = wasSpawnedOnCeiling


	if ( bDropToFloor ) then
		NPC:DropToFloor()
	end


	-- Body groups
	if ( NPCData.BodyGroups ) then
		for k, v in pairs( NPCData.BodyGroups ) do
			NPC:SetBodygroup( k, v )
		end
	end


    -- "Register"
    table.insert(ZBaseNPCInstances, NPC)
	NPC:CallOnRemove("ZBaseNPCInstancesRemove", function() table.RemoveByValue(ZBaseNPCInstances, NPC) end)

	if !NPC.IsZBase_SNPC then
		table.insert(ZBaseNPCInstances_NonScripted, NPC)
		NPC:CallOnRemove("ZBaseNPCInstances_NonScripted_Remove", function() table.RemoveByValue(ZBaseNPCInstances_NonScripted, NPC) end)
	end


	-- Enhancement dogshit
	local EnhFunc = ZBaseEnhancementTable[NPCData.Class]
	if EnhFunc then

		EnhFunc(NPC)
		
		local EnhInitFunc = NPC.ZBaseEnhancedInit
		if EnhInitFunc then
			EnhInitFunc( NPC )
		end

	end


    NPC:ZBaseInit()


	duplicator.StoreEntityModifier( NPC, "ZBaseNPCDupeApplyStuff", {Class} )


	-- for i = 1, math.log(16777216, 2)+1 do
		-- MsgN(2^i, " ", NPC:HasSpawnFlags(2^i))
	-- end


	print("OAISHDOPAIUSHDOIUASH")
	return NPC
end
---------------------------------------------------------------------------------=#
function ZBaseInternalSpawnNPC( ply, Position, Normal, Class, Equipment, SpawnFlagsSaved, NoDropToFloor )
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
	if ( !IsValid( NPC ) ) then return end


	--
	-- Offset the position
	--
	NPC:SetPos( Position + Normal * 32 )
	if NPCData.Offset then
		timer.Simple(0, function()
			if !IsValid(NPC) then return end

			NPC:SetPos( Position + Normal * NPCData.Offset )
		end)

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


	NPC.ZBase_PlayerWhoSpawnedMe = ply


	return ZBaseInitialize( NPC, NPCData, Class, Equipment, true, wasSpawnedOnCeiling, bDropToFloor )
end


function Spawn_ZBaseNPC( ply, NPCClassName, WeaponName, tr )

	-- We don't support this command from dedicated server console
	if ( !IsValid( ply ) ) then return end

	if ( !NPCClassName ) then return end

	-- Give the gamemode an opportunity to deny spawning
	if ( !gamemode.Call( "PlayerSpawnNPC", ply, NPCClassName, WeaponName ) ) then return end

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


concommand.Add( "zbase_debug_spawn_many", function( ply, cmd, args )
	for x = 1, args[ 2 ] or 25 do
		for y = 1, args[ 2 ] or 25 do
			if ZBaseNPCs[args[ 1 ]] then
				Spawn_ZBaseNPC( ply, args[ 1 ], args[3], util.TraceLine({
					start = ply:GetEyeTrace().HitPos+Vector(x*200, y*200, 1000),
					endpos = ply:GetEyeTrace().HitPos+Vector(x*200, y*200, -1000),
					mask = MASK_NPCWORLDSTATIC,
				}) )
			else
				Spawn_NPC( ply, args[ 1 ], args[3], util.TraceLine({
					start = ply:GetEyeTrace().HitPos+Vector(x*200, y*200, 1000),
					endpos = ply:GetEyeTrace().HitPos+Vector(x*200, y*200, -1000),
					mask = MASK_NPCWORLDSTATIC,
				}) )
			end
		end
	end
end)

