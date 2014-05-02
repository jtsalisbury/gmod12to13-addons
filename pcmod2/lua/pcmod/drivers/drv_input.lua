
// Display Driver for PCMod 2

DRV = PCMod.DeriveDriver( "base" )

DRV.NiceName = "Generic Input Driver"
DRV.Name = "gen_input"
DRV.Type = "input"
DRV.ID = 0
DRV.PortHook = "ps2"
DRV.PortID = 0

function DRV:Initialize()
	if (!self.Entity) then return end
	
	// Get our primary PS2 port
	local ports = self.Entity:Ports()
	for k, v in pairs( ports ) do
		if (v.Type == self.PortHook) then
			self.PortID = k
			break
		end
	end
end

function DRV:GetPort()
	if (!self.Entity) then return end
	return self.Entity:Ports()[ self.PortID ]
end

function DRV:DataRecieved( port, data )
	local pt = self.Entity:GetPorts()[ port ]
	if (!pt) then return end
	if (pt.Type == "vga") then
		if (data[1] == "keyboard_req") then
			PCMod.Msg( "Recieved keyboard lock request from VGA port!", true )
			self.Entity:PushData( self.Entity:GetPorts()[ self.PortID ], data ) -- Forward data to keyboard
		end
	end
end