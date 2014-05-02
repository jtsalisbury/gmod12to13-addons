
// USB Driver for PCMod 2

DRV = PCMod.DeriveDriver( "base" )

DRV.NiceName = "Generic USB Driver"
DRV.Name = "gen_usb"
DRV.Type = "usb"

DRV.USBPorts = {}
DRV.PTData = {}

function DRV:Initialize()
	if (!self.Entity) then return end
	
	// Hook our stuff
	self.Entity:AddEHook( "driver", self.Name, "linked" )
	self.Entity:AddEHook( "driver", self.Name, "unlinked" )
	
	// Get our usb ports
	local ports = self.Entity:Ports()
	for k, v in pairs( ports ) do
		if (v.Type == "usb") then
			table.insert( self.USBPorts, k )
			self:ResetPortData( k )
		end
	end
end

function DRV:DataRecieved( port, data )
	if (!self.PTData[ port ]) then self.PTData[ port ] = {} end
	if (data[1] == "deviceinfo") then
		PCMod.Msg( "USB Driver recieved device info!", true )
		self.PTData[ port ].DeviceType = data[2]
		self.PTData[ port ].DeviceName = data[3]
		self.PTData[ port ].HasIdent = true
		return
	end
	table.insert( self.PTData[ port ].Data, data )
end

function DRV:CallEvent( data )
	if (!data) then return end
	if (!data.Event) then return end
	if (data.Event == "linked") then
		self:GetPortData( data[1] )
	end
	if (data.Event == "unlinked") then
		self:ResetPortData( data[1] )
	end
end

function DRV:RetrievePortData()
	for _, id in pairs( self.USBPorts ) do
		self:GetPortData( id )
	end
end

function DRV:GetPortData( id )
	self:ResetPortData( id )
	local port = self.Entity:Ports()[ id ]
	if (port) then self.Entity:PushData( port, { "getdeviceinfo" } ) end
end

function DRV:ResetPortData( id )
	local tmp = {}
		tmp.DeviceType = ""
		tmp.DeviceName = ""
		tmp.HasIdent = false
		tmp.Data = {}
	self.PTData[ id ] = table.Copy( tmp )
end

function DRV:FindDevices( devtype )
	local tmp = {}
	for _, id in pairs( self.USBPorts ) do
		local dat = self.PTData[ id ]
		if (dat) then
			if ((dat.DeviceType == devtype) || (devtype == "all")) then table.insert( tmp, id ) end
		end
	end
	return tmp
end

function DRV:GetDevice( port )
	return self.PTData[ port ]
end

function DRV:SendDeviceData( port, data )
	local pt = self.Entity:Ports()[ port ]
	if (pt) then self.Entity:PushData( pt, data ) end
end

function DRV:GetDeviceData( port )
	local dat = table.Copy( self.PTData[ port ].Data )
	self.PTData[ port ].Data = {}
	return dat
end