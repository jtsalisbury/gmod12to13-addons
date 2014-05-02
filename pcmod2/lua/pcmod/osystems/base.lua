
OS.IntName = "baseos"
OS.ExtName = "Base OS"

OS.Version = "1.0.0"
OS.USBDevices = {}

OS.NetPorts = {}
OS.TraceRouteData = {}

function OS:Print( txt )
	self:Bios():AddStatusText( "]> " .. txt )
end

function OS:Bios()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	return PCMod.Data[ ent:EntIndex() ].Drivers[ "gen_bios" ]
end

function OS:Display()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	return PCMod.Data[ ent:EntIndex() ].Drivers[ "gen_display" ]
end

function OS:Sound()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	return PCMod.Data[ ent:EntIndex() ].Drivers[ "gen_sound" ]
end

function OS:USB()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	return PCMod.Data[ ent:EntIndex() ].Drivers[ "gen_usb" ]
end

function OS:Network()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	return PCMod.Data[ ent:EntIndex() ].Drivers[ "gen_network" ]
end

function OS:RequestControl()
	return self:Bios():SetState( 7 )
end

function OS:FirstRun()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	local fl = ent:ReadFile( "system/firstrun.sys" )
	if ((!fl) || (fl == "")) then return false end
	if (fl == "1") then return true end
end

function OS:RegisterRun()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	ent:UnlinkItem( "system/firstrun.sys" )
end

function OS:SaveData()
	self.Entity:WriteFile( "system/data/pcdata.dat", PCMod.TableToString( self.PCData ) )
end

function OS:LoadData()
	self.PCData = PCMod.StringToTable( self.Entity:ReadFile( "system/data/pcdata.dat" ) )
end

function OS:SetState( st )
	self.State = st
	self.NUpdate = 0
	self:TriggerUpdate( st )
end

function OS:DelayUpdate( amount )
	self.NUpdate = CurTime() + amount
end

function OS:Launch()
	self.Mode = "bios"
	self.NUpdate = 0
	self.State = 0
	PCMod.Msg( "Launching " .. self.ExtName .. "...", true )
	self:Boot()
end

function OS:Boot()
	if (self.Mode == "bios") then
		self:DelayUpdate( 0 )
		self:Tick()
	end
end

function OS:Tick()
	if (self.NUpdate == 0) then return end
	if (CurTime() > self.NUpdate) then
		self:SetState( self.State + 1 )
	end
	for k, v in pairs( self.Progs ) do
		self.Progs[ k ]:Tick()
	end
end

function OS:InstallProgram( progname, setup )
	if ((self.State != 10) && (!setup)) then return "Installation denied!" end
	if (!PCMod.Progs[ progname ]) then
		PCMod.Msg( "Tried to install invalid program! (" .. progname .. ")", true )
		return "Installation invalid!"
	end
	local pr = PCMod.Progs[ progname ]
	if ((self.Progs[ progname ]) && (!setup)) then
		PCMod.Msg( "Tried to install already present program! (" .. progname .. ")", true )
		return "Program already installed!"
	end
	self.Progs[ progname ] = table.Copy( pr )
	if (!self.Progs[ progname ]:CanUse()) then
		PCMod.Msg( "Removed program '" .. progname .. "', flagged as unusable!", true )
		self.Progs[ progname ] = nil
		return "Installation denied!"
	end
	if (self.Progs[ progname ].OS != self.IntName) then
		PCMod.Msg( "Removed program '" .. progname .. "', flagged as invalid os!", true )
		self.Progs[ progname ] = nil
		return "Wrong operating system!"
	end
	PCMod.Msg( "Installed program '" .. progname .. "')", true )
	self.Progs[ progname ].Entity = self.Entity
	self.Progs[ progname ]:OnInstall()
	return true
end

function OS:LaunchProgram( progname )
	if (!self.Progs[ progname ]) then return false end
	PCMod.Progs[ progname ].Entity = self.Entity
	return PCMod.Progs[ progname ]:Start()
end

function OS:ShutDown()
	// Instead of.. shutting down.. this actually just closes all programs. - thomasfn
	for k, v in pairs( self.Progs ) do
		self.Progs[ k ]:Exit()
	end
end

function OS:GetAllProgs()
	return (PCMod.StringToTable( self.Entity:ReadFile( "system/data/allprogs.dat" ) ) )
end

function OS:SetAllProgs( ps )
	self.Entity:WriteFile( "system/data/allprogs.dat", PCMod.TableToString( ps ) )
end

function OS:AddProg( icon, dispname, com )
	PCMod.Msg( "Adding prog: " .. icon ..", " .. dispname .. ", " .. com, true )
	local ps = self:GetAllProgs()
	table.insert( ps, { icon, dispname, com } )
	self:SetAllProgs( ps )
end

function OS:RefreshUSBData()
	self:USB():RetrievePortData()
end

function OS:GetUSBDevicePorts( devname )
	return self:USB():FindDevices( devname )
end

function OS:SendUSBData( port, data )
	self:USB():SendDeviceData( port, data )
end

function OS:GetUSBData( port )
	return self:USB():GetDevice( port )
end

function OS:OpenNetPort( portid, dest, destid )
	if (!self:ValidatePortID( portid )) then return end
	if (self:NetPortOpen( portid )) then return end
	local tmp = {}
	tmp.PortID = portid
	tmp.Dest = dest
	tmp.DestID = destid
	tmp.Locked = false -- Locked means block all incoming but allow outgoing
	self.NetPorts[ portid ] = tmp
end

