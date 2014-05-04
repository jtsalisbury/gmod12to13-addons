
// PCMod ScreenSpace Device | Choose Print Target \\

DEV.Name = "window_printloc"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"
DEV.Fs = {}

DEV.IsChanged = false

function DEV:Initialize( x, y, w, h )
	// Make exit button
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.1), y, h*0.1, h*0.1, "X" )
	
	// Make the location box
	self:CreateTextbox( self.Th, "txtLoc", x+(w*0.5), y+(h*0.7), w*0.96, h*0.1, "Target:" )
	self:SetTextboxText( "txtLoc", "local" )
	
	// Make the print button
	self:CreateButton2( self.Th, "btnPrint", x+(w*0.02), y+(h*0.9), w*0.96, h*0.08, "Print" )
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "Print File", h*0.1 )
	self:Draw()
	self:RenderText( x+(w*0.5), y+(h*0.12), { "Select a location to print to.", "An IP address is acceptable.", "Use 'local' to print locally." }, Color( 0, 0, 0, 255 ), 1 )
	
	if (PCMod.SDraw.DevParams[self.Entity:EntIndex()][ "window_printloc" ][ 1 ]) then
		self:RenderError( self.Th, x+(w*0.5), y+(h*0.45), "You have unsaved changes" )
		self:RenderError( self.Th, x+(w*0.5), y+(h*0.55), "These changes wont print" )
	end
end

function DEV:ButtonClick( btn )
	if (btn == "btnExit") then
		self:PassData( self.Parent, "runcommand", "closeprint" )
	end
	if (btn == "btnPrint") then
		local tg = self:GetTextboxText( "txtLoc" )
		if ((tg) && (tg != "")) then
			self:PassData( self.Parent, "doprint", tg )
		end
	end
end

function DEV:DoClick( x, y )
	self:ProcessClick( x, y )
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
end

function DEV:Kill()
	self.IsChanged = false
end

function DEV:KeyPress( key, txt )
	self:KeyPressTextboxes( key, txt )
end