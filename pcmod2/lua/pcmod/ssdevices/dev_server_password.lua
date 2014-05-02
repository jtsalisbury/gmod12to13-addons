
// PCMod ScreenSpace Device | Password Entry \\

DEV.Name = "server_password"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Text = { "Welcome to the Server Control Panel.", "Please enter the password to continue." }

DEV.PI = 0

DEV.Th = "server"

function DEV:Initialize( x, y, w, h )
	self:CreateButton( self.Th, "btnGo", x+(w*0.5), y+(h*0.75), "Login" )
	self:CreateTextbox( self.Th, "txtPass", x+(w*0.5), y+(h*0.5), w*0.6, h*0.04, "Password:" )
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
	self:RenderWindow( self.Th, x+(w*0.1), y+(h*0.1), w*0.8, h*0.8, "Server Control Panel - Password Entry", h*0.04 )
	self:RenderText( x+(w/2), y+(h*0.15), self.Text, Color( 0, 0, 0, 255 ), 1 )
	self:DrawButtons()
	self:DrawTextboxes()
	if (self.PI == 1) then self:RenderError( self.Th, x+(w*0.5), y+(h*0.3), "Password Incorrect!" ) end
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btnGo") then
		self:SubmitCommand( "os_command", "password_enter", self:GetTextboxText( "txtPass" ) )
	end
end

function DEV:DoClick( x, y )
	self:ClickButtons( x, y )
	self:ClickTextboxes( x, y )
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