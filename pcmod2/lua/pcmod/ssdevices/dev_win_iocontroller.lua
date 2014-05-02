
// PCMod ScreenSpace Device | I/O Controller \\

DEV.Name = "window_iocontroller"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.Ins = {}
DEV.Outs = {}

DEV.SelOut = "None"
DEV.St = 0

function DEV:Initialize( x, y, w, h )
	// Make exit button
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	
	// Make the input list
	self:CreateListbox( self.Th, "lstIns", x+(w*0.04), y+(h*0.14), w*0.21, h*0.82 )
	self:BuildInputList()
	
	// Make the output list
	self:CreateListbox( self.Th, "lstOuts", x+(w*0.31), y+(h*0.14), w*0.21, h*0.82 )
	self:BuildOutputList()
	
	// Make output set box
	self:CreateTextbox( self.Th, "txtVal", x+(w*0.77), y+(h*0.3), w*0.38, h*0.06, "Value:" )
	self:CreateButton2( self.Th, "btnSet", x+(w*0.58), y+(h*0.35), w*0.38, h*0.06, "Set" )
	
	// Make the refresh button
	self:CreateButton2( self.Th, "btnRefresh", x+(w*0.58), y+(h*0.9), w*0.38, h*0.06, "Refresh Inputs" )
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "I/O Controller", h*0.06 )
	self:RenderFrame( self.Th, "Inputs", x+(w*0.02), y+(h*0.1), w*0.25, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, "Outputs", x+(w*0.29), y+(h*0.1), w*0.25, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, "Control", x+(w*0.56), y+(h*0.1), w*0.42, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderText( x+(w*0.77), y+(h*0.14), { "Selected Output:", self.SelOut }, Color( 255, 255, 255, 255 ), 1 )
	self:RenderText( x+(w*0.77), y+(h*0.9), { self.St }, Color( 255, 255, 255, 255 ), 1 )
	self:Draw()
end

function DEV:ButtonClick( btn )
	// local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btnExit") then
		self:RunProgCommand( "iocontroller", "exit" )
		return
	end
	if (btn == "btnRefresh") then
		self:RunProgCommand( "iocontroller", "refresh" )
		return
	end
	if (self.SelOut == "None") then return end
	if (btn == "btnSet") then
		local val = self:GetTextboxText( "txtVal" )
		self:RunProgCommand( "iocontroller", "setoutput", self.SelOut, val )
		return
	end
end

function DEV:ListboxSelect( name, option )
	if (name == "lstOuts") then
		self:SelectOutput( tostring( option ) )
	end
end

function DEV:SelectOutput( id )
	self.SelOut = id
	local val = tostring( self.Outs[ id ] )
	if (id == 0) then val = "0" end
	if (val == "nil") then val = "0" end
	self:SetTextboxText( "txtVal", val )
end

function DEV:BuildInputList()
	self:ClearListbox( "lstIns" )
	for k, v in pairs( self.Ins ) do
		self:AddListboxItem( "lstIns", k, k .. " - " .. tostring( v ) )
	end
end

function DEV:BuildOutputList()
	self:ClearListbox( "lstOuts" )
	for k, v in pairs( self.Outs ) do
		self:AddListboxItem( "lstOuts", k, k .. " - " .. tostring( v ) )
	end
end

function DEV:OnUpdate()
	self:BuildInputList()
	self:BuildOutputList()
	self:SelectOutput( self.SelOut )
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