
// PCMod ScreenSpace Device | Desktop \\

DEV.Name = "desktop"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.State = 1
-- 1 = just desktop
-- 2 = desktop with start menu
-- 3 = desktop with start menu and programs menu

DEV.BarSize = 0.06

DEV.BtnSize = 0.06
DEV.BtnW = 0.12

DEV.Th = "basic"

function DEV:Initialize( x, y, w, h )
	local btny = y + (h * (1 - self.BtnSize))
	self:CreateButton2( self.Th, "btn_start", x, btny, w*self.BtnW, h*self.BtnSize, "Start" )
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	local c_pri = PCMod.Gui.GetThemeColour( self.Th, "Primary" )
	local c_sec = PCMod.Gui.GetThemeColour( self.Th, "Secondary" )
	local c_tsk = PCMod.Gui.GetThemeColour( self.Th, "TaskBar" )
	local c_bor = PCMod.Gui.GetThemeColour( self.Th, "Border" )
	local bary = y + (h * (1 - self.BarSize))
	local bg = self.BG
	if (!bg) then
		surface.SetDrawColor( c_sec.r, c_sec.g, c_sec.b, c_sec.a )
		surface.DrawRect( x, y, w, h )
	else
		local id = self.BGID
		if (!id) then
			self.BGID = surface.GetTextureID( self.BG )
			id = self.BGID
		end
		surface.SetTexture( id )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( x, y, w, h )
	end
	surface.SetDrawColor( c_tsk.r, c_tsk.g, c_tsk.b, c_tsk.a )
	surface.DrawRect( x, bary, w, h*self.BarSize )
	surface.SetDrawColor( c_bor.r, c_bor.g, c_bor.b, c_bor.a )
	surface.DrawLine( x+(w*self.BtnW), bary, x+w, bary )
	self:Draw()
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	PCMod.Msg( "CLICKING " .. btn, true )
	if (btn == "btn_start") then
		PCMod.Msg( "CLICKING START", true )
		self:SubmitCommand( "os_command", "startmenu_open" )
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