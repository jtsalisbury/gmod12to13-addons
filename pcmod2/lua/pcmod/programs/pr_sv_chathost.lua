
// My Computer Program for PCMod 2 \\

PROG.Name = "chathost"
PROG.Author = "[GU]thomasfn"
PROG.Title = "Chat Host"
PROG.Icon = ""
PROG.OS = "server"

PROG.SimpleMode = true

PROG.DeviceLink = "server_chathost"
PROG.DeviceName = "server_chathost"
PROG.DeviceData = {}

PROG.Clients = {}

function PROG:OnStart()
	self:GetOS():OpenNetPort( 72, "prog", "chathost" )
end

function PROG:OnEnd()
	self:PrintMessage( "Server shutting down!" )
	self:GetOS():CloseNetPort( 72 )
	self.Clients = {} -- I learnt this the hard way, from PCMod 1  -thomasfn
end

function PROG:ProcessPacket( pt, dat, hdl )
	if (!self.Enabled) then return end
	if (pt == 72) then
		local ip = hdl[1]
		PCMod.Msg( "ChatHost recieved net msg! (" .. dat[1] .. ")", true )
		if (dat[1] == "netChat_Register") then
			if (self:HasClient( ip )) then
				self:GetOS():ReplyNetMessage( hdl, { "netChat_Register_Fail" } )
			else
				self:RegisterClient( ip, dat[2] )
				self:GetOS():ReplyNetMessage( hdl, { "netChat_Register_Success" } )
			end
		end
		if (dat[1] == "netChat_Message") then
			if (!self:HasClient( ip )) then
				self:GetOS():ReplyNetMessage( hdl, { "netChat_Message_Fail" } )
			else
				self:ChatMessage( ip, dat[2] )
			end
		end
		if (dat[1] == "netChat_Unregister") then
			self:UnregisterClient( ip )
			self:GetOS():ReplyNetMessage( hdl, { "netChat_Unregistered" } )
		end
	end
end

function PROG:HasClient( ip )
	for _, v in pairs( self.Clients ) do
		if (v[1] == ip) then return true end
	end
	return false
end

function PROG:RegisterClient( ip, nick )
	if (self:HasClient( ip )) then return end
	if (!nick) then nick = ip end
	self:PrintMessage( "'" .. nick .. "' has connected from '" .. ip .. "'!" )
	table.insert( self.Clients, { ip, nick } )
	self.DeviceData.RCC = #self.Clients
	self:UpdateSS()
end

function PROG:UnregisterClient( ip )
	for k, v in pairs( self.Clients ) do
		if (v[1] == ip) then
			table.remove( self.Clients, k )
		end
	end
	self:PrintMessage( "'" .. ip .. "' has disconnected!" )
	self.DeviceData.RCC = #self.Clients
	self:UpdateSS()
end

function PROG:ChatMessage( ip, msg )
	local nick = ip
	for _, v in pairs( self.Clients ) do
		if (v[1] == ip) then
			nick = v[2]
			break
		end
	end
	self:PrintMessage( nick .. ": " .. msg )
end

function PROG:PrintMessage( msg )
	for _, v in pairs( self.Clients ) do
		self:GetOS():SendNetMessage( v[1], 72, { "netChat_Message_Cl", msg } )
	end
end

function PROG:UpdateMe()
	// self.DeviceData.Ps = self.PCnt
	local on = 0
	if (self.Enabled) then on = 1 end
	self.DeviceData.On = on
	self:UpdateSS()
end

function PROG:DoCommand( com, args )
	if (com == "enable") then
		self.Enabled = true
		self:UpdateMe()
	end
	if (com == "disable") then
		self.Enabled = false
		self:UpdateMe()
		self:PrintMessage( "Server shutting down!" )
		self.Clients = {}
	end
end