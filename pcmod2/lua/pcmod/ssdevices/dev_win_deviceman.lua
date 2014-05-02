
// PCMod ScreenSpace Device | Device Manager \\

DEV.Name = "window_devman"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.Dvs = {}

function DEV:Initialize( x, y, w, h )
	// Make exit button
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	
	// Make the device list
	self:CreateListbox( self.Th, "lstDevices", x+(w*0.04), y+(h*0.14), w*0.21, h*0.82 )
	for k, v in pairs( self.Dvs ) do
		if (v[1]) then
			self:AddListboxItem( "lstDevices", tostring( v[1] ), v[2] )
		end
	end
	
	// Make main buttons
	self:CreateButton2( self.Th, "btnRefresh", x+(w*0.31), y+(h*0.14), w*0.65, h*0.06, "Refresh Device List" )
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "Device Manager", h*0.06 )
	// self:RenderText( x+(w*0.5), y+(h*0.1), { "USB Dev" }, Color( 0, 0, 0, 255 ), 1 )
	self:RenderFrame( self.Th, "USB Devices", x+(w*0.02), y+(h*0.1), w*0.25, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, "Tools", x+(w*0.29), y+(h*0.1), w*0.69, h*0.88, Color( 255, 255, 255, 255 ) )
	self:Draw()
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btnExit") then
		self:RunProgCommand( "deviceman", "exit" )
		return
	end
	if (btn == "btnRefresh") then
		self:RunProgCommand( "deviceman", "refresh" )
		return
	end
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