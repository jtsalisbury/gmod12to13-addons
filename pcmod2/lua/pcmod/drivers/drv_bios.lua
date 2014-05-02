
// Bios Driver for PCMod 2
// Loads the OS

DRV = PCMod.DeriveDriver( "base" )

DRV.NiceName = "Computer Bios"
DRV.Name = "gen_bios"
DRV.Type = "control"

DRV.NextUpdate = 0

function DRV:Initialize()
	if (!self.Entity) then return end
	
	self.Entity:AddEHook( "driver", self.Name, "linked" )
	self.Entity:AddEHook( "driver", self.Name, "unlinked" )
	self.Entity:AddEHook( "driver", self.Name, "use" )
	self.Entity:AddEHook( "driver", self.Name, "turnon" )
	self.Entity:AddEHook( "driver", self.Name, "turnoff" )
	self.Entity:AddEHook( "driver", self.Name, "player_input" )
	
	self:Flush()
end

function DRV:Think()
	if (!self.Data) then self:Flush() end
	local st = self.Data.State
	if (!st) then return end
	if (st == 0) then return end
	if (st == 1) then
		// We are advancing to running the command
		if (CurTime()>self.NextUpdate) then self:SetState( 2 ) end
	end
	if (st == 2) then
		// We are about to run the command
		if (CurTime()>self.NextUpdate) then self:SetState( 3 ) end
	end
	if (st == 5) then
		// We are about to launch OS
		if (CurTime()>self.NextUpdate) then self:SetState( 6 ) end
	end
	if ((st == 6) || (st == 7)) then
		if (self.OS) then
			self.OS:Tick()
		end
	end
end

function DRV:CallEvent( data )
	if ((!data) || (!data.Event)) then return end
	local e = data.Event
	PCMod.Msg( "Bios CallEvent called! (" .. e .. ")", true )
	if (e == "turnon") then self:SetState( 1 ) return end
	if (e == "turnoff") then
		if (self.OS) then self.OS:ShutDown() end
		self:SetState( 0 )
		return
	end
	if (e == "player_input") then
		PCMod.Msg( "Bios recieved player input!", true )
		if (!data[2]) then return end
		local dat = data[2]
		local com = dat[1]
		table.remove( dat, 1 )
		if (com == "force_bsod") then
			self:SetState( 8 )
			return
		end
		if (com == "bios_command") then
			self:Exec( table.concat( dat, " " ) )
			return
		end
		if (com == "os_command") then
			self.OS:RunCommand( table.concat( dat, " " ) )
			return
		end
		if (com == "file_dump") then
			PrintTable( PCMod.Data[ self.Entity:EntIndex() ].HardDrive )
		end
		if (com == "write_file") then
			local args = table.Copy( dat )
			local fn = args[1]
			table.remove( args, 1 )
			self.Entity:WriteFile( fn, table.concat( args, " " ) )
		end
		if (com == "clear_os") then
			self.OS = nil
		end
	end
end

function DRV:GetPort()
	if (!self.Entity) then return end
	return self.Entity:Ports()[ self.PortID ]
end

function DRV:GetOSDriver( dname )
	return PCMod.Data[ self.Entity:EntIndex() ].Drivers[ dname ]
end

function DRV:Flush()
	PCMod.Msg( "Bios Flushing...", true )
	self.Data = {}
	self.Data.State = 0
	local display = self:GetOSDriver( "gen_display" )
	if (!display) then
		PCMod.Msg( ">> NO DISPLAY DRIVER FOUND! <<", true )
		return
	end
	display:FullFlush()
	return display
end

function DRV:InitScreen()
	local display = self:GetOSDriver( "gen_display" )
	if (!display) then
		PCMod.Msg( ">> NO DISPLAY DRIVER FOUND! <<", true )
		return
	end
	local ss = display:GetScreen()
	if (ss) then
		local dev = ss:MakeDevice( "window_bios", 0, 0, 1, 1, { Text = {} }, 2 )
		ss:AddDevice( "win_bios", dev )
		PCMod.Msg( "Bios updating screenspace...", true )
	else
		PCMod.Msg( ">> NO SCREEN-SPACE FOUND! <<", true )
	end
	display:SetScreen( ss )
end

function DRV:BootUp()
	self:Flush()
	self:SetState( 1 )
end

function DRV:ShutDown()
	self:Flush()
	self:SetState( 0 )
	self.Entity:TurnOff()
	self.OS:ShutDown()
end

function DRV:SetState( state )
	self.Data.State = state
	self:TriggerState( state )
end

