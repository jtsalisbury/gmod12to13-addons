
// PCMod ScreenSpace Device | Server Panel \\

DEV.Name = "server_panel"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "server"
DEV.Progs = {}

DEV.StatusText = ""
DEV.StatusEnd = 0

function DEV:Initialize( x, y, w, h )

	self:CreateButton2( self.Th, "btnShutDown", x+(w*0.04), y+(h*0.15), w*0.21, h*0.06, "Shut Down" )
	self:CreateButton2( self.Th, "btnLockTower", x+(w*0.04), y+(h*0.22), w*0.21, h*0.06, "Lock Tower" )
	self:CreateButton2( self.Th, "btnRestart", x+(w*0.04), y+(h*0.29), w*0.21, h*0.06, "Restart System" )
	self:CreateButton2( self.Th, "btnReset", x+(w*0.04), y+(h*0.36), w*0.21, h*0.06, "Reset System" )
	self:CreateButton2( self.Th, "btnRefresh", x+(w*0.04), y+(h*0.43), w*0.21, h*0.06, "[ Refresh ]" )
	
	self:CreateListbox( self.Th, "lstProgs", x+(w*0.31), y+(h*0.15), w*0.21, h*0.73 )
	self:RebuildProgs()
	self:CreateButton2( self.Th, "btnSelect", x+(w*0.31), y+(h*0.9), w*0.21, h*0.06, "Load Program" )
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:RebuildProgs()
	self:ClearListbox( "lstProgs" )
	for k, v in pairs( self.Progs ) do
		self:AddListboxItem( "lstProgs", v[3], v[2] )
	end
end

function DEV:Paint( x, y, w, h )
	local ttl = "Server Control Panel"
	if (self.Sn) then ttl = ttl .. " - " .. self.Sn end
	if (self.StatusText != "") then ttl = ttl .. " - " .. self.StatusText end
	local cprog = self.CP
	if (!cprog) then cprog = "No Program" end
	self:RenderWindow( self.Th, x, y, w, h, ttl, h*0.06 )
	self:RenderFrame( self.Th, "System Control", x+(w*0.02), y+(h*0.1), w*0.25, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, "Server Programs", x+(w*0.29), y+(h*0.1), w*0.25, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, cprog, x+(w*0.56), y+(h*0.1), w*0.4, h*0.88, Color( 255, 255, 255, 255 ) )
	self:Draw()
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btnShutDown") then self:SubmitCommand( "os_command", "sys_shutdown" ) end
	if (btn == "btnLockTower") then self:SubmitCommand( "os_command", "sys_logoff" ) end
	if (btn == "btnRestart") then self:SubmitCommand( "os_command", "sys_restart" ) end
	if (btn == "btnReset") then self:SubmitCommand( "os_command", "sys_reset" ); self:SetStatus( "System reset!" ) end
	if (btn == "btnRefresh") then
		self:SubmitCommand( "os_command", "sys_refresh" )
		self:SetStatus( "System refreshed!" )
		self:RebuildProgs()
	end
	if (btn == "btnSelect") then
		local prog = self:GetListboxSelRow( "lstProgs" )
		if ((prog) && (prog != "")) then
			self:SubmitCommand( "os_command", "sys_reset" )
			self:SubmitCommand( "os_command", "sys_loadprog", prog )
			self:SetStatus( "Program selected!" )
		end
	end
end

function DEV:DoClick( x, y )
	self:ProcessClick( x, y )
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
	if (self.StatusEnd != 0) then
		if (CurTime() > self.StatusEnd) then
			self.StatusEnd = 0
			self.StatusText = ""
		end
	end
end

function DEV:KeyPress( key, txt )
	self:KeyPressTextboxes( key, txt )
end

function DEV:SetStatus( txt )
	self.StatusText = txt
	self.StatusEnd = CurTime()+3
end

function DEV:OnUpdate()
	self:RebuildProgs()
end