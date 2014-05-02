
// PCMod ScreenSpace Device | P2P Chat \\

DEV.Name = "window_p2pchat"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.Nk = "Unknown"
DEV.IP = "127.0.0.1"
DEV.Msgs = {}

function DEV:Initialize( x, y, w, h )
	// Make control buttons
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	
	// Make upper control stuff
	self:CreateTextbox( self.Th, "txtNick", x+(w*0.4), y+(h*0.11), w*0.74, h*0.06, "Nickname:" )
	self:CreateButton2( self.Th, "btnSetNick", x+(w*0.8), y+(h*0.08), w*0.18, h*0.06, "Set" )
	
	self:CreateTextbox( self.Th, "txtIP", x+(w*0.4), y+(h*0.19), w*0.74, h*0.06, "IP:" )
	self:CreateButton2( self.Th, "btnSetIP", x+(w*0.8), y+(h*0.16), w*0.18, h*0.06, "Set" )
	
	// Make chat message textbox
	self:CreateTextbox( self.Th, "txtChat", x+(w*0.4), y+(h*0.94), w*0.74, h*0.06, "Chat:" )
	self:CreateButton2( self.Th, "btnSend", x+(w*0.8), y+(h*0.91), w*0.18, h*0.06, "Send" )
	
	// Update
	self:OnUpdate()
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "P2P Chat", h*0.06 )
	self:Draw()
	
	local c_bor = PCMod.Gui.GetThemeColour( self.Th, "Border" )
	local c_tbbg = PCMod.Gui.GetThemeColour( self.Th, "TextboxBG" )
	local c_tb_txt = PCMod.Gui.GetThemeColour( self.Th, "Textbox_Text" )
	surface.SetDrawColor( c_tbbg.r, c_tbbg.g, c_tbbg.b, c_tbbg.a )
	local a = {}
	a.x, a.y, a.w, a.h = x+(w*0.02), y+(h*0.24), w*0.96, h*0.63
	surface.DrawRect( a.x, a.y, a.w, a.h )
	surface.DrawOutline( a.x, a.y, a.w, a.h, c_bor )
	
	surface.SetFont( "pcmod_3d2d" )
	local cnt
	for cnt=1, #self.Msgs do
		local txt = self.Msgs[ cnt ]
		if (type( txt ) != "string") then txt = PCMod.Cfg.StatusCodes[ txt ] end
		if (!txt) then txt = "Status code invalid!" end
		local tw, th = surface.GetTextSize( txt )
		local ypos = a.y+((cnt-1)*th)
		txt = string.Replace( txt, "/M", self.Nk )
		draw.SimpleText( txt, "pcmod_3d2d", a.x+1, ypos, c_tb_txt, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end
end

function DEV:OnUpdate()
	self:SetTextboxText( "txtNick", self.Nk )
	self:SetTextboxText( "txtIP", self.IP )
end

function DEV:ButtonClick( btn )
	if (btn == "btnExit") then
		self:RunProgCommand( "p2pchat", "exit" )
	end
	if (btn == "btnSetNick") then
		self:RunProgCommand( "p2pchat", "setnick", self:GetTextboxText( "txtNick" ) )
	end
	if (btn == "btnSetIP") then
		self:RunProgCommand( "p2pchat", "setip", self:GetTextboxText( "txtIP" ) )
	end
	if (btn == "btnSend") then
		self:RunProgCommand( "p2pchat", "msg", self:GetTextboxText( "txtChat" ) )
		self:SetTextboxText( "txtChat", "" )
	end
end

function DEV:DoClick( x, y )
	self:ProcessClick( x, y )
end

function DEV:DataRecieved( name, data )
	if (name == "filename") then self:SetTextboxText( "txtFilename", data ) end
	if (name == "runcommand") then self:RunProgCommand( "notepad", data ) end
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
end

function DEV:KeyPress( key, txt )
	self:KeyPressTextboxes( key, txt )
end