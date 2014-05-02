
// ---------------------------------------------------------------------------------------------------------
// pcmod_router
// Router entity - networking node
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "Networking Router"
ENT.Class = "pcmod_router"

ENT.ItemModel = "models/props_lab/reciever01a.mdl"

ENT.IsNetworkDevice = true

ENT.DefaultSetupData = {
	Wireless = false,
}

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup( setupdata )
	if (!setupdata) then setupdata = self.DefaultSetupData end -- Ensure we have setup data
	local dt = self:Data() -- Get our data
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "network" ) )
	table.insert( pts, self:CreatePort( "network" ) )
	table.insert( pts, self:CreatePort( "network" ) )
	table.insert( pts, self:CreatePort( "network" ) )
	table.insert( pts, self:CreatePort( "optic" ) )
	dt.Ports = pts
	
	// Install the main driver
	self:InstallDriver( "webgr_router" ).Wireless = setupdata.Wireless

	// Register our data
	local registered = PCMod.Network.RegisterRouter( self.Entity )
	if (!registered) then
		PCMod.Warning( "== ROUTER FAILED TO REGISTER ==" )
		self:SetGVar( "noreg", true )
		return
	end
	dt.IsWireless = setupdata.Wireless
	self:SetGVar( "wireless", setupdata.Wireless )
	
	// Update us
	self:UpdateData( dt )
end

function ENT:RunOnRemove()
	PCMod.Network.UnRegisterRouter( self.Entity )
end

function ENT:DataRecieved( port, data )
	// Feed it straight through to the driver
	if (!PCMod.Data[ self:EntIndex() ].Drivers[ "webgr_router" ]) then return end
	PCMod.Data[ self:EntIndex() ].Drivers[ "webgr_router" ]:DataRecieved( port, data )
end