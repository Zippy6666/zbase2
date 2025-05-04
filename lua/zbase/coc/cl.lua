-- local function normUserData( tab, typeOf )
-- 	for i = 1, #tab do
-- 		local data = tab[ i ]
-- 		data = string.gsub( data, typeOf, "" )
-- 		data = string.gsub( data, "[()]", "" )
-- 		data = string.gsub( data, " ", "" )
-- 		tab[ i ] = data
-- 	end

-- 	return tab
-- end

-- local function COCTranslate(data, funcN, ent)

-- 	local vars = string.find( data:lower(), "; " ) && string.Split( data, "; " ) || string.find( data:lower(), ";" ) && string.Split( data, ";" ) || { [1] = data }

-- 	for i = 1, #vars do

-- 		local var = vars[ i ]
		
-- 		if var && string.find( var, "Player " ) || string.find( var, "NPC " ) || string.find( var, "Entity " ) || string.find( var, "Vehicle " ) then
-- 			local type = string.find( var, "Player " ) && "Player [[]" || string.find( var, "NPC " ) && "NPC [[]" || string.find( var, "Entity " ) && "Entity [[]" || string.find( var, "Vehicle " ) && "Vehicle [[]"
-- 			local splts = string.Split( var, "]" )
-- 			local entID = string.gsub( splts[ 1 ], type, "" )
			
-- 			entID = tonumber( entID )

-- 			vars[ i ] = Entity( entID ) 
-- 			var = nil			
-- 		end

-- 		if var && string.find( var, "Color" ) && string.find( var, "[()]" ) then 
-- 			local splts = string.find( var:lower(), ", " ) && string.Split( var, ", " ) || string.find( var:lower(), "," ) && string.Split( var, "," )

-- 			splts = normUserData( splts, "Color" )

-- 			vars[ i ] = splts[ 4 ] && Color( splts[ 1 ], splts[ 2 ], splts[ 3 ], splts[ 4 ] ) || Color( splts[ 1 ], splts[ 2 ], splts[ 3 ] )
-- 			var = nil 							
-- 		end

-- 		if var && string.find( var, "Vector" ) && string.find( var, "[()]" ) then
-- 			local splts = string.find( var:lower(), ", " ) && string.Split( var, ", " ) || string.find( var:lower(), "," ) && string.Split( var, "," )

-- 			splts = normUserData( splts, "Vector" )

-- 			vars[ i ] = Vector( splts[ 1 ], splts[ 2 ], splts[ 3 ] )
-- 			var = nil
-- 		end

-- 		if var && string.find( var, "Angle" ) && string.find( var, "[()]" ) then
-- 			local splts = string.find( var:lower(), ", " ) && string.Split( var, ", " ) || string.find( var:lower(), "," ) && string.Split( var, "," )

-- 			splts = normUserData( splts, "Angle" )

-- 			vars[ i ] = Angle( splts[ 1 ], splts[ 2 ], splts[ 3 ] )
-- 			var = nil
-- 		end

-- 		if var then
-- 			if string.find( var, "true" ) then
-- 				vars[ i ] = true 
-- 				var = nil
-- 			elseif string.find( var, "false" ) then
-- 				vars[ i ] = false 	
-- 				var = nil
-- 			elseif string.find( var, "nil" ) then
-- 				vars[ i ] = nil 
-- 				var = nil
-- 			end
-- 		end

-- 		if var && string.find( var, "%d" ) && !string.find( var, "%a" ) then 
-- 			vars[ i ] = tonumber( var ) 
-- 			var = nil 
-- 		end

-- 		if var && string.find( var, "%a" ) then		

-- 			vars[ i ] = var 
-- 			var = nil 
-- 		end

-- 	end	

-- 	if ent then
-- 		ent[ funcN ]( ent, vars[ 1 ], vars[ 2 ], vars[ 3 ], vars[ 4 ], vars[ 5 ], vars[ 6 ], vars[ 7 ], vars[ 8 ], vars[ 9 ] )
-- 	else
-- 		funcN( vars[ 1 ], vars[ 2 ], vars[ 3 ], vars[ 4 ], vars[ 5 ], vars[ 6 ], vars[ 7 ], vars[ 8 ], vars[ 9 ] )
-- 	end

-- end

-- net.Receive( "zippy_callonclient_ent", function()

-- 	local ent = net.ReadEntity()
-- 	local funcN = net.ReadString()
-- 	local data = net.ReadString()
	
-- 	if IsValid(ent) || ent == game.GetWorld() then

-- 		if isfunction( ent[ funcN ] ) then

-- 			COCTranslate( data, funcN, ent )

-- 		end

-- 	end

-- end )

-- net.Receive( "zippy_callonclient", function()

-- 	local funcN = net.ReadString()
-- 	local data = net.ReadString()
	
-- 	funcN = _G[ funcN ]

-- 	if isfunction( funcN ) then

-- 		COCTranslate( data, funcN )

-- 	end

-- end )