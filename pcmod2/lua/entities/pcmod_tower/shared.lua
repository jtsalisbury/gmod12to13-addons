
// ---------------------------------------------------------------------------------------------------------
// pcmod_tower
// Tower entity - for servers and PCs
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "Computer Tower"
ENT.Class = "pcmod_tower"

ENT.ItemModel = "models/props_lab/harddrive02.mdl"

ENT.AlwaysOn = false

ENT.IsComputer = true

ENT.DefaultSetupData = {
	OS = "personal",
	BootCommand = "os:instance\nos:launch"
}

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup( setupdata )
	if ((!setupdata) || (setupdata == {})) then setupdata = self.DefaultSetupData end -- Ensure we have setup data
	local dt = self:Data() -- Get our data
	
	// Patch the use event to turnon and turnoff
	self:AddEHook( "patch", "toggleon", "use" )
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "vga" ) )
	table.insert( pts, self:CreatePort( "ps2" ) )
	table.insert( pts, self:CreatePort( "network" ) )
	table.insert( pts, self:CreatePort( "usb" ) )
	table.insert( pts, self:CreatePort( "usb" ) )
	table.insert( pts, self:CreatePort( "minijack" ) )
	dt.Ports = pts
	
	// Setup the file structure
	self:LinkFolder( "system/" )
	self:LockItem( "system/" )
	
	self:LinkFolder( "system/os/" )
	self:LockItem( "system/os/" )
	
	self:WriteFile( "system/boot.sys", setupdata.BootCommand )
	self:LockItem( "system/boot.sys" )
	
	self:WriteFile( "system/os/osid.sys", setupdata.OS )
	self:LockItem( "system/os/osid.sys" )
	
	self:WriteFile( "system/firstrun.sys", "1" )
	
	// Install drivers
	local disp = self:InstallDriver( "gen_display" ) -- Display Driver
	local bios = self:InstallDriver( "gen_bios" ) -- Bios Driver
	local snd = self:InstallDriver( "gen_sound" ) -- Sound Driver
	local usb = self:InstallDriver( "gen_usb" ) -- USB Driver
	local network = self:InstallDriver( "gen_network" ) --Network Driver
	
	// Setup the screenspace
	if (disp) then disp:FullFlush() end
	
	// Update us
	self:UpdateData( dt )
end

function ENT:DataRecieved( port, data )
	local prt = self:Ports()[ port ]
	if (!prt) then return end
	if (prt.Type == "vga") then
		if (data[1] == "player_locked") then
			for _, v in pairs( self:Ports() ) do
				if (v.Type == "ps2") then
					self:PushData( v, { "keyboard_req", data[2] } )
					PCMod.Msg( "Forwarding keyboard req to ps2 hardware!", true )
				end
			end
		elseif (data[1] == "player_input") then
			PCMod.Msg( "Player input recieved! Firing event...", true )
			self:FireEvent( data )
		else
			self:PushDriverData( "gen_display", port, data ) -- Unlikely circumstances, but just in case
		end
	end
	if (prt.Type == "ps2") then self:PushDriverData( "gen_input", port, data ) end
	if (prt.Type == "network") then self:PushDriverData( "gen_network", port, data ) end
	if (prt.Type == "usb") then self:PushDriverData( "gen_usb", port, data ) end
end

function ENT:InstallProgram( progname )
	if (self:Data().Drivers[ "gen_bios" ]) then
		if (self:Data().Drivers[ "gen_bios" ].OS) then
			return self:Data().Drivers[ "gen_bios" ].OS:InstallProgram( progname )
		end
	end
	return false
end