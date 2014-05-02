
OS.IntName = "server"
OS.ExtName = "Server OS"

OS.Version = "1.0.0"

OS.Progs = {}

function OS:Setup()
	local ent = self.Entity
	ent:LinkFolder( "system/data/" )
	ent:LockItem( "system/data/" )
	ent:LinkFolder( "serverfiles/" )
	self:SetAllProgs( {} )
	self.PCData = {}
	if (self.tmp.Th) then
		self.PCData.Theme = self.tmp.Th
	end
	self:SaveData()
end

function OS:TriggerUpdate( st )
	if (st == 0) then return end
	if (st == 1) then
		self.tmp = {}
		self:Print( "Server OS Core Initialized..." )
		self:DelayUpdate( 1 )
		return
	end
	if (st == 2) then
		self:Print( "Preparing to boot system..." )
		self:DelayUpdate( 1 )
		return
	end
	if (st == 3) then
		self:RequestControl()
		return
	end
	if (st == 4) then
		self:Display():FullFlush()
		local ss = self:Display():GetScreen()
		ss:AddDevice( "win_boot", ss:MakeDevice( "server_boot", 0, 0, 1, 1, {}, 1 ) )
		self:Display():SetScreen( ss )
		self:DelayUpdate( 3 )
	end
	if (st == 5) then
		self:Display():FullFlush()
		self:DelayUpdate( 1 )
	end
	if (st == 6) then
		if (self:FirstRun()) then
			self:SetState( 7 )
		else
			self:SetState( 8 )
		end
	end
	if (st == 7) then
		local ss = self:Display():GetScreen()
		ss:AddDevice( "win_firstrun", ss:MakeDevice( "server_firstrun", 0, 0, 1, 1, {}, 1 ) )
		self:Display():SetScreen( ss )
	end
	if (st == 8) then
		local dt = self.Entity:Data()
		local pw = dt.Password
		if (pw == "") then
			self:SetState( 9 )
			return
		end
		local ss = self:Display():GetScreen()
		ss:ClearAll()
		local tmp = {}
		tmp.Th = self:GetTheme()
		ss:AddDevice( "win_pass", ss:MakeDevice( "server_password", 0, 0, 1, 1, tmp, 1 ) )
		self:Display():SetScreen( ss )
	end
	if (st == 9) then
		self:Display():FullFlush()
		self:DelayUpdate( 1 )
		self:LoadData()
	end
	if (st == 10) then
		self:BuildDesktop()
	end
	if (st == 11) then
		// Shutting down
		local ss = self:Display():GetScreen()
		ss:ClearAll()
		local tmp = {}
		tmp.Th = self:GetTheme()
		ss:AddDevice( "win_shutdown", ss:MakeDevice( "server_shutdown", 0, 0, 1, 1, tmp, 1 ) )
		self:Display():SetScreen( ss )
		self:DelayUpdate( 2 )
	end
	if (st == 12) then
		self:Bios():Exec( "shutdown" )
	end
end

function OS:GiveControl()
	self:DelayUpdate( 1 )
end

function OS:RunCommand( com )
	local coms = string.Explode( " ", com )
	local com = coms[1]
	table.remove( coms, 1 )
	local args = coms
	// PCMod.Msg( "COM: " .. com ..", " .. table.concat( args, " " ), true )
	if (com == "password_set") then
		if (self.State != 7) then return end
		if (args[1]) then PCMod.Data[ self.Entity:EntIndex() ].Password = args[1] end
		self:RegisterRun()
		self:Setup()
		if (self.ServerName) then
			self.PCData.ServerName = self.ServerName
			self:SaveData()
			PCMod.Msg( "Server name saved!", true )
		end
		self:SetState( 8 )
	end
	if (com == "servername_set") then
		if (self.State != 7) then return end
		if (args[1]) then
			self.ServerName = args[1]
			// self:SaveData()
		end
	end
	if (com == "password_enter") then
		if (self.State != 8) then return end
		if (args[1] == PCMod.Data[ self.Entity:EntIndex() ].Password) then
			self:SetState( 9 )
		else
			local ss = self:Display():GetScreen()
			local dev = ss:GetDevice( "win_pass" )
			dev.PI = 1
			ss:AddDevice( "win_pass", dev )
			self:Display():SetScreen( ss )
		end
	end
	if (com == "sys_logoff") then
		if (self.State != 10) then return end
		self:ShutDown()
		self:SetState( 8 )
	end
	if (com == "sys_shutdown") then
		if (self.State != 10) then return end
		self:SetState( 11 )
	end
	if (com == "sys_restart") then
		self:RunCommand( "sys_shutdown" )
	end
	if (com == "sys_reset") then
		self:ShutDown()
	end
	if (com == "sys_refresh") then
		self:BuildDesktop()
	end
	if (com == "sys_loadprog") then
		if (self.State != 10) then return end
		self:ShutDown()
		if (args[1]) then
			local p = args[1]
			if (self.Progs[p]) then self.Progs[p]:Start() end
			self.CP = p
		end
	end
	if (com == "sys_resetprog") then
		if (self.Progs[ args[1] ]) then
			self.Progs[ args[1] ]:Exit()
			self.Progs[ args[1] ] = table.Copy( PCMod.Progs[ args[1] ] )
			self.Progs[ args[1] ].Entity = self.Entity
		end
	end
	if (com == "sys_settheme") then
		if (args[1]) then
			if (!self.PCData) then
				self.tmp.Th = args[1]
			else
				self.PCData.Theme = args[1]
				self:SaveData()
			end
		end
		if (!args[2]) then
			self:ShutDown()
			self:SetState( 9 )
		end
	end
	if (com == "snd_play") then
		if (self.State != 10) then return end
		if (args[1]) then
			self:Sound():PlaySound( args[1] )
		end
	end
	if (com == "snd_stop") then
		if (self.State != 10) then return end
		self:Sound():StopSounds()
	end
	if (com == "prog_command") then
		if ((args[1]) && (args[2])) then
			local newargs = args
			local prog = args[1]
			local newcom = args[2]
			table.remove( newargs, 1 )
			table.remove( newargs, 1 ) -- Repeated on purpose
			if (self.Progs[ prog ]) then
				self.Progs[ prog ]:DoCommand( newcom, newargs )
			end
		end
	end
end

function OS:BuildDesktop()
	local ss = self:Display():GetScreen()
	ss:AddDevice( "desktop", ss:MakeDevice( "server_panel", 0, 0, 1, 1, self:BuildDesktopData(), 1 ) )
	self:Display():SetScreen( ss )
end

function OS:GetTheme()
	if (self.PCData.Theme) then return self.PCData.Theme end
	return "server"
end

function OS:BuildDesktopData()
	local tmp = {}
		if (self.PCData.BG) then tmp.BG = self.PCData.BG end
		if (self.PCData.ServerName) then tmp.Sn = self.PCData.ServerName end
		tmp.Th = self:GetTheme()
		local ps = self:GetAllProgs()
		if (ps) then tmp.Progs = table.Copy( ps ) end
		tmp.CP = self.CP
	return tmp
end

function OS:DoPacket( pt, dat, handle )

end