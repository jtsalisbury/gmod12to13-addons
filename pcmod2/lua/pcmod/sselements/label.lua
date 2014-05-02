/*
	***************************
	* PCMod 2 SS Device Element *
	***************************
	
	 Element: Label

*/

local PANEL = {}

function PANEL:Initialize()
	self.Text = "Label"
	self.XAlign = TEXT_ALIGN_CENTER
	self.Font = "pcmod_3d2d"
	self.Col = Color( 0, 0, 0, 255 )
end

function PANEL:Paint()
	if (self.XAlign == TEXT_ALIGN_CENTER) then
		draw.SimpleText( self.Text, self.Font, self.MX, self.MY, self.Col, 1, 1 )
	else
		draw.SimpleText( self.Text, self.Font, self.X, self.MY, self.Col, TEXT_ALIGN_LEFT, 1 )
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

PCMod.SSEL.Register( "Label", PANEL )