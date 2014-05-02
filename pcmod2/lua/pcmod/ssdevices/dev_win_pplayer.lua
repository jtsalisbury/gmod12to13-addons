
// PCMod ScreenSpace Device | Server Panel \\

DEV.Name = "window_pplayer"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.Snd = ""
DEV.SName = ""

function DEV:Initialize( x, y, w, h )
	// Make exit button
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	
	// Make the category list
	self:CreateListbox( self.Th, "lstCats", x+(w*0.03), y+(h*0.14), w*0.23, h*0.82 )
	for k, v in pairs( PCMod.Cfg.Music ) do
		if ((v)&&(k)) then
			self:AddListboxItem( "lstCats", k, k )
		end
	end
	
	// Make the song list
	self:CreateListbox( self.Th, "lstSongs", x+(w*0.30), y+(h*0.14), w*0.23, h*0.82 )
	
	// Make the player buttons
	self:CreateButton2( self.Th, "btnStop", x+(w*0.58), y+(h*0.3), w*0.38, h*0.08, "Stop Music" )
	
	// Init some other stuff
	self:OnUpdate()
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "Personal Player", h*0.06 )
	self:RenderFrame( self.Th, "Categories", x+(w*0.02), y+(h*0.1), w*0.25, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, "Songs", x+(w*0.29), y+(h*0.1), w*0.25, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderFrame( self.Th, "Player", x+(w*0.56), y+(h*0.1), w*0.42, h*0.88, Color( 255, 255, 255, 255 ) )
	self:RenderText( x+(w*0.77), y+(h*0.12), { "Currently Playing:", self.SName }, Color( 255, 255, 255, 255 ), 1 )
	self:Draw()
end

function DEV:ListboxSelect( lbname, option )
	if (lbname == "lstCats") then
		self:ClearListbox( "lstSongs" )
		for _, v in pairs( PCMod.Cfg.Music[ option ] ) do
			self:AddListboxItem( "lstSongs", v[2], v[1] )
		end
	end
	if (lbname == "lstSongs") then
		// self:SubmitCommand( "os_command", "snd_play", option )
		self:RunProgCommand( "pplayer", "play_sound", option )
	end
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btnExit") then self:RunProgCommand( "pplayer", "exit" ) end
	if (btn == "btnStop") then self:RunProgCommand( "pplayer", "stop_sound" ) end
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

function DEV:FindSoundName( snd )
	if ((!snd) || (snd == "")) then return "" end
	for k, v in pairs( PCMod.Cfg.Music ) do
		if (type( v ) == "table") then
			for _, sng in pairs( v ) do
				if (sng[2] == snd) then return k .. " - " .. sng[1] end
			end
		end
	end
	return snd
end

function DEV:OnUpdate()
	PCMod.Msg( "PPlayer updating!", true )
	self.SName = self:FindSoundName( self.Snd )
	if (self.SName == "") then self.SName = "None" end
end