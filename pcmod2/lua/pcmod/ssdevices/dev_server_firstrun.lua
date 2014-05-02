
// PCMod ScreenSpace Device | First-Run Window \\

DEV.Name = "server_firstrun"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.StepText = {
	{ "Welcome to the Server OS!", "This is the first time you have turned the server on.", "You may set some options in the next screen.", "Click 'Next' to continue." },
	{ "It has been found that bloom can cause readability", "issues in PCMod. You can choose to use our", "bloom friendly theme below. Click the bloom button", "to try the theme out and then use the server button", "if you decide not to use it. A listbox has been provided", "to demonstrate what things might look like.", "Click 'Next' to continue." },
	{ "Please enter a password to use.", "You can leave it blank for no password.", "Once you have finished, click 'Finish' to continue." }
}

DEV.Step = 1

DEV.Th = "server"

function DEV:Initialize( x, y, w, h )
	self:CreateButton( self.Th, "s1_next", x+(w*0.5), y+(h*0.75), "Next" )
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	local c_pri = PCMod.Gui.GetThemeColour( self.Th, "Primary" )
	local c_sec = PCMod.Gui.GetThemeColour( self.Th, "Secondary" )
	surface.SetDrawColor( c_sec.r, c_sec.g, c_sec.b, c_sec.a )
	surface.DrawRect( x, y, w, h )
	self:RenderWindow( self.Th, x+(w*0.1), y+(h*0.1), w*0.8, h*0.8, "Server - First Run", h*0.04 )
	self:RenderText( x+(w/2), y+(h*0.15), self.StepText[self.Step], Color( 0, 0, 0, 255 ), 1 )
	if(self.Step == 2) then
		local lb = {}
			lb.Theme = self.Th
			lb.List = {}
			lb.List[ "op1" ] = "option 1"
			lb.List[ "op2" ] = "option 2"
			lb.SelItem = "op1"
			lb.X = x+(w*0.35)
			lb.Y = y+(h*0.7)
			lb.W = w*0.3
			lb.H = h*0.114
			lb.MX = lb.X+(lb.W/2)
		self:RenderListbox( lb )
	end
	self:Draw()
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "s1_next") then
		self.Step = 2
		self:RemoveElement( "s1_next" )
		self:CreateButton( self.Th, "s2_next", x+(w*0.5), y+(h*0.851), "Next" )
		self:CreateButton( self.Th, "s2_bloom", x+(w*0.5), y+(h*0.6), "Set Bloom Theme" )
		self:CreateButton( self.Th, "s2_server", x+(w*0.5), y+(h*0.66), "Set Server Theme" )
	end
	if (btn == "s2_bloom") then
		self:SubmitCommand( "os_command", "sys_settheme", "bloom", "true" )
		self.Th = "bloom"
		self:RemoveElement( "s2_next" )
		self:RemoveElement( "s2_bloom" )
		self:RemoveElement( "s2_server" )
		self:CreateButton( self.Th, "s2_next", x+(w*0.5), y+(h*0.851), "Next" )
		self:CreateButton( self.Th, "s2_bloom", x+(w*0.5), y+(h*0.6), "Set Bloom Theme" )
		self:CreateButton( self.Th, "s2_server", x+(w*0.5), y+(h*0.66), "Set Server Theme" )
	end
	if (btn == "s2_server") then
		self:SubmitCommand( "os_command", "sys_settheme", "server", "true" )
		self.Th = "server"
		self:RemoveElement( "s2_next" )
		self:RemoveElement( "s2_bloom" )
		self:RemoveElement( "s2_server" )
		self:CreateButton( self.Th, "s2_next", x+(w*0.5), y+(h*0.851), "Next" )
		self:CreateButton( self.Th, "s2_bloom", x+(w*0.5), y+(h*0.6), "Set Bloom Theme" )
		self:CreateButton( self.Th, "s2_server", x+(w*0.5), y+(h*0.66), "Set Server Theme" )
	end
	if (btn == "s2_next") then
		self.Step = 3
		self:RemoveElement( "s2_next" )
		self:RemoveElement( "s2_bloom" )
		self:RemoveElement( "s2_server" )
		self:CreateButton( self.Th, "s3_next", x+(w*0.5), y+(h*0.75), "Finish" )
		self:CreateTextbox( self.Th, "s3_pass", x+(w*0.5), y+(h*0.5), w*0.6, h*0.04, "Password:" )
		self:CreateTextbox( self.Th, "s3_name", x+(w*0.5), y+(h*0.55), w*0.6, h*0.04, "Server Name:" )
	end
	if (btn == "s3_next") then
		local pw = self:GetTextboxText( "s3_pass" )
		if (!pw) then pw = "" end
		local svrn = self:GetTextboxText( "s3_name" )
		if (!svrn) then svrn = "" end
		self:SubmitCommand( "os_command", "servername_set", svrn )
		self:SubmitCommand( "os_command", "password_set", pw )
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
	
end

function DEV:KeyPress( key, txt )
	self:KeyPressTextboxes( key, txt )
end