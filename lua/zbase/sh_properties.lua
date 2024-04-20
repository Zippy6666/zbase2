if SERVER then
    util.AddNetworkString("ZBaseUpdateSpawnMenuFactionDropDown")
end


--[[
======================================================================================================================================================
                                           Funcs
======================================================================================================================================================
--]]


local prop_shared = {
	Filter = function( self, ent, ply ) -- A function that determines whether an entity is valid for this property
		return IsValid(ply) && IsValid( ent ) && ent:GetNWBool("IsZBaseNPC")
	end,
    Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()
    end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local npc = net.ReadEntity()
		if ( !properties.CanBeTargeted( npc, ply ) ) then return end
		if ( !self:Filter( npc, ply ) ) then return end
        self:ZBaseNPCRecieve(npc, length, ply)
	end
}


local CurOrder = 7000
local function AddZBaseNPCProperty( name, icon, func )

    local prop_tbl = {
        MenuLabel = "[ZBase] "..name,
        Order = CurOrder,
        MenuIcon = icon, 
        ZBaseNPCRecieve = func,
    }

    table.Merge(prop_tbl, prop_shared)
    properties.Add( "ZBase"..name, prop_tbl )

    CurOrder = CurOrder+1

end


if CLIENT then

    net.Receive("ZBaseUpdateSpawnMenuFactionDropDown", function()
        if LocalPlayer().FactionDropDown then
            LocalPlayer().FactionDropDown:ChooseOption(net.ReadString())
        end
    end)

end


--[[
======================================================================================================================================================
                                           Add properties
======================================================================================================================================================
--]]


AddZBaseNPCProperty("Join Faction", "icon16/connect.png", function( self, npc, length, ply )

    if npc.ZBaseFaction == ply.ZBaseFaction then
        ply:PrintMessage(HUD_PRINTTALK, "You are already in the same faction! ("..npc.ZBaseFaction..")")
        return
    end

    ZBaseSetFaction(ply, npc.ZBaseFaction)
    ply:PrintMessage(HUD_PRINTTALK, "You are now in ".. npc.Name .."'s faction ("..npc.ZBaseFaction..")")

    net.Start("ZBaseUpdateSpawnMenuFactionDropDown")
    net.WriteString(npc.ZBaseFaction)
    net.Send(ply)

end)

AddZBaseNPCProperty("Add to My Faction", "icon16/add.png", function( self, npc, length, ply )

    if npc.ZBaseFaction == ply.ZBaseFaction then
        ply:PrintMessage(HUD_PRINTTALK, "You are already in the same faction! ("..npc.ZBaseFaction..")")
        return
    end

    ZBaseSetFaction(npc, ply.ZBaseFaction)
    ply:PrintMessage(HUD_PRINTTALK, npc.Name.." is now in your faction ("..ply.ZBaseFaction..")")

end)

AddZBaseNPCProperty("Kill", "icon16/gun.png", function( self, npc, length, ply )

    npc:TakeDamage(0, ply, ply)
    npc:InduceDeath()

end)
