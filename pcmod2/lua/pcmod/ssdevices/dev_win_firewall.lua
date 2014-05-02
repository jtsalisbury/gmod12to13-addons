
// PCMod ScreenSpace Device | Firewall \\

DEV.Name = "window_firewall"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.Pts = {}

DEV.SelPort = "None"
DEV.PTLocked = false

function DEV:Initialize( x, y, w, h )
	// Make exit button
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	
	// Make the port
	self:CreateListbox( self.Th, "lstPorts", x+(w*0.04), y+(h*0.14), w*0.21, h*0.82 )
	self:BuildPortList()
	
	// Make main buttons
	self:CreateButton2( self.Th, "btnRefresh", x+(w*0.31), y+(h*0.9), w*0.65, h*0.06, "Refresh Port List" )
	self:CreateButton2( self.Th, "btnLock", x+(w*0.31), y+(h*0.32), w*0.32, h*0.06, "Lock Port" )
	self:CreateButton2( self.Th, "btnUnlock", x+(w*0.64), y+(h*0.32), w*0.32, h*0.06, "Unlock Port" )
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "Firewall", h*0.06 )
	// self:RenderText( x+(w*0.5), y+(h*0.1), { "USB Dev" }, Color( 0, 0, 0, 255 ), 1 )
	self:RenderFrame( self.Th, "NetPorts", x+(w*0.02), y+(h*0.1), w*0.25, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, "Firewall", x+(w*0.29), y+(h*0.1), w*0.69, h*0.88, Color( 255, 255, 255, 255 ) )
	local lcked = "Not Locked"
	if (self.PTLocked) then lcked = "[ LOCKED ]" end
	self:RenderText( x+(w*0.625), y+(h*0.14), { "Selected Port:", self.SelPort, lcked }, Color( 255, 255, 255, 255 ), 1 )
	self:Draw()
end

function DEV:ButtonClick( btn )
	// local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btnExit") then
		self:RunProgCommand( "firewall", "exit" )
		return
	end
	if (btn == "btnRefresh") then
		self:RunProgCommand( "firewall", "refresh" )
		return
	end
	if (self.SelPort == "None") then return end
	if (btn == "btnLock") then
		self:RunProgCommand( "firewall", "lockport", self.SelPort )
		return
	end
	if (btn == "btnUnlock") then
		self:RunProgCommand( "firewall", "unlockport", self.SelPort )
		return
	end
end

function DEV:ListboxSelect( name, option )
	if (name == "lstPorts") then
		self:SelectPort( tostring( option ) )
	end
end

function DEV:SelectPort( port )
	self.SelPort = port
	local pt
	for _, v in pairs( self.Pts ) do
		if (v[1] == tonumber( port )) then
			pt = v
			break
		end
	end
	if (!pt) then return end
	PCMod.Msg( "Determining locked or not: " .. pt[2], true )
	self.PTLocked = (pt[2] == 1)
end

function DEV:BuildPortList()
	self:ClearListbox( "lstPorts" )
	for k, v in pairs( self.Pts ) do
		if (v[1]) then
			local pt = tostring( v[1] )
			self:AddListboxItem( "lstPorts", pt, pt )
		end
	end
end

function DEV:OnUpdate()
	self:BuildPortList()
	self:SelectPort( self.SelPort )
end

function DEV:DoClick( x, y )
	self:ProcessClick( x, y )
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
end

function DEV:KeyPress( key, txt )
	self:KeyPressTextboxes( key, txt )
end