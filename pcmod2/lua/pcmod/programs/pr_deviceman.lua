
// Device Manager Program for PCMod 2 \\

PROG.Name = "deviceman"
PROG.Author = "[GU]thomasfn"
PROG.Title = "Device Manager"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true
PROG.NoShortcut = true

PROG.DeviceLink = "window_devman"
PROG.DeviceName = "window_devman"
PROG.DeviceData = {}

function PROG:OnStart()
	self:RefreshDevices( "all" )
end

function PROG:RefreshDevices( devname )
	// Get all USB devices
	self:GetOS():RefreshUSBData()
	local devs = self:GetOS():GetUSBDevicePorts( devname )
	local tmp = {}
	for k, v in pairs( devs ) do
		local pd = self:GetOS():GetUSBData( v )
		if (pd.HasIdent) then
			local dat = {}
			dat[1] = v
			dat[2] = pd.DeviceType
			table.insert( tmp, dat )
		end
	end
	self.DeviceData.Dvs = tmp
end

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:GetOS():RunCommand( "sys_openprog mycomputer" )
		self:Exit()
		return
	end
	if (com == "refresh") then
		self:RefreshDevices( "all" )
		self:UpdateSS()
		return
	end
end