
// PCMod ScreenSpace Device | ChatServ - Connect \\

DEV.Name = "window_chatserv_connect"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.Nk = "Unknown"
DEV.IP = ""
DEV.St = 0

function DEV:Initialize( x, y, w, h )
	// Make control buttons
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.08), y, h*0.08, h*0.08, "X" )
	
	// Make control stuff
	self:CreateTextbox( self.Th, "txtNick", x+(w*0.5), y+(h*0.15), w*0.96, h*0.08, "Nick:" )
	self:CreateTextbox( self.Th, "txtIP", x+(w*0.5), y+(h*0.25), w*0.96, h*0.08, "IP:" )
	self:CreateButton2( self.Th, "btnConnect", x+(w*0.02), y+(h*0.32), w*0.96, h*0.08, "Connect" )
	
	// Update
	self:OnUpdate()
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	// Draw window
	self:RenderWindow( self.Th, x, y, w, h, "ChatServ - Connect", h*0.08 )
	
	// Draw status text
	self:RenderText( x+(w*0.5), y+(h*0.42), { self.St }, Color( 255, 255, 255, 255 ), 1 )
	
	// Draw stuff
	self:Draw()
end

function DEV:ButtonClick( btn )
	if (btn == "btnConnect") then
		local nick = self:GetTextboxText( "txtNick" )
		local ip = self:GetTextboxText( "txtIP" )
		self:RunProgCommand( "chatserv", "connect", nick, ip )
	end
end

function DEV:OnUpdate()
	self:SetTextboxText( "txtIP", self.IP )
	self:SetTextboxText( "txtNick", self.Nk )
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