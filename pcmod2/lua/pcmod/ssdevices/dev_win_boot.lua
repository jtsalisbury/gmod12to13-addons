
// PCMod ScreenSpace Device | Boot Screen \\

DEV.Name = "window_boot"

DEV.LastTick = 0
DEV.LastFrame = 0
//DEV.Ang = 0

function DEV:Paint( x, y, w, h )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( x, y, w, h )
	local logo = PCMod.Res.Mats[ "gui/pcmod_logo" ]
	surface.SetTexture( logo )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( x+(w*0.2), y+(h*0.2), w*0.6, h*0.3 )
	//local circle = PCMod.Res.Mats[ "gui/pcmod_circle" ]
	//surface.SetTexture( circle )
	// surface.DrawTexturedRectRotated( x+(w*0.42), y+(h*0.52), w*0.16, w*0.16, self.Ang ) -- The height is (w*0.16), this is on purpose
	draw.SimpleText( "[ Personal Operating System ]", "pcmod_3d2d", x+(w*0.5), y+(h*0.7), Color( 255, 255, 255, 255 ), 1, 1 )
	draw.SimpleText( "Loading...", "pcmod_3d2d", x+(w*0.5), y+(h*0.75), Color( 255, 255, 255, 255 ), 1, 1 )
end

function DEV:DoClick( x, y )
	
end

function DEV:Tick()
	//local oldt = self.LastTick
	self.LastTick = CurTime()
	//local tp = CurTime() - oldt
	self.LastFrame = PCMod.SDraw.CFrame
	//self.Ang = self.Ang + (tp/3)
	//if (self.Ang > 360) then self.Ang = self.Ang - 360 end
end

function DEV:Kill()
	
end

function DEV:KeyPress( key )

end