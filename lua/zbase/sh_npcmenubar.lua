local zbwepinfo = CLIENT && {} || nil

hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )
	if swep.IsZBaseWeapon && class != "weapon_zbase" && swep.NPCSpawnable then 
        local wepinfo = { 
            class       = class, 
            title       = swep.PrintName, 
            category    = swep.Category, 
            author      = swep.Author,
        }
        
        -- Add to NPC usable weapons serverside
		if SERVER then
            list.Add( "NPCUsableWeapons", wepinfo )
        end

        -- Add to ZBase weapon table clientside
        -- This will show up in a custom drop down in the C menu
        if CLIENT then
            table.insert(zbwepinfo, wepinfo)
        end

        -- Add to language
        if CLIENT && language.GetPhrase(class) == class then
            language.Add(class, swep.PrintName) 
        end
	end
end)

if CLIENT then
    local function giveZBaseIcon(pnl)
        pnl.ZBaseIcon = vgui.Create("DImage", pnl)
        pnl.ZBaseIcon:SetImage("entities/zippy.png")
        pnl.ZBaseIcon:SetSize(16, 16)
        pnl.ZBaseIcon:SetPos(3, 3)
        pnl.OnChecked = conv.wrapFunc2(pnl.OnChecked, function(_, checked)
            pnl.ZBaseIcon:SetImage( checked && "icon16/accept.png" || "entities/zippy.png" )
        end)
    end

    -- Separate ZBase Weapons from regular NPC weapons
    hook.Add("PopulateMenuBar", "ZBASE", function( menubar )
        local npcmenu = menubar:AddOrGetMenu( "#menubar.npcs" )
        
        local factions = npcmenu:AddSubMenu( "Player Faction" )
        ZBaseNPCFactionBar = factions
        giveZBaseIcon(factions:GetParent())
        factions:SetDeleteSelf( false )

        local rndweppnl = npcmenu:AddCVar("Randomize Weapons", "zbase_randwep", "1", "0")
        giveZBaseIcon(rndweppnl)

        local guardpnl = npcmenu:AddCVar("Spawn as Guards", "zbase_guardonspwn", "1", "0")
        giveZBaseIcon(guardpnl)

        local spwndocpnl = npcmenu:AddCVar("Spawn Docile", "zbase_spwndocile", "1", "0")
        giveZBaseIcon(spwndocpnl)

        local zbwpns = npcmenu:AddSubMenu( "ZBase Weapons" )
        giveZBaseIcon(zbwpns:GetParent())
        zbwpns:SetDeleteSelf( false )

        local groupedWeps = {}
        local noAuthorWpns = {}
        for _, v in pairs( zbwepinfo ) do
            if !isstring(v.author) || v.author == "" then
                noAuthorWpns[#noAuthorWpns+1] = v
                continue
            end

            groupedWeps[ v.author ] = groupedWeps[ v.author ] || {}
            groupedWeps[ v.author ][ v.class ] = language.GetPhrase( v.title )
        end

        for group, items in SortedPairs( groupedWeps ) do
            local authormenu = zbwpns:AddSubMenu( group )
            authormenu:SetDeleteSelf( false )

            for class, title in SortedPairsByValue( items ) do
                authormenu:AddCVar( title, "gmod_npcweapon", class )
            end
        end

        zbwpns:AddSpacer()
        for _, v in ipairs( noAuthorWpns ) do
            zbwpns:AddCVar( v.title, "gmod_npcweapon", v.class )
        end
    end)
end