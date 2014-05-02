
// Router Control Driver for PCMod 2 (This is for the router, not the pc)

DRV = PCMod.DeriveDriver( "base" )

DRV.NiceName = "WebGear Router Core"
DRV.Name = "webgr_router"
DRV.Type = "networking"
DRV.ID = 0
DRV.LAN = {}
DRV.BLAN = {}
DRV.NPorts = {}
DRV.OPorts = {}
DRV.BSubnet = nil
DRV.Subnet = nil
DRV.Wireless = false

function DRV:Initialize()
	if (!self.Entity) then return end
	
	PCMod.Msg( "Initializing WebGear Router Core..", true )
	
	// Hook in our events
	self.Entity:AddEHook( "driver", self.Name, "linked" ) -- Something has been linked up
	self.Entity:AddEHook( "driver", self.Name, "unlinked" ) -- Something has been unlinked
	
	// Get a list of valid ports
	local ports = self.Entity:Ports()
	local tmp = {}
	self.LAN = {}
	for k, v in pairs( ports ) do
		if (v.Type == "network") then
			table.insert( tmp, k )
			table.insert( self.LAN, k, v )
		end
	end
	self.NPorts = table.Copy( tmp )
	local tmp = {}
	self.BLAN = {}
	for k, v in pairs( ports ) do
		if (v.Type == "optic") then
			table.insert( tmp, k )
			table.insert( self.BLAN, k, v )
		end
	end
	self.OPorts = table.Copy( tmp )

	timer.Simple(1, function() self.BSubnet = self.Entity:GetBSubnet() end)
	timer.Simple(1, function() self.Subnet = self.Entity:GetSubnet() end)
end

function DRV:DataRecieved( port, data )
	PCMod.Msg( "[webgr]Checking Ports", true )
	if (table.HasValue( self.NPorts, port )) then
		// Data is from a network port (PC)
		return self:Process( data )
	end
	if (table.HasValue( self.OPorts, port )) then
		// Data is from a optic port (Router)
		return self:Process( data )
	end
	if (port == 0) then
		// Data is from wireless
		if (self.Wireless) then self:Process( data ) end
	end
	// Data is from another port unrelated to us
end

function DRV:Process( data )
	PCMod.Msg( "[webgr]Data check " .. self.Entity:GetClass() .. " " .. tostring(self.Subnet) .. " (" .. tostring(self.BSubnet) .. ")", true )
	PCMod.Msg( table.ToString(data, "data", false), true )
	if (!data && !data[1] && table.maxn( data ) < 2) then return end
	local tag = data[1]
	local body = data[2]
	// PCMod.Msg( "Router Driver is processing this packet ["..tag.."] { "..body[1]..", "..body[2]..", "..body[3]..", "..body[4].." }", true )
	PCMod.Msg( "[webgr] Router Driver is processing this packet [" .. tag .. "]", true )
	PCMod.Msg( "[webgr] Body datatype: " .. type( data ) .. " " .. tostring(body), true )
	if ((tag == "sendpacket") && (type( body ) == "table")) then
		local pid = PCMod.Network.CreatePacket( body[1], body[2], body[3], body[4] )
		return self:ProcessPacket( pid )
	end
	if ((tag == "deliver") && (type( body ) == "number")) then
		return self:ProcessPacket( body, data[3] )
	end
end

function DRV:ProcessPacket( pid, pass )
	pass = (pass or 0) + 1
	if (pass > PCMod.Cfg.MaxNetworkPass) then
		PCMod.Msg( "[webgr]WARNING: Packet reached maximum pass! (id " .. tostring( pid ) .. ")" )
		return
	else
		PCMod.Msg( "[webgr]Parsed packet with pass: " .. pass .. " (id " .. tostring( pid ) .. ")" )
	end
	if (!pid) then
		PCMod.Msg( "[webgr]No pid", true )
		return
	end
	local mem = self.Entity:Memory()
	if (!mem.P) then mem.P = {} end
	if (mem.P[pid]) then
		PCMod.Msg( "[webgr]Already processed", true )
		return
	end -- Already processed, skip
	mem.P[pid] = true -- Processed flag enabled
	self.Entity:UpdateMemory( mem )
	local packet = PCMod.Network.Packets[ pid ] -- Get the packet
	if (!packet) then
		PCMod.Msg( "[webgr]Packet is nil", true )
		return
	end
	if (packet.Delivered) then
		PCMod.Msg( "[webgr]Already delivered", true )
		return
	end -- Task completed by another router!
	// See if its a traceroute
	PCMod.Msg( "[webgr]The packet was not delivered, begin target checks", true )
	if ((packet.Body) && (packet.Body[1]) && (packet.Body[1] == "netTrace")) then
		local sip = "n/a"
		local sid = "n/a"
		if (self.Entity:GetClass() == "pcmod_router") then
			sip = "192.168." .. tostring( self.Entity:GetSubnet() ) .. ".0"
			sid = "RTR"
		end
		if (self.Entity:GetClass() == "pcmod_brouter") then
			sip = "10.0." .. tostring( self.Entity:GetBSubnet() ) .. ".0"
			sid = "BRTR"
		end
		if (self.Wireless) then
			sid = "WRTR"
		end
		PCMod.Msg( "[webgr][== This entity has found a trace packet! (" .. sip .. ") ==]", true )
		// source, dest, port, body
		self:Process( { "sendpacket", { sip, packet.Source, 0, { "netTraceNode", packet.Body[3], sid } } } )
	end
	if (string.find( packet.Dest, "10.0" ) && self:HasRouter( packet.Dest )) then
		PCMod.Msg( "[webgr]This packet is headed for a backbone IP, searching local network", true )
		local port = self:HasRouter( packet.Dest )

		PCMod.Msg( "[webgr]The target on this network is on port " .. port .. ". Pushing data", true )

		// Deliver to Router
		self.Entity:PushData( port, { "deliver", pid, pass } )

		// Check to see if the packet has been delivered yet
		if (PCMod.Network.Packets[ pid ].Delivered) then
			PCMod.Msg( "[webgr]The packet was delivered", true )
			// Delivery successful!
			return
		end
	elseif (string.find( packet.Dest, "192.168" ) && self:HasPC( packet.Dest )) then
		PCMod.Msg( "[webgr]This packet is headed for a normal IP, searching local network", true )
		local port = self:HasPC( packet.Dest )

		PCMod.Msg( "[webgr]The target on this network is on port " .. port .. ". Pushing data", true )

		// Deliver to PC
		self.Entity:PushData( port, { "deliver", pid, pass } )
	
		// Check to see if the packet has been delivered yet
		if (PCMod.Network.Packets[ pid ].Delivered) then
			PCMod.Msg( "[webgr]The packet was delivered", true )
			// Delivery successful!
			return
		end
	end

	PCMod.Msg( "[webgr]This router does not have the target. Pushing to other routers", true )

	// If not, push it to all connected routers
	self.Entity:FullPushData( { "deliver", pid, pass }, "optic" )
	
	// If we are wireless, push to every router in the area
	local ets = {}
	local range = PCMod.Cfg.WirelessRange
	if (range > 0) then
		ets = ents.FindInSphere( self.Entity:GetPos(), range )
	else
		ets = ents.FindByClass( self.Entity:GetClass() )
	end
	local myents = {}
	for _, ent in pairs( ets ) do
		if ((ent) && (ent:IsValid()) && (ent.IsPCMod) && (ent != self.Entity)) then
			if (ent:Data().IsWireless) then
				table.insert( myents, ent )
			end
		end
	end
	for _, ent in pairs( myents ) do
		ent:DataRecieved( 0, { "deliver", pid, pass } )
	end
