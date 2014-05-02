
// PCMod ScreenSpace Device | Control Panel \\

DEV.Name = "window_mycomp"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"

DEV.PWE = 0

function DEV:Initialize( x, y, w, h )
	// Make exit button
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	
	// Make all themes
	self:CreateListbox( self.Th, "lstThemes", x+(w*0.05), y+(h*0.1), w*0.25, h*0.8 )
	local cnt = 0
	for k, v in pairs( PCMod.Gui.Themes ) do
		cnt = cnt + 1
		self:AddListboxItem( "lstThemes", k, v.NiceName )
	end
	self:SetListboxSelRow( "lstThemes", self.Th )
	self:CreateButton2( self.Th, "btnSetTheme", x+(w*0.05), y+(h*0.91), w*0.25, h*0.06, "Apply" )
	
	// Make password change boxes
	self:CreateTextbox( self.Th, "txtOldPass", x+(w*0.65), y+(h*0.2), w*0.64, h*0.04, "Old Password:" )
	self:CreateTextbox( self.Th, "txtNewPass", x+(w*0.65), y+(h*0.25), w*0.64, h*0.04, "New Password:" )
	self:CreateButton( self.Th, "btnApplyPass", x+(w*0.6), y+(h*0.34), "Change" )
	
	// Make other buttons
	self:CreateButton2( self.Th, "btnDeviceManager", x+(w*0.35), y+(h*0.8), w*0.6, h*0.06, "Device Manager" )
	self:CreateButton2( self.Th, "btnNetTools", x+(w*0.35), y+(h*0.88), w*0.6, h*0.06, "Network Tools" )
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "Control Panel", h*0.06 )
	self:RenderText( x+(w*0.67), y+(h*0.1), { "Welcome to the control panel!" }, Color( 0, 0, 0, 255 ), 1 )
	if (self.PWE == 1) then self:RenderError( self.Th, x+(w*0.6), y+(h*0.4), "Old password wrong!" ) end
	if (self.PWE == 2) then self:RenderText( x+(w*0.6), y+(h*0.4), { "Password changed!" }, Color( 0, 0, 0, 255 ), 1 ) end
	self:Draw()
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btnExit") then
		self:RunProgCommand( "mycomputer", "exit" )
		return
	end
	if (btn == "btnApplyPass") then
		local old = self:GetTextboxText( "txtOldPass" )
		local new = self:GetTextboxText( "txtNewPass" )
		self:RunProgCommand( "mycomputer", "changepass", old, new )
		return
	end
	if (btn == "btnSetTheme") then
		local newth = self:GetListboxSelRow( "lstThemes" )
		if ((newth) && (newth != "")) then self:SubmitCommand( "os_command", "sys_settheme", newth ) end
	end
	if (btn == "btnDeviceManager") then
		// self:SubmitCommand( "os_command", "sys_openprog", "deviceman" )
		self:RunProgCommand( "mycomputer", "open_devman" )
	end
	if (btn == "btnNetTools") then
		//self:SubmitCommand( "os_command", "sys_openprog", "nettools" )
		self:RunProgCommand( "mycomputer", "open_nettools" )
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