
// I/O Controller Program for PCMod 2 \\

PROG.Name = "iocontroller"
PROG.Author = "[GU]thomasfn"
PROG.Title = "I/O Controller"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true

PROG.DeviceLink = "window_iocontroller"
PROG.DeviceName = "window_iocontroller"
PROG.DeviceData = {}

PROG.Device = 0

function PROG:OnStart()
	self:RefreshInputs()
	self.DeviceData.Outs = {}
	for _, v in pairs( PCMod.Cfg.IO_Outputs ) do
		self.DeviceData.Outs[ v ] = 0
	end
end

function PROG:GetDevice()
	self:GetOS():RefreshUSBData()
	local devs = self:GetOS():GetUSBDevicePorts( "iodev" )
	if (#devs == 0) then self.Device = 0 end
	if (#devs > 0) then self.Device = devs[1] end
end

function PROG:RefreshInputs()
	// Get all USB devices
	self:GetDevice()
	local pt = self.Device
	self:GetOS():SendUSBData( pt, { "get_inputs" } )
	if (pt == 0) then return end
	local tmp = {}
	local dat = self:GetOS():USB():GetDeviceData( pt )
	if (dat) then
		for k, v in pairs( dat ) do
			if (v[1] == "inputs") then tmp = v[2] end
		end
	end
	self.DeviceData.Ins = tmp
	self:UpdateSS()
end

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
		return
	end
	if (com == "refresh") then
		self:RefreshInputs()
		return
	end
	if (com == "setoutput") then
		if ((!args[1]) || (!tonumber(args[2]))) then return end
		if (string.len( args[2] ) > 5) then return end
		self:GetDevice()
		self:GetOS():SendUSBData( self.Device, { "set_output", args[1], tonumber( args[2] ) } )
		self.DeviceData.Outs[ args[1] ] = tonumber( args[2] )
		self:UpdateSS()
		return
	end
end