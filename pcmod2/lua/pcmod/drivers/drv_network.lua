
// Network Driver for PCMod 2

DRV = PCMod.DeriveDriver( "base" )

DRV.NiceName = "Generic Network Driver"
DRV.Name = "gen_network"
DRV.Type = "network"

DRV.PTData = {}
DRV.NetworkPort = 0

function DRV:Initialize()
	if (!self.Entity) then return end
	for k, v in pairs( self.Entity:Ports() ) do
		if (v.Type == "network") then self.NetworkPort = k end
	end
end

function DRV:GetOSDriver( dname )
	return PCMod.Data[ self.Entity:EntIndex() ].Drivers[ dname ]
end

function DRV:PacketRecieved( packet )
	if (self:GetOSDriver( "gen_bios" ).OS) then
		self:GetOSDriver( "gen_bios" ).OS:NetDataRecieved( packet )
	end
end

function DRV:SendPacket( dest, port, body )
	if (dest == "127.0.0.1") then
		local pk = {}
		pk.Source = self:GetIP()
		pk.Dest = dest
		pk.Port = port
		pk.Body = body
		pk.Delivered = true
		self:PacketRecieved( pk )
		return
	end
	if (self.NetworkPort == 0) then return end
	return self.Entity:SendPacket( self.NetworkPort, dest, port, body )
end

function DRV:GetIP()
	return self.Entity:GetIP()
end