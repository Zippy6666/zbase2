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

		panel.m_pPoster = vgui.Create( "DImage", self ) 		
		panel.m_pPoster:SetImage( posterTab['Image'], "vgui/zbase_menu.png" )

		panel.m_pPoster:SetSize( posterTab['Size'][ 1 ] || 512, posterTab['Size'][ 2 ] || 512 ) 		
		panel.m_pPoster:SetImageColor( posterTab['Color'] || Color( 255, 255, 255, 255 ) )
		panel.m_pPoster:SetKeepAspect( true )
		panel.m_pPoster:Dock( TOP )

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
ZBaseToolMenuGlobal = {}

function ZBaseAddToolMenu(category, name, panel, tab)
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
    for i = 1, #ZBaseToolMenuGlobal do
        local toolData = ZBaseToolMenuGlobal[ i ]
        if toolData then spawnmenu.AddToolMenuOption( "ZBase", toolData['Category'], IDCreate( toolData['Category'] ) .. "_" .. IDCreate( toolData['Name'] ) .. "_menu", toolData['Name'], nil, nil, toolData['Panel'], toolData['Table'] || nil ) end
    end        
end )

-- Example custom tool menu --

-- local SettingColor = Color( 0, 0, 0, 255 )
-- local SettingFont = "Trebuchet18"
-- local DescriptionColor = Color( 50, 50, 50, 255 )
-- local DescriptionFont = "DefaultSmall"

-- local posterTab = {
-- 	['Image'] 	= "Sex",
-- 	['Size'] 	= { 512, 600 },
-- 	['Color'] 	= Color( 255, 255, 255, 255 ),
-- }

-- ZBaseAddToolMenu( "NPC Pack", "Settings", function(panel) 

-- 	panel:ZBase_ToolMenuCustomize( "Sex", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )

-- 	panel:ZBase_ToolMenuAddCategory( "Category 1" )
-- 	panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Check Box", "anp_cup_medic_heal_all" ) }, SettingColor, SettingFont, "This is a DForm checkbox.", DescriptionColor, DescriptionFont )
-- 	panel:ZBase_ToolMenuAddItem( { panel:NumSlider( "Slider", "anp_cup_medic_heal_range", 50, 2048, 0 ) }, SettingColor, SettingFont, "This is a DForm slider.", DescriptionColor, DescriptionFont)
	
--     panel:ZBase_ToolMenuAddCategory( "Category 2" )
-- 	panel:ZBase_ToolMenuAddItem( { panel:Button( "Button", "anp_cup_over_dmg_res" ) }, SettingColor, SettingFont, "This is a DForm button.", DescriptionColor, DescriptionFont )
-- 	panel:ZBase_ToolMenuAddItem( { panel:ComboBox( "ComboBox", "anp_cup_over_dmg_res" ) }, SettingColor, SettingFont, "This is a DForm button.", DescriptionColor, DescriptionFont )

-- end ) 

--[[
==================================================================================================
                                           DEFAULT TOOL MENU
==================================================================================================
--]]

local SettingColor      = Color( 0, 0, 0, 255 )
local SettingFont       = "Trebuchet18"
local DescriptionColor  = Color( 50, 50, 50, 255 )
local DescriptionFont   = "DefaultSmall"
local posterTab = {
	['Image'] 	= "Sex",
	['Size'] 	= { 512, 600 },
	['Color'] 	= Color( 255, 255, 255, 255 ),
}

ZBaseAddToolMenu( "ZBASE", "Misc", function(panel)
    panel:ZBase_ToolMenuCustomize( "MISC", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )

    panel:ZBase_ToolMenuAddCategory( "MENU" )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Pop-Up", "zbase_popup" ) }, SettingColor, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "NPC Tab", "zbase_defmenu" ) }, SettingColor, SettingFont, "NPCs in regular NPC tab too", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Tab Mixin", "zbase_mixmenu" ) }, SettingColor, SettingFont, "Don't use separate categories in default NPC tab", DescriptionColor, DescriptionFont )

    panel:ZBase_ToolMenuAddCategory( "NPC GENERAL" )

    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Ply Hurt Ally", "zbase_ply_hurt_ally" ) }, SettingColor, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "NPC Hurt Ally", "zbase_friendly_fire" ) }, SettingColor, SettingFont, "", DescriptionColor, DescriptionFont )
    panel:ZBase_ToolMenuAddItem( { panel:CheckBox( "Nocollide between NPCs", "zbase_nocollide" ) }, SettingColor, SettingFont, "", DescriptionColor, DescriptionFont )

    panel:ZBase_ToolMenuAddCategory( "RESET" )

    local resetBtn = panel:ZBase_ToolMenuAddItem( { panel:Button( "Reset All Settings" ) }, SettingColor, SettingFont, "", DescriptionColor, DescriptionFont )
    resetBtn.DoClick = function()
        for k, v in pairs(ZBCVAR or {}) do
            if !v.Revert then continue end
            if !v.GetFlags then continue end
            if bit.band(v:GetFlags(), FCVAR_REPLICATED) == FCVAR_REPLICATED then continue end
            v:Revert()
        end
        if LocalPlayer():IsSuperAdmin() then
            RunConsoleCommand("zbase_resetsettings")
        end
    end
