
// Alarmz Program for PCMod 2 \\

PROG.Name = "alarmz"
PROG.Author = "[GU]thomasfn"
PROG.Title = "AlarmZ"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true

PROG.DeviceLink = "window_alarmz"
PROG.DeviceName = "window_alarmz"
PROG.DeviceData = {}

PROG.Device = 0
PROG.AlarmSound = "ambient/alarms/alarm1.wav"

function PROG:OnStart()
	self:GetDevice()
	self:DoCommand( "disable", {} )
end

function PROG:GetDevice()
	self:GetOS():RefreshUSBData()
	local devs = self:GetOS():GetUSBDevicePorts( "iodev" )
	if (#devs == 0) then self.Device = 0 end
	if (#devs > 0) then self.Device = devs[1] end
end

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
		return
	end
	if (com == "enable") then
		self:GetOS():RunCommand( "snd_play " .. self.AlarmSound )
		self:GetDevice()
		self:GetOS():SendUSBData( self.Device, { "set_output", 1, 1 } )
		self.DeviceData.Al = 1
		self:UpdateSS()
	end
	if (com == "disable") then
		self:GetOS():RunCommand( "snd_stop" )
		self:GetDevice()
		self:GetOS():SendUSBData( self.Device, { "set_output", 1, 0 } )
		self.DeviceData.Al = 0
		self:UpdateSS()
	end
	if (com == "enable_c") then
		self.DeviceData.Cm = 1
		self:UpdateSS()
	end
	if (com == "disable_c") then
		self.DeviceData.Cm = 0
		self:UpdateSS()
	end	
	if (com == "setalarmsound") then
		self.AlarmSound = args[1]
	end
end