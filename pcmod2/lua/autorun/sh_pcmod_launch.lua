
// ---------------------------------------------------------------------------------------------------------
// sh_pcmod_launch.lua - Revision 1
// Shared
// Runs the core PCMod files
// ---------------------------------------------------------------------------------------------------------

function PCMod_ResetOld( hookid )
	PCMod = nil
	local hktbl = table.Copy( hook.GetTable() )
	for name, tbl in pairs( hktbl ) do
		for uniquename, func in pairs( tbl ) do
			if (string.Left( uniquename, string.len( hookid ) ) == hookid) then
				hook.Remove( name, uniquename )
				Msg( "PCMod2: Removed old hook '" .. uniquename .. "'\n" )
			end
		end
	end
end

// Check if PCMod is already installed
if (PCMod) then

	Error( "PCMod2: PCMod libraries already exist!\n" )
	Error( "PCMod2: Attempting to reset...\n" )
	
	PCMod_ResetOld( "PCMod_" )

end

if (SERVER) then

	AddCSLuaFile( "autorun/sh_pcmod_launch.lua" ) -- Add this file

	include( "pcmod/sv_core.lua" ) -- Include the core serverside PCMod file

end

if (CLIENT) then

	// Define kick-start functions
	function PCMod_KickStart()
		PCMod_ResetOld( "PCMod_" )
		PCMod_ResetOld( "PCMod." )
		Msg( "==> About to KickStart PCMod! <==\n" )
		include( "autorun/sh_pcmod_launch.lua" )
		PCMod_Init( "PCMod." )
	end
	function PCMod_IsValid()
		return ((PCMod) && (PCMod.IsPCMod2))
	end
	function PCMod_Init( hookid )
		for uniquename, func in pairs( hook.GetTable().Initialize ) do
			if (string.Left( uniquename, string.len( hookid ) ) == hookid) then
				func()
				Msg( "PCMod2: Called init hook '" .. uniquename .. "'\n" )
			end
		end
	end
	concommand.Add( "pc_kickstart", PCMod_KickStart )

	include( "pcmod/cl_core.lua" ) -- Include the core clientside PCMod file

end