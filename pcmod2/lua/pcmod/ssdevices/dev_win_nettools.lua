
// PCMod ScreenSpace Device | Net-Tools \\

DEV.Name = "window_nettools"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.St = 0
DEV.IP = ""
DEV.Tg = ""

DEV.Tr = {}

function DEV:Initialize( x, y, w, h )
	// Make exit button
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	
	// Make the trace results
	self:CreateListbox( self.Th, "lstTrace", x+(w*0.61), y+(h*0.14), w*0.35, h*0.82 )
	self:BuildTraceResults()
	
	// Make main buttons
	self:CreateButton2( self.Th, "btnPing", x+(w*0.04), y+(h*0.22), w*0.5, h*0.06, "Ping" )
	self:CreateButton2( self.Th, "btnTrace", x+(w*0.04), y+(h*0.3), w*0.5, h*0.06, "Trace" )
	
	// Make IP entry box
	self:CreateTextbox( self.Th, "txtIP", x+(w*0.28), y+(h*0.18), w*0.5, h*0.06, "IP:" )
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "Net Tools", h*0.06 )
	// self:RenderText( x+(w*0.5), y+(h*0.1), { "USB Dev" }, Color( 0, 0, 0, 255 ), 1 )
	self:RenderFrame( self.Th, "Trace Results", x+(w*0.59), y+(h*0.1), w*0.39, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, "Tools", x+(w*0.02), y+(h*0.1), w*0.54, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderText( x+(w*0.26), y+(h*0.8), { self.St, self.IP, self.Tg }, Color( 255, 255, 255, 255 ), 1 )
	self:Draw()
end

function DEV:ButtonClick( btn )
	// local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	local ip = self:GetTextboxText( "txtIP" )
	if (!ip) then ip = "" end
	if (btn == "btnExit") then
		self:RunProgCommand( "nettools", "exit" )
		return
	end
	if (btn == "btnPing") then
		self:RunProgCommand( "nettools", "ping", ip )
		return
	end
	if (btn == "btnTrace") then
		self:RunProgCommand( "nettools", "trace", ip )
		return
	end
end

function DEV:ListboxSelect( name, option )
	//if (name == "lstPorts") then
		//self:SelectPort( tostring( option ) )
	//end
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

function DEV:OnUpdate()
	self:BuildTraceResults()
end

function DEV:BuildTraceResults()
	self:ClearListbox( "lstTrace" )
	for k, v in pairs( self.Tr ) do
		self:AddListboxItem( "lstTrace", tostring( k ), v )
	end
end