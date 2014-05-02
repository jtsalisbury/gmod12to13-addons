
// Device Manager Program for PCMod 2 \\

PROG.Name = "firewall"
PROG.Author = "[GU]thomasfn"
PROG.Title = "Firewall"
PROG.Icon = "firewall"
PROG.OS = "personal"

PROG.SimpleMode = true

PROG.DeviceLink = "window_firewall"
PROG.DeviceName = "window_firewall"
PROG.DeviceData = {}

function PROG:OnStart()
	self:RefreshPorts()
end

function PROG:RefreshPorts()
	// Get all NetPorts
	local tmp = {}
	for port, data in pairs( self:GetOS().NetPorts ) do
		local ld = 0
		if (data.Locked) then ld = 1 end
		local dt = { port, ld }
		table.insert( tmp, dt )
	end
	self.DeviceData.Pts = tmp
end

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
		return
	end
	if (com == "refresh") then
		self:RefreshPorts()
		self:UpdateSS()
		return
	end
	if (com == "lockport") then
		if (args[1]) then
			self:GetOS():SetPortLock( tonumber( args[1] ), true )
			self:DoCommand( "refresh", {} )
		end
		return
	end
	if (com == "unlockport") then
		if (args[1]) then
			self:GetOS():SetPortLock( tonumber( args[1] ), false )
			self:DoCommand( "refresh", {} )
		end
		return
	end
end