end

function DRV:CallEvent( data )
	if ((!data) || (!data.Event)) then return end
	PCMod.Msg( "[webgr]An event was called(" .. table.ToString(data) .. ")", true )
	local e = data.Event
	if (e == "linked") then
		local port = self.Entity:Ports()[ data[ 1 ] ]
		
		PCMod.Msg( "[webgr]Linked event called on router! (" .. self.Entity:EntIndex() .. ")", true )
		PCMod.Msg( "[webgr]REMOTE: " .. port.ConEnt:GetClass(), true )
		PCMod.Msg( "[webgr]SOURCE: " .. self.Entity:GetClass(), true )
		
		if (self.Entity:GetClass() == "pcmod_brouter" && port.ConEnt:GetClass() == "pcmod_router") then
			table.insert( self.BLAN, data[ 1 ], port )
			PCMod.Network.RegisterPC( port.ConEnt, self.Entity:GetBSubnet(), true )
		end

		if (self.Entity:GetClass() == "pcmod_router" && port.ConEnt:GetClass() != "pcmod_router" && port.ConEnt:GetClass() != "pcmod_brouter") then
			table.insert( self.LAN, data[ 1 ], port )
			PCMod.Network.RegisterPC( port.ConEnt, self.Entity:GetSubnet(), false )
		end
	end
	if (e == "unlinked") then
		local port = {}
		port.ConEnt = data[ 2 ]

		PCMod.Msg( "[webgr]An unlink event was called", true )

		if (self.Entity:GetClass() == "pcmod_brouter" && port.ConEnt:GetClass() == "pcmod_router") then
			table.insert( self.BLAN, data[ 1 ], self.Entity:Ports()[ data[ 1 ] ] )
			PCMod.Network.UnRegisterPC( port.ConEnt, self.Entity:GetBSubnet(), true )
		end

		if (self.Entity:GetClass() == "pcmod_router" && port.ConEnt:GetClass() != "pcmod_router" && port.ConEnt:GetClass() != "pcmod_brouter") then
			table.insert( self.LAN, data[ 1 ], self.Entity:Ports()[ data[ 1 ] ] )
			PCMod.Network.UnRegisterPC( port.ConEnt, self.Entity:GetSubnet(), false )
		end
	end
end

function DRV:HasRouter( ip )
	PCMod.Msg( "[webgr]looking for router " .. ip, true )
	for k, v in pairs( self.BLAN ) do
		if (v.Connected) then
			PCMod.Msg( "[webgr]port " .. k .. " has the ips " .. tostring(v.ConEnt:GetFullIP()) .. "(" .. tostring(v.ConEnt:GetFullBIP()) .. ")", true )
			if (v.ConEnt:GetFullBIP() == ip || v.ConEnt:GetFullIP() == ip) then
				return k
			end
		end
	end
	return false
end

function DRV:HasPC( ip )
	PCMod.Msg( "[webgr]looking for pc " .. ip, true )
	for k, v in pairs( self.LAN ) do
		if (v.Connected) then
			PCMod.Msg( "[webgr]port " .. k .. " has the ips " .. tostring(v.ConEnt:GetFullIP()) .. "(" .. tostring(v.ConEnt:GetFullBIP()) .. ")", true )
			if (v.ConEnt:GetFullBIP() == ip || v.ConEnt:GetFullIP() == ip) then
				return k
			end
		end
	end
	return false
end

function DRV:OnRemove()
	self.LAN = {}
	self.BLAN = {}
	self.BSubnet = self.Entity:GetBSubnet()
	self.Subnet = self.Entity:GetSubnet()
	self.NPorts = {}
	self.OPorts = {}
end