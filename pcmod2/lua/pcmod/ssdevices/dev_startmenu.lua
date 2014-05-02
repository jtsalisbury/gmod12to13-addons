
// PCMod ScreenSpace Device | Start Menu \\

DEV.Name = "menu_start"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.CSize = 0.1

DEV.Th = "basic"

function DEV:Initialize( x, y, w, h )
	self:CreateButton2( self.Th, "btn_close", x+(w*(1-self.CSize)), y, self.CSize*w, self.CSize*h, "x" )
	self:CreateButton2( self.Th, "btn_logoff", x+(w*0.05), y+(h*0.8), w*0.425, h*0.15, "Log Off" )
	self:CreateButton2( self.Th, "btn_shutdown", x+(w*0.525), y+(h*0.8), w*0.425, h*0.15, "Shut Down" )
	self:CreateButton2( self.Th, "btn_allprogs", x+(w*0.05), y+(h*0.6), w*0.9, h*0.15, "All Programs ->" )
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	local c_sm = PCMod.Gui.GetThemeColour( self.Th, "StartMenuBG" )
	local c_bor = PCMod.Gui.GetThemeColour( self.Th, "Border" )
	surface.SetDrawColor( c_sm.r, c_sm.g, c_sm.b, c_sm.a )
	surface.DrawRect( x, y, w, h )
	surface.DrawOutline( x, y, w, h, c_bor )
	self:Draw()
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btn_close") then
		self:SubmitCommand( "os_command", "startmenu_close" )
	end
	if (btn == "btn_logoff") then
		self:SubmitCommand( "os_command", "sys_logoff" )
	end
	if (btn == "btn_shutdown") then
		self:SubmitCommand( "os_command", "sys_shutdown" )
	end
	if (btn == "btn_allprogs") then
		self:SubmitCommand( "os_command", "progmenu_open" )
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