function OS:CloseNetPort( portid )
	if (!self:ValidatePortID( portid )) then return end
	if (!self:NetPortOpen( portid )) then return end
	self.NetPorts[ portid ] = nil
end

function OS:NetPortOpen( portid )
	if (!self:ValidatePortID( portid )) then return false end
	if (self.NetPorts[ portid ]) then return true end
	return false
end

function OS:SetPortLock( portid, lock )
	if (!self:NetPortOpen( portid )) then return end
	self.NetPorts[ portid ].Locked = (lock == true)
end

function OS:ValidatePortID( portid )
	if (!portid) then return false end
	if (type( portid ) != "number") then return false end
	if ((portid<0) || (portid>5000)) then return false end
	return true
end

function OS:NetDataRecieved( packet )
	if (!packet) then return end
	if (type( packet ) != "table") then return end
	local pt = packet.Port
	if (!pt) then return end
	local dat = packet.Body
	if (!dat) then return end
	local hdl = { packet.Source, packet.Port }
	if (!self:NetPortOpen( pt )) then
		self:ReplyNetMessage( hdl, { "netPortClosed", dat } )
		return
	end
	local port = self.NetPorts[ pt ]
	if (port.Locked) then
		self:ReplyNetMessage( hdl, { "netPortLocked", dat } )
		return
	end
	if (port.Dest == "osbase") then self:ProcessPacket( pt, dat, hdl ) end
	if (port.Dest == "prog") then self.Progs[ port.DestID ]:ProcessPacket( pt, dat, hdl ) end
end

function OS:LinkNetPorts()
	self:OpenNetPort( 0, "osbase", nil ) -- Ping / Traceroute
end

function OS:UnlinkNetPorts()
	self:CloseNetPort( 0 )
end

function OS:ProcessPacket( pt, dat, handle )
	if ((dat[1] == "netPortClosed") || (dat[1] == "netPortLocked")) then
		local olddat = dat[2]
		// Olddat is the data we sent
		local hk = olddat[2]
		if (hk) then
			if (hk == "os") then
				self:MessageFailed( handle, dat[1], olddat )
			else
				if (self.Progs[ hk ]) then self.Progs[ hk ]:MessageFailed( handle, dat[1], olddat ) end
			end
		end
	end
	if (pt == 0) then
		// We have been pinged / tracerouted!
		PCMod.Msg( "OS BASE: " .. dat[1], true )
		if (dat[1] == "netPing") then self:ReplyNetMessage( handle, { "netPingResponse", dat[2], "Computer Tower OS" } ) end
		if (dat[1] == "netPing_DEBUG") then
			PCMod.Msg( "==] 'netPing_DEBUG' has been recieved! (OS BASE, ent " .. self.Entity:EntIndex() .. ")" )
			if (dat[2]) then dat[2]:Say( "Ping was recieved! (OS BASE, ent " .. self.Entity:EntIndex() .. ")" ) end
		end
		if (dat[1] == "netTrace") then self:ReplyNetMessage( handle, { "netTraceResponse", dat[2], dat[3], "Computer Tower OS" } ) end
		if (dat[1] == "netPingResponse") then
			local hk = dat[2]
			if (hk) then
				if (hk == "os") then
					self:PingSuccess( handle[1] )
				else
					if (self.Progs[ hk ]) then self.Progs[ hk ]:PingSuccess( handle[1], dat[3] ) end
				end
			end
		end
		if (dat[1] == "netTraceResponse") then
			local hk = dat[2]
			if (hk) then
				local trace = self.TraceRouteData[ dat[3] ]
				self.TraceRouteData[ dat[3] ] = nil
				if (hk == "os") then
					self:TraceSuccess( handle[1], trace )
				else
					if (self.Progs[ hk ]) then self.Progs[ hk ]:TraceSuccess( handle[1], trace ) end
				end
			end
		end
		if (dat[1] == "netTraceNode") then
			if (!self.TraceRouteData[ dat[2] ]) then self.TraceRouteData[ dat[2] ] = {} end
			table.insert( self.TraceRouteData[ dat[2] ], handle[1] .. " - " .. dat[3] )
		end
	end
	self:DoPacket( pt, dat, handle )
end

function OS:SendNetMessage( dest, port, body )
	if ((!dest) || (!port) || (!body)) then
		PCMod.Msg( "Os failed to send net message! (" .. tostring(dest != nil) .. "," .. tostring(port != nil) .. "," .. tostring(body != nil ) .. ")", true )
		return
	end
	PCMod.Msg( "Os sending net message... (" .. dest .. ":" .. port .. ")", true )
	PrintTable( body )
	return self:Network():SendPacket( dest, port, body )
end

function OS:ReplyNetMessage( handle, body )
	return self:SendNetMessage( handle[1], handle[2], body )
end

function OS:GetIP()
	return self:Network():GetIP()
end

function OS:NetPing( dest, hk )
	return self:SendNetMessage( dest, 0, { "netPing", hk } )
end

function OS:NetTrace( dest, hk )
	// Get a trace handle
	local thdl
	local cnt = 0
	for cnt=1, 50 do
		if (!self.TraceRouteData[ cnt ]) then
			thdl = cnt
			break
		end
	end
	if (!thdl) then
		PCMod.Msg( "== OS FAILED TO FIND EMPTY TRACE HANDLE! ==" )
		return
	end
	self.TraceRouteData[ thdl ] = {}
	return self:SendNetMessage( dest, 0, { "netTrace", hk, thdl } )
end

function OS:MessageFailed( hdl, code, data )
	PCMod.Msg( "OS Base recieved msg fail code! (" .. hdl[1] .. ":" .. hdl[2] .. "), " .. code, true )
end