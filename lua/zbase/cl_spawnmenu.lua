-- Note: Contains a lot of borrowed gmod source code!

ZBaseCategoryImages = ZBaseCategoryImages or {}
ZBaseSetCategoryIcon( "HL2: Combine", "games/16/hl2.png" )
ZBaseSetCategoryIcon( "HL2: Zombies + Enemy Aliens", "games/16/hl2.png" )
ZBaseSetCategoryIcon( "HL2: Humans + Resistance", "games/16/hl2.png" )

local PANEL = {}
local GenericIcon = "entities/zippy.png"

Derma_Hook( PANEL, "Paint", "Paint", "Tree" )
PANEL.m_bBackground = true -- Hack for above

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
		local override = (ZBCVAR.RandWep:GetBool() && "zbase_random_weapon") or GetConVar("gmod_npcweapon"):GetString()

		RunConsoleCommand( "zbase_spawnnpc", obj.spawnname, override == "" && table.Random(obj.weapon) or override )
		surface.PlaySound( "buttons/button16.wav" )
	end
	icon.DoMiddleClick = function()
		local tr = LocalPlayer():GetEyeTrace()

		net.Start("ZBASE_CreateSpawner")
		net.WriteString(obj.spawnname)
		net.WriteVector(tr.HitPos + tr.HitNormal*5)
		net.SendToServer()

		surface.PlaySound( "buttons/button16.wav" )
	end

	icon.OpenMenu = function( self )
		local menu = DermaMenu()
		
		menu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText( self:GetSpawnName() ) end ):SetIcon( "icon16/page_copy.png" )
		if ( isfunction( self.OpenMenuExtra ) ) then
			self:OpenMenuExtra( menu )
		end
	
		menu:AddOption( "#spawnmenu.menu.spawn_with_toolgun", function()
			local override = (ZBCVAR.RandWep:GetBool() && "zbase_random_weapon") or GetConVar("gmod_npcweapon"):GetString()

			RunConsoleCommand( "gmod_tool", "creator" ) RunConsoleCommand( "creator_type", "2" )
			RunConsoleCommand( "creator_name", obj.spawnname ) RunConsoleCommand( "creator_arg", override == "" && table.Random(obj.weapon) or override )
		end ):SetIcon( "icon16/brick_add.png" )

		if LocalPlayer():IsSuperAdmin() then
			menu:AddOption( "Create Spawner", function()
				
				local tr = LocalPlayer():GetEyeTrace()

				net.Start("ZBASE_CreateSpawner")
				net.WriteString(obj.spawnname)
				net.WriteVector(tr.HitPos + tr.HitNormal*5)
				net.SendToServer()

				surface.PlaySound( "buttons/button16.wav" )
				
			end ):SetIcon( "icon16/control_repeat_blue.png" )
		end

		menu:Open()
	end

	if istable(obj.tblMisc) && isstring(obj.tblMisc.Class) && isstring(obj.tblMisc.Author) then
		icon:SetToolTip(obj.nicename .. "\n\nClass: '" .. obj.tblMisc.Class .. "'\nAuthor: " .. (obj.tblMisc.Author) .. "\n\n Middle-click to create spawner.")
	end

	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon
end)

local function GiveIconsToNode( pnlContent, tree, node, categories )
	node.DoPopulate = function( self ) -- When we click on the node - populate it using this function
		-- If we've already populated it - forget it.
		if ( self.PropPanel ) then return end

		-- Create the container panel
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		for category, npcdata in pairs(categories) do
			local header = vgui.Create("ContentHeader", self.PropPanel )
			header:SetText(category)
			self.PropPanel:Add( header )
			
			for name, ent in SortedPairsByMemberValue( npcdata, "Name" ) do
				local mat = ent.IconOverride or GenericIcon

				if file.Exists( "materials/entities/" .. name .. ".png", "GAME" ) then
					mat = "entities/" .. name .. ".png"
				end

				local icon = spawnmenu.CreateContentIcon( "zbase_npcs", self.PropPanel, {
					nicename	= ent.Name or name,
					spawnname	= name,
					material	= mat,
					weapon		= ent.Weapons,
					admin		= ent.AdminOnly,
					tblMisc		= ent
				} )
			end
		end
	end

	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end
end

hook.Add( "PopulateZBase", "ZBaseAddNPCContent", function( pnlContent, tree, node )
	-- Horror code
	local tbl = {}
	for class, npcdata in pairs( list.GetForEdit("NPC") ) do
		-- Skip non ZBase NPCs
		if !ZBaseNPCs[class] then continue end

		if isstring(npcdata.ZBaseCategory) then
			local split = string.Split(npcdata.ZBaseCategory, ": ")
			local s1, s2 = split[1], split[2]
			tbl[s1] = tbl[s1] or {}

			if s2 then
				tbl[s1][s2] = tbl[s1][s2] or {}
				tbl[s1][s2][class] = npcdata
			else
				tbl[s1][class] = npcdata
			end
		end
	end

	local allNPCs = {}

	local allNode = tree:AddNode( "ZBASE", GenericIcon )
	allNode:SetExpanded(!ZBCVAR.CollapseCat:GetBool())

	for divisionName, division in SortedPairs( tbl ) do
		local allCatIconsSame = true
		local lastIconPath

		for categoryName in pairs(division) do
			local catIcon = ZBaseCategoryImages[divisionName..": "..categoryName]
			if isstring(lastIconPath) && catIcon != lastIconPath then
				allCatIconsSame=false
			end
			lastIconPath = catIcon
		end

		if !lastIconPath then 
			lastIconPath=ZBaseCategoryImages[divisionName] 
		end

		local divisionIcon = (allCatIconsSame && lastIconPath ) or GenericIcon
		local divisionNPCs = {}
		local node = allNode:AddNode( divisionName, divisionIcon ) -- Add a node to the tree

		for categoryName, category in SortedPairs(division) do

			if ZBaseNPCs[categoryName] then
				-- This is not a category, it is npc data
				GiveIconsToNode( pnlContent, tree, node, {[divisionName]=division} )
				table.Merge(allNPCs, {[divisionName]=division})
			else
				node:SetExpanded(!ZBCVAR.CollapseCat:GetBool())

				local catNode = node:AddNode(categoryName, ZBaseCategoryImages[divisionName..": "..categoryName] or GenericIcon)
				GiveIconsToNode( pnlContent, tree, catNode, {[divisionName..": "..categoryName]=category} )
				divisionNPCs[categoryName] = category
			end

		end

		if !table.IsEmpty(divisionNPCs) then
			GiveIconsToNode( pnlContent, tree, node, divisionNPCs )

			for k, v in pairs(divisionNPCs) do
				allNPCs[k] = allNPCs[k] or {}
				table.Merge(allNPCs[k], v)
			end
		end
	end

	if !table.IsEmpty(allNPCs) then
		GiveIconsToNode( pnlContent, tree, allNode, allNPCs )
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

	timer.Create("ZBaseGiveFactionTableToDerma", 1, 1, function()
		if LocalPlayer().ZBaseDDrawer then
			LocalPlayer().ZBaseDDrawer:GetAllFactions(tbl)
		end

		if IsValid(LocalPlayer().ZBaseToolFactionCombox) then
			LocalPlayer().ZBaseToolFactionCombox:Clear()
			for k in pairs(tbl) do
				LocalPlayer().ZBaseToolFactionCombox:AddChoice(k)
			end
		end

		timer.Remove("ZBaseGiveFactionTableToDerma")
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

function PANEL:AddCheckbox( text, cvar )
	local DermaCheckbox = self:Add( "DCheckBoxLabel", self )
	DermaCheckbox:Dock( TOP )
	DermaCheckbox:SetText( text )
	DermaCheckbox:SetDark( true )
	DermaCheckbox:SetConVar( cvar)
	DermaCheckbox:SizeToContents()
	DermaCheckbox:DockMargin( 0, 5, 0, 0 )
end

function PANEL:Init()
	self:DockPadding( 15, 10, 15, 10 )
	self:SetOpenSize(150)

	self:AddCheckbox( "Random Weapons", "zbase_randwep" )

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