end)

ZBaseAddToolMenu( "ZBASE", "AI", function(panel)
    panel:ZBase_ToolMenuCustomize( "AI", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
end)

-- ZBaseAddToolMenu( "ZBASE", "Replace", function(panel)
--     panel:ZBase_ToolMenuCustomize( "REPLACE", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
-- end)

-- ZBaseAddToolMenu( "ZBASE", "Cleanup", function(panel)
--     panel:ZBase_ToolMenuCustomize( "CLEAN UP", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
-- end)

-- ZBaseAddToolMenu( "ZBASE", "Spawner", function(panel)
--     panel:ZBase_ToolMenuCustomize( "SPAWNER", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
-- end)

-- ZBaseAddToolMenu( "ZBASE", "Effects", function(panel)
--     panel:ZBase_ToolMenuCustomize( "FX", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
-- end)

-- ZBaseAddToolMenu( "ZBASE", "Dev", function(panel)
--     panel:ZBase_ToolMenuCustomize( "DEV", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
-- end)

ZBaseAddToolMenu( "DEF. NPCs", "Zombie", function(panel)
    panel:ZBase_ToolMenuCustomize( "ZOMBIE", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
end)

-- ZBaseAddToolMenu( "DEF. NPCs", "Combine", function(panel)
--     panel:ZBase_ToolMenuCustomize( "COMBINE", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
-- end)

-- ZBaseAddToolMenu( "DEF. NPCs", "Citizen", function(panel)
--     panel:ZBase_ToolMenuCustomize( "CITIZEN", Color( 255, 255, 255, 255 ), "ChatFont", Color( 150, 150, 150, 255 ), Color( 200, 200, 200, 255 ), posterTab  )
-- end)

-- local enableZBaseLogo   = CreateClientConVar("zbase_enable_logo", "0", true, false)

-- local function ZBaseAddMenuCategory( name, func, cat )
--     spawnmenu.AddToolMenuOption("ZBase", cat or "ZBase", name, name, "", "", function(panel)
--         if enableZBaseLogo:GetBool() then
--             panel:ControlHelp("")
--             panel:ControlHelp("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
--             panel:ControlHelp("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
--             panel:ControlHelp("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
--             panel:ControlHelp("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
--             panel:ControlHelp("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
--             panel:ControlHelp("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --")
--             panel:ControlHelp("")
--             panel:ControlHelp("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
--             panel:ControlHelp("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
--             panel:ControlHelp("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")
--         end

--         func(panel)
--     end)

-- end

-- hook.Add("PopulateToolMenu", "ZBASE", function()
--     spawnmenu.AddToolTab( "ZBase", "ZBase", "entities/zippy.png" )

--     --[[
--     ==================================================================================================
--                                             MISC
--     ==================================================================================================
--     --]]

--     ZBaseAddMenuCategory("Misc", function( panel )
--         panel:CheckBox("Pop-Up", "zbase_popup")

--         panel:CheckBox( "Logo", "zbase_enable_logo")
--         panel:Help("ASCII-style 'ZBASE' logo in menu, requires spawn menu reload")

--         panel:CheckBox("NPC Tab", "zbase_defmenu")
--         panel:Help("NPCs in regular NPC tab too")

--         panel:CheckBox("Tab Mixin", "zbase_mixmenu")
--         panel:Help("Don't use separate categories in default NPC tab")

--         panel:CheckBox( "Ply Hurt Ally", "zbase_ply_hurt_ally" )
--         panel:CheckBox( "NPC Hurt Ally", "zbase_friendly_fire" )

--         panel:CheckBox( "NPC Nocollide", "zbase_nocollide" )
--         panel:Help("Nocollide between NPCs")

--         local resetBtn = panel:Button("Reset All Settings")
--         resetBtn.DoClick = function()
--             for k, v in pairs(ZBCVAR or {}) do
--                 if !v.Revert then continue end
--                 if !v.GetFlags then continue end
--                 if bit.band(v:GetFlags(), FCVAR_REPLICATED) == FCVAR_REPLICATED then continue end
--                 v:Revert()
--             end
--             if LocalPlayer():IsSuperAdmin() then
--                 RunConsoleCommand("zbase_resetsettings")
--             end
--         end
--     end)

--     --[[
--     ==================================================================================================
--                                             AI
--     ==================================================================================================
--     --]]

--     ZBaseAddMenuCategory("AI", function( panel )
--         panel:NumSlider( "HP Mul", "zbase_hp_mult", 0, 20, 2 )
--         panel:NumSlider( "DMG Mul", "zbase_dmg_mult", 0, 20, 2 )

--         panel:CheckBox("Nerf", "zbase_nerf")
--         panel:Help("Nerf NPC AR2 alts, RPGs, crossbow, etc")

--         panel:NumSlider( "Grenades", "zbase_gren_count", -1, 20, 0 )
--         panel:Help("'-1' = inf")

--         panel:NumSlider( "Alt Fires", "zbase_alt_count", -1, 20, 0 )
--         panel:Help("'-1' = inf")

--         panel:CheckBox("Grenade/Alt Rnd", "zbase_gren_alt_rand")
--         panel:Help("NPCs spawn with 0 to MAX grenades & alts, where the sliders above are MAX")

--         panel:NumSlider("Max Shooters", "zbase_max_npcs_shoot_ply", 0, 10, 0)
--         panel:Help("Max NPCs that can shoot at a single player, '0' = infinite")
    
--         panel:CheckBox( "Patrol", "zbase_patrol" )

--         panel:CheckBox( "Call Allies", "zbase_callforhelp" )
--         panel:Help("Call any ally for help when in danger")

--         panel:CheckBox( "Squad", "zbase_autosquad" )
--         panel:Help("Initially spawn with same squad name as faction name")

--         panel:CheckBox("+USE Follow", "zbase_followplayers")
 
--         panel:CheckBox("Move Aid", "zbase_fallback_nav")
--         panel:Help("Enable if navigation is poor")
        
--         panel:CheckBox("Jump Aid", "zbase_more_jumping")
--         panel:Help("Enable if navigation is poor")

--         panel:NumSlider( "Sight Dist", "zbase_sightdist", 1, 30000, 0 )

--         panel:CheckBox("Override", "zbase_sightdist_override")
--         panel:Help("Override all ZBase NPC sight distances")
--     end)

--     --[[
--     ==================================================================================================
--                                             REPLACER
--     ==================================================================================================
--     --]]

--     ZBaseAddMenuCategory("Replace", function( panel )
--         panel:CheckBox("Menu Replace", "zbase_replace")
--         panel:Help("Should the default HL2 NPCs be replaced by their ZBase equivalents in the spawn menu? This only works if you have 'NPC Tab' option enabled. You will also need to restart the map for changes to take effect.")

--         panel:CheckBox("Campaign Replace", "zbase_camp_replace")
--         panel:Help("Enable the zbase campaign replace system. Replaces retail HL2 NPCs with any desired ZBase NPC.")
    
--         local ReloadButton = vgui.Create("DButton", panel)
--         ReloadButton:Dock(TOP)
--         ReloadButton:DockMargin(5, 25, 5, 0)
--         ReloadButton:SetText("Load Campaign Replace File")
--         function ReloadButton:DoClick()
--             net.Start("zbase_camp_replace_reload")
--             net.SendToServer()
--         end
--         panel:Help("Loads the 'zbase_campaign_replace.json' file in your data directory with your supplied changes.")
--     end)

--     --[[
--     ==================================================================================================
--                                             AFTERMATH
--     ==================================================================================================
--     --]]

--     ZBaseAddMenuCategory("Cleanup", function( panel )
--         panel:NumSlider( "Ragdoll Time", "zbase_rag_remove_time", 0, 600, 1 )
--         panel:Help("'0' = never")
--         panel:NumSlider( "Max Ragdolls", "zbase_rag_max", 1, 200, 0 )

--         panel:CheckBox( "CL Ragdolls", "zbase_cl_ragdolls")
--         panel:Help("Use client ragdolls instead, may not always work")

--         panel:NumSlider( "Gib Time", "zbase_gib_remove_time", 0, 600, 1 )
--         panel:Help("'0' = never")

--         panel:NumSlider( "Max Gibs", "zbase_gib_max", 1, 200, 0 )

--         panel:CheckBox( "Item Drops", "zbase_item_drops")
--         panel:CheckBox( "Dissolve Weapons", "zbase_dissolve_wep")
--     end)

--     --[[
--     ==================================================================================================
--                                             SPAWNERS
--     ==================================================================================================
--     --]]

--     ZBaseAddMenuCategory("Spawner", function( panel )
--         panel:NumSlider( "Spawn Cooldown", "zbase_spawner_cooldown", 0, 300, 2 )

--         panel:CheckBox( "VisCheck", "zbase_spawner_vis")
--         panel:Help("Don't spawn NPCs when in sight")

--         panel:CheckBox( "Check MinDist", "zbase_spawner_mindist")

--         panel:NumSlider( "MinDist", "zbase_spawner_mindist", 0, 20000, 0 )
--         panel:Help("Don't spawn this close to player")
--     end)

--     --[[
--     ==================================================================================================
--                                             EFFECTS
--     ==================================================================================================
--     --]]

--     ZBaseAddMenuCategory("Effects", function( panel )
--         panel:CheckBox("SV Glowing Eyes", "zbase_sv_glowing_eyes")
--         panel:Help("Network eye sprites globally")

--         panel:CheckBox("CL Glowing Eyes (Client)", "zbase_glowing_eyes")
--         panel:Help("Render eye sprites on client")

--         panel:CheckBox("Armor Spark", "zbase_armor_sparks")
--         panel:CheckBox("Follow Halo", "zbase_follow_halo")

--         panel:NumSlider("Light Quality", "zbase_muzzle_light", 0, 2, 0)

--         local mFlashesBox = panel:ComboBox("Muzzle Flashes", "zbase_muzztyle")
--         mFlashesBox:AddChoice("hl2")
--         mFlashesBox:AddChoice("black_mesa")
--         mFlashesBox:AddChoice("mmod")
--         mFlashesBox:ChooseOption(ZBCVAR.Muzzle:GetString())
 
--         local ar2FlashesBox = panel:ComboBox("AR2 Flashes", "zbase_mar2tyle")
--         ar2FlashesBox:AddChoice("hl2")
--         ar2FlashesBox:AddChoice("mmod")
--         ar2FlashesBox:ChooseOption(ZBCVAR.AR2Muzzle:GetString())
--     end)

--     --[[
--     ==================================================================================================
--                                             DEVELOPER
--     ==================================================================================================
--     --]]

--     ZBaseAddMenuCategory("Dev", function( panel )
--         local gitlink = panel:TextEntry("ZBase Github")
--         gitlink:SetValue("https://github.com/Zippy6666/zbase2")

--         panel:CheckBox( "Show Aerial Navigator", "zbase_show_navigator")
--         panel:Help("Show the 'ghost NPC' that Helps the aerial NPCs navigate.")

--         panel:CheckBox( "Show NPC Schedule", "zbase_show_sched")
--         panel:Help("Show what schedule the NPC is currently doing.")

--         panel:CheckBox( "ZBase Reload Spawnmenu", "zbase_reload_spawnmenu")
--         panel:Help("Should 'zbase_reload' also reload the spawn menu?")

--         local ReloadButton = vgui.Create("DButton", panel)
--         ReloadButton:Dock(TOP)
--         ReloadButton:DockMargin(5, 25, 5, 0)
--         ReloadButton:SetText("Reload NPCs")
--         function ReloadButton:DoClick()
--             net.Start("ZBaseReload")
--             net.SendToServer()
--         end
--         panel:Help("Runs 'zbase_reload' which can be necessary if your NPCs aren't updating properly on save.")
--     end)

--     --[[
--     ==================================================================================================
--                                             ZOMBIES
--     ==================================================================================================
--     --]]
    
--     ZBaseAddMenuCategory("Zombies", function( panel )
--         panel:CheckBox("Headcrabs", "zbase_zombie_headcrabs")
--         panel:CheckBox("Red Blood", "zbase_zombie_red_blood")
--     end, "NPCs")

--     --[[
--     ==================================================================================================
--                                             COMBINE
--     ==================================================================================================
--     --]]
    
--     ZBaseAddMenuCategory("Combine", function( panel )
--         panel:CheckBox("Metrocop Glow Eyes", "zbase_metrocop_glow_eyes")
--         panel:CheckBox("Metrocop Arrest", "zbase_metrocop_arrest")
--         panel:Help("Metrocops will 'arrest' enemies, instead of attacking immediately")
--     end, "NPCs")

--     --[[
--     ==================================================================================================
--                                             CITIZEN
--     ==================================================================================================
--     --]]
    
--     ZBaseAddMenuCategory("Citizens", function( panel )
--         panel:CheckBox("Give Ammo", "zbase_reb_ammo")
--         panel:CheckBox("Rock Throw", "zbase_cit_rocks")
--         panel:Help("For any unarmed citizen, refugee, rebel, or similiar")
--     end, "NPCs")
-- end)



