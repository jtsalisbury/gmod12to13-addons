
// ---------------------------------------------------------------------------------------------------------
// pcmod_iodevice
// I/O Device - Simple input/output device, multiple purposes
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "I/O Device"
ENT.Class = "pcmod_iodevice"

ENT.ItemModel = "models/props_lab/reciever01d.mdl"

ENT.AlwaysOn = true

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup()
	local dt = self:Data() -- Get our data
	
	// Hook in our events
	self:AddEHook( "ent", nil, "linked" )
	self:AddEHook( "ent", nil, "unlinked" )
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "usb" ) )
	dt.Ports = pts
	
	// Create our inputs table
	dt.Inputs = {}
	
	// Register with Wiremod
	local wire = ((WireAddon) && (WireLib))
	if (wire) then
		self.Inputs = Wire_CreateInputs( self, PCMod.Cfg.IO_Inputs )
		self.Outputs = Wire_CreateOutputs( self, PCMod.Cfg.IO_Outputs )
	end
	
	// Update us
	self:UpdateData( dt )
end

function ENT:DataRecieved( port, data )
	local prt = self:Ports()[ port ]
	if (!prt) then return end
	if (prt.Type == "usb") then
		PCMod.Msg( "IO Device recieved '" .. data[1] .. "' through USB port!", true )
		// Generic USB stuff
		if (data[1] == "getdeviceinfo") then
			local dat = { "deviceinfo", "iodev", "I/O Device (Wire)" }
			self:PushData( prt, dat )
		end
		// Printer stuff
		if (data[1] == "set_output") then
			self:SetOutput( data[2], data[3] )
		end
		if (data[1] == "get_input") then
			local dat = { "input", data[2], self:GetInput( data[2] ) }
			self:PushData( prt, dat )
		end
		if (data[1] == "get_inputs") then
			local dt = self:Data()
			local dat = { "inputs", dt.Inputs }
			self:PushData( prt, dat )
		end
		if (data[1] == "getstatus") then
			local dat = { "status", "Idle" }
			self:PushData( prt, dat )
		end
	end
end

if (SERVER) then

	function ENT:SetOutput( id, output )
		if (!id) then return end
		if (!output) then return end
		local wire = ((WireAddon) && (WireLib))
		if (wire) then
			Wire_TriggerOutput( self, tostring( id ), tonumber( output ) )
		end
	end

	function ENT:GetInput( id )
		if (!id) then return end
		local i = self:Data().Inputs[ id ]
		return i or 0
	end
	
	function ENT:TriggerInput( iname, value )
		local dt = self:Data()
		PCMod.Msg( "IO Device recieved wire input!", true )
		dt.Inputs[ iname ] = tonumber( value )
		self.Inputs[ iname ].Value = value
		self:PushData( 1, { "inputs", dt.Inputs } ) -- We are assuming port 1 is our USB port  -thomasfn
		self:UpdateData( dt )
	end
	
end