
// PCMod ScreenSpace Device | All Programs Menu \\

DEV.Name = "menu_allprogs"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.ShortcutHeight = 0.06

DEV.Progs = {}

DEV.Th = "basic"

function DEV:Initialize( x, y, w, h )
	
	for k, v in pairs( self.Progs ) do
		local ypos = y + ((k-1) * h * self.ShortcutHeight )
		self:CreateButton2( self.Th, "btn_p_" .. tostring( k ), x, ypos, w, self.ShortcutHeight*h, v[2], v[1] )
	end
	
	
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
	for k, v in pairs( self.Progs ) do
		local bname = "btn_p_" .. tostring( k )
		if (btn == bname) then
			self:SubmitCommand( "os_command", "startmenu_close" )
			self:SubmitCommand( "os_command", v[3] )
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
	
end

function DEV:KeyPress( key, txt )
	//self:KeyPressTextboxes( key, txt )
end