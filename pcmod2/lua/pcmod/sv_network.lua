
// ---------------------------------------------------------------------------------------------------------
// sv_network.lua - Revision 1
// Server-Side
// Controls the networking aspect of PCMod
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------

PCMod.Network = {}
PCMod.Network.Version = "1.0"
PCMod.Network.Packets = {}
PCMod.Network.NextID = 1
PCMod.Network.Subnets = {}
PCMod.Network.Backbones = {}
PCMod.Network.Availible = {}
PCMod.Network.Availible.Back = {}
PCMod.Network.Availible.Sub = {}

for i = 1, 255 do
	PCMod.Network.Availible.Back[ i ] = true
	PCMod.Network.Availible.Sub[ i ] = true
end

PCMod.Msg( "Network Library Loaded (V" .. PCMod.Network.Version .. ")", true )


// ---------------------------------------------------------------------------------------------------------
/* Basic Concept of how networking in PCMod works:
	
	Say we have 2 PCs, A and B. A wants to send a packet to B. It compiles the data to send in a table, and sends it to the router it is connected to.
	
	The router creates a packet out of the data. The packet contains the source, destination, port and data and it has a unique ID. The packet is stored in a global table.
	
	The router will then proceed to send that packet's ID to every other router it can.
	
	When a router recieves a packet ID, it will check 3 things.
	 - If the packet is flagged 'delivered', it will ignore it.
	 - If the packet has already been processed by the router, it will ignore it.
	 - If the packet's destination is a PC linked to the router, it will forward it to the PC.
	 
	 If the packet does not meet any of these conditions, the router will forward it on to other routers and record the fact that the packet has been processed.
	 
	This will, as long as there is a path from source to destination, ensure the packet will reach the target 100% of the time. (Unless a function call is ignored by the engine)
	
*/
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// CreatePacket - Forms a packet, stores it, and returns the UID
// ---------------------------------------------------------------------------------------------------------
function PCMod.Network.CreatePacket( source, dest, port, body )
	local pk = {}
	pk.Source = source
	pk.Dest = dest
	pk.Port = port
	pk.Body = body
	pk.Delivered = false
	PCMod.Network.Packets[ PCMod.Network.NextID ] = pk
	PCMod.Network.NextID = PCMod.Network.NextID + 1
	return PCMod.Network.NextID - 1
end

// ---------------------------------------------------------------------------------------------------------
// RegisterRouter - Registers a router with the network system
// ---------------------------------------------------------------------------------------------------------
function PCMod.Network.RegisterRouter( ent )
	local back = ""
	local rtr = {}
	local id
	rtr.LAN = {}
	rtr.Ent = ent
	rtr.EntID = ent:EntIndex()
	rtr.IsBackbone = false
	if (ent:GetClass() == "pcmod_brouter") then
		for _, v in pairs(PCMod.Network.Backbones) do
			if (v.EntID == rtr.EntID) then
				PCMod.Msg( "Router "..ent:EntIndex().."(Backbone) is already registered", true )
				return
			end
		end
		id = PCMod.Network.GetSub( true )
		rtr.IsBackbone = true
		if (!id) then
			rtr.Ent:ForceRemove( "No subnets availible" )
			return
		end
		PCMod.Network.Backbones[ id ] = rtr
		back = "(Backbone)"
		rtr.Ent:SetBSubnet( id )
		rtr.Ent:SetBIP( 0 )
	else
		for _, v in pairs(PCMod.Network.Subnets) do
			if (v.EntID == rtr.EntID) then
				PCMod.Msg( "Router "..ent:EntIndex().." is already registered", true )
				return
			end
		end
		id = PCMod.Network.GetSub( false )
		if (!id) then
			rtr.Ent:ForceRemove( "No subnets availible" )
			return
		end
		PCMod.Network.Subnets[ id ] = rtr
		rtr.Ent:SetSubnet( id )
		rtr.Ent:SetIP( 0 )
	end

	PCMod.Msg( "Registered router "..ent:EntIndex()..back.." and aquired subnet "..id, true )
	
	return true
end

