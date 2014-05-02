
// ---------------------------------------------------------------------------------------------------------
// pcmod_laptop
// Laptop entity - all-in-one keyboard, monitor, pc
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "Laptop"
ENT.Class = "pcmod_laptop"

ENT.ItemModel = "models/pcmod/eeepc.mdl"

ENT.AlwaysOn = false

ENT.IsComputer = true

ENT.DefaultSetupData = {
	OS = "personal",
	BootCommand = "os:instance\nos:launch"
}

ENT.IsScreen = true

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup( setupdata )
	if ((!setupdata) || (setupdata == {})) then setupdata = self.DefaultSetupData end -- Ensure we have setup data
	local dt = self:Data() -- Get our data
	
	// Patch the use event to turnon and turnoff
	// self:AddEHook( "patch", "toggleon", "use" )
	self:AddEHook( "ent", nil, "user_input" )
	self:AddEHook( "ent", nil, "use" )
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "network" ) )
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
	
	disp.IsLaptop = true
	bios.IsLaptop = true
	
	self:SetGVar( "laptop", true )
	
	// Update us
	self:UpdateData( dt )
end

function ENT:CallEvent( data )
	if ((!data) || (!data.Event)) then return end
	if (data.Event == "use") then
		PCMod.Msg( "Laptop running 'use' event...", true )
		PCMod.Beam.LockCam( self:EntIndex(), data[1] )
		PCMod.Beam.LockKeyboard( data[1], self:EntIndex() )
	end
	if (data.Event == "user_input") then
		self:FireEvent( { "player_input", data[1], data[2] } )
	end
end

function ENT:DataRecieved( port, data )
	if (data[1] == "display") then
		PCMod.Msg( "Laptop hardware recieved display data!", true )
		local oldss = self:ScreenSpace()
		oldss.Data = data[2]
		self:UpdateScreenSpace( oldss )
		return
	end
	local prt = self:Ports()[ port ]
	if (!prt) then return end
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