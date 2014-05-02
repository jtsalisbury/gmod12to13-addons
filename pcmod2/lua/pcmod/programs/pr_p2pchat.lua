
// P2P Chat Program for PCMod 2 \\

PROG.Name = "p2pchat"
PROG.Author = "[GU]thomasfn"
PROG.Title = "P2P Chat"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true

PROG.DeviceLink = "window_p2pchat"
PROG.DeviceName = "window_p2pchat"
PROG.DeviceData = {}

PROG.Nick = "Unknown"
PROG.IP = "127.0.0.1"

PROG.MLimit = 10

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
	end
	if (com == "setnick") then
		if (args[1]) then
			self.Nick = args[1]
			self.DeviceData.Nk = args[1]
			self:UpdateSS()
		end
	end
	if (com == "setip") then
		if ((args[1]) && (string.IsIP( args[1] ))) then
			self.IP = args[1]
			self.DeviceData.IP = args[1]
			self:UpdateSS()
		end
	end
	if (com == "msg") then
		if (string.IsIP( self.IP ) && args[1]) then
			local msg = table.concat( args, " " )
			self:AddMessage( self.Nick .. ": " .. msg )
			self:GetOS():SendNetMessage( self.IP, 75, { "netChat_P2P", self.Nick, msg } )
		end
	end
end

function PROG:OnStart()
	self:GetOS():OpenNetPort( 75, "prog", "p2pchat" )
	self.DeviceData.Msgs = {}
end

function PROG:OnEnd()
	self:GetOS():CloseNetPort( 75 )
	self.DeviceData.Msgs = {}
end

function PROG:ProcessPacket( pt, dat, hdl )
	PCMod.Msg( "P2P Chat recieved msg! (" .. dat[1] .. ")", true )
	if (pt == 75) then
		if (dat[1] == "netChat_P2P") then
			self:AddMessage( dat[2] .. ": " .. dat[3] )
		end
		if (dat[1] == "netPortClosed") then
			self:AddMessage( 25 ) -- Target port closed!
		end
		if (dat[1] == "netPortLocked") then
			self:AddMessage( 26 ) -- Target port locked!
		end
	end
end

function PROG:MessageFailed( handle, code, olddat )
	
end

function PROG:AddMessage( msg )
	local oldmsgs = self.DeviceData.Msgs
	if (type(msg) == "string") then
		msg = string.Replace( msg, self.Nick, "/M" )
	end
	table.insert( oldmsgs, msg )
	if (#oldmsgs > self.MLimit) then
		local tm = #oldmsgs - self.MLimit
		local cnt
		for cnt=1,tm do
			table.remove( oldmsgs, 1 )
		end
	end
	self.DeviceData.Msgs = oldmsgs
	self:UpdateSS()
end