// ---------------------------------------------------------------------------------------------------------
// UnRegisterRouter - Unregisters a router with the network system
// ---------------------------------------------------------------------------------------------------------
function PCMod.Network.UnRegisterRouter( ent )
	local res = PCMod.Network.FindSubByEnt( ent )
	local back = ""
	if (!res) then return end

	if (res[2]) then
		for i = 1, 10 do
			if (PCMod.Network.Backbones[ res[ 1 ] ].LAN[ i ]) then
				PCMod.Network.UnRegisterPC( PCMod.Network.Backbones[ res[ 1 ] ].LAN[ i ].Ent, res[ 1 ], true )
			end
		end
		PCMod.Network.Backbones[ res[ 1 ] ] = nil
		PCMod.Network.Availible.Back[ res[ 1 ] ] = true
		back = "(Backbone)"
	else
		for i = 1, 4 do
			if (PCMod.Network.Subnets[ res[ 1 ] ].LAN[ i ]) then
				PCMod.Network.UnRegisterPC( PCMod.Network.Subnets[ res[ 1 ] ].LAN[ i ].Ent, res[ 1 ], false )
			end
		end
		PCMod.Network.Subnets[ res[ 1 ] ] = nil
		PCMod.Network.Availible.Sub[ res[ 1 ] ] = true
	end

	PCMod.Msg( "Unregistered router "..ent:EntIndex()..back.." and released subnet "..res[1], true )
end

// ---------------------------------------------------------------------------------------------------------
// GetSub - Gets the subnet of an entity based on recount
// ---------------------------------------------------------------------------------------------------------
function PCMod.Network.GetSub( isBackbone, recount )
	local num = 0
	local avail1a = #PCMod.Network.Availible.Back
	local avail1b = #PCMod.Network.Backbones
	local avail2a = #PCMod.Network.Availible.Sub
	local avail2b = #PCMod.Network.Subnets
	local num1 = 0
	local num2 = 0

	if ((avail1a == 0 && avail1b < 255) || recount) then
		for i = 1, 255 do
			if (!PCMod.Network.Backbones[ i ]) then
				PCMod.Network.Availible.Back[ i ] = true
			else
				PCMod.Network.Availible.Back[ i ] = false
			end
		end
	end
	if ((avail2a == 0 && avail2b < 255) || recount) then
		for i = 1, 255 do
			if (!PCMod.Network.Subnets[ i ]) then
				PCMod.Network.Availible.Sub[ i ] = true
			else
				PCMod.Network.Availible.Sub[ i ] = false
			end
		end
	end

	for k,v in pairs(PCMod.Network.Availible.Back) do
		if (v == true && num1 == 0) then
			num1 = k
		end
	end
	for k,v in pairs(PCMod.Network.Availible.Sub) do
		if (v == true && num2 == 0) then
			num2 = k
		end
	end

	if (isBackbone) then
		if (!PCMod.Network.Backbones[ num1 ]) then
			PCMod.Network.Availible.Back[ num1 ] = false
			return num1
		elseif (num2 > 0) then
			PCMod.Network.Availible.Back[ num1 ] = false
			return PCMod.Network.GetSub( isBackbone, true )
		else
			return false
		end
	else
		if (!PCMod.Network.Subnets[ num2 ]) then
			PCMod.Network.Availible.Sub[ num2 ] = false
			return num2
		elseif (num2 > 0) then
			PCMod.Network.Availible.Sub[ num2 ] = false
			return PCMod.Network.GetSub( isBackbone, true )
		else
			return false
		end
	end
end

// ---------------------------------------------------------------------------------------------------------
// FindSubByEnd - Gets the subnet based on the entity
// ---------------------------------------------------------------------------------------------------------
function PCMod.Network.FindSubByEnt( ent )
	local EntID = ent:EntIndex()
	for i = 1, 255 do
		if (PCMod.Network.Subnets[ i ] && PCMod.Network.Subnets[ i ].EntID == EntID) then
			return { i, false }
		end
	end
	for i = 1, 255 do
		if (PCMod.Network.Backbones[ i ] && PCMod.Network.Backbones[ i ].EntID == EntID) then
			return { i, true }
		end
	end
	return false
end

