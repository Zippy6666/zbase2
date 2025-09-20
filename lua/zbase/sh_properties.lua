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
local function AddZBaseNPCProperty( name, icon, func, bZBaseOnly )
    local prop_tbl = {
        MenuLabel = name,
        Order = CurOrder,
        MenuIcon = icon, 
        ZBaseNPCRecieve = func,
        PrependSpacer = CurOrder==7000
    }

    table.Merge(prop_tbl, prop_shared)
    properties.Add( "ZBase"..name, prop_tbl )

    -- Don't filter out ZBase NPCs if we shouldn't
    if bZBaseOnly == false then
        prop_tbl.Filter = function( self, ent, ply )
            return IsValid(ply) && IsValid( ent ) && ent:IsNPC() && !ent.IsVJBaseSNPC
        end
    end

    CurOrder = CurOrder+1
end

if CLIENT then
    net.Receive("ZBaseUpdateSpawnMenuFactionDropDown", function()
        if LocalPlayer().FactionDropDown then
            LocalPlayer().FactionDropDown:ChooseOption(net.ReadString())
        end
    end)
end

AddZBaseNPCProperty("Control", "icon16/controller.png", function( self, npc, length, ply )
    if SERVER then
        ZBASE_CONTROLLER:StartControlling( ply, npc )
    end
end, false)

AddZBaseNPCProperty("Guard", "icon16/anchor.png", function( self, npc, length, ply )
    if SERVER then
        ply:ConCommand("zbase_guard " .. npc:EntIndex())
        conv.sendGModHint( ply, !npc.ZBase_Guard && "Enabled guarding." or "Disabled guarding.", 0, 2 )
    end

end, false)
 
AddZBaseNPCProperty("Join Faction", "icon16/connect.png", function( self, npc, length, ply )
    if npc.ZBaseFaction == ply.ZBaseFaction then
        ply:PrintMessage(HUD_PRINTTALK, "You are already in the same faction! ("..npc.ZBaseFaction..")")
        return
    end

    -- ply:PrintMessage(HUD_PRINTTALK, "You are now in ".. npc.Name .."'s faction ("..npc.ZBaseFaction..")")

    net.Start("ZBaseUpdateSpawnMenuFactionDropDown")
    net.WriteString(npc.ZBaseFaction)
    net.Send(ply)
end)

AddZBaseNPCProperty("Add to My Faction", "icon16/add.png", function( self, npc, length, ply )
    if npc.ZBaseFaction == ply.ZBaseFaction then
        ply:PrintMessage(HUD_PRINTTALK, "You are already in the same faction! ("..npc.ZBaseFaction..")")
        return
    end

    ZBaseSetFaction(npc, ply.ZBaseFaction, ply)
    -- ply:PrintMessage(HUD_PRINTTALK, npc.Name.." is now in your faction ("..ply.ZBaseFaction..")")
end)

AddZBaseNPCProperty("Kill", "icon16/gun.png", function( self, npc, length, ply )
    if !ply:IsAdmin() then return end

    local cls = npc:GetClass()

    -- This will make so that they will die
    -- regardless if they were previously allied
    npc.ZBaseFaction = "none"

    if cls == "npc_combinedropship" or cls == "npc_helicopter" or cls == "npc_combinegunship" then
        hook.Run("OnNPCKilled", npc, ply, game.GetWorld())
    end

    if cls == "npc_combinedropship" then
        npc:Remove()
        return
    end

    npc:SetHealth(0)
    conv.callNextTick(function()
        if !IsValid(npc) then return end

        local dmginfo = DamageInfo()
        dmginfo:SetDamage(npc:GetMaxHealth())
        dmginfo:SetAttacker(ply)
        dmginfo:SetInflictor(game.GetWorld())
        dmginfo:SetDamageForce(Vector(1,1,1))
        dmginfo:SetDamagePosition(npc:WorldSpaceCenter())
        dmginfo:SetDamageType(DMG_BLAST)

        if cls=="npc_helicopter" then
            dmginfo:SetDamageType(DMG_AIRBOAT)
        end

        npc:TakeDamageInfo(dmginfo)
    end)

end, false)