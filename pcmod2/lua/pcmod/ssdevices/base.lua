
// PCMod ScreenSpace Device | BASE DEVICE \\

// Device name
DEV.Name = "base"

// Override functions
function DEV:Paint() end
function DEV:Kill() end
function DEV:KeyPress() end
function DEV:Initialize() end
function DEV:ButtonClick() end
function DEV:ListboxSelect() end
function DEV:OnUpdate() end
function DEV:DataRecieved() end
function DEV:QuickType() end

// Input focus
DEV.TB_Focus = ""

// Default vars
DEV.win_x = 0
DEV.win_y = 0
DEV.win_w = 0
DEV.win_h = 0

// ------------------------------------------------------------------------------------------------------------------------------------------------
//	 Internal Functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:OnCreate()
		self.Textboxes = {}
		self.Listboxes = {}
		self.Elements = {}
	end

	function DEV:Int_KeyPress( key, txt )
		for _, v in pairs( self.Elements ) do
			if ((v) && (v:IsValid())) then
				if (v:OnKeyPress( key, txt )) then return end
			end
		end
		self:KeyPress( key, txt )
	end

	function DEV:Int_QuickType( text )
		PCMod.Msg( "SS Device recieved quicktype!", true )
		for _, v in pairs( self.Elements ) do
			if ((v) && (v:IsValid())) then
				if (v:OnQuickType( text )) then return end
			end
		end
		if (self.Textboxes[ self.TB_Focus ]) then
			if (!self.Textboxes[ self.TB_Focus ].Content) then self.Textboxes[ self.TB_Focus ].Content = "" end
			self.Textboxes[ self.TB_Focus ].Content = self.Textboxes[ self.TB_Focus ].Content .. text
			self:CalcTextWrap( self.TB_Focus )
		else
			self:QuickType( text )
		end
	end

	function DEV:Int_DoClick( x, y )
		self:DoClick( x, y )
	end

	function DEV:DoClick( x, y )
		self:ProcessClick( x, y )
	end

	function DEV:Int_Paint( x, y, w, h )
		self:Paint( x, y, w, h )
	end

	function DEV:Int_Initialize( x, y, w, h )
		self:Tick()
		self:Initialize( x, y, w, h )
		self.win_x = x
		self.win_y = y
		self.win_w = w
		self.win_h = h
	end

	function DEV:Int_Update()
		// We have recieved an update from server, but we are NOT 'fresh'
		self:OnUpdate()
	end
	
// ------------------------------------------------------------------------------------------------------------------------------------------------
//	 Element drawing functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:DrawTextboxes()
		for _, v in pairs( self.Textboxes ) do
			self:RenderTextbox( v )
		end
	end

	function DEV:DrawListboxes()
		for _, v in pairs( self.Listboxes ) do
			self:RenderListbox( v )
		end
	end

	function DEV:DrawElements()
		for _, v in pairs( self.Elements ) do
			if ((v) && (v:IsValid())) then v:Paint() end
		end
	end
	
// ------------------------------------------------------------------------------------------------------------------------------------------------
//	 Element clicking functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:ClickTextboxes( x, y )
		for _, v in pairs( self.Textboxes ) do
			if (self:CursorInTextbox( v, x, y )) then
				self:Int_TextboxClick( v.Name, x, y )
				return
			end
		end
	end

	function DEV:ClickListboxes( x, y )
		for _, v in pairs( self.Listboxes ) do
			if (self:CursorInListbox( v, x, y )) then
				self:Int_ListboxClick( v.Name, x, y )
			end
		end
	end

	function DEV:ClickElements( x, y )
		local cx = self.win_x + (self.win_w*x)
		local cy = self.win_y + (self.win_h*y)
		for _, v in pairs( self.Elements ) do
			if (v:CursorInside( cx, cy )) then
				v:OnClick()
				break
			end
		end
	end