// ---------------------------------------------------------------------------------------------------------
// RegisterPC - Registers a tower with the network system
// ---------------------------------------------------------------------------------------------------------
function PCMod.Network.RegisterPC( ent, subnet, backbone )
	local pc = {}
	pc.Ent = ent
	pc.EntID = ent:EntIndex()
	local tmp
	local good = true
	PCMod.Msg( "Attempt RegisterPC("..ent:EntIndex()..", "..subnet..", "..tostring( backbone )..")", true )
	if (backbone) then
		tmp = PCMod.Network.Backbones[ subnet ]
		if(!PCMod.Network.Backbones[ subnet ]) then
			good = false
		end
		if (good) then
			for _, v in pairs(tmp.LAN) do
				if (v.EntID == pc.EntID) then
					PCMod.Msg( "Router "..ent:EntIndex().." is already registered to backbone", true )
					return
				end
			end
			for i = 1, 10 do
				if (!PCMod.Network.Backbones[ subnet ].LAN[ i ]) then
					PCMod.Network.Backbones[ subnet ].LAN[ i ] = pc
					pc.Ent:SetBSubnet( subnet )
					pc.Ent:SetBIP( i )
					PCMod.Msg( "Registered router "..ent:EntIndex().." to backbone and aquired ip 10.0."..subnet.."."..i, true )
					return
				end
			end
		end
	else
		tmp = PCMod.Network.Subnets[ subnet ]
		if(!PCMod.Network.Subnets[ subnet ]) then
			good = false
		end
		if (good) then
			for _, v in pairs(tmp.LAN) do
				if (v.EntID == pc.EntID) then
					PCMod.Msg( "PC "..ent:EntIndex().." is already registered to router", true )
					return
				end
			end
			for i = 1, 4 do
				if (!PCMod.Network.Subnets[ subnet ].LAN[ i ]) then
					PCMod.Network.Subnets[ subnet ].LAN[ i ] = pc
					pc.Ent:SetSubnet( subnet )
					pc.Ent:SetIP( i )
					PCMod.Msg( "Registered pc "..ent:EntIndex().." to router and aquired ip 192.168."..subnet.."."..i, true )
					return
				end
			end
		end
	end
	local port
	for k, v in pairs(ent:Ports()) do
		if ((v.Type == "network" || v.Type == "optic") && (!tmp || v.ConEnt == tmp.Ent)) then
			port = k
		end
	end
	PCMod.Wiring.UnlinkPort( ent, port )
	if (good) then
		PCMod.Notice( "No ips availible", ent:GetOwner() )
	else
		PCMod.Notice( "Invalid subnet", ent:GetOwner() )
	end
end

// ---------------------------------------------------------------------------------------------------------
// UnRegisterPC - Unregisters a tower with the network system
// ---------------------------------------------------------------------------------------------------------
function PCMod.Network.UnRegisterPC( ent, subnet, backbone )
	if (backbone) then
		if (!PCMod.Network.Backbones[ subnet ]) then return end
		for i = 1, 10 do
			if (PCMod.Network.Backbones[ subnet ].LAN[ i ] && PCMod.Network.Backbones[ subnet ].LAN[ i ].EntID == ent:EntIndex()) then
				PCMod.Network.Backbones[ subnet ].LAN[ i ] = nil
				ent:SetBSubnet( false )
				ent:SetBIP( false )
				PCMod.Msg( "Unregistered router "..ent:EntIndex().." from backbone and released ip 10.0."..subnet.."."..i, true )
				return
			end
		end
	else
		if (!PCMod.Network.Subnets[ subnet ]) then return end
		for i = 1, 4 do
			if (PCMod.Network.Subnets[ subnet ].LAN[ i ] && PCMod.Network.Subnets[ subnet ].LAN[ i ].EntID == ent:EntIndex()) then
				PCMod.Network.Subnets[ subnet ].LAN[ i ] = nil
				ent:SetSubnet( false )
				ent:SetIP( false )
				PCMod.Msg( "Unregistered pc "..ent:EntIndex().." from router and released ip 192.168."..subnet.."."..i, true )
				return
			end
		end
	end
end