local PANEL = {}
local icon = "entities/zbase.png"

Derma_Hook( PANEL, "Paint", "Paint", "Tree" )
PANEL.m_bBackground = true -- Hack for above

-----------------------------------------------------------------------------------------=#
hook.Add( "PopulateZBase", "ZBaseAddNPCContent", function( pnlContent, tree, node )
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
		local node = tree:AddNode( CategoryName, icon ) -- Add a node to the tree

		node.DoPopulate = function( self ) -- When we click on the node - populate it using this function
			-- If we've already populated it - forget it.
			if ( self.PropPanel ) then return end

			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "Name" ) do
				local icon = spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "npc", self.PropPanel, {

					nicename	= ent.Name or name,
					spawnname	= name,

					material	=
								ent.IconOverride
								or file.Exists( "materials/entities/" .. name .. ".png", "GAME" )&&"entities/" .. name .. ".png"
								or icon,

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
function PANEL:AddCheckbox( text, cvar )
	local DermaCheckbox = self:Add( "DCheckBoxLabel", self )
	DermaCheckbox:Dock( TOP )
	DermaCheckbox:SetText( text )
	DermaCheckbox:SetDark( true )
	DermaCheckbox:SetConVar( cvar)
	DermaCheckbox:SizeToContents()
	DermaCheckbox:DockMargin( 0, 5, 0, 0 )
end
-----------------------------------------------------------------------------------------=#
function PANEL:Init()

	self:SetOpenSize( 150 )
	self:DockPadding( 15, 10, 15, 10 )

	self:AddCheckbox( "#menubar.npcs.disableai", "ai_disabled" )
	self:AddCheckbox( "#menubar.npcs.ignoreplayers", "ai_ignoreplayers" )
	self:AddCheckbox( "#menubar.npcs.keepcorpses", "ai_serverragdolls" )
	self:AddCheckbox( "#menubar.npcs.autoplayersquad", "npc_citizen_auto_player_squad" )

	local label = vgui.Create( "DLabel", self )
	label:Dock( TOP )
	label:DockMargin( 0, 5, 0, 0 )
	label:SetDark( true )
	label:SetText( "#menubar.npcs.weapon" )

	local DComboBox = vgui.Create( "DComboBox", self )
	DComboBox:Dock( TOP )
	DComboBox:DockMargin( 0, 0, 0, 0 )
	DComboBox:SetConVar( "gmod_npcweapon" )
	DComboBox:SetSortItems( false )

	DComboBox:AddChoice( "#menubar.npcs.defaultweapon", "" )
	DComboBox:AddChoice( "#menubar.npcs.noweapon", "none" )

	-- Sort the items by name, and group by category
	local groupedWeps = {}
	for _, v in pairs( list.Get( "NPCUsableWeapons" ) ) do
		local cat = (v.category or ""):lower()
		groupedWeps[ cat ] = groupedWeps[ cat ] or {}
		groupedWeps[ cat ][ v.class ] = language.GetPhrase( v.title )
	end

	for group, items in SortedPairs( groupedWeps ) do
		DComboBox:AddSpacer()
		for class, title in SortedPairsByValue( items ) do
			DComboBox:AddChoice( title, class )
		end
	end

	function DComboBox:OnSelect( index, value )
		self:ConVarChanged( self.Data[ index ] )
	end

	self:Open()

end
-----------------------------------------------------------------------------------------=#
vgui.Register( "SpawnmenuNPCSidebarToolbox", PANEL, "DDrawer" )
spawnmenu.AddCreationTab( "ZBase", function(...)

    local pnlContent = vgui.Create( "SpawnmenuContentPanel" )
	pnlContent:EnableSearch( "npcs", "PopulateZBase" )
	pnlContent:CallPopulateHook( "PopulateZBase" )

	local sidebar = pnlContent.ContentNavBar
	sidebar.Options = vgui.Create( "SpawnmenuNPCSidebarToolbox", sidebar )
    
    return pnlContent

end, icon, 25)
-----------------------------------------------------------------------------------------=#