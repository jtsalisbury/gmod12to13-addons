
// PCMod ScreenSpace Device | ShutDown Window \\

DEV.Name = "server_shutdown"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "server"

function DEV:Paint( x, y, w, h )
	local c_pri = PCMod.Gui.GetThemeColour( self.Th, "Primary" )
	local c_sec = PCMod.Gui.GetThemeColour( self.Th, "Secondary" )
	surface.SetDrawColor( c_sec.r, c_sec.g, c_sec.b, c_sec.a )
	surface.DrawRect( x, y, w, h )
	self:RenderWindow( self.Th, x+(w*0.1), y+(h*0.3), w*0.8, h*0.4, "Server - System Shutdown", h*0.04 )
	self:RenderText( x+(w/2), y+(h/2), { "System Shutdown..." }, Color( 0, 0, 0, 255 ), 1 )
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
end