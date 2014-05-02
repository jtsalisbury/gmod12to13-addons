
// ---------------------------------------------------------------------------------------------------------
// cl_vgui.lua - Revision 1
// Client-Side
// Controls drawing operations on the client (specifically derma and the vgui library)
// ---------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------
// ShowLockFrame - Shows / Hides the lock frame
// ---------------------------------------------------------------------------------------------------------
function PCMod.Gui.ShowLockFrame( show )
	if (!show) then
		if (PCMod.Gui.LFrame) then
			PCMod.Gui.LFrame:Remove()
			PCMod.Gui.LFrame = nil
		end
		return
	end
	local pn = vgui.Create( "DFrame" )
	pn:SetPos( ScrW()*0.86, ScrH()*0.1 )
	pn:SetSize( ScrW()*0.12, ScrH()*0.2 )
	pn:SetTitle( "PCMod 2" )
	pn:SetDraggable( false )
	pn:ShowCloseButton( false )
	PCMod.Gui.LFrame = pn
	
	local btn = vgui.Create( "DButton" )
	btn:SetParent( pn )
	btn:SetSize( pn:GetWide()-10, 20 )
	btn:SetPos( 5, 30 )
	btn:SetText( "Close" )
	btn.DoClick = function( self )
		PCMod.Beam.UnlockCam( LocalPlayer() )
	end

	local btn = vgui.Create( "DButton" )
	btn:SetParent( pn )
	btn:SetSize( pn:GetWide()-10, 20 )
	btn:SetPos( 5, 55 )
	btn:SetText( "Quick Type" )
	btn.DoClick = function( self )
		RunConsoleCommand( "pc_quicktype", PCMod.SDraw.KeyboardEntID )
	end
	
	local ent = ents.GetByIndex( PCMod.Gui.CamLockID )
	
	if ((ent) && (ent:IsValid()) && (ent:GetClass() == "pcmod_laptop")) then
		local btn = vgui.Create( "DButton" )
		btn:SetParent( pn )
		btn:SetSize( pn:GetWide()-10, 20 )
		btn:SetPos( 5, 80 )
		btn:SetText( "Toggle Power" )
		btn.DoClick = function( self )
			RunConsoleCommand( "pc_command", PCMod.Gui.CamLockID, "power" )
		end
	end
end

// ---------------------------------------------------------------------------------------------------------
// EnableHackyClicky - Toggles the HackyClicky control (lol)
// ---------------------------------------------------------------------------------------------------------
function PCMod.Gui.EnableHackyClicky( on )
	if (on == false) then
		if (PCMod.Gui.HackyClicky) then
			PCMod.Gui.HackyClicky:Remove()
			PCMod.Gui.HackyClicky = nil
		end
		return
	end
	if (on == true) then
		if (!PCMod.Gui.HackyClicky) then
			PCMod.Gui.HackyClicky = vgui.Create( "HackyClicky" )
			PCMod.Gui.HackyClicky:PerformLayout()
		end
	end
end

// ---------------------------------------------------------------------------------------------------------
// TestIcon - Tests the flashy icon
// ---------------------------------------------------------------------------------------------------------
function PCMod.Gui.TestIcon( pl, com, args )
	local ico = "gui/silkicons/wrench"
	if (args[1]) then ico = args[1] end
	PCMod.Gui.FlashIcon( ico )
end
concommand.Add( "pc_testicon", PCMod.Gui.TestIcon )

// ---------------------------------------------------------------------------------------------------------
// FlashIcon - Flashes up an icon
// ---------------------------------------------------------------------------------------------------------
function PCMod.Gui.FlashIcon( ico, dir )
	local pn = vgui.Create( "FlashIcon" )
	local w = ScrW()
	local h = ScrH()
	pn:SetPos( 0, 0 )
	pn:SetSize( w, h )
	if (dir == 1) then
		pn:Setup( ico, w*0.9, h*0.5, w*0.5, h*0.5, w*0.1, h*0.1 )
	else
		pn:Setup( ico, w*0.5, h*0.5, w*0.9, h*0.5, w*0.1, h*0.1 )
	end
	pn:Start()
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: CreateWindow - Creates a DFrame and sets it all up
// ---------------------------------------------------------------------------------------------------------
function vgui.CreateWindow( w, h, title, draggable )
	local pn = vgui.Create( "DFrame" )
	local sw = ScrW()
	local sh = ScrH()
	pn:SetSize( w*sw, h*sh )
	pn:SetPos( (sw/2)-((w/2)*sw), (sh/2)-((h/2)*sh) )
	pn:SetTitle( title )
	pn:SetDraggable( false )
	if (draggable) then pn:SetDraggable( true ) end
	pn:ShowCloseButton( true )
	pn:SetScreenLock( true )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: CreateSheet - Creates a DPropertySheet and sets it all up
// ---------------------------------------------------------------------------------------------------------
function vgui.CreateSheet( pframe )
	local pn = vgui.Create( "DPropertySheet" )
	local sw = pframe:GetWide()
	local sh = pframe:GetTall()
	pn:SetParent( pframe )
	pn:SetSize( sw-10, sh-35 )
	pn:SetPos( 5, 30 )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: AddTab - Adds a tab to a property sheet, and returns the panel
// ---------------------------------------------------------------------------------------------------------
function vgui.AddTab( psheet, bgcol, title, icon, text )
	local pn = vgui.Create( "DPanelList" )
	pn:SetPos( 5, 30 )
	local w, h = psheet:GetSize()
	pn:SetSize( w-10, h-35 )
	pn:SetSpacing( 5 )
	pn:SetPadding( 5 )
	pn:EnableHorizontal( false )
	pn:EnableVerticalScrollbar( true )
	pn.Col = bgcol
	function pn:Paint()
		draw.RoundedBox( 6, 0, 0, self:GetWide(), self:GetTall(), self.Col )
	end
	if (!icon) then icon = "user" end
	if (!text) then text = title end
	psheet:AddSheet( title, pn, "gui/silkicons/" .. icon, false, false, text )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: AddText - Adds a text label to a panel list and sets it up
// ---------------------------------------------------------------------------------------------------------
function vgui.AddText( plist, text )
	local pn = vgui.Create( "DLabel" )
	pn:SetText( text )
	pn:SizeToContents()
	plist:AddItem( pn )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: AddCheckbox - Adds a checkbox to a panel list and sets it up
// ---------------------------------------------------------------------------------------------------------
function vgui.AddCheckbox( plist, text, checked, oncheck )
	local pn = vgui.Create( "DCheckBoxLabel" )
	pn:SetText( text )
	if (checked) then pn:SetChecked( 1 ) end
	pn.OnChange = oncheck
	pn:SizeToContents()
	plist:AddItem( pn )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: AddCombobox - Adds a combobox to a panel list and sets it up
// ---------------------------------------------------------------------------------------------------------
function vgui.AddCombobox( plist, options )
	local pn = vgui.Create( "DComboBox" )
	pn:SetMultiple( false )
	for _, v in pairs( options ) do
		pn:AddItem( v )
	end
	plist:AddItem( pn )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: AddButton - Adds a button to a panel list and sets it up
// ---------------------------------------------------------------------------------------------------------
function vgui.AddButton( plist, text, onclick )
	local pn = vgui.Create( "DButton" )
	pn:SetText( text )
	pn.DoClick = onclick
	plist:AddItem( pn )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: AddSI - Adds a spawnicon to a panel list and sets it up
// ---------------------------------------------------------------------------------------------------------
function vgui.AddSI( plist, mdl, onclick )
	local pn = vgui.Create( "SpawnIcon" )
	pn:SetModel( mdl )
	if (onclick) then pn.DoClick = onclick end
	plist:AddItem( pn )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// VGUI: AddSlider - Adds a slider to a panel list and sets it up
// ---------------------------------------------------------------------------------------------------------
function vgui.AddSlider( plist, txt, min, max, convar, changefunc, id )
	local pn = vgui.Create( "DNumSlider" )
	pn:SetText( txt )
	pn:SetMin( min )
	pn:SetMax( max )
	pn:SetDecimals( 0 )
	pn:SetConVar( convar )
	/*if (changefunc) then
		pn.ChangeID = id
		pn.ChangeFunc = changefunc
		function pn:OnValueChanged( val )
			self.ChangeFunc( self.ChangeID, val )
		end
	end*/
	plist:AddItem( pn )
	return pn
end

// ---------------------------------------------------------------------------------------------------------
// DERMA: FlashyIcon - A flashy icon that appears and vanishes with effects
// ---------------------------------------------------------------------------------------------------------
local PANEL = {}
PANEL.Frame = 0
-- States:
-- 0 = Dormant
-- 1 = Stretching from source
-- 2 = Flashing Background
-- 3 = Shrinking to target
PANEL.FPS = 20 -- If the client's FPS is lower, this will render at whatever FPS it can
PANEL.NextUpdate = 0
PANEL.StateFrames = {
	{0, 15},
	{15, 45},
	{45, 60}
}
PANEL.RemoveFrame = 60

function PANEL:Setup( ico, sx, sy, tx, ty, w, h )
	self.Icon = surface.GetTextureID( ico )
	self.SX = sx
	self.SY = sy
	self.TX = tx
	self.TY = ty
	self.W = w
	self.H = h
end
function PANEL:Start()
	self.Frame = 1
end
function PANEL:Think()
	if (self.Frame == 0) then return end
	if (self.NextUpdate < CurTime()) then
		self.NextUpdate = CurTime() + (1/self.FPS)
		self.Frame = self.Frame + 1
		if (self.Frame > (self.RemoveFrame-1)) then
			self:Remove()
			return
		end
	end
end
function PANEL:Paint()
	if (self.Frame == 0) then return end
	local f = self.Frame
	local state = 0
	local lower = 0
	local upper = 0
	for st, v in pairs( self.StateFrames ) do
		local l = v[1]
		local u = v[2]
		if ((f > l) && (f < (u+1))) then
			state = st
			lower = l
			upper = u
		end
	end
	if (state == 0) then
		self.Frame = 0
		return
	end
	local dec = math.Clamp( (f-(lower+1))/(upper-(lower+1)), 0, 1 )
	// Msg( "State: ", state, ", Frame: ", f, ", Dec: ", dec, "\n" )
	if (state == 1) then
		local cx = math.Mid( self.SX, ScrW()*0.5, dec )
		local cy = math.Mid( self.SY, ScrH()*0.5, dec )
		local cw = math.Mid( 0, self.W, dec )
		local ch = math.Mid( 0, self.H, dec )
		local x = cx - (cw/2)
		local y = cy - (ch/2)
		surface.SetTexture( self.Icon )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( x, y, cw, ch )
		return
	end
	if (state == 2) then
		local x = (ScrW()*0.5)-(self.W*0.5)
		local y = (ScrH()*0.5)-(self.H*0.5)
		local al = math.Mid( 255, 0, dec )
		local bw = self.W*(1+(dec*2))
		local bh = self.H*(1+(dec*2))
		local bx = (ScrW()*0.5)-(bw*0.5)
		local by = (ScrH()*0.5)-(bh*0.5)
		surface.SetTexture( self.Icon )
		surface.SetDrawColor( 255, 255, 255, al )
		surface.DrawTexturedRect( bx, by, bw, bh )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( x, y, self.W, self.H )
		return
	end
	if (state == 3) then
		local cx = math.Mid( ScrW()*0.5, self.TX, dec )
		local cy = math.Mid( ScrH()*0.5, self.TY, dec )
		local cw = math.Mid( self.W, 0, dec )
		local ch = math.Mid( self.H, 0, dec )
		local x = cx - (cw/2)
		local y = cy - (ch/2)
		surface.SetTexture( self.Icon )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( x, y, cw, ch )
		return
	end
end
vgui.Register( "FlashIcon", PANEL, "PANEL" )

// ---------------------------------------------------------------------------------------------------------
// DERMA: UnlockButton - Unlocks the player cam
// ---------------------------------------------------------------------------------------------------------
local PANEL = {}
function PANEL:PerformLayout()
	self:SetText( "X" )
end
function PANEL:Paint()
	local w, h = self:GetSize()
	local col = Color( 50, 50, 50, 200 )
	if (self.Hovered) then col = Color( 100, 100, 100, 200 ) end
	draw.RoundedBox( 6, 0, 0, w, h, col )
	//draw.SimpleText( "X", "ScoreboardText", w/2, h/2, Color( 255, 255, 255, 255 ), 1, 1 )
end
function PANEL:DoClick()
	PCMod.Beam.UnlockCam( LocalPlayer() )
end
vgui.Register( "UnlockButton", PANEL, "DButton" )

// ---------------------------------------------------------------------------------------------------------
// DERMA: HackyClicky - A hacky way to sense mouse clicks
// ---------------------------------------------------------------------------------------------------------
local PANEL = {}
function PANEL:Initialize()
	self:SetText( "" )
end
function PANEL:Paint() end
function PANEL:DoClick()
	PCMod.Gui.RegisterClick( gui.MouseX(), gui.MouseY() )
end
function PANEL:PerformLayout()
	self:SetSize( ScrW(), (ScrH()*0.99)-PCMod.Gui.KeyBoard:GetTall() ) -- Don't break the onscreen keyboard -_-
	self:SetPos( 0, 0 )
	self:SetText( "" )
end
vgui.Register( "HackyClicky", PANEL, "DButton" )

// ---------------------------------------------------------------------------------------------------------
// DERMA: PrintedDoc - The screen for a printed document
// ---------------------------------------------------------------------------------------------------------
local PANEL = {}
function PANEL:SetText( text, font, padding )
	self:PerformLayout()
	if (!font) then font = "ScoreboardText" end
	if (!text) then text = "" end
	if (!padding) then padding = ScrW()*0.02 end
	surface.SetFont( font )
	local tw, th = surface.GetTextSize( string.Replace( text, "\n", "" ) )
	self.RH = th
	self.Font = font
	self.Text = PCMod.Gui.CalcTextWrap( text, font, self:GetWide()-(padding*2) )
	self.Padding = padding
	self:Initialize()
end
function PANEL:Initialize()
	if (self.CloseMe) then return end
	local pn = vgui.Create( "DButton" )
	pn:SetParent( self )
	pn:SetText( "" )
	pn:SetSize( 25, 25 )
	pn.Font = self.Font
	pn.Paint = function( self )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawOutline( 0, 0, self:GetWide()-1, self:GetTall()-1, Color( 0, 0, 0, 255 ) )
		draw.SimpleText( "X", self.Font, self:GetWide()*0.5, self:GetTall()*0.5, Color( 0, 0, 0, 255 ), 1, 1 )
	end
	pn.DoClick = function() PCMod.Gui.HideDocument() end
	self.CloseMe = pn
	// self:InvalidateLayout()
end
function PANEL:PerformLayout()
	local w = ScrW()
	local h = ScrH()
	self:SetPos( w*0.25, h*0.1 )
	self:SetSize( w*0.5, h*0.8 )
	if (self.CloseMe) then self.CloseMe:SetPos( self:GetWide()-25, 0 ) end
end
function PANEL:Paint()
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutline( 0, 0, self:GetWide()-1, self:GetTall()-1, Color( 0, 0, 0, 255 ) )
	local txt = self.Text
	if ((txt) && (type(txt) == "table")) then
		local cnt
		for cnt=1, #txt do
			local t = string.Replace( txt[cnt], "\n", "" )
			local y = ((cnt-1) * self.RH) + self.Padding
			if ((y+self.RH) < self:GetTall()) then
				draw.SimpleText( t, self.Font, self.Padding, y, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
		end
	end
end
vgui.Register( "PrintedDoc", PANEL, "PANEL" )

// ---------------------------------------------------------------------------------------------------------
// DERMA: PopupWindow - A popup window
// ---------------------------------------------------------------------------------------------------------
local PANEL = {}
PANEL.Title = ""
PANEL.Padding = 0
PANEL.Description = ""
function PANEL:SetTitle( str )
	self.Title = str
end
function PANEL:Setup( description )
	self.Description = description
	self.Padding = ScrW()*0.01
	self:SetSize( ScrW()*0.4, ScrH()*0.25 )
	self:SetPos( (ScrW()*0.5) - (self:GetWide()*0.5), (ScrH()*0.5) - (self:GetTall()*0.5) )
	local btn = vgui.Create( "DButton", self )
	btn:SetSize( self:GetWide()-(self.Padding*2), 25 )
	btn:SetPos( self.Padding, self:GetTall()*0.7 )
	btn:SetText( "Ok" )
	btn.DoClick = function( self ) self:GetParent():Hide() end
end
function PANEL:MakePopup()
	self:SetVisible( true )
	gui.EnableScreenClicker( true )
end
function PANEL:Paint()
	//local border = Color( 100, 100, 140, 255 )
	local title = Color( 60, 60, 255, 255 )
	//local title = border
	local border = title
	local bg = Color( 128, 128, 128, 255 )
	draw.RoundedBox( 12, 0, 0, self:GetWide(), self:GetTall(), title )
	surface.SetDrawColor( border.r, border.g, border.b, border.a )
	surface.DrawRect( 0, 24, self:GetWide(), self:GetTall()-24 )
	surface.SetDrawColor( bg.r, bg.g, bg.b, bg.a )
	surface.DrawRect( self.Padding*0.5, 26, self:GetWide()-self.Padding, self:GetTall()-26-(self.Padding*0.5) )
	surface.DrawOutline( self.Padding*0.5, 26, self:GetWide()-self.Padding, self:GetTall()-26-(self.Padding*0.5), Color( 0, 0, 0, 255 ) )
	draw.SimpleText( "PCMod 2 - " .. self.Title, "ScoreboardText", 12+(self.Padding*0.5), 13, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( self.Description, "ScoreboardText", self:GetWide()*0.5, self:GetTall()*0.3, Color( 255, 255, 255, 255 ), 1, 1 )
end
function PANEL:Hide()
	self:Remove()
	gui.EnableScreenClicker( false )
end
vgui.Register( "PopupWindow", PANEL, "PANEL" )