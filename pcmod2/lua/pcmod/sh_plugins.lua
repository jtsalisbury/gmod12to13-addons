
// ---------------------------------------------------------------------------------------------------------
// sh_plugins.lua - Revision 1
// Shared
// Loads plugin functionality
// ---------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------
// Define core tables
// ---------------------------------------------------------------------------------------------------------

PCMod.Plugins = {}


// ---------------------------------------------------------------------------------------------------------
// RegisterPlugin - Adds a plugin to the master table
// ---------------------------------------------------------------------------------------------------------
function PCMod.RegisterPlugin( id, tbl )
	if (!id) then return end
	if (!tbl) then return end
	PCMod.Plugins[ id ] = table.Copy( tbl )
	PCMod.Msg( "Loaded plugin '" .. id .. "'!" )
end

// ---------------------------------------------------------------------------------------------------------
// CallHook - Calls a hook on all plugins until something is returned
// ---------------------------------------------------------------------------------------------------------
function PCMod.CallHook( hookname, ... )
	for plugin, _ in pairs( PCMod.Plugins ) do
		//local result = PCMod.Plugins[ plugin ]:Hook( hookname, ... )
		//if (result) then return result end
	end
end


// ---------------------------------------------------------------------------------------------------------
// Load all plugins
// ---------------------------------------------------------------------------------------------------------

for _, v in pairs( file.Find( "pcmod/plugins/*.lua", "LUA") ) do
	PLUGIN = {}
	local fn = "pcmod/plugins/" .. v
	PLUGIN.FileName = fn
	PLUGIN.Name = "base"
	if (SERVER) then AddCSLuaFile( fn ) end
	include( fn )
	PCMod.RegisterPlugin( PLUGIN.Name, PLUGIN )
end
PCMod.CallHook( "pre_load" )


// ---------------------------------------------------------------------------------------------------------
// Setup the timed delay
// ---------------------------------------------------------------------------------------------------------
timer.Create( "PCMod_TimedDelay", 5, 1, function()
	PCMod.CallHook( "timed_delay" )
end )