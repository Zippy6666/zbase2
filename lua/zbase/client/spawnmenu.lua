    -- Note: Contains a lot of borrowed gmod source code! --


local PANEL = {}
local icon = "entities/zbase.png"


Derma_Hook( PANEL, "Paint", "Paint", "Tree" )
PANEL.m_bBackground = true -- Hack for above


-----------------------------------------------------------------------------------------=#
local function DoGenericSpawnmenuRightclickMenu( self )
	local menu = DermaMenu()
	
	menu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText( self:GetSpawnName() ) end ):SetIcon( "icon16/page_copy.png" )
	if ( isfunction( self.OpenMenuExtra ) ) then
		self:OpenMenuExtra( menu )
	end

	menu:Open()
end
-----------------------------------------------------------------------------------------=#
spawnmenu.AddContentType("zbase_npcs", function( container, obj )
	if ( !obj.material ) then return end
	if ( !obj.nicename ) then return end
	if ( !obj.spawnname ) then return end
	if ( !obj.weapon ) then return end


	local icon = vgui.Create( "ContentIcon", container )
	icon:SetContentType( "zbase_npcs" )
	icon:SetSpawnName( obj.spawnname )
	icon:SetName( obj.nicename )
	icon:SetMaterial( obj.material )
	icon:SetAdminOnly( obj.admin )
	icon:SetColor( Color( 205, 92, 92, 255 ) )
	icon.DoClick = function()
		local override = GetConVar("gmod_npcweapon"):GetString()
		RunConsoleCommand( "zbase_spawnnpc", obj.spawnname, override == "" && table.Random(obj.weapon) or override )
		surface.PlaySound( "buttons/button16.wav" )
	end


	-- icon.OpenMenuExtra = function( self, menu )

	-- 	menu:AddOption( "#spawnmenu.menu.spawn_with_toolgun", function()
	-- 		RunConsoleCommand( "gmod_tool", "creator" )
	-- 		RunConsoleCommand( "creator_type", "0" )
	-- 		RunConsoleCommand( "creator_name", obj.spawnname, table.Random(obj.weapon) )
	-- 		end 
	-- 	):SetIcon( "icon16/brick_add.png" )

	-- end


	icon.OpenMenu = DoGenericSpawnmenuRightclickMenu


	if ( IsValid( container ) ) then
		container:Add( icon )
	end


	return icon
end)
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
				local icon = spawnmenu.CreateContentIcon( "zbase_npcs", self.PropPanel, {

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
function PANEL:AddTextEntry( text, func, startVal, placeholdertext )
	local label = vgui.Create("DLabel", self)
	label:SetText(text)
	label:Dock(TOP)
	label:SetColor(Color(0,0,0))

	local textentry = vgui.Create("DTextEntry", self)
	textentry:Dock(TOP)
	textentry:SetPlaceholderText(placeholdertext)

	if startVal then
		textentry:SetText(startVal)
	end

	function textentry:OnEnter()
		func(textentry:GetText())
	end
end
-----------------------------------------------------------------------------------------=#
function PANEL:AddHelp( text )
	local label = vgui.Create("DLabel", self)
	label:SetText(text)
	label:Dock(TOP)
	label:SetColor(Color(100,100,100))
end
-----------------------------------------------------------------------------------------=#
function PANEL:Init()

	self:DockPadding( 15, 10, 15, 10 )
	self:SetOpenSize(240)

	self:AddHelp("Default Factions")
	self:AddHelp("	> 'ally' - Allied with players and rebel NPCs")
	self:AddHelp("	> 'combine' - Allied with combine NPCs")
	self:AddHelp("	> 'zombie' - Allied with zombie NPCs")
	self:AddHelp("	> 'antlion' - Allied with antlion NPCs")
	self:AddHelp("	> 'none' - Allied with no NPCs")
	self:AddHelp("	> 'neutral' - Allied with all NPCs")

	self:AddTextEntry("Your Faction", function( v )
		if v != "" then
			net.Start("ZBasePlayerFactionSwitch")
			net.WriteString(v)
			net.SendToServer()
		end
	end, "ally", "Enter Your Faction Here")

	self:AddTextEntry("NPC Faction Override", function( v )
		net.Start("ZBaseNPCFactionOverrideSwitch")
		net.WriteString(v)
		net.SendToServer()
	end, nil, "No Override")

	self:Open()

end
-----------------------------------------------------------------------------------------=#
vgui.Register( "ZBaseSussyBaka", PANEL, "DDrawer" )
spawnmenu.AddCreationTab( "ZBase", function(...)

    local pnlContent = vgui.Create( "SpawnmenuContentPanel" )
	pnlContent:CallPopulateHook( "PopulateZBase" )

	local sidebar = pnlContent.ContentNavBar
	sidebar.Options = vgui.Create( "ZBaseSussyBaka", sidebar )

    return pnlContent

end, icon, 25)
-----------------------------------------------------------------------------------------=#