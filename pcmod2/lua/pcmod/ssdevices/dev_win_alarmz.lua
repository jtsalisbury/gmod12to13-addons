
// PCMod ScreenSpace Device | AlarmZ \\

DEV.Name = "window_alarmz"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.Al = 0
DEV.Cm = 0

local rtmat = surface.GetTextureID( "models/rendertarget" )

function DEV:Initialize( x, y, w, h )
	// Make exit button
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	
	// Make main buttons
	self:CreateButton2( self.Th, "btnEnable", x+(w*0.02), y+(h*0.84), w*0.47, h*0.06, "Enable Alarm" )
	self:CreateButton2( self.Th, "btnDisable", x+(w*0.51), y+(h*0.84), w*0.47, h*0.06, "Disable Alarm" )
	self:CreateButton2( self.Th, "btnEnableC", x+(w*0.02), y+(h*0.92), w*0.47, h*0.06, "Enable Camera" )
	self:CreateButton2( self.Th, "btnDisableC", x+(w*0.51), y+(h*0.92), w*0.47, h*0.06, "Disable Camera" )
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "AlarmZ", h*0.06 )
	self:Draw()
	
	if (self.Cm == 1) then
		surface.SetTexture( rtmat )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( x+(w*0.06), y+(h*0.1), w*0.88, h*0.66 )
	else
		if (self.Al == 1) then
			local a = math.AlphaFlash( 128, 255, 1 )
			draw.RoundedBox( 12, x+(w*0.06), y+(h*0.16), w*0.88, h*0.54, Color( 255, 0, 0, a ) )
			draw.SimpleText( "ALARM ACTIVE", "pcmod_3d2d", x+(w*0.5), y+(h*0.43), Color( 255, 255, 255, 255 ), 1, 1 )
		else
			draw.RoundedBox( 12, x+(w*0.06), y+(h*0.16), w*0.88, h*0.54, Color( 0, 200, 0, 255 ) )
			draw.SimpleText( "ALARM INACTIVE", "pcmod_3d2d", x+(w*0.5), y+(h*0.43), Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end
end

function DEV:ButtonClick( btn )
	if (btn == "btnEnable") then
		self:RunProgCommand( "alarmz", "enable" )
		return
	end
	if (btn == "btnDisable") then
		self:RunProgCommand( "alarmz", "disable" )
		return
	end
	if (btn == "btnEnableC") then
		self:RunProgCommand( "alarmz", "enable_c" )
		return
	end
	if (btn == "btnDisableC") then
		self:RunProgCommand( "alarmz", "disable_c" )
		return
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