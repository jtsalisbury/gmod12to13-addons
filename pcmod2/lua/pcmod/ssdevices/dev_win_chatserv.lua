
// PCMod ScreenSpace Device | ChatServ \\

DEV.Name = "window_chatserv"

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
	self:CreateButton2( self.Th, "btnDisconnect", x+(w*0.6), y+(h*0.08), w*0.38, h*0.06, "Disconnect" )
	
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
	self:RenderWindow( self.Th, x, y, w, h, "ChatServ - " .. self.IP, h*0.06 )
	self:Draw()
	
	local c_bor = PCMod.Gui.GetThemeColour( self.Th, "Border" )
	local c_tbbg = PCMod.Gui.GetThemeColour( self.Th, "TextboxBG" )
	local c_tb_txt = PCMod.Gui.GetThemeColour( self.Th, "Textbox_Text" )
	surface.SetDrawColor( c_tbbg.r, c_tbbg.g, c_tbbg.b, c_tbbg.a )
	local a = {}
	a.x, a.y, a.w, a.h = x+(w*0.02), y+(h*0.16), w*0.96, h*0.71
	surface.DrawRect( a.x, a.y, a.w, a.h )
	surface.DrawOutline( a.x, a.y, a.w, a.h, c_bor )
	
	self:RenderText( x+(w*0.02), y+(h*0.08), { "Connected as: '" .. self.Nk .. "'" }, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
	
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
	// self:SetTextboxText( "txtNick", self.Nk )
	// self:SetTextboxText( "txtIP", self.IP )
end

function DEV:ButtonClick( btn )
	if (btn == "btnExit") then
		self:RunProgCommand( "chatserv", "exit" )
	end
	if (btn == "btnDisconnect") then
		self:RunProgCommand( "chatserv", "disconnect" )
	end
	if (btn == "btnSend") then
		self:RunProgCommand( "chatserv", "msg", self:GetTextboxText( "txtChat" ) )
		self:SetTextboxText( "txtChat", "" )
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