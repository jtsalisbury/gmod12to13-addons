
// ---------------------------------------------------------------------------------------------------------
// cl_rp.lua - Revision 1
// Client-Side
// Controls the RolePlay mode
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------

PCMod.RP = {}
PCMod.RP.Version = "1.0"

PCMod.Msg( "RolePlay library loaded! (" .. PCMod.RP.Version .. ")", true )


// ---------------------------------------------------------------------------------------------------------
// OpenBuyMenu - Opens the buy menu for PCMod
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.OpenBuyMenu()
	// Check if we're in RP mode
	if (!PCMod.Cfg.RPMode) then
		PCMod.Msg( "Not in RP Mode!" )
		return
	end
	if (LocalPlayer():Team() != TEAM_COMPTECH) then return; end
	
	// Create the window
	local pn = vgui.CreateWindow( 0.5, 0.8, "PCMod - Buy Menu", true )
	pn:SetVisible( true )
	pn:MakePopup()
	PCMod.RP.BuyMenu = pn
	
	// Create the property sheet
	local pn = vgui.CreateSheet( PCMod.RP.BuyMenu )
	PCMod.RP.BuySheet = pn
	
	// Create the information tab
	// local pn = vgui.AddTab( PCMod.RP.BuySheet, Color( 50, 50, 50, 255 ), "Information" )
	// PCMod.RP.InfoSheet = pn
	
	// Create the hardware tab
	local pn = vgui.AddTab( PCMod.RP.BuySheet, Color( 50, 50, 50, 255 ), "Hardware", "wrench" )
	PCMod.RP.HWareSheet = pn
	
	// Populate it
	for k, v in pairs( PCMod.Cfg.RPItems ) do
		local pn = vgui.Create( "BuyRow" )
		pn:SetPos( 5, 0 )
		pn:Setup( k, PCMod.RP.HWareSheet:GetWide()-10, "hardware" )
		PCMod.RP.HWareSheet:AddItem( pn )
	end
	
	// Create the software tab
	local pn = vgui.AddTab( PCMod.RP.BuySheet, Color( 50, 50, 50, 255 ), "Software", "page" )
	PCMod.RP.SWareSheet = pn
	
	// Populate it
	for k, v in pairs( PCMod.Cfg.RPDisks ) do
		local pn = vgui.Create( "BuyRow" )
		pn:SetPos( 5, 0 )
		pn:Setup( k, PCMod.RP.SWareSheet:GetWide()-10, "software" )
		PCMod.RP.SWareSheet:AddItem( pn )
	end
	
	// Create the tools tab
	local pn = vgui.AddTab( PCMod.RP.BuySheet, Color( 50, 50, 50, 255 ), "Tools", "wrench" )
	PCMod.RP.ToolsSheet = pn
	
	// Populate it
	for k, v in pairs( PCMod.Cfg.RPTools ) do
		local pn = vgui.Create( "BuyRow" )
		pn:SetPos( 5, 0 )
		pn:Setup( k, PCMod.RP.ToolsSheet:GetWide()-10, "tool" )
		PCMod.RP.ToolsSheet:AddItem( pn )
	end
end
usermessage.Hook( "pcmod_rpmenu", PCMod.RP.OpenBuyMenu )

// ---------------------------------------------------------------------------------------------------------
// HideBuyMenu - Hides the RP buy menu
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.HideBuyMenu()
	if (PCMod.RP.BuyMenu) then
		PCMod.RP.BuyMenu:Remove()
		PCMod.RP.BuyMenu = nil
	end
end
		
// ---------------------------------------------------------------------------------------------------------
// BuyHardware - Opens a small window confirming purchase
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.BuyHardware( itemid )
	// Hide the buy menu
	PCMod.RP.HideBuyMenu()
	
	// Retrieve the item
	local item = PCMod.Cfg.RPItems[ itemid ]
	if (!item) then return end
	local class = item[1]
	local name = item[2]
	local mdl = item[3]
	local price = PCMod.Cfg.RPCost[ class ] or 0
	
	// Create the window and panel list
	local window = vgui.CreateWindow( 0.3, 0.35, "Confirm Purchase" )
	PCMod.RP.ConfirmMenu = window
	local pl = vgui.Create( "DPanelList", window )
	pl:SetPos( 5, 30 )
	pl:SetSize( window:GetWide()-10, window:GetTall()-40 )
	pl:SetPadding( 5 )
	pl:SetSpacing( 5 )
	pl:EnableHorizontal( false ) // Only vertical items 
	pl:EnableVerticalScrollbar( true ) // Allow scrollbar if you exceed the Y axis
	
	// Add the components
	vgui.AddText( pl, "Selected Item: " .. name )
	vgui.AddText( pl, "Item Price: $" .. price )
	vgui.AddSI( pl, mdl )
	local btn = vgui.AddButton( pl, "Buy", function( self )
		if (PCMod.RP.OSID) then
			RunConsoleCommand( "pc_buyitem", self.Class, self.Mdl, PCMod.RP.OSID )
			PCMod.RP.OSID = nil
		else
			RunConsoleCommand( "pc_buyitem", self.Class, self.Mdl )
		end
		PCMod.RP.ConfirmMenu:Remove()
		PCMod.RP.ConfirmMenu = nil
	end )
	btn.Class = class
	btn.Mdl = mdl
	
	// If this is a tower, add extra stuff (hard coded, should be in config somehow)
	if (name == "Tower") then
		PCMod.RP.OSID = "personal"
		vgui.AddButton( pl, "Select OS", function( self )
			local menu = DermaMenu()
			menu:AddOption( "Personal OS", function() PCMod.RP.OSID = "personal" end )
			menu:AddOption( "Server OS", function() PCMod.RP.OSID = "server" end )
			menu:Open()
		end )
		PCMod.RP.OSID = cb
	end
	
	// Popup the window
	window:MakePopup()
	window:SetVisible( true )