function DRV:TriggerState( state )
	if (state == 0) then
		self:Flush()
		self:EnableCursor( false )
	else
		self:EnableCursor( true )
	end
	if (state == 1) then
		self:InitScreen()
		self.NextUpdate = CurTime()+2
		self:AddStatusText( 10 ) -- ==| BIOS Initialised |==
		self:AddStatusText( 11 ) -- ==| Version: 1.0.0 |==
		
	end
	if (state == 2) then
		self:AddStatusText( 12 ) -- -> Running execution command...
		self.NextUpdate = CurTime()+1
	end
	if (state == 3) then
		local res = self:ExecFile( "system/boot.sys" )
		if (res == false) then
			self:SetState( 4 )
		end
	end
	if (state == 4) then
		// Awaiting Command
		self:AddStatusText( 13 ) -- -> Awaiting command...
		self:SetWaitingCommand( true )
	end
	if (state == 5) then
		// Launching OS!
		self:SetWaitingCommand( false )
		self.NextUpdate = CurTime()+2
	end
	if (state == 6) then
		// OS launched, Bios in control
		self.OS:Launch()
	end
	if (state == 7) then
		// OS launched, OS in control
		self.OS:GiveControl()
	end
	if (state == 8) then
		// Blue-screening!
		self.NextUpdate = CurTime()+1
		local display = self:GetOSDriver( "gen_display" )
		local ss = display:GetScreen()
		ss:Clear()
		local dev = ss:MakeDevice( "bsod", 0, 0, 1, 1, { Text = {} }, 2 )
		ss:AddDevice( "win_bsod", dev )
	end
	if (state == 9) then
		self:ShutDown()
	end
end

function DRV:AddStatusText( str )
	local display = self:GetOSDriver( "gen_display" )
	if (!display) then return end
	local ss = display:GetScreen()
	if (!ss) then return end
	local txt = ss:GetDevice( "win_bios" )
	if (!txt) then return end
	table.insert( txt.Text, str )
	ss:AddDevice( "win_bios", txt )
	display:SetScreen( ss )
end

function DRV:Exec( com )
	self:AddStatusText( "] " .. com )
	if (com == "waitcommand") then
		self:SetState( 4 )
		return
	end
	if (com == "os:instance") then
		if (self.OS) then
			self:AddStatusText( 14 ) -- OS already instanced!
			return
		else
			local osname = self.Entity:ReadFile( "system/os/osid.sys" )
			if ((!osname) || (osname == "")) then
				self:AddStatusText( 15 ) -- No OS detected!
				return
			end
			if (!PCMod.OSys[ osname ]) then
				self:AddStatusText( 16 ) -- OS Installation Invalid!
				return
			end
			self.OS = table.Copy( PCMod.OSys[ osname ] )
			self.OS.Entity = self.Entity
			self:AddStatusText( 17 ) -- OS instance created!
		end
	end
	if (com == "os:launch") then
		if (!self.OS) then
			self:AddStatusText( 18 ) -- OS not instanced!
			return
		end
		self:AddStatusText( 19 ) -- Launching OS...
		self.OS:LinkNetPorts()
		self:SetState( 5 )
	end
	if (com == "shutdown") then
		self.OS:UnlinkNetPorts()
		self:ShutDown()
	end
end

function DRV:ExecFile( filename )
	if (!self.Entity:FileFolderExist( filename )) then
		self:AddStatusText( "-> Couldn't exec '" .. filename .. "'!" )
		return false
	end
	local fc = self.Entity:ReadFile( filename )
	if ((!fc) || (fc == "")) then return false end
	local tmp = string.Explode( "\n", fc )
	for _, v in pairs( tmp ) do
		self:Exec( v )
	end
	return true
end

function DRV:SetWaitingCommand( enabled )
	local display = self:GetOSDriver( "gen_display" )
	if (!display) then
		PCMod.Msg( ">> NO DISPLAY DRIVER FOUND! <<", true )
		return
	end
	local ss = display:GetScreen()
	if (ss) then
		local dev = ss:GetDevice( "win_bios" )
		dev.CF = enabled
		//ss:MakeDevice( "window_bios", 0, 0, 1, 1, { Text = {} }, 2 )
		ss:AddDevice( "win_bios", dev )
		PCMod.Msg( "Bios updating screenspace...", true )
	else
		PCMod.Msg( ">> NO SCREEN-SPACE FOUND! <<", true )
	end
	display:SetScreen( ss )
end

function DRV:EnableCursor( state )
	local display = self:GetOSDriver( "gen_display" )
	if (!display) then
		PCMod.Msg( ">> NO DISPLAY DRIVER FOUND! <<", true )
		return
	end
	local ss = display:GetScreen()
	if (ss) then
		if (state) then ss:EnableCursor() end
		if (!state) then ss:DisableCursor() end
	else
		PCMod.Msg( ">> NO SCREEN-SPACE FOUND! <<", true )
	end
	display:SetScreen( ss )
end