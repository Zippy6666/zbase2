-- util.AddNetworkString( "zippy_callonclient_ent" )
-- util.AddNetworkString( "zippy_callonclient" )

-- function ZippyCallOnClient( ply, ent, functionName, ... ) -- ANPlusCallOnClient( "SetColorOnClient", "Color( 255, 255, 255 )" )

-- 	if !isstring(functionName) || !... then return end

-- 	local data = {...}
	
-- 	for i = 1, #data do 

-- 		local var = data[ i ]

-- 		if isentity(var) then
-- 			data[ i ] = tostring( var )
-- 		elseif isbool(var) then
-- 			data[ i ] = var == true && "true" || var == false && "false" || "nil"
-- 		elseif isnumber(var) then
-- 			data[ i ] = tostring( var )
-- 		elseif isvector(var) then
-- 			data[ i ] = "Vector( " .. var.x .. ", " .. var.y .. ", " .. var.z .. " )"
-- 		elseif isangle(var) then
-- 			data[ i ] = "Angle( " .. var.p .. ", " .. var.y .. ", " .. var.r .. " )"
-- 		elseif IsColor(var) then
-- 			data[ i ] = "Color( " .. var.r .. ", " .. var.g .. ", " .. var.b .. ", " .. var.a .. " )"
-- 		end

-- 		local send = {}
		
-- 		if i == #data then
-- 			data = table.concat( data, "; ", 1, #data )

-- 			if IsValid(ent) || ent == game.GetWorld() then
-- 				net.Start( "zippy_callonclient_ent" )
-- 				net.WriteEntity( ent )
-- 			else
-- 				net.Start( "zippy_callonclient" )
-- 			end
-- 			net.WriteString( functionName )
-- 			net.WriteString( data )
			
-- 			if IsValid(ply) && ply:IsPlayer() then
-- 				net.Send( ply )
-- 			else
-- 				net.Broadcast()
-- 			end
-- 		end

-- 	end

-- end