
// PCMod ScreenSpace Device | Background \\
// Standard background, always black, clientside \\

DEV.Name = "background"

DEV.LastTick = 0
DEV.LastFrame = 0

function DEV:Paint( x, y, w, h )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( x, y, w, h )
end

function DEV:DoClick( x, y )
	
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
end

function DEV:Kill()
	
end

function DEV:KeyPress( key )

end