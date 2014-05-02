
// PCMod ScreenSpace Device | Notepad \\

DEV.Name = "window_notepad"

DEV.LastTick = 0
DEV.LastFrame = 0

DEV.Th = "basic"
DEV.TC = ""

DEV.St = 0
DEV.Status = ""
DEV.StatClose = 0

function DEV:Initialize( x, y, w, h )
	// Make control buttons
	self:CreateButton2( self.Th, "btnExit", (x+w)-(h*0.06), y, h*0.06, h*0.06, "X" )
	self:CreateButton2( self.Th, "btnNew", x+(w*0.02), y+(h*0.88), w*0.23, h*0.05, "New" )
	self:CreateButton2( self.Th, "btnSave", x+(w*0.27), y+(h*0.88), w*0.23, h*0.05, "Save" )
	self:CreateButton2( self.Th, "btnOpen", x+(w*0.52), y+(h*0.88), w*0.22, h*0.05, "Open" )
	self:CreateButton2( self.Th, "btnPrint", x+(w*0.76), y+(h*0.88), w*0.22, h*0.05, "Print" )
	self:CreateButton2( self.Th, "btnBrowse", x+(w*0.9), y+(h*0.94), w*0.08, h*0.05, "..." )
	
	// Make text area
	self:CreateTextEntry( self.Th, "txtMain", x+(w*0.02), y+(h*0.08), w*0.96, h*0.74 )
	
	// Make filename textbox
	self:CreateTextbox( self.Th, "txtFilename", x+(w*0.45), y+(h*0.97), w*0.84, h*0.05, "Filename" )
	
	// Update
	self:OnUpdate()
	
	// Record window data
	self.WinX = x
	self.WinY = y
	self.WinW = w
	self.WinH = h
end

function DEV:OnUpdate()
	PCMod.Msg( "Device reported update!", true )
	self.StatClose = CurTime()+3
	self.Status = ""
	local st = self.St
	if (st == 1) then self.Status = "File saved." end
	if (st == 2) then self.Status = "File opened." end
	if (st == 3) then self.Status = "File does not exist." end
	if (st == 4) then self.Status = "No printer hardware." end
	if (st == 5) then self.Status = "File printed." end
	if (!self.TC) then return end
	self:SetTextboxText( "txtMain", self.TC )
end

function DEV:Paint( x, y, w, h )
	self:RenderWindow( self.Th, x, y, w, h, "Notepad", h*0.06 )
	self:Draw()
	local status = self.Status
	if (!status) then status = "" end
	if ((status == "") && (self.TC != self:GetTextboxText( "txtMain" ))) then status = "Unsaved Changes" end
	self:RenderText( x+(w*0.5), y+(h*0.82), { status }, Color( 0, 0, 0, 255 ), 1 )
end

function DEV:ButtonClick( btn )
	local x, y, w, h = self.win_x, self.win_y, self.win_w, self.win_h
	if (btn == "btnExit") then
		self:RunProgCommand( "notepad", "exit" )
	end
	if (btn == "btnSave") then
		local fn = self:GetTextboxText( "txtFilename" )
		if ((!fn) || (fn == "")) then
			fn = "untitled.txt"
			self:SetTextboxText( "txtFilename", fn )
		end
		self:SubmitContent( fn )
		// self:RunProgCommand( "notepad", "save", fn )
	end
	if (btn == "btnNew") then
		self:SetTextboxText( "txtMain", "" )
		self:SetTextboxText( "txtFilename", "newdocument.txt" )
		self:SubmitContent( "newdocument.txt" )
	end
	if (btn == "btnOpen") then
		local fn = self:GetTextboxText( "txtFilename" )
		if ((!fn) || (fn == "")) then
			fn = "untitled.txt"
			self:SetTextboxText( "txtFilename", fn )
		end
		self:RunProgCommand( "notepad", "open", fn )
	end
	if (btn == "btnBrowse") then
		self:RunProgCommand( "notepad", "browse" )
	end
	if (btn == "btnPrint") then
		local statusn = 0
		local status = self.Status
		if (!status) then status = "" end
		if ((status == "") && (self.TC != self:GetTextboxText( "txtMain" ))) then statusn = 1 end

		self:RunProgCommand( "notepad", "print", statusn )
		// self:SubmitCommand( "os_command", "sys_print", 
	end
end

function DEV:DoClick( x, y )
	self:ProcessClick( x, y )
end

function DEV:DataRecieved( name, data )
	if (name == "filename") then self:SetTextboxText( "txtFilename", data ) end
	if (name == "runcommand") then self:RunProgCommand( "notepad", data ) end
	if (name == "doprint") then self:RunProgCommand( "notepad", "printdoc", data ) end
end

function DEV:Tick()
	self.LastTick = CurTime()
	self.LastFrame = PCMod.SDraw.CFrame
	if ((self.StatClose != 0) && (CurTime() > self.StatClose)) then
		self.StatClose = 0
		self.Status = ""
	end
end

function DEV:KeyPress( key, txt )
	self:KeyPressTextboxes( key, txt )
end

function DEV:SubmitContent( filename )
	// Split our content into segments of 128
	local str = self:GetTextboxText( "txtMain" )
	//datastream.Send( "pc_stream", { PCMod.Gui.CamLockID, "input", "os_command", "prog_command", "notepad", "content", str } )
	self:StreamProgCommand( "notepad", "savecontent", filename, str )
	// RunConsoleCommand( "pc_command", PCMod.Gui.CamLockID, "input", ... )
	/*
	if ((!str) || (str == "")) then
		self:RunProgCommand( "notepad", "ct_clear" )
		return
	end
	local segs = PCMod.SplitString( str, 128 )
	local cnt
	self:RunProgCommand( "notepad", "ct_start" )
	for cnt=1, #segs do
		local seg = segs[ cnt ]
		if (seg) then
			self:RunProgCommand( "notepad", "ct_seg", seg )
		end
	end
	self:RunProgCommand( "notepad", "ct_end" )
	*/
end