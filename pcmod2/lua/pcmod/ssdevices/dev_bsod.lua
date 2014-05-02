
// PCMod ScreenSpace Device | Blue Screen of Death \\

DEV.Name = "bsod"

DEV.LastTick = 0
DEV.LastFrame = 0

function DEV:Paint( x, y, w, h )
	surface.SetDrawColor( 0, 0, 200, 255 )
	surface.DrawRect( x, y, w, h )
	
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
end