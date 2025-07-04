--[[
==================================================================================================
                                           META STUFF
==================================================================================================
--]]

local metaPanel = FindMetaTable( "Panel" )

-- Used to edit tool menu's header and background --
function metaPanel:ZBase_ToolMenuCustomize(text, textColor, textFont, catColor, bgColor, posterTab)

    bgColor = bgColor || Color( 255, 255, 255, 255 )
    local oldPaint = self.Paint
    self.Paint = function( self, w, h ) 
        oldPaint( self, w, h ) 

        surface.SetDrawColor( bgColor.r, bgColor.g, bgColor.b, bgColor.a )
        surface.DrawRect( 0, 0, w, h )

    end 

    local panel = self:GetChildren()[ 1 ]

    self.m_colCategory = catColor || Color( 17, 148, 240, 255 )
    
    panel.Paint = function( panel, w, h ) 
        surface.SetDrawColor( self.m_colCategory.r, self.m_colCategory.g, self.m_colCategory.b, self.m_colCategory.a )
        surface.DrawRect( 0, 0, w, h )
    end

    panel:SetText( text || panel:GetText() )

    self.m_colText = textColor || Color( 255, 255, 255, 255 )

    panel:SetTextColor( self.m_colText )

    self.m_sFont = textFont || "DermaDefaultBold"

    panel:SetFont( self.m_sFont )


    if posterTab then

        local w, h = posterTab['Size'][ 1 ] || 512, posterTab['Size'][ 2 ] || 512

        panel.m_pScroll = vgui.Create( "DHorizontalScroller", self )
        panel.m_pScroll:SetSize( w, h )     
        panel.m_pScroll:Dock( TOP )
        panel.m_pScroll.btnLeft.Paint = nil
        panel.m_pScroll.btnRight.Paint = nil

        panel.m_pPoster = vgui.Create( "DImage", panel.m_pScroll )         
        panel.m_pPoster:SetImage( posterTab['Image'], "vgui/zbase_menu.png" )
        panel.m_pPoster:SetSize( w, h )         
        panel.m_pPoster:SetImageColor( posterTab['Color'] || Color( 255, 255, 255, 255 ) )
        panel.m_pScroll:AddPanel( panel.m_pPoster )
        panel.m_pPoster:Dock( FILL )
        local scroll = posterTab['Scroll'] || 0

        if scroll && scroll > 0 then

            panel.m_pPoster.Think = function(self)            
                local time = CurTime() * posterTab['Scroll']
                scroll = math.abs( ( time % 2 ) - 1 ) * ( self:GetWide() - panel:GetParent():GetWide() )
                panel.m_pScroll:SetScroll( scroll )
            end

        end

    else

        self:SetHeaderHeight( 0 )

    end

end

-- Used to add tool menu items with a description. You should always put panel in a table --> {panel} as they usualy return more than one thing. --
function metaPanel:ZBase_ToolMenuAddItem(panel, textColor, textFont, desc, descColor, descFont)

    if !panel then return end

	local function CLabel(child)
		child = child.Label || child
		return ( isfunction(child.SetText) || isfunction(child.GetName) && child:GetName() == "DLabel" ) && child
	end

	for i = 1, #panel do
		local child = panel[ i ]
		child = ( child && CLabel(child) ) || CLabel(panel)
		if child then
			child:SetTextColor( textColor || child:GetTextColor() )
			child:SetFont( textFont || child:GetFont() )
		end
	end

	if desc then 
		local label = self:ControlHelp( desc ) 
		label:SetTextColor( descColor || label:GetTextColor() )
		label:SetFont( descFont || label:GetFont() )
	end

	return panel
end

-- Tool menu separator, great for making sub categories --
function metaPanel:ZBase_ToolMenuAddCategory(text, textColor, textFont, bgColor)
	
	local panel = vgui.Create( "DCategoryHeader", self )
	panel:Dock( TOP )
	panel:SetSize( 20, 20 )

	bgColor = bgColor || self.m_colCategory || Color( 17, 148, 240, 255 )
	panel:SetText( text || "" )

	panel:SetTextColor( textColor || self.m_colText || Color( 255, 255, 255, 255 ) )
	panel:SetFont( self.m_sFont || "DermaDefaultBold" )
	panel.Paint = function( self, w, h ) 
		surface.SetDrawColor( bgColor.r, bgColor.g, bgColor.b, bgColor.a )
		surface.DrawRect( 0, 0, w, h )
	end

	panel:SetMouseInputEnabled( false )

	return panel
end

--[[
==================================================================================================
                                           HOOKS?
==================================================================================================
--]]

-- Used to add custom tool menus with settings --
ZBaseToolMenuGlobal = ZBaseToolMenuGlobal or {}

function ZBaseAddToolMenuInternal(category, name, panel, tab)
	if ZBaseToolMenuGlobal then 
		local addTab = { [ #ZBaseToolMenuGlobal + 1 ] = { ['Category'] = category, ['Name'] = name, ['Panel'] = panel, ['Table'] = tab } } -- This should help with all these NPC spawner tools :/
		table.Merge( ZBaseToolMenuGlobal, addTab )				
	end
end

-- Should be added to your hook that adds default settings --
local invChars = {" ","{","}","[","]","(",")","!","+","=","?",".",",","/","-","`","~"}

local function IDCreate(name)
	for i = 1, #invChars do
		name = string.Replace( name, invChars[ i ], invChars[ i ] == " " && "_" || "" )	
	end	
	name = string.lower( name )	
	return name	
end

hook.Add( "AddToolMenuTabs", "ZBase_AddToolMenuTabs", function( category, name, panel, tab )
    spawnmenu.GetToolMenu( "ZBase", "ZBase", "entities/zippy.png" )
    for i = 1, #ZBaseToolMenuGlobal do
        local toolData = ZBaseToolMenuGlobal[ i ]
        if toolData then spawnmenu.AddToolMenuOption( "ZBase", toolData['Category'], IDCreate( toolData['Category'] ) .. "_" .. IDCreate( toolData['Name'] ) .. "_menu", toolData['Name'], nil, nil, toolData['Panel'], toolData['Table'] || nil ) end
    end
end )
