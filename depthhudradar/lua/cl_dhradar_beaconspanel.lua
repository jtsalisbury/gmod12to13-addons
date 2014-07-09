////////////////////////////////////////////////
// -- Depth HUD : Radar                       //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// The Menu                                   //
////////////////////////////////////////////////

include( 'CtrlColor.lua' )

local MY_VERSION = 0
local SVN_VERSION = nil
local DOWNLOAD_LINK = nil

local function dhradar_GetVersion( contents , size )
	//Taken from RabidToaster Achievements mod.
	local split = string.Explode( "\n", contents )
	local version = tonumber( split[ 1 ] or "" )
	
	if ( !version ) then
		SVN_VERSION = -1
		return
	end
	
	SVN_VERSION = version
	
	if ( split[ 2 ] ) then
		DOWNLOAD_LINK = split[ 2 ]
	end
end

function dhradar_ShowMenu()
	local DermaPanel = vgui.Create( "DFrame" )
	local w,h = 232,364
	local border = 4
	local W_WIDTH = w - 2*border
	
	////// // // THE FRAME
	DermaPanel:SetPos( ScrW()*0.5 - w*0.5 , ScrH()*0.5 - h*0.5 )
	DermaPanel:SetSize( w, h )
	DermaPanel:SetTitle( "DepthHUD Radar" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	
	local PanelList = vgui.Create( "DPanelList", DermaPanel )
	PanelList:SetPos( border , 22 + border )
	PanelList:SetSize( W_WIDTH, h - 2*border - 22 )
	PanelList:SetSpacing( 5 )
	PanelList:EnableHorizontal( false )
	PanelList:EnableVerticalScrollbar( false )
	
	////// CATEGORY : GENERAL
	local GeneralCategory = vgui.Create("DCollapsibleCategory", PanelList)
	GeneralCategory:SetSize( W_WIDTH, 50 )
	GeneralCategory:SetExpanded( 1 ) -- Expanded when popped up
	GeneralCategory:SetLabel( "General" )
	
	local GeneralCatList = vgui.Create( "DPanelList" )
	GeneralCatList:SetSize(W_WIDTH, 128 )
	GeneralCatList:EnableHorizontal( false )
	GeneralCatList:EnableVerticalScrollbar( false )
	
	// ENABLE CHECK
	local GeneralEnableCheck = vgui.Create( "DCheckBoxLabel" )
	GeneralEnableCheck:SetText( "Enable" )
	GeneralEnableCheck:SetConVar( "dhradar_enable" )
	GeneralEnableCheck:SetValue( GetConVarNumber( "dhradar_enable" ) )
	
	// ENABLE PLAYERNAMES
	local GeneralNamesCheck = vgui.Create( "DCheckBoxLabel" )
	GeneralNamesCheck:SetText( "Show Player Names" )
	GeneralNamesCheck:SetConVar( "dhradar_ui_showplayernames" )
	GeneralNamesCheck:SetValue( GetConVarNumber( "dhradar_ui_showplayernames" ) )
	
	// ENABLE FRIENDS
	local GeneralFriendsCheck = vgui.Create( "DCheckBoxLabel" )
	GeneralFriendsCheck:SetText( "Show out-of-range Players if friend" )
	GeneralFriendsCheck:SetConVar( "dhradar_ui_showplayeriffriend" )
	GeneralFriendsCheck:SetValue( GetConVarNumber( "dhradar_ui_showplayeriffriend" ) )
	
	// WALLS CHECK
	local GeneralWallsCheck = vgui.Create( "DCheckBoxLabel" )
	GeneralWallsCheck:SetText( "Show Walls (Soliton Scan)" )
	GeneralWallsCheck:SetConVar( "dhradar_showwalls" )
	GeneralWallsCheck:SetValue( GetConVarNumber( "dhradar_showwalls" ) )
	
	// HEIGHTS CHECK
	local GeneralHeightsCheck = vgui.Create( "DCheckBoxLabel" )
	GeneralHeightsCheck:SetText( "Show Heights (Live Map)" )
	GeneralHeightsCheck:SetConVar( "dhradar_showheights" )
	GeneralHeightsCheck:SetValue( GetConVarNumber( "dhradar_showheights" ) )
	
	// SCALE SLIDER
	local GeneralScaleSlider = vgui.Create("DNumSlider")
	GeneralScaleSlider:SetText( "Scale" )
	GeneralScaleSlider:SetMin( 5 )
	GeneralScaleSlider:SetMax( 40 )
	GeneralScaleSlider:SetDecimals( 0 )
	GeneralScaleSlider:SetConVar("dhradar_ui_scale")
	
	// FORWARD EXPLORER
	local GeneralFwexploreCheck = vgui.Create( "DCheckBoxLabel" )
	GeneralFwexploreCheck:SetText( "Enable Forward Farseer" )
	GeneralFwexploreCheck:SetConVar( "dhradar_forwardexplore" )
	GeneralFwexploreCheck:SetValue( GetConVarNumber( "dhradar_forwardexplore" ) )
	
	// SCALE EXPLORER
	local GeneralScaleexploreCheck = vgui.Create( "DCheckBoxLabel" )
	GeneralScaleexploreCheck:SetText( "Enable Scale Farseer" )
	GeneralScaleexploreCheck:SetConVar( "dhradar_scaleexplore" )
	GeneralScaleexploreCheck:SetValue( GetConVarNumber( "dhradar_scaleexplore" ) )
	
	// REVERT BUTTON
	local GeneralRevertexploreButton = vgui.Create("DButton")
	GeneralRevertexploreButton:SetText( "Revert Farseer Values" )
	GeneralRevertexploreButton.DoClick = function()
		RunConsoleCommand("dhradar_revertexplore")
	end
	// HOWTO BUTTON
	local GeneralHowtoexploreButton = vgui.Create("DButton")
	GeneralHowtoexploreButton:SetText( "How to use Farseer ?" )
	GeneralHowtoexploreButton.DoClick = function()
		RunConsoleCommand("dhradar_explorehelp")
	end
	
	// DHDIV
	local GeneralTextLabel = vgui.Create("DLabel")
	local GeneralTextLabelMessage = "The command \"dhradar_menu\" calls this menu.\n"
	if not (MY_VERSION and SVN_VERSION and (MY_VERSION < SVN_VERSION)) then
		GeneralTextLabelMessage = GeneralTextLabelMessage .. "Example : To assign radar menu to F6, type in the console :"
	else
		GeneralTextLabelMessage = GeneralTextLabelMessage .. "Your version is "..MY_VERSION.." and the updated one is "..SVN_VERSION.." ! You should update !"
	end
	GeneralTextLabel:SetWrap( true )
	GeneralTextLabel:SetText( GeneralTextLabelMessage )
	GeneralTextLabel:SetContentAlignment( 7 )
	GeneralTextLabel:SetSize( W_WIDTH, 40 )
	
	// DHMENU BUTTON
	local GeneralCommandLabel = vgui.Create("DTextEntry")
	if not (MY_VERSION and SVN_VERSION and (MY_VERSION < SVN_VERSION) and DOWNLOAD_LINK) then
		GeneralCommandLabel:SetText( "bind \"F6\" \"dhradar_menu\"" )
	else
		GeneralCommandLabel:SetText( DOWNLOAD_LINK )
	end
	GeneralCommandLabel:SetEditable( false )
	
	// MAKE: GENERAL
	GeneralCatList:AddItem( GeneralEnableCheck )         //Adds the ENABLE CHECK
	GeneralCatList:AddItem( GeneralNamesCheck )          //Adds the PLAYERNAMES CHECK
	GeneralCatList:AddItem( GeneralFriendsCheck )        //Adds the FRIEND CHECK
	GeneralCatList:AddItem( GeneralWallsCheck )          //Adds the WALLS CHECK
	GeneralCatList:AddItem( GeneralHeightsCheck )        //Adds the HEIGHTS CHECK
	GeneralCatList:AddItem( GeneralFwexploreCheck )      //Adds the FORWARD EXPCHECK
	GeneralCatList:AddItem( GeneralScaleexploreCheck )   //Adds the SCALE EXPCHECK
	
	GeneralCatList:AddItem( GeneralScaleSlider )         //Adds the SCALE SLIDER
	
	GeneralCatList:AddItem( GeneralTextLabel )           //Adds the DHDIV
	GeneralCatList:AddItem( GeneralCommandLabel )           //Adds the DHMENU
	
	GeneralCatList:AddItem( GeneralRevertexploreButton ) //Adds the REVERT EXP BTN
	GeneralCatList:AddItem( GeneralHowtoexploreButton )  //Adds the HOWTO EXP BTN
	
	GeneralCatList:PerformLayout()
	GeneralCatList:SizeToContents()
	GeneralCategory:SetContents( GeneralCatList )        //CATEGORY GENERAL FILLED
	
	
	
	////// CATEGORY : BEACONS
	local BeaconsCategory = vgui.Create("DCollapsibleCategory", PanelList)
	BeaconsCategory:SetSize( W_WIDTH, 50 )
	BeaconsCategory:SetExpanded( 0 ) -- Expanded when popped up
	BeaconsCategory:SetLabel( "Beacons" )
	
	local BeaconsCatList = vgui.Create( "DPanelList" )
	BeaconsCatList:SetSize(W_WIDTH, 170 + 70 )
	BeaconsCatList:EnableHorizontal( false )
	BeaconsCatList:EnableVerticalScrollbar( false )
	
	
	// MAIN BEACON LIST
	local BeaconsList = vgui.Create( "DPanelList" )
	BeaconsList:SetSize( W_WIDTH, 110 + 70 )
	BeaconsList:SetSpacing( 5 )
	BeaconsList:EnableHorizontal( false )
	BeaconsList:EnableVerticalScrollbar( true )
	local names = dhradar.GetNamesTable()
	for k,name in pairs(names) do
		local beacon_name = dhradar.Get(name).Name or name
		
		local ListCheck = vgui.Create( "DCheckBoxLabel" )
		ListCheck:SetText( beacon_name )
		ListCheck:SetConVar( "dhradar_beacon_" .. name )
		ListCheck:SetValue( GetConVarNumber( "dhradar_beacon_" .. name ) )
		ListCheck:SizeToContents()
		BeaconsList:AddItem( ListCheck ) -- Add the item above
	end
	
	// RELOAD BUTTON
	local BeaconReloadButton = vgui.Create("DButton")
	BeaconReloadButton:SetText( "Reload Beacon Files" )
	BeaconReloadButton.DoClick = function()
		RunConsoleCommand("dhradar_reloadbeacons")
		DermaPanel:Close()
		RunConsoleCommand("dhradar_menu")
	end
	
	// RANGE SLIDER
	local BeaconRangeSlider = vgui.Create("DNumSlider")
	BeaconRangeSlider:SetText( "Range of Detection" )
	BeaconRangeSlider:SetMin( 48 )
	BeaconRangeSlider:SetMax( 4096 )
	BeaconRangeSlider:SetDecimals( 0 )
	BeaconRangeSlider:SetConVar("dhradar_range")
	
	// MAKE: BEACONS
	BeaconsCatList:AddItem( BeaconsList )         //Adds the BEACON LIST
	BeaconsCatList:AddItem( BeaconRangeSlider )   //Adds the RANGE SLIDER
	BeaconsCatList:AddItem( BeaconReloadButton )  //Adds the RELOAD BUTTON
	BeaconsCatList:PerformLayout()
	BeaconsCatList:SizeToContents()
	BeaconsCategory:SetContents( BeaconsCatList ) //CATEGORY BEACONS FILLED
	
	
	////// CATEGORY : UIStyle
	local UIStyleCategory = vgui.Create("DCollapsibleCategory", PanelList)
	UIStyleCategory:SetSize( W_WIDTH, 50 )
	UIStyleCategory:SetExpanded( 0 ) -- Expanded when popped up
	UIStyleCategory:SetLabel( "UI Design" )
	
	local UIStyleCatList = vgui.Create( "DPanelList" )
	UIStyleCatList:SetSize(W_WIDTH, 128 )
	UIStyleCatList:EnableHorizontal( false )
	UIStyleCatList:EnableVerticalScrollbar( false )
	
	// SIZE XREL
	local UIStyleXrelSlider = vgui.Create("DNumSlider")
	UIStyleXrelSlider:SetText( "Relative X Position" )
	UIStyleXrelSlider:SetMin( 0 )
	UIStyleXrelSlider:SetMax( 1 )
	UIStyleXrelSlider:SetDecimals( 3 )
	UIStyleXrelSlider:SetConVar("dhradar_ui_x_rel")
	
	// SIZE XREL
	local UIStyleYrelSlider = vgui.Create("DNumSlider")
	UIStyleYrelSlider:SetText( "Relative Y Position" )
	UIStyleYrelSlider:SetMin( 0 )
	UIStyleYrelSlider:SetMax( 1 )
	UIStyleYrelSlider:SetDecimals( 3 )
	UIStyleYrelSlider:SetConVar("dhradar_ui_y_rel")
	
	// PINSCALE SLIDER
	local UIStylePinscaleSlider = vgui.Create("DNumSlider")
	UIStylePinscaleSlider:SetText( "Pin Scale" )
	UIStylePinscaleSlider:SetMin( 0 )
	UIStylePinscaleSlider:SetMax( 2 )
	UIStylePinscaleSlider:SetDecimals( 1 )
	UIStylePinscaleSlider:SetConVar("dhradar_ui_pinscale")
	
	// SIZE SLIDER
	local UIStyleSizeSlider = vgui.Create("DNumSlider")
	UIStyleSizeSlider:SetText( "Size" )
	UIStyleSizeSlider:SetMin( 64 )
	UIStyleSizeSlider:SetMax( 512 )
	UIStyleSizeSlider:SetDecimals( 0 )
	UIStyleSizeSlider:SetConVar("dhradar_ui_size")
	
	// OVERALL OPACITY SLIDER
	local UIStyleOpacitySlider = vgui.Create("DNumSlider")
	UIStyleOpacitySlider:SetText( "Overall Opacity" )
	UIStyleOpacitySlider:SetMin( 0 )
	UIStyleOpacitySlider:SetMax( 1 )
	UIStyleOpacitySlider:SetDecimals( 3 )
	UIStyleOpacitySlider:SetConVar("dhradar_ui_opacity")
	
	// LIVEMAP OPACITY SLIDER
	local UIHeightOpacitySlider = vgui.Create("DNumSlider")
	UIHeightOpacitySlider:SetText( "Heights (Live Map) Opacity" )
	UIHeightOpacitySlider:SetMin( 0 )
	UIHeightOpacitySlider:SetMax( 1 )
	UIHeightOpacitySlider:SetDecimals( 3 )
	UIHeightOpacitySlider:SetConVar("dhradar_ui_heightopacity")
	
	// COLOR
	local UIRingCLabel = vgui.Create("DLabel")
	UIRingCLabel:SetText( "Ring Color" )
	local UIRingColor = vgui.Create("CtrlColor")
	UIRingColor:SetSize( W_WIDTH, 108 )
	UIRingColor:SetConVarR("dhradar_col_ring_r")
	UIRingColor:SetConVarG("dhradar_col_ring_g")
	UIRingColor:SetConVarB("dhradar_col_ring_b")
	UIRingColor:SetConVarA("dhradar_col_ring_a")
	
	local UICircleCLabel = vgui.Create("DLabel")
	UICircleCLabel:SetText( "Back Color" )
	local UICircleColor = vgui.Create("CtrlColor")
	UICircleColor:SetSize( W_WIDTH, 108 )
	UICircleColor:SetConVarR("dhradar_col_circle_r")
	UICircleColor:SetConVarG("dhradar_col_circle_g")
	UICircleColor:SetConVarB("dhradar_col_circle_b")
	UICircleColor:SetConVarA("dhradar_col_circle_a")
	
	// MAKE: UIStyle
	UIStyleCatList:AddItem( UIStyleXrelSlider )          //Adds the XREL SLIDER
	UIStyleCatList:AddItem( UIStyleYrelSlider )          //Adds the YREL SLIDER
	UIStyleCatList:AddItem( UIStylePinscaleSlider )      //Adds the PINSCALE SLIDER
	UIStyleCatList:AddItem( UIStyleSizeSlider )          //Adds the SIZE SLIDER
	UIStyleCatList:AddItem( UIStyleOpacitySlider )       //Adds the OVERALLOPACITY SLIDER
	UIStyleCatList:AddItem( UIHeightOpacitySlider )      //Adds the HEIGHTOPACITY SLIDER
	UIStyleCatList:AddItem( UIRingCLabel )               //Adds the RING LBL
	UIStyleCatList:AddItem( UIRingColor )                //Adds the RING COLOR
	UIStyleCatList:AddItem( UICircleCLabel )               //Adds the RING LBL
	UIStyleCatList:AddItem( UICircleColor )                //Adds the RING COLOR
	UIStyleCatList:PerformLayout()
	UIStyleCatList:SizeToContents()
	UIStyleCategory:SetContents( UIStyleCatList )        //CATEGORY GENERAL FILLED
	
	
	
	
	
	
	//FINISHING THE PANEL
	PanelList:AddItem( GeneralCategory )	      //CATEGORY GENERAL CREATED
	PanelList:AddItem( BeaconsCategory )	      //CATEGORY BEACONS CREATED
	PanelList:AddItem( UIStyleCategory )	      //CATEGORY UIStyle CREATED

end
concommand.Add("dhradar_menu",dhradar_ShowMenu)

function dhradar_ShowExploreHelp()
	local DermaPanel = vgui.Create( "DFrame" )
	local w,h = 488,382
	local border = 4
	local W_WIDTH = w - 2*border
	
	////// // // THE FRAME
	DermaPanel:SetPos( ScrW()*0.5 - w*0.5 , ScrH()*0.5 - h*0.5 )
	DermaPanel:SetSize( w, h )
	DermaPanel:SetTitle( "DepthHUD Radar : \"Farseer\" feature Help" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	
	local TextLabel = vgui.Create("HTML" , DermaPanel)
	local TextLabelMsg = 
[[
<html>
	<head>
	<style type="text/css">
		html
		{
			background-color: rgb(192,192,192);
		}
		body
		{
			font-size: 1em;
			background-color: white;
			border: 8px solid #0066C0;
			margin: 5px;
			padding: 5px;
			font-family: "Trebuchet MS",Verdana,Arial,serif;
			color: #0066C0;
		}
		h1
		{
			font-variant: small-caps;
			margin: 0px;
			
			font-size: 18px;
			line-height: 18px;
		}
		p
		{
			margin: 0px;
			margin-top: 5px;
			
			font-size: 12px;
			line-height: 14px;
			text-indent: 2em;
			text-align: justify;
		}
		strong
		{
			color: red;
		}
	</style>
	</head>
	<body>
		<h1>What is the "Farseer" Feature</h1>
		<p>"Farseer" is a feature that allows you to offset the radar center position dynamically.</p>
		<p>Usually, the center of the radar is your own position. Using this feature, you will be able look ahead, or look underground. If you couple this with the Height Live Map, you can find out what people are doing several rooms ahead.</p>
		<p>The "Scale Farseer" feature works the same way, and allows you to change the scale in real time, to fit your immediate needs.</p>
		
		<h1>How to use the "Farseer" Feature</h1>
		<p>If you have "Forward Farseer" enabled :
			<br/><strong>- Look ahead :</strong> HOLD DOWN "Strafe LEFT" AND "Strafe RIGHT" and Scroll the mouse wheel."
			<br/><strong>- Explore Up and Down :</strong> HOLD DOWN "Move Forward" AND "Move Backwards" and Scroll the mouse wheel.
			<br/><strong>- Reset Radar Back to your Position :</strong> TAP TWICE "Strafe LEFT" AND "Strafe RIGHT" at the same time.
		</p>
		<p>If you have "Scale Farseer" enabled :
			<br/><strong>- Scale (Zoom) :</strong> HOLD DOWN "Use Key (default E)" and Scroll the mouse wheel."
			<br/><strong>- Reset Scale Back to Normal :</strong> TAP TWICE "Move Forward" AND "Move Backwards" at the same time.
		</p>
	</body>
</html>
]]
	TextLabel:SetWrap( true )
	TextLabel:SetHTML( TextLabelMsg )
	TextLabel:SetContentAlignment( 4 )
	TextLabel:SetSize(w-8,h-16-8)
	TextLabel:CenterHorizontal()
	TextLabel:AlignBottom( 4 )
end
concommand.Add("dhradar_explorehelp",dhradar_ShowExploreHelp)