end

// ---------------------------------------------------------------------------------------------------------
// BuyDisk - Buys an install disk pack
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.BuyDisk( itemid )
	// Hide the buy menu
	PCMod.RP.HideBuyMenu()
	
	// Buy the disk
	RunConsoleCommand( "pc_buydisk", itemid )
end

// ---------------------------------------------------------------------------------------------------------
// BuyTool - Buys a tool swep
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.BuyTool( itemid )
	// Hide the buy menu
	PCMod.RP.HideBuyMenu()
	
	// Buy the tool
	RunConsoleCommand( "pc_buytool", itemid )
end

// ---------------------------------------------------------------------------------------------------------
// DERMA: BuyRow - A row assigned to an item you can buy
// ---------------------------------------------------------------------------------------------------------
PANEL = {}
function PANEL:Setup( id, w, etype )
	local cost = 0
	local mdl = ""
	local class = ""
	local name = ""
	if (etype == "hardware") then
		local item = PCMod.Cfg.RPItems[ id ]
		class = item[1]
		name = item[2]
		mdl = item[3]
		cost = PCMod.Cfg.RPCost[ class ]
	end
	if (etype == "software") then
		local item = PCMod.Cfg.RPDisks[ id ]
		mdl = PCMod.Cfg.InstallDiskModel
		name = item[1]
		class = id
		cost = item[2]
	end
	if (etype == "tool") then
		local item = PCMod.Cfg.RPTools[ id ]
		mdl = item[1]
		name = item[2]
		class = id
		cost = PCMod.Cfg.RPCost[ item[3] ]
	end
	// if (etype == "software") then item = PCMod.Cfg.RPDisks[ id ] end
	if (!cost) then cost = 0 end
	self.ItemClass = class
	self.PW = w
	// self.SI = vgui.Create( "DModelPanel" )
	self.SI = vgui.Create( "ModelImage" )
	// self.SI.Icon:RunAnimation()
	self.SI:SetParent( self )
	self.SI:SetModel( mdl )
	// self.SI:SetFOV( 40 )
	// self.SI:SetCamPos( Vector( 0, -12, 0 ) )
	self.Btn = vgui.Create( "DButton" )
	self.Btn.ItemClass = class
	self.Btn.ItemModel = mdl
	self.Btn:SetParent( self )
	self.Btn:SetText( "Buy ($" .. tostring( cost ) .. ")" )
	self.Btn.EType = etype
	self.Btn.ID = id
	self.Btn.DoClick = function( self )
		if (self.EType == "hardware") then PCMod.RP.BuyHardware( self.ID ) end
		if (self.EType == "software") then PCMod.RP.BuyDisk( self.ID ) end
		if (self.EType == "tool") then PCMod.RP.BuyTool( self.ID ) end
	end
	self.ItemName = name
	self:InvalidateLayout()
end
function PANEL:PerformLayout()
	self:SetWide( self.PW )
	if (self.SI) then
		self.SI:SetSize( 60, 60 )
		self:SetHeight( self.SI:GetTall()+10 )
		self.SI:SetPos( 5, 5 )
		self.Btn:SetPos( 10 + self.SI:GetWide(), self:GetTall()/2 )
		self.Btn:SetSize( self:GetWide()-15-self.SI:GetWide(), (self:GetTall()/2)-5 )
	end
end
function PANEL:Paint()
	draw.RoundedBox( 6, 0, 0, self:GetWide(), self:GetTall(), Color( 255, 255, 255, 128 ) )
	draw.SimpleText( self.ItemName, "ScoreboardText", (self:GetWide()/2) + (self.SI:GetWide()/2) + 5, self:GetTall()/4, Color( 0, 0, 0, 255 ), 1, 1 )
end
vgui.Register( "BuyRow", PANEL, "PANEL" )