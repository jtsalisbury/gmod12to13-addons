
// ---------------------------------------------------------------------------------------------------------
// sv_drivers.lua - Revision 1
// Server-Side
// Loads drivers
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------

PCMod.Drivers = {}
PCMod.Msg( "Loading all drivers...", true )



// ---------------------------------------------------------------------------------------------------------
// Add the base file
// ---------------------------------------------------------------------------------------------------------

DRV = {}
include( "pcmod/drivers/drv_base.lua" )
PCMod.Drivers[ "base" ] = table.Copy( DRV )

function PCMod.DeriveDriver( dname )
	local tmp = PCMod.Drivers[ dname ]
	if (!tmp) then tmp = {} end
	return table.Copy( tmp )
end


// ---------------------------------------------------------------------------------------------------------
// Loads all drivers
// ---------------------------------------------------------------------------------------------------------

function PCMod.LoadAllDrivers()
	// ---------------------------------------------------------------------------------------------------------
	// Get driver file list
	// ---------------------------------------------------------------------------------------------------------

	local files = file.Find( "pcmod/drivers/drv_*", "LUA")
	if ((!files) || (table.Count( files ) == 0)) then
		PCMod.Error( "No drivers to load!" )
		return
	end
	for k, v in pairs( files ) do
		PCMod.LoadDriver( v )
	end
end

// ---------------------------------------------------------------------------------------------------------
// Loads selected driver
// ---------------------------------------------------------------------------------------------------------

function PCMod.LoadDriver( driver )
	DRV = {}
	if (driver == "base") then
		include( "pcmod/drivers/drv_base.lua" )
		PCMod.Drivers[ "base" ] = table.Copy( DRV )
		return
	end
	DRV.Name = ""
	local fn = "pcmod/drivers/" .. driver
	DRV.FileName = fn
	
	include( fn )
	
	PCMod.Drivers[ DRV.Name ] = table.Copy( DRV )
	
	PCMod.Msg( "Loading driver '" .. DRV.Name .. "'", true )
end
PCMod.LoadAllDrivers()

concommand.Add( "pc_drv_reload", function( pl, com, args )
	if (!pl:IsAdmin()) then
		PCMod.Notice( "You are not an admin!", pl )
		return
	end
	PCMod.LoadDriver( args[1] )
end )
concommand.Add( "pc_drv_reloadall", function( pl, com, args )
	if (!pl:IsAdmin()) then
		PCMod.Notice( "You are not an admin!", pl )
		return
	end
	PCMod.LoadAllDrivers()
end )