// ------------------------------------------------------------------------------------------------------------------------------------------------
//	Textbox cursor functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:MoveCursor( tbname, char, line )
		if (char) then self.Textboxes[ tbname ].Char = char end
		if (line) then self.Textboxes[ tbname ].Line = line end
		self.Textboxes[ tbname ].CursorX = self:CharToX( self.Textboxes[ tbname ].Content, "pcmod_3d2d", char )
		PCMod.Msg( "Moving cursor! (" .. char .. ":" .. line .. ") (" .. tbname .. ")", true )
	end

	function DEV:CUR_Forward( tbname )
		if (!tbname) then tbname = self.TB_Focus end
		local tb = self.Textboxes[ tbname ]
		if (!tb) then return end
		if (!tb.Char) then tb.Char = 0 end
		self:CUR_SetPos( tbname, tb.Char+1 )
	end

	function DEV:CUR_Back( tbname )
		if (!tbname) then tbname = self.TB_Focus end
		local tb = self.Textboxes[ tbname ]
		if (!tb) then return end
		if (!tb.Char) then tb.Char = 0 end
		self:CUR_SetPos( tbname, tb.Char-1 )
	end

	function DEV:CUR_ToEnd( tbname )
		if (!tbname) then tbname = self.TB_Focus end
		local tb = self.Textboxes[ tbname ]
		if (!tb) then return end
		if (!tb.Char) then tb.Char = 0 end
		self:CUR_SetPos( tbname, string.len( tb.Content )-1 )
	end

	function DEV:CUR_ToStart( tbname )
		if (!tbname) then tbname = self.TB_Focus end
		local tb = self.Textboxes[ tbname ]
		if (!tb) then return end
		if (!tb.Char) then tb.Char = 0 end
		self:CUR_SetPos( tbname, 0 )
	end

	function DEV:CUR_SetPos( tbname, char )
		if (!tbname) then tbname = self.TB_Focus end
		local tb = self.Textboxes[ tbname ]
		if (!tb) then return end
		if (!tb.Content) then tb.Content = "" end
		if (!tb.Char) then tb.Char = 0 end
		if (!char) then char = tb.Char end
		if (!tb.TEntry) then
			// tb.W = tb.BW
		end
		local tl = string.len( tb.Content )
		char = math.Clamp( char, 0, tl )
		tb.Char = char
		local pos = self:CUR_CalcPos( tb.Content, tb.W, char, "pcmod_3d2d", tb.TEntry, tb.ScrollOffset )
		tb.CUR_X = pos.x
		tb.CUR_Y = pos.y
	end

	function DEV:CUR_CalcPos( text, width, char, font, multiline, offset )
		if (!offset) then offset = 0 end
		surface.SetFont( font )
		local tl = string.len( text )
		char = math.Clamp( char, 0, tl )
		local str = ""
		if (char > 0) then str = string.sub( text, 1, char ) end
		if (str == "") then return { x=0, y=0 } end
		local tbl
		local line = 0
		local txt
		if (multiline) then
			tbl = PCMod.Gui.CalcTextWrap( str, font, width )
			if (#tbl == 0) then return { x=0, y=0 } end
			line = #tbl
			txt = string.Replace( tbl[ line ], "\n", "" )
		else
			line = 1
			txt = string.Replace( text, "\n", "" )
		end
		local tw, th = surface.GetTextSize( string.Replace( txt, "\n", "" ) )
		local y = th*((line-1)-offset)
		local x = tw
		return { x=x, y=y }
	end

	function DEV:KeyPressTextboxes( key, txt )
		if (!self.Textboxes[ self.TB_Focus ]) then return end
		if ((key == "ctrl") || (key == "shift") || (key == "alt")) then return end
		if (key == "arrow_left") then
			self:CUR_Back()
			return
		end
		if (key == "arrow_right") then
			self:CUR_Forward()
			return
		end
		local tb = self.Textboxes[ self.TB_Focus ]
		local oldtxt = tb.Content
		local char = tb.Char
		local left = ""
		local right = ""
		local f = false
		if (char>0) then left = string.sub( oldtxt, 1, char ) end
		if (char<string.len( oldtxt )) then right = string.sub( oldtxt, char+1, string.len( oldtxt ) ) end
		if (key == "<--") then
			if (string.len( left ) > 0) then left = string.sub( left, 1, string.len( left )-1 )	end
			f = true
		end
		if (key == "enter") then
			if (tb.TEntry) then
				left = left .. "\n"
			else
				self.TB_Focus = ""
				return
			end
			f = true
		end
		if (key == "tab") then txt = "	" end
		if (f == false) then left = left .. txt end
		self.Textboxes[ self.TB_Focus ].Content = left .. right
		if (key == "<--") then
			self:CUR_Back()
		else
			self:CUR_Forward()
		end
		self:CalcTextWrap( self.TB_Focus )
	end

	function DEV:CalcTextWrap( tbname )
		local tb = self.Textboxes[ tbname ]
		if (!tb.TEntry) then return end
		local txt = tb.Content
		if (!txt) then txt = "" end
		local w = tb.W
		surface.SetFont( "pcmod_3d2d" )
		local tw, th = surface.GetTextSize( "X" )
		if (tb.ScrollBar) then w = w - tw end
		self.Textboxes[ tbname ].ContentTbl = PCMod.Gui.CalcTextWrap( txt, "pcmod_3d2d", w )
	end
	
// ------------------------------------------------------------------------------------------------------------------------------------------------
//	Element Control Functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:CreateElement( class, name, theme, x, y, w, h )
		PCMod.Msg( "Creating element '" .. class .. "' with name '" .. name .. "'!", true )
		local el = PCMod.SSEL.Create( class )
		if ((!el) || (!el:IsValid())) then
			PCMod.Msg( "Failed to create element '" .. class .. "'!", true )
			return
		end
		self.Elements[ name ] = el
		el:SetTheme( theme )
		el:SetLayout( x, y, w, h )
		el.DEVICE = self
		el.NAME = name
		return el
	end

	function DEV:GetElement( name )
		return self.Elements[ name ]
	end

	function DEV:RemoveElement( name )
		self.Elements[ name ]:Remove()
		self.Elements[ name ] = nil
	end
	
// ------------------------------------------------------------------------------------------------------------------------------------------------
//	Element Creation functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:CreateButton( theme, name, x, y, text, padding )
		if (!padding) then padding = 0 end
		surface.SetFont( "pcmod_3d2d" )
		local tw, th = surface.GetTextSize( text )
		tw = tw + padding
		th = th + padding
		local btn = self:CreateElement( "Button", name, theme, x-(tw*0.5), y-(th*0.5), tw, th )
		btn:SetText( text )
		btn:SetFunc( "DoClick", function( self ) self.DEVICE:ButtonClick( self.NAME ) end )
		return btn
	end
	
	function DEV:CreateButton2( theme, name, x, y, w, h, text, ico )
		local btn = self:CreateElement( "Button", name, theme, x, y, w, h )
		btn:SetText( text )
		btn:SetIcon( ico )
		btn:SetFunc( "DoClick", function( self ) self.DEVICE:ButtonClick( self.NAME ) end )
		return btn
	end	

	function DEV:CreateListbox( theme, name, x, y, w, h )
		PCMod.Msg( "Creating listbox '" .. name .. "'!", true )
		local tmp = {}
			tmp.Name = name
			tmp.X = x
			tmp.Y = y
			tmp.W = w
			tmp.H = h
			tmp.MX = x+(w/2)
			tmp.Theme = theme
			tmp.List = {}
			tmp.SelItem = ""
			tmp.ScrollBar = false
			tmp.ScrollOffset = 0
			self.Listboxes[ name ] = tmp
		return tmp
	end

	function DEV:CreateTextbox( theme, name, x, y, w, h, text )
		PCMod.Msg( "Creating textbox '" .. name .. "'!", true )
		local tmp = {}
			tmp.Name = name
			surface.SetFont( "pcmod_3d2d" )
			local tw, th = surface.GetTextSize( text .. " " )
			tmp.BX = x-(w/2)+tw
			tmp.TX = x-(w/2)
			tmp.TMX = x-(w/2)+(tw/2)
			tmp.Y = y-(h/2)
			tmp.BW = w-tw
			tmp.W = w
			tmp.H = h
			tmp.MX = x
			tmp.MY = y
			tmp.Text = text
			tmp.Theme = theme
			tmp.Content = ""
			tmp.Locked = false
			tmp.Char = 0
			tmp.CUR_X = 0
			tmp.CUR_Y = 0
			self.Textboxes[ name ] = tmp
		return tmp
	end

	function DEV:CreateTextEntry( theme, name, x, y, w, h )
		PCMod.Msg( "Creating text entry '" .. name .. "'!", true )
		local tmp = {}
			tmp.Name = name
			tmp.TEntry = true
			tmp.X = x
			tmp.Y = y
			tmp.W = w
			tmp.H = h
			tmp.ScrollBar = false
			tmp.ScrollOffset = 0
			tmp.Theme = theme
			tmp.Content = ""
			tmp.Locked = false
			self.Textboxes[ name ] = tmp
		return tmp
	end
	
// ------------------------------------------------------------------------------------------------------------------------------------------------
//	Element Properties
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:SetTextboxLock( tbname, locked )
		if (!self.Textboxes[ tbname ]) then return end
		self.Textboxes[ tbname ].Locked = locked
	end

	function DEV:GetTextboxText( name )
		return self.Textboxes[ name ].Content
	end

	function DEV:SetTextboxText( name, text )
		if (!text) then text = "" end
		self.Textboxes[ name ].Content = text
		self:CUR_ToEnd( name )
		self:CalcTextWrap( name )
	end

	function DEV:AddListboxItem( name, itemname, text )
		self.Listboxes[ name ].List[ itemname ] = text
	end

	function DEV:ClearListbox( name )
		self.Listboxes[ name ].List = {}
	end

	function DEV:SetListboxSelRow( name, itemname )
		self.Listboxes[ name ].SelItem = itemname
	end

	function DEV:GetListboxSelRow( name )
		return self.Listboxes[ name ].SelItem
	end

	function DEV:RemoveTextbox( name )
		self.Textboxes[ name ] = nil
	end

	function DEV:RemoveListbox( name )
		self.Listboxes[ name ] = nil
	end
	
// ------------------------------------------------------------------------------------------------------------------------------------------------
//	Calculation functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:MouseToChar( tbname, cx, cy )
		// cx, cy are actual coords relative to the textbox
		PCMod.Msg( "cx,cy="..cx..","..cy, true )
		local tb = self.Textboxes[ tbname ]
		local txt = {}
		local fline = ""
		if (tb.TEntry) then
			// Get the text table
			self:CalcTextWrap( tbname )
			txt = self.Textboxes[ tbname ].ContentTbl
			if (!txt) then return 0 end
			if (!txt[1]) then txt[1] = "" end
			fline = string.Replace( txt[1], "\n", "" )
			if ((!fline) || (fline == "")) then return 0 end
		else
			txt = { tb.Content }
			fline = string.Replace( tb.Content, "\n", "" )
		end
		
		if (PCMod.Cfg.DebugMode) then
			print( "BASE SSDEVICE: Attempting to figure out char..." )
			PrintTable( txt )
		end
		
		// Figure out what line we are on
		surface.SetFont( "pcmod_3d2d" )
		local tw, th = surface.GetTextSize( fline )
		local lineid = math.Clamp( math.ceil( cy/th ), 1, #txt )
		
		if (tb.ScrollBar) then lineid = lineid + tb.ScrollOffset end
		if (lineid > #txt) then lineid = #txt end
		
		PCMod.Msg( "=> LINE ID: " .. lineid, true )
		
		// Figure out what character we are on
		local ow = 0
		local cw = 0
		local text = txt[ lineid ]
		if ((!text) || (text == "")) then return 0 end
		PCMod.Msg( "=> TEXT: " .. text, true )
		local t = string.Explode( "", text )
		local cnt
		local charid = #t
		local tw, th = surface.GetTextSize( t[1] )
		if ((cx > ow) && (cx < 5)) then charid = 0 end
		for cnt=1, #t do
			local tw, th = surface.GetTextSize( t[ cnt ] )
			cw = cw + tw
			if ((cx > (ow+(cw*0.5))) && (cx < (cw+(cw*0.5)))) then
				charid = cnt
				break
			end
		end
		PCMod.Msg( "Real line,char: " .. lineid .. "," .. charid, true )
		if ((lineid>1) && (char == 0)) then
			charid = 1
		end
		
		// We have line and char, now we need to figure out exactly which character we are on
		local char = table.PartialVal( txt, lineid-1 ) + charid
		return char
	end

// ------------------------------------------------------------------------------------------------------------------------------------------------
//	Rendering functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:RenderWindow( theme, x, y, w, h, caption, ch )
		if (PCMod.Gui.ThemeDraw( theme, "window", x, y, w, h, caption, ch )) then return end
		local c_pri = PCMod.Gui.GetThemeColour( theme, "Primary" )
		local c_sec = PCMod.Gui.GetThemeColour( theme, "Secondary" )
		local c_bar = PCMod.Gui.GetThemeColour( theme, "Bar" )
		local c_bar_txt = PCMod.Gui.GetThemeColour( theme, "Bar_Text" )
		local c_bor = PCMod.Gui.GetThemeColour( theme, "Border" )
		surface.SetDrawColor( c_pri.r, c_pri.g, c_pri.b, c_pri.a )
		surface.DrawRect( x, y, w, h )
		surface.SetDrawColor( c_bar.r, c_bar.g, c_bar.b, c_bar.a )
		surface.DrawRect( x, y, w, ch )
		draw.SimpleText( caption, "pcmod_3d2d", x, y+(ch/2), c_bar_txt, TEXT_ALIGN_LEFT, 1 )
		surface.DrawOutline( x, y, w, h, c_bor )
		surface.DrawLine( x, y+ch, x+w, y+ch )
	end

	function DEV:RenderText( x, y, text, col, align )
		if ((!text) || (!text[1])) then return end
		if (PCMod.Gui.ThemeDraw( theme, "text", x, y, text, col, align )) then return end
		surface.SetFont( "pcmod_3d2d" )
		local tw, th = surface.GetTextSize( text[1] )
		for k, txt in pairs( text ) do
			local ty = y + ((k-1)*th)
			local t = tostring( txt )
			if (type(txt) == "number") then t = PCMod.Cfg.StatusCodes[ txt ] end
			if (!t) then t = "Invalid Statuscode!" end
			draw.SimpleText( t, "pcmod_3d2d", x, ty, col, align, TEXT_ALIGN_TOP )
		end
	end

	function DEV:RenderError( theme, x, y, text )
		if (PCMod.Gui.ThemeDraw( theme, "error", x, y, text )) then return end
		surface.SetFont( "pcmod_3d2d" )
		local w, h = surface.GetTextSize( text )
		local c_err = PCMod.Gui.GetThemeColour( theme, "ErrorBG" )
		local c_err_txt = PCMod.Gui.GetThemeColour( theme, "Error_Text" )
		local c_bor = PCMod.Gui.GetThemeColour( theme, "Border" )
		surface.SetDrawColor( c_err.r, c_err.g, c_err.b, c_err.a )
		surface.DrawRect( x-(w/2), y-(h/2), w, h )
		draw.SimpleText( text, "pcmod_3d2d", x, y, c_err_txt, 1, 1 )
		surface.DrawOutline( x-(w/2), y-(h/2), w, h, c_bor )
	end

	function DEV:RenderTextbox( tb )
		local c_bor = PCMod.Gui.GetThemeColour( tb.Theme, "Border" )
		local c_tbbg = PCMod.Gui.GetThemeColour( tb.Theme, "TextboxBG" )
		local c_tb_txt = PCMod.Gui.GetThemeColour( tb.Theme, "Textbox_Text" )
		surface.SetDrawColor( c_tbbg.r, c_tbbg.g, c_tbbg.b, c_tbbg.a )
		local txt = string.Replace( tb.Content, "\n", "" ) -- This gets rid of all newlines which might happen to screw up GetTextSize. -thomasfn
		surface.SetFont( "pcmod_3d2d" )
		local tw, th = surface.GetTextSize( txt )
		local odec = 0
		if (tb.TEntry) then
			if (!PCMod.Gui.ThemeDraw( tb.Theme, "textentry", tb )) then
				surface.DrawRect( tb.X, tb.Y, tb.W, tb.H )
				surface.DrawOutline( tb.X, tb.Y, tb.W, tb.H, c_bor )
			end
			local strs = tb.ContentTbl
			if (strs) then
				local cnt = 0
				local lpbox = math.floor( tb.H / th )
				if (tb.ScrollOffset > (#strs-lpbox)) then tb.ScrollOffset = #strs-lpbox end
				local o = tb.ScrollOffset
				local st = o+1
				local ed = lpbox+o
				odec = o/(#strs-lpbox)
				if (ed>#strs) then ed = #strs end
				if (#strs > lpbox) then
					tb.ScrollBar = true
				else
					tb.ScrollBar = false
					tb.ScrollOffset = 0
				end
				local i = -1
				for cnt=st,ed do
					if (strs[cnt]) then
						i = i + 1
						local text = string.Replace( strs[ cnt ], "\n", "" )
						local ypos = tb.Y + (i * th)
						draw.SimpleText( text, "pcmod_3d2d", tb.X, ypos, c_tb_txt, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
					end
				end
			end
			if (tb.ScrollBar) then
				local tw, th = surface.GetTextSize( "XX" )
				local c_btbg = PCMod.Gui.GetThemeColour( tb.Theme, "ButtonBG" )
				local c_bt_txt = PCMod.Gui.GetThemeColour( tb.Theme, "Button_Text" )
				surface.SetDrawColor( c_btbg.r, c_btbg.g, c_btbg.b, c_btbg.a )
				local xpos = tb.X+(tb.W-tw)
				surface.DrawRect( xpos, tb.Y+1, tw, tb.H-2 )
				surface.SetDrawColor( c_bor.r, c_bor.g, c_bor.b, c_bor.a )
				surface.DrawLine( xpos, tb.Y, xpos, tb.Y+tb.H )
				surface.DrawLine( xpos, tb.Y+th, xpos+tw, tb.Y+th )
				surface.DrawLine( xpos, (tb.Y+tb.H)-th, xpos+tw, (tb.Y+tb.H)-th )
				if (odec) then
					local oy = tb.Y+th+((tb.H-(th*2))*odec)
					surface.DrawLine( xpos, oy, xpos+tw, oy )
				end
				draw.SimpleText( "^", "pcmod_3d2d", xpos+(tw/2), tb.Y+(th/2), c_bt_txt, 1, 1 )
				draw.SimpleText( "v", "pcmod_3d2d", xpos+(tw/2), (tb.Y+tb.H)-(th/2), c_bt_txt, 1, 1 )
			end
		else
			if (!PCMod.Gui.ThemeDraw( tb.Theme, "textbox", tb )) then
				surface.DrawRect( tb.BX, tb.Y, tb.BW, tb.H )
				surface.DrawOutline( tb.BX, tb.Y, tb.BW, tb.H, c_bor )
			end
			draw.SimpleText( tb.Text, "pcmod_3d2d", tb.TX, tb.MY, c_tb_txt, TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( txt, "pcmod_3d2d", tb.BX, tb.MY, c_tb_txt, TEXT_ALIGN_LEFT, 1 )
		end
		local ch = math.Clamp( th, 0, tb.H ) -- Cursor is not going to be bigger than the textbox! -thomasfn
		if ((self.TB_Focus == tb.Name) && (tb.CUR_Y >= 0) && ((tb.CUR_Y+ch) <= tb.H)) then -- Must be > 0, otherwise the cursor is scrolled off the screen -thomasfn
			local cx = (tb.CUR_X or 0)
			local cy = (tb.CUR_Y or 0) + tb.Y
			if (tb.TEntry) then cx = cx + tb.X; else cx = cx + tb.BX; end
			surface.SetDrawColor( c_tb_txt.r, c_tb_txt.g, c_tb_txt.b, c_tb_txt.a )
			if ((CurTime()%1)>=0.5) then surface.DrawLine( cx, cy, cx, cy+ch ) end
		end
		self.Textboxes[ tb.Name ] = tb
	end

	function DEV:RenderListbox( lb )
		local c_bor = PCMod.Gui.GetThemeColour( lb.Theme, "Border" )
		local c_lbbg = PCMod.Gui.GetThemeColour( lb.Theme, "ListboxBG" )
		local c_lb_txt = PCMod.Gui.GetThemeColour( lb.Theme, "Listbox_Text" )
		local c_lb_selbg = PCMod.Gui.GetThemeColour( lb.Theme, "Listbox_SelBG" )
		local c_lb_seltxt = PCMod.Gui.GetThemeColour( lb.Theme, "Listbox_SelText" )
		if (!PCMod.Gui.ThemeDraw( lb.Theme, "listbox", lb )) then
			surface.SetDrawColor( c_lbbg.r, c_lbbg.g, c_lbbg.b, c_lbbg.a )
			surface.DrawRect( lb.X, lb.Y, lb.W, lb.H )
			surface.DrawOutline( lb.X, lb.Y, lb.W, lb.H, c_bor )
		end
		local ypos = 0
		local odec = 0
		surface.SetFont( "pcmod_3d2d" )
		local sbw, sbh = surface.GetTextSize( "XX" )
		local tw = 0
		local th = 0
		for _, v in pairs( lb.List ) do
			tw, th = surface.GetTextSize( v )
			break
		end
		local cy = 0
		if (lb.List) then
			local cnt = table.Count( lb.List )
			local t_h = cnt * th
			if (t_h > lb.H) then
				lb.ScrollBar = true
			else
				lb.ScrollBar = false
				lb.ScrollOffset = 0
			end
			local o = lb.ScrollOffset
			if (!o) then o = 0 end
			local i = 0
			odec = o/(cnt-(math.floor( lb.H / th )))
			for name, text in pairs( lb.List ) do
				if (i >= o) then
					local tw, th = surface.GetTextSize( text )
					cy = cy + th
					if (cy < lb.H) then
						local tcol = c_lb_txt
						if (lb.SelItem == name) then
							surface.SetDrawColor( c_lb_selbg.r, c_lb_selbg.g, c_lb_selbg.b, c_lb_selbg.a )
							surface.DrawRect( lb.X+2, lb.Y + ypos + 1, lb.W-2, th - 1 )
							tcol = c_lb_seltxt
						end
						surface.SetDrawColor( c_bor.r, c_bor.g, c_bor.b, c_bor.a )
						surface.DrawLine( lb.X, lb.Y + ypos + th, lb.X + lb.W, lb.Y + ypos + th )
						local sa = 0
						if (lb.ScrollBar) then sa = sbw * 0.5 end
						draw.SimpleText( text, "pcmod_3d2d", lb.MX-sa, lb.Y + ypos + (th*0.5), tcol, 1, 1 )
						ypos = ypos + th
					end
				end
				i = i + 1
			end
		end
		if (lb.ScrollBar) then
			local tw = sbw
			local th = sbh
			local c_btbg = PCMod.Gui.GetThemeColour( lb.Theme, "ButtonBG" )
			local c_bt_txt = PCMod.Gui.GetThemeColour( lb.Theme, "Button_Text" )
			surface.SetDrawColor( c_btbg.r, c_btbg.g, c_btbg.b, c_btbg.a )
			local xpos = lb.X+(lb.W-tw)
			surface.DrawRect( xpos, lb.Y+1, tw, lb.H-2 )
			surface.SetDrawColor( c_bor.r, c_bor.g, c_bor.b, c_bor.a )
			surface.DrawLine( xpos, lb.Y, xpos, lb.Y+lb.H )
			surface.DrawLine( xpos, lb.Y+th, xpos+tw, lb.Y+th )
			surface.DrawLine( xpos, (lb.Y+lb.H)-th, xpos+tw, (lb.Y+lb.H)-th )
			if (odec) then
				local oy = lb.Y+th+((lb.H-(th*2))*odec)
				surface.DrawLine( xpos, oy, xpos+tw, oy )
			end
			draw.SimpleText( "^", "pcmod_3d2d", xpos+(tw/2), lb.Y+(th/2), c_bt_txt, 1, 1 )
			draw.SimpleText( "v", "pcmod_3d2d", xpos+(tw/2), (lb.Y+lb.H)-(th/2), c_bt_txt, 1, 1 )
		end
		if (lb.Name) then self.Listboxes[ lb.Name ] = lb end
	end

	function DEV:RenderFrame( theme, title, x, y, w, h, color )
		if (PCMod.Gui.ThemeDraw( theme, "frame", title, x, y, w, h, color )) then return end
		local c_bor = PCMod.Gui.GetThemeColour( theme, "Border" )
		surface.SetFont( "pcmod_3d2d" )
		local tw, th = surface.GetTextSize( title )
		surface.SetDrawColor( c_bor.r, c_bor.g, c_bor.b, c_bor.a )
		surface.DrawLine( x, y, x, y+h )
		surface.DrawLine( x, y+h, x+w, y+h )
		surface.DrawLine( x+w, y, x+w, y+h )
		surface.DrawLine( x, y, x+((w*0.5)-(tw*0.5)), y )
		surface.DrawLine( x+((w*0.5)+(tw*0.5)), y, x+w, y )
		draw.SimpleText( title, "pcmod_3d2d", x+(w*0.5), y, color, 1, 1 )
	end
	
// ------------------------------------------------------------------------------------------------------------------------------------------------
//	Click processing functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:Int_ListboxClick( lbname, x, y )
		local lb = self.Listboxes[ lbname ]
		if (!lb) then return end
		surface.SetFont( "pcmod_3d2d" )
		local sbw, sbh = surface.GetTextSize( "XX" )
		local cx = self.win_x + (self.win_w*x)
		local cy = self.win_y + (self.win_h*y)
		local xpos = lb.X+(lb.W-sbw)
		if ((cx>xpos) && (cx<(lb.X+lb.W)) && (lb.ScrollBar)) then
			local btn = { X = xpos, Y = lb.Y, W = sbw, H = sbh }
			if (self:CursorInButton( btn, x, y )) then
				// Scroll up!
				PCMod.Msg( "Scrolling up!", true )
				lb.ScrollOffset = lb.ScrollOffset - 1
			end
			local btn = { X = xpos, Y = lb.Y+(lb.H-sbh), W = sbw, H = sbh }
			if (self:CursorInButton( btn, x, y )) then
				// Scroll down!
				PCMod.Msg( "Scrolling down!", true )
				lb.ScrollOffset = lb.ScrollOffset + 1
			end
			lb.ScrollOffset = math.Clamp( lb.ScrollOffset, 0, table.Count( lb.List ) - math.floor( lb.H / sbh ))
			// self:CUR_SetPos( name ) -- This will re-calc the position of the cursor
		else
			local tmp = {}
			local RowH = 0
			local ypos = 0
			local oh = 0
			local o = lb.ScrollOffset
			if ((!o) || (!lb.ScrollBar)) then o = 0 end
			for name, text in pairs( lb.List ) do
				local tw, th = surface.GetTextSize( text )
				RowH = th
				if (oh == 0) then oh = o*RowH end
				table.insert( tmp, { name, ypos - oh } )
				ypos = ypos + th
			end
			table.insert( tmp, { "", ypos } )
			local i = 0
			for i=1, #tmp-1 do
				local yn = tmp[ i+1 ]
				local yc = tmp[ i ]
				if ((yn) && (yc)) then
					// PCMod.Msg( "Checking (" .. cx .. "," .. cy .. ") v '" .. yn[2] .. "' & '" .. yc[2] .. "'...", true )
					if ((cy < (lb.Y+yn[2])) && (cy > (lb.Y+yc[2]))) then
						PCMod.Msg( "Listbox item selected! (" .. yn[1] .. ")", true )
						self.Listboxes[ lbname ].SelItem = yc[1]
						self:ListboxSelect( lbname, yc[1] )
					else
						PCMod.Msg( "No match!", true )
					end
				else
					PCMod.Msg( "Missing values!", true )
				end
			end
		end
		if (lb.Name) then self.Listboxes[ lb.Name ] = lb end
	end

	function DEV:Int_TextboxClick( name, x, y )
		local tb = self.Textboxes[ name ]
		if (!tb) then return end
		self.TB_Focus = name
		local cx = self.win_x + (self.win_w*x)
		local cy = self.win_y + (self.win_h*y)
		if (!tb.TEntry) then
			tb.X = tb.BX
		end
		surface.SetFont( "pcmod_3d2d" )
		local tw, th = surface.GetTextSize( "XX" )
		local xpos = tb.X+(tb.W-tw)
		if ((cx>xpos) && (cx<(tb.X+tb.W)) && (tb.ScrollBar)) then
			local btn = { X = xpos, Y = tb.Y, W = tw, H = th }
			if (self:CursorInButton( btn, x, y )) then
				// Scroll up!
				PCMod.Msg( "Scrolling up!", true )
				tb.ScrollOffset = tb.ScrollOffset - 1
				if (tb.ScrollOffset < 0) then tb.ScrollOffset = 0 end
			end
			local btn = { X = xpos, Y = tb.Y+(tb.H-th), W = tw, H = th }
			if (self:CursorInButton( btn, x, y )) then
				// Scroll down!
				PCMod.Msg( "Scrolling down!", true )
				tb.ScrollOffset = tb.ScrollOffset + 1
			end
			self:CUR_SetPos( name ) -- This will re-calc the position of the cursor
		else
			local char = self:MouseToChar( name, cx-tb.X, cy-tb.Y )
			PCMod.Msg( "Calculated char '" .. char .. "'!", true )
			self:CUR_SetPos( name, char )
		end
		self.Textboxes[ name ] = tb
	end

// ------------------------------------------------------------------------------------------------------------------------------------------------
//	Misc functions
// ------------------------------------------------------------------------------------------------------------------------------------------------

	function DEV:CursorInTextbox( tb, x, y )
		local cx = self.win_x + (self.win_w*x)
		local cy = self.win_y + (self.win_h*y)
		if (tb.TEntry) then
			return ((cx>tb.X) && (cx<(tb.X+tb.W)) && (cy>tb.Y) && (cy<(tb.Y+tb.H)))
		else
			return ((cx>tb.BX) && (cx<(tb.BX+tb.BW)) && (cy>tb.Y) && (cy<(tb.Y+tb.H)))
		end
	end

	function DEV:CursorInListbox( lb, x, y )
		local cx = self.win_x + (self.win_w*x)
		local cy = self.win_y + (self.win_h*y)
		return ((cx>lb.X) && (cx<(lb.X+lb.W)) && (cy>lb.Y) && (cy<(lb.Y+lb.H)))
	end

	function DEV:SubmitCommand( ... )
		RunConsoleCommand( "pc_command", self.EntID, "input", ... )
	end

	function DEV:StreamCommand( ... )
		PrintTable({...})
		//datastream.StreamToServer( "pc_stream", { self.EntID, "input", ... }, Msg )
		net.Start("pc_stream")
			net.WriteTable({self.EntID, "input", ...})
		net.SendToServer();
	end

	function DEV:StreamProgCommand( progname, ... )
		self:StreamCommand( "os_command", "prog_command", progname, ... )
	end

	function DEV:RunProgCommand( progname, ... )
		self:SubmitCommand( "os_command", "prog_command", progname, ... )
	end

	function DEV:Draw()
		self:DrawTextboxes()
		self:DrawListboxes()
		self:DrawElements()
	end

	function DEV:ProcessClick( x, y )
		self:ClickTextboxes( x, y )
		self:ClickListboxes( x, y )
		self:ClickElements( x, y )
	end

	function DEV:PassData( devname, dname, data )
		if (!devname) then return end
		local ent = self.Entity
		if ((!ent) || (!ent:IsValid())) then return end
		local devid = tostring( ent:EntIndex() ) .. ":" .. devname
		if (PCMod.SDraw.DevMap[ devid ]) then PCMod.SDraw.DevMap[ devid ]:DataRecieved( dname, data ) end
	end

	function DEV:Tick()
		self.LastTick = CurTime()
		self.LastFrame = PCMod.SDraw.CFrame
	end

	// The following 2 functions are overrides for compatability with the old SS Devices class
	function DEV:DrawButtons()
		self:Draw()
	end

	function DEV:ClickButtons( x, y )
		self:ProcessClick( x, y )
	end