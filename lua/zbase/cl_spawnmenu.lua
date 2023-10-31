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
-- local factionColors = {
-- 	ally = Color(0, 255, 0),
-- }

function PANEL:AddTextEntry( text, func, startVal )
	local label = vgui.Create("DLabel", self)
	label:SetText(text)
	label:Dock(TOP)
	label:SetColor(Color(0,0,0))

	local textentry = vgui.Create("DTextEntry", self)
	textentry:Dock(TOP)

	local function setCol()
		-- if factionColors[textentry:GetText()] then
		-- 	label:SetTextColor(factionColors[textentry:GetText()])
		-- end
	end

	if startVal then
		textentry:SetText(startVal)
		setCol()
	end

	function textentry:OnEnter()
		func(textentry:GetText())
		setCol()
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
	self:SetOpenSize(300)

	self:AddHelp("Default factions:")
	self:AddHelp("	- ally - Allied with players and rebel NPCs")
	self:AddHelp("	- combine - Allied with combine NPCs")
	self:AddHelp("	- zombie - Allied with zombie NPCs")
	self:AddHelp("	- antlion - Allied with antlion NPCs")
	self:AddHelp("	- none - Allied with no NPCs")

	self:AddTextEntry("Your Faction:", function( v )
		net.Start("ZBasePlayerFactionSwitch")
		net.WriteString(v)
		net.SendToServer()
	end, "ally")

	self:AddTextEntry("NPC Faction Override:", function( v )
		net.Start("ZBaseNPCFactionOverrideSwitch")
		net.WriteString(v)
		net.SendToServer()
	end)

	self:Open()

end
-----------------------------------------------------------------------------------------=#
vgui.Register( "ZBaseSussyBaka", PANEL, "DDrawer" )
spawnmenu.AddCreationTab( "ZBase", function(...)

    local pnlContent = vgui.Create( "SpawnmenuContentPanel" )
	pnlContent:EnableSearch( "", "PopulateZBase" )
	pnlContent:CallPopulateHook( "PopulateZBase" )

	local sidebar = pnlContent.ContentNavBar
	sidebar.Options = vgui.Create( "ZBaseSussyBaka", sidebar )

    return pnlContent

end, icon, 25)
-----------------------------------------------------------------------------------------=#