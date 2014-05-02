
// ChatServ Program for PCMod 2 \\

PROG.Name = "chatserv"
PROG.Author = "[GU]thomasfn"
PROG.Title = "ChatServ"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true -- Let the base do it's stuff, but we override our own stuff too

PROG.DeviceLink = "window_chatserv" -- This is the main window
PROG.DeviceName = "window_chatserv"
PROG.DeviceData = {}

PROG.Nick = "Unknown"
PROG.IP = "127.0.0.1"

PROG.MLimit = 10

function PROG:TriggerState( st )
	if (self:GetOS()) then self.DeviceData.Th = self:GetOS():GetTheme() end
	local ss = self:GetScreenSpace()
	if (st == 0) then
		self:OnEnd()
		ss:RemoveDevice( self.DeviceName )
		ss:RemoveDevice( "window_chatserv_connect" )
		self:SetScreenSpace( ss )
	end
	if (st == 1) then
		ss:RemoveDevice( self.DeviceName )
		self:OnStart()
		self:UpdateSS()
	end
	if (st == 2) then
		ss:RemoveDevice( self.DeviceName )
		ss:RemoveDevice( "window_chatserv_connect" )
		self:SetScreenSpace( ss )
	end
end

function PROG:UpdateSS()
	if (self.State == 1) then
		local ss = self:GetScreenSpace()
		// local dms = self:GetDimensions()
		local dms = { x=0.1, y=0.1, w=0.8, h=0.8 }
		local dat = table.Copy( self.DeviceData )
		if (dat.Msgs) then dat.Msgs = nil end
		local dev = ss:MakeDevice( "window_chatserv_connect", dms.x, dms.y, dms.w, dms.h, dat, self:GetPriority() )
		ss:AddDevice( "window_chatserv_connect", dev )
		self:SetScreenSpace( ss )
	end
	if (self.State == 2) then
		local ss = self:GetScreenSpace()
		local dms = self:GetDimensions()
		local dat = self.DeviceData
		local dev = ss:MakeDevice( self.DeviceLink, dms.x, dms.y, dms.w, dms.h, dat, self:GetPriority() )
		ss:AddDevice( self.DeviceName, dev )
		self:SetScreenSpace( ss )
	end
end

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
	end
	if (self.State == 1) then
		if (com == "setnick") then
			if (args[1]) then
				self.Nick = args[1]
				self.DeviceData.Nk = args[1]
				self:UpdateSS()
			end
		end
		if (com == "connect") then
			if ((args[1]) && (args[2]) && (string.IsIP( args[2] ))) then
				self:DoCommand( "setnick", { args[1] } )
				self.IP = args[2]
				self.DeviceData.IP = args[2]
				self.DeviceData.St = 21 -- Waiting for response...
				self:UpdateSS()
				self:GetOS():SendNetMessage( self.IP, 72, { "netChat_Register", self.Nick } )
			end
		end
	end
	if (self.State == 2) then
		if (com == "disconnect") then
			self:GetOS():SendNetMessage( self.IP, 72, { "netChat_Unregister" } )
			self.DeviceData.Msgs = {}
			self.DeviceData.St = nil
			self:SetState( 1 )
		end
		if (com == "msg") then
			local msg = table.concat( args, " " )
			//self:AddMessage( self.Nick .. ": " .. msg )
			self:GetOS():SendNetMessage( self.IP, 72, { "netChat_Message", msg } )
		end
	end
end

function PROG:OnStart()
	self:GetOS():OpenNetPort( 72, "prog", "chatserv" )
	self.DeviceData.Msgs = {}
end

function PROG:OnEnd()
	self:GetOS():SendNetMessage( self.IP, 72, { "netChat_Unregister" } )
	self:GetOS():CloseNetPort( 72 )
	self.DeviceData.Msgs = {}
	self.DeviceData.St = nil
end

function PROG:ProcessPacket( pt, dat, hdl )
	PCMod.Msg( "ChatServ recieved msg! (" .. dat[1] .. ")", true )
	if (pt == 72) then
		if (self.State == 1) then
			if (dat[1] == "netChat_Register_Success") then
				self:SetState( 2 )
				self:AddMessage( "Connected to " .. self.IP .. "!" )
			end
			if (dat[1] == "netChat_Register_Fail") then
				self.DeviceData.St = 27 -- Failed to connect!
				self:UpdateSS()
			end
			if (dat[1] == "netPortClosed") then
				self.DeviceData.St = 25 -- Target port closed!
				self:UpdateSS()
			end
			if (dat[1] == "netPortLocked") then
				self.DeviceData.St = 26 -- Target port locked!
				self:UpdateSS()
			end
		end
		if (self.State == 2) then
			if (dat[1] == "netChat_Message_Cl") then
				self:AddMessage( dat[2] )
			end
			if (dat[1] == "netPortClosed") then
				self:AddMessage( 25 ) -- Target port closed!
			end
			if (dat[1] == "netPortLocked") then
				self:AddMessage( 26 ) -- Target port locked!
			end
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
	self:UpdateSS()
end