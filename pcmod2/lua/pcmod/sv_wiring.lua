
// ---------------------------------------------------------------------------------------------------------
// sv_wiring.lua - Revision 1
// Server-Side
// Loads wiring based functions
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------

PCMod.Wiring = {}
PCMod.Wiring.Version = "1.0"
PCMod.Wiring.WireTypes = PCMod.Cfg.WireTypes

PCMod.Msg( "Wiring Library Loaded (V" .. PCMod.Wiring.Version .. ")", true )


// ---------------------------------------------------------------------------------------------------------
// TypeToName - Converts a port type to the nice name
// ---------------------------------------------------------------------------------------------------------
function PCMod.Wiring.TypeToName( ptype )
	for _, v in pairs( PCMod.Wiring.WireTypes ) do
		if (v.Name == ptype) then return v.ExtName end
	end
	return "Unknown"
end

// ---------------------------------------------------------------------------------------------------------
// CanWireSameType - Determines if a wire type can be wired to the same class
// ---------------------------------------------------------------------------------------------------------
function PCMod.Wiring.CanWireSameType( ptype )
	for _, v in pairs( PCMod.Wiring.WireTypes ) do
		if (v.Name == ptype) then return v.SameType end
	end
	return false
end

// ---------------------------------------------------------------------------------------------------------
// LinkPorts - Links two ports together
// ---------------------------------------------------------------------------------------------------------
function PCMod.Wiring.LinkPorts( srcent, srcprt, destent, destprt, ropetable, cties )
	if ((!srcent) || (!srcent:IsValid()) || (!srcent.IsPCMod)) then return false end
	if ((!destent) || (!destent:IsValid()) || (!destent.IsPCMod)) then return false end
	local source = srcent:Ports()[srcprt]
	if (!source) then return false end
	local dest = destent:Ports()[destprt]
	if (!dest) then return false end
	if (source.Connected || dest.Connected) then return false end
	source.Connected = true
	source.ConEnt = destent
	source.RemotePort = destprt
	source.RopeTable = ropetable
	source.CableTies = cties
	srcent:UpdatePort( srcprt, source )
	dest.Connected = true
	dest.ConEnt = srcent
	dest.RemotePort = srcprt
	dest.RopeTable = ropetable
	dest.CableTies = cties
	destent:UpdatePort( destprt, dest )
	srcent:FireEvent( { "linked", srcprt } )
	destent:FireEvent( { "linked", destprt } )
	return true
end

// ---------------------------------------------------------------------------------------------------------
// UnlinkPort - Unlinks a port, as well as it's target
// ---------------------------------------------------------------------------------------------------------
function PCMod.Wiring.UnlinkPort( srcent, srcprt )
	if ((!srcent) || (!srcent:IsValid()) || (!srcent.IsPCMod)) then return false end
	local source = srcent:Ports()[srcprt]
	if (source.RopeTable) then PCMod.Wiring.UnlinkRopeTable( source.RopeTable ) end
	source.RopeTable = nil
	if (source.CableTies) then
		for _, ent in pairs( source.CableTies ) do
			if ((ent) && (ent:IsValid()) && (ent.IsCableTie)) then
				PCMod.Wiring.RemoveEntPortLink( ent, srcent, srcprt )
			end
		end
	end
	if (!source) then return false end
	if (!source.Connected) then return false end
	local destent = source.ConEnt
	if ((!destent) || (!destent:IsValid()) || (!destent.IsPCMod)) then return false end
	local dest = destent:Ports()[source.RemotePort]
	if (dest) then
		dest.Connected = false
		dest.ConEnt = nil
		dest.RemotePort = 0
		if (dest.RopeTable) then PCMod.Wiring.UnlinkRopeTable( dest.RopeTable ) end
		dest.RopeTable = nil
		if (dest.CableTies) then
			for _, ent in pairs( dest.CableTies ) do
				if ((ent) && (ent:IsValid()) && (ent.IsCableTie)) then
					PCMod.Wiring.RemoveEntPortLink( ent, destent, source.RemotePort )
				end
			end
		end
		destent:UpdatePort( source.RemotePort, dest )
	end
	source.Connected = false
	source.ConEnt = nil
	source.RemotePort = 0
	srcent:UpdatePort( srcprt, source )
	srcent:FireEvent( { "unlinked", srcprt, destent } )
	destent:FireEvent( { "unlinked", source.RemotePort, srcent } )
	return true
end

// ---------------------------------------------------------------------------------------------------------
// UnlinkRopeTable - Destroys all ropes and constraints in a table (should work for any entity type)
// ---------------------------------------------------------------------------------------------------------
function PCMod.Wiring.UnlinkRopeTable( ropetable )
	for _, tbl in pairs( ropetable ) do
		for _, ent in pairs( tbl ) do
			if ((ent) && (ent:IsValid())) then ent:Remove() end
		end
	end
	ropetable = {}
	return ropetable
end

// ---------------------------------------------------------------------------------------------------------
// RemoveEntPortLink - Removes all data about an entity and it's port from a cable tie
// ---------------------------------------------------------------------------------------------------------
function PCMod.Wiring.RemoveEntPortLink( cabletie, ent, port )
	if ((!cabletie) || (!cabletie:IsValid())) then return end
	local tmp = table.Copy( cabletie.LinkedPorts )
	for k, v in pairs( cabletie.LinkedPorts ) do
		if (((v.EntA == ent) && (v.PortA == port)) || ((v.EntB == ent) && (v.PortB == port))) then
			tmp[ k ] = nil
		end
	end
	local tmp2 = {}
	for _, v in pairs( tmp ) do
		if ((v) && (type(v) == "table")) then table.insert( tmp2, v ) end
	end
	cabletie.LinkedPorts = table.Copy( tmp2 )
end