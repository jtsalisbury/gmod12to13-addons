/*
	***************************
	* PCMod 2 SS Device Element *
	***************************
	
	 Element: BASE ELEMENT

*/

local PANEL = {}

function PANEL:OnCreate()
	self.X = 0
	self.Y = 0
	self.W = 0
	self.H = 0
	self.MX = 0
	self.MY = 0
	self.Theme = "basic"
	self.Valid = true
	self:Initialize()
end

function PANEL:OnDestroy()
	self.Valid = false
end

function PANEL:SetTheme( th )
	self.Theme = th
	PCMod.Msg( "Setting theme to '" .. th .. "'...", true )
end

function PANEL:GetTheme()
	return self.Theme
end

function PANEL:SetLayout( x, y, w, h )
	self.X = x or 0
	self.Y = y or 0
	self.W = w or 0
	self.H = h or 0
	self.MX = x + (w*0.5)
	self.MY = y + (h*0.5)
end

function PANEL:Paint()

end

function PANEL:Initialize()

end

function PANEL:OnClick()
	
	self:DoClick()
end

function PANEL:DoClick()

end

function PANEL:OnKeyPress( key, txt )

	self:DoKeyPress( key, txt )
end

function PANEL:DoKeyPress( key, txt )

end

function PANEL:OnQuickType( text )

end

function PANEL:CallThemeHook( ... )
	return PCMod.Gui.ThemeDraw( self:GetTheme(), ... )
end

local white = Color( 255, 255, 255 )
function PANEL:GetCol( id )
	return PCMod.Gui.GetThemeColour( self:GetTheme(), id ) or white
end

function PANEL:GetStruct()
	if (self.Struct) then return self.Struct end
	local tmp = {}
	tmp.X = self.X
	tmp.Y = self.Y
	tmp.W = self.W
	tmp.H = self.H
	self.Struct = tmp
	return tmp
end

function PANEL:CursorInside( cx, cy )
	return ((cx > self.X) && (cx < (self.X+self.W)) && (cy > self.Y) && (cy < (self.Y+self.H)))
end

function PANEL:IsValid()
	return self.Valid
end

function PANEL:Remove()
	PCMod.SSEL.Destroy( self )
end

function PANEL:SetFunc( funcname, func )
	self[ funcname ] = func
end

PCMod.SSEL.RegisterBase( PANEL )