/*
	***************************
	* PCMod 2 SS Device Element *
	***************************
	
	 Element: Text Block

*/

local PANEL = {}

function PANEL:Initialize()
	self.Text = "Text Block"
	self.XAlign = TEXT_ALIGN_CENTER
	self.Font = "pcmod_3d2d"
	self.Col = Color( 0, 0, 0, 255 )
end

function PANEL:Paint()
	if (self.XAlign == TEXT_ALIGN_CENTER) then self:DrawText( self.MX, self.MY, self.XAlign ) end
	if (self.XAlign == TEXT_ALIGN_LEFT) then self:DrawText( self.X, self.MY, self.XAlign ) end
	if (self.XAlign == TEXT_ALIGN_RIGHT) then self:DrawText( self.X+self.W, self.MY, self.XAlign ) end
end

local tmp
function PANEL:DrawText( x, y, xalign )
	if (type( self.Text ) == "table") then tmp = self.Text end
	tmp = tmp or {}
	tmp[1] = self.Text
	surface.SetFont( self.Font )
	local tw, th = surface.GetTextSize( tmp[1] )
	for cnt=1, #tmp do
		local txt = tmp[ cnt ] or ""
		local ty = y + ((cnt-1)*th)
		local t = tostring( txt )
		if (type(txt) == "number") then t = PCMod.Cfg.StatusCodes[ txt ] end
		if (!t) then t = "Invalid Statuscode!" end
		draw.SimpleText( t, self.Font, x, ty, self.Col, xalign, TEXT_ALIGN_TOP )
	end
end

function PANEL:SetText( txt )
	self.Text = txt
end

function PANEL:SetColor( col )
	self.Col = col
end

function PANEL:SetXAlign( al )
	self.XAlign = al
end

PCMod.SSEL.Register( "TextBlock", PANEL )