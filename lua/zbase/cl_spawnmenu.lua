    -- Note: Contains a lot of borrowed gmod source code! --


ZBaseCategoryImages = ZBaseCategoryImages or {}
ZBaseSetCategoryIcon( "HL2: Combine", "games/16/hl2.png" )
ZBaseSetCategoryIcon( "HL2: Zombies + Enemy Aliens", "games/16/hl2.png" )
ZBaseSetCategoryIcon( "HL2: Humans + Resistance", "games/16/hl2.png" )


local PANEL = {}
local GenericIcon = "entities/zippy.png"


Derma_Hook( PANEL, "Paint", "Paint", "Tree" )
PANEL.m_bBackground = true -- Hack for above




hook.Add("InitPostEntity", "ZBaseReplaceFuncsClient", function()
	-- this does something important idk what
	local spawnmenu_reload = concommand.GetTable()["spawnmenu_reload"]


	
	
	concommand.Add("spawnmenu_reload", function(...)
        ZBase_JustReloadedSpawnmenu = true

		spawnmenu_reload(...)

        timer.Simple(0.5, function()
            ZBase_JustReloadedSpawnmenu = false 
        end)
	end)
	
	
end)


local function DoGenericSpawnmenuRightclickMenu( self )
	local menu = DermaMenu()
	
	menu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText( self:GetSpawnName() ) end ):SetIcon( "icon16/page_copy.png" )
	if ( isfunction( self.OpenMenuExtra ) ) then
		self:OpenMenuExtra( menu )
	end

	menu:Open()
end


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


	icon.OpenMenu = DoGenericSpawnmenuRightclickMenu


	if ( IsValid( container ) ) then
		container:Add( icon )
	end


	return icon
end)


hook.Add( "PopulateZBase", "ZBaseAddNPCContent", function( pnlContent, tree, node )

	-- Find all categories
	local Categories = {}
	for k, v in pairs( ZBaseSpawnMenuNPCList ) do
		local Category = v.Category or "Other"
		if ( !isstring( Category ) ) then Category = tostring( Category ) end

		local Tab = Categories[ Category ] or {}
		Tab[ k ] = v
		Categories[ Category ] = Tab
	end



	-- THE ALL NODE
	local all_node = tree:AddNode( "[ALL]", GenericIcon ) -- Add a node to the tree
	local AllPropPanel
	all_node.DoPopulate = function( self ) -- When we click on the node - populate it using this function
		-- If we've already populated it - forget it.
		if ( self.PropPanel ) then return end

		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )
		AllPropPanel = self.PropPanel
	end
	-- If we click on the node populate it and switch to it.
	all_node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end
	all_node:InternalDoClick()

	-- Create the categories
	for CategoryName, v in SortedPairs( Categories ) do
		local node = tree:AddNode( CategoryName, ZBaseCategoryImages[CategoryName] or GenericIcon ) -- Add a node to the tree
		node.DoPopulate = function( self ) -- When we click on the node - populate it using this function
			-- If we've already populated it - forget it.
			if ( self.PropPanel ) then return end

			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "Name" ) do
				local mat = ent.IconOverride or GenericIcon

				if file.Exists( "materials/entities/" .. name .. ".png", "GAME" ) then
					mat = "entities/" .. name .. ".png"
				end

				local icon = spawnmenu.CreateContentIcon( "zbase_npcs", self.PropPanel, {
					nicename	= ent.Name or name,
					spawnname	= name,
					material	= mat,
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
	

		-- Populate "All" category with the npcs of this category
		for name, ent in SortedPairsByMemberValue( v, "Name" ) do
			local mat = ent.IconOverride or GenericIcon

			if file.Exists( "materials/entities/" .. name .. ".png", "GAME" ) then
				mat = "entities/" .. name .. ".png"
			end

			local icon = spawnmenu.CreateContentIcon( "zbase_npcs", AllPropPanel, {
				nicename	= ent.Name or name,
				spawnname	= name,
				material	= mat,
				weapon		= ent.Weapons,
				admin		= ent.AdminOnly,
			} )
		end
	end
end)


function PANEL:GetAllFactions( factions )
	self.PlyFactionDropDown:Clear()
	self.NPCFactionDropDown:Clear()

	self.NPCFactionDropDown:AddChoice("No Override")

	for k in pairs(factions) do
		self.PlyFactionDropDown:AddChoice(k)
		self.NPCFactionDropDown:AddChoice(k)
	end

	self.PlyFactionDropDown:ChooseOption(self.PlyFactionDropDown.StartVal)
	self.NPCFactionDropDown:ChooseOption(self.NPCFactionDropDown.StartVal)
end


net.Receive("ZBaseListFactions", function()
	local tbl = table.Copy(net.ReadTable())


	timer.Create("ZBasePlayerDDrawerGiveFactionTable", 1, 1, function()
		if LocalPlayer().ZBaseDDrawer then
			LocalPlayer().ZBaseDDrawer:GetAllFactions(tbl)
			timer.Remove("ZBasePlayerDDrawerGiveFactionTable")
		end
	end)
end)


function PANEL:AddDropdown( text, func, startVal )
	local label = vgui.Create("DLabel", self)
	label:SetText(text)
	label:Dock(TOP)
	label:SetColor(Color(0,0,0))

	local dropdown = vgui.Create("DComboBox", self)
	dropdown:Dock(TOP)
	function dropdown:OnSelect(_, faction)
		func(faction)
	end

	dropdown.StartVal = startVal

	return dropdown
end


function PANEL:AddHelp( text )
	local label = vgui.Create("DLabel", self)
	label:SetText(text)
	label:Dock(TOP)
	label:SetColor(Color(100,100,100))
end


function PANEL:Init()

	self:DockPadding( 15, 10, 15, 10 )
	self:SetOpenSize(135)

	self:AddHelp("Faction Settings")

	self.PlyFactionDropDown = self:AddDropdown("Your Faction", function( v )
		if v != "" then
			net.Start("ZBasePlayerFactionSwitch")
			net.WriteString(v)
			net.SendToServer()
		end
	end, "ally")
	LocalPlayer().FactionDropDown = self.PlyFactionDropDown

	self.NPCFactionDropDown = self:AddDropdown("NPC Faction Override", function( v )
		net.Start("ZBaseNPCFactionOverrideSwitch")
		net.WriteString(v)
		net.SendToServer()
	end, "No Override")

	ZBaseListFactions()

	self:Open()

end


vgui.Register( "ZBaseSussyBaka", PANEL, "DDrawer" )
spawnmenu.AddCreationTab( "ZBase", function(...)

    local pnlContent = vgui.Create( "SpawnmenuContentPanel" )
	pnlContent:CallPopulateHook( "PopulateZBase" )


	local sidebar = pnlContent.ContentNavBar
	sidebar.Options = vgui.Create( "ZBaseSussyBaka", sidebar )


	timer.Create("ZBasePlayerDDrawer", 1, 1, function()
		if IsValid(LocalPlayer()) then
			LocalPlayer().ZBaseDDrawer = sidebar.Options
			timer.Remove("ZBasePlayerDDrawer")
		end
	end)


    return pnlContent

end, "entities/zippy.png", 25)

