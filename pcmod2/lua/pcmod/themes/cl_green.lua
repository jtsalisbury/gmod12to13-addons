
THEME.Name = "green"
THEME.Description = "Green theme for PCMod"
THEME.NiceName = "Green"
THEME.Author = "[GU]thomasfn"

THEME.Primary = Color( 0, 255, 0, 255 )
THEME.Secondary = Color( 0, 128, 0, 255 )

THEME.Bar = Color( 200, 255, 200, 255 )
THEME.Bar_Text = Color( 0, 0, 0, 255 )

THEME.Border = Color( 0, 0, 0, 255 )
THEME.Border_Locked = Color( 100, 100, 100, 255 )

THEME.ButtonBG = Color( 200, 255, 200, 255 )
THEME.ButtonBG_Active = Color( 220, 255, 220, 255 )
THEME.Button_Text = Color( 0, 0, 0, 255 )
THEME.Button_Text_Locked = Color( 100, 100, 100, 255 )

THEME.TextboxBG = Color( 220, 255, 220, 255 )
THEME.Textbox_Text = Color( 0, 0, 0, 255 )

THEME.ListboxBG = Color( 220, 255, 220, 255 )
THEME.Listbox_Text = Color( 0, 0, 0, 255 )
THEME.Listbox_SelBG = Color( 50, 255, 50, 255 )
THEME.Listbox_SelText = THEME.Listbox_Text

THEME.ErrorBG = Color( 255, 0, 0, 255 )
THEME.Error_Text = Color( 255, 255, 255, 255 )

THEME.TaskBar = Color( 100, 255, 100, 255 )

THEME.StartMenuBG = THEME.Primary


THEME.ButtonCol = {
	UpperOuter = Color( 255, 255, 255, 255 ),
	LowerOuter = Color( 50, 50, 50, 255 ),
	UpperMid = Color( 200, 200, 200, 255 ),
	LowerMid = Color( 100, 100, 100, 255 ),
	BG = Color( 150, 180, 150, 255 ),
	Text = Color( 0, 0, 0, 255 ),
	Outline = Color( 0, 0, 0, 255 )
}

THEME.ListboxCol = {
	LowerOuter = Color( 255, 255, 255, 255 ),
	UpperOuter = Color( 50, 50, 50, 255 ),
	LowerMid = Color( 200, 200, 200, 255 ),
	UpperMid = Color( 100, 100, 100, 255 ),
	BG = Color( 200, 220, 200, 255 ),
	Text = Color( 0, 0, 0, 255 ),
	Outline = Color( 0, 0, 0, 255 )
}

THEME.TextboxCol = {
	LowerOuter = Color( 255, 255, 255, 255 ),
	UpperOuter = Color( 50, 50, 50, 255 ),
	LowerMid = Color( 200, 200, 200, 255 ),
	UpperMid = Color( 100, 100, 100, 255 ),
	BG = Color( 200, 220, 200, 255 ),
	Text = Color( 0, 0, 0, 255 ),
	Outline = Color( 0, 0, 0, 255 )
}


function THEME:Draw( id, ... )
	local args = { ... }
	if (id == "button") then
		local struct = args[1]
		self:Draw3DBox( struct, self.ButtonCol )
		return true
	end
	if (id == "listbox") then
		local struct = args[1]
		self:Draw3DBox( struct, self.ListboxCol )
		return true
	end
	if (id == "textbox") then
		local struct = args[1]
		self:Draw3DBox( { X=struct.BX, Y=struct.Y, W=struct.BW, H=struct.H }, self.TextboxCol )
		return true
	end
	if (id == "textentry") then
		local struct = args[1]
		self:Draw3DBox( struct, self.TextboxCol )
		return true
	end
end

function THEME:Draw3DBox( lstruct, cstruct )
	local x, y, w, h = lstruct.X, lstruct.Y, lstruct.W, lstruct.H
	surface.SetDrawCol( cstruct.BG )
	surface.DrawRect( x, y, w, h )
	surface.SetDrawCol( cstruct.LowerOuter )
	surface.DrawLine( x+w, y, x+w, y+h )
	surface.DrawLine( x, y+h, x+w, y+h )
	surface.SetDrawCol( cstruct.UpperOuter )
	surface.DrawLine( x, y, x+w, y )
	surface.DrawLine( x, y, x, y+h )
	surface.SetDrawCol( cstruct.LowerMid )
	surface.DrawLine( x+w-1, y, x+w-1, y+h-1 )
	surface.DrawLine( x, y+h-1, x+w-1, y+h-1 )
	surface.SetDrawCol( cstruct.UpperMid )
	surface.DrawLine( x+1, y+1, x+w-1, y+1 )
	surface.DrawLine( x+1, y+1, x+1, y+h-1 )
end

function surface.SetDrawCol( col )
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
end