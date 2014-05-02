/*
	***************************
	* PCMod 2 SS Device Element *
	***************************
	
	 Element: Button

*/

local PANEL = {}

function PANEL:Initialize()
	self.Locked = false
	self.Active = false
	self.HasIcon = false
	self.Icon = ""
	self.Text = "Button"
end

function PANEL:Paint()
	local c_bor = self:GetCol( "Border" )
	local c_btbg = self:GetCol( "ButtonBG" )
	local c_bt_txt = self:GetCol( "Button_Text" )
	if (self.Locked) then
		c_bor = self:GetCol( "Border_Locked" )
		c_bt_txt = self:GetCol( "Button_Text_Locked" )
	end
	if (self.Active) then
		c_btbg = self:GetCol( "ButtonBG_Active" )
	end
	if (!self:CallThemeHook( "button", self:GetStruct() )) then
		surface.SetDrawColor( c_btbg.r, c_btbg.g, c_btbg.b, c_btbg.a )
		surface.DrawRect( self.X, self.Y, self.W, self.H )
		surface.DrawOutline( self.X, self.Y, self.W, self.H, c_bor )
	end
	draw.SimpleText( self.Text, "pcmod_3d2d", self.MX, self.MY, c_bt_txt, 1, 1 )
	if (self.HasIcon) then
		local ico = self.Icon
		local fn = "gui/icons/ico_" .. ico
		local sid = PCMod.Res.Mats[ fn ]
		surface.SetTexture( sid )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( self.X, self.Y, self.H, self.H ) -- Yes, self.H is repeated on purpose
	end
end

function PANEL:SetText( txt )
	self.Text = txt
end

function PANEL:SetIcon( ico )
	self.Icon = ico
	if ((ico) && (ico != "")) then self.HasIcon = true end
end

PCMod.SSEL.Register( "Button", PANEL )