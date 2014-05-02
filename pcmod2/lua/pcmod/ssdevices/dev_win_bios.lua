
// PCMod ScreenSpace Device | Bios Window \\

DEV.Name = "window_bios"

DEV.LastTick = 0
DEV.LastFrame = 0
DEV.Num = 0

DEV.FocusTextBox = false
DEV.Com = ""

DEV.CF = false

function DEV:Paint( x, y, w, h )
	if (!self.Text) then self.Text = {} end
	surface.SetDrawColor( 0, 0, 50, 255 )
	surface.DrawRect( x, y, w, h )
	local cnt = #self.Text
	if (cnt == 0) then return end
	surface.SetFont( "pcmod_3d2d" )
	local xs,ys = surface.GetTextSize( self.Text[1] )
	local perlbl = ys
	if ((perlbl*#self.Text) > (h*0.8)) then
		local offset = math.ceil( ((perlbl*#self.Text)-(h*0.8))/perlbl )
		local i
		for i=1,offset do
			//table.remove( self.Text, 1 )
		end
	end
	for k, v in pairs( self.Text ) do
		local ypos = (k-1)*perlbl
		local txt = tostring( v )
		if (type(v) == "number") then
			if (PCMod.Cfg.StatusCodes[ v ]) then
				txt = PCMod.Cfg.StatusCodes[ v ]
			else
				txt = "Invalid status code!"
			end
		end
		draw.SimpleText( txt, "pcmod_3d2d", x, y+ypos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end
	local selchar = ""
	if (self.FocusTextBox) then
		surface.SetDrawColor( 255, 255, 255, 50 )
		surface.DrawRect( x, y+(h*0.9), w, h*0.1 )
		selchar = "_"
	end
	if (self.CF) then surface.DrawLine( x, y+(h*0.9), x+w, y+(h*0.9) ) end
	surface.SetDrawColor( 255, 255, 255, 255 )
	//draw.SimpleText( tostring( self.Num ), "pcmod_3d2d", x+(w*0.95), y+(h*0.95), Color( 255, 255, 255, 255 ), 1, 1 )
	draw.SimpleText( self.Com .. selchar, "pcmod_3d2d", x, y+(h*0.95), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
end

function DEV:DoClick( x, y )
	if ((y>0.9) && (self.CF)) then
		self.FocusTextBox = true
	else
		self.FocusTextBox = false
	end
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
	self.Num = self.Num + 1
end

function DEV:Kill()

end

function DEV:KeyPress( key, txt )
	if (!self.FocusTextBox) then return end
	if ((key == "<--") && (string.len( self.Com ) > 0)) then self.Com = string.sub( self.Com, 1, string.len( self.Com )-1 ); return end
	if ((key == "ctrl") || (key == "shift") || (key == "alt") || (key == "tab")) then return end
	if (key == "enter") then
		PCMod.Msg( "Return key has been pressed!", true )
		self:SubmitCommand( "bios_command", self.Com )
		self.Com = ""
		return
	end
	self.Com = self.Com .. txt
end