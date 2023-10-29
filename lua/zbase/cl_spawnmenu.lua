local icon = "icon16/exclamation.png"
-----------------------------------------------------------------------------------------=#
hook.Add( "PopulateZBase", "ZBaseAddNPCContent", function( pnlContent, tree, node )
	-- Categorize
	local Categories = {}
	for k, v in pairs( ZBaseSpawnMenuNPCList ) do

		local Category = v.Category or "Other"
		if ( !isstring( Category ) ) then Category = tostring( Category ) end

		local Tab = Categories[ Category ] or {}
		Tab[ k ] = v
		Categories[ Category ] = Tab

	end

	-- Create an icon for each one and put them on the panel
	for CategoryName, v in SortedPairs( Categories ) do

		-- Add a node to the tree
		local node = tree:AddNode( CategoryName, "icon16/monkey.png" )

		-- When we click on the node - populate it using this function
		node.DoPopulate = function( self )

			-- If we've already populated it - forget it.
			if ( self.PropPanel ) then return end

			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "Name" ) do

				spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "npc", self.PropPanel, {
					nicename	= ent.Name or name,
					spawnname	= name,
					material	= ent.IconOverride or "entities/" .. name .. ".png",
					weapon		= ent.Weapons,
					admin		= ent.AdminOnly
				} )

			end

		end

		-- If we click on the node populate it and switch to it.
		node.DoClick = function( self )

			self:DoPopulate()
			pnlContent:SwitchPanel( self.PropPanel )

		end

	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end
end)
-----------------------------------------------------------------------------------------=#
spawnmenu.AddCreationTab( "ZBase", function(...)

    local pnlContent = vgui.Create( "SpawnmenuContentPanel" )
    pnlContent:CallPopulateHook( "PopulateZBase" )
    return pnlContent

end, icon)
-----------------------------------------------------------------------------------------=#