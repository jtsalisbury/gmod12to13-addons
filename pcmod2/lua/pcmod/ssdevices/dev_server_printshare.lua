
// PCMod ScreenSpace Device | Printshare CPanel \\

DEV.Name = "server_printshare"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.On = 0

function DEV:Initialize( x, y, w, h )
	// Create the main buttons
	self:CreateButton2( self.Th, "btnEnable", x+(w*0.02), y+(h*0.10), w*0.96, h*0.08, "Enable" )
	self:CreateButton2( self.Th, "btnDisable", x+(w*0.02), y+(h*0.20), w*0.96, h*0.08, "Disable" )
end

function DEV:Paint( x, y, w, h )
	self:Draw()
	local txt = "Disabled"
	if (self.On == 1) then txt = "Enabled" end
	self:RenderText( x+(w*0.5), y+(h*0.02), { txt }, Color( 255, 255, 255, 255 ), 1 )
end

function DEV:ButtonClick( btn )
	if (btn == "btnEnable") then
		self:RunProgCommand( "printshare", "enable" )
		return
	end
	if (btn == "btnDisable") then
		self:RunProgCommand( "printshare", "disable" )
		return
	end
end