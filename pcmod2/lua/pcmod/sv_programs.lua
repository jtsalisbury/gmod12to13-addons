
// ---------------------------------------------------------------------------------------------------------
// sv_programs.lua - Revision 1
// Server-Side
// Loads and controls tower programs
// ---------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------
// Define core tables
// ---------------------------------------------------------------------------------------------------------

PCMod.Progs = {}

PCMod.Msg( "Preparing to load all programs...", true )


// ---------------------------------------------------------------------------------------------------------
// Define the loading function
// ---------------------------------------------------------------------------------------------------------

function PCMod.Progs.Load( id )

	if (id == "base") then
		PROG = {}
		include( "pcmod/programs/base.lua" )
		PCMod.Progs[ "base" ] = table.Copy( PROG )
		PCMod.Msg( "Base program loaded!", true )
		return
	end
	local fn = "pcmod/programs/" .. id
	PROG = {}
	PROG = table.Copy( PCMod.Progs[ "base" ] )
	PROG.FileName = fn
	include( fn )
	PCMod.Progs[ PROG.Name ] = table.Copy( PROG )
	PCMod.Progs[ PROG.Name ]:Initialize()
	PCMod.Msg( "Program '" .. PROG.Name .. "' loaded!" )
end

concommand.Add( "pc_prog_reload", function( pl, com, args ) PCMod.Progs.Load( args[1] ); end )


// ---------------------------------------------------------------------------------------------------------
// Load the base program
// ---------------------------------------------------------------------------------------------------------

PROG = {}
PCMod.Progs.Load( "base" )


// ---------------------------------------------------------------------------------------------------------
// Load all other programs
// ---------------------------------------------------------------------------------------------------------

for _, v in pairs( file.Find( "pcmod/programs/pr_*", "LUA") ) do
	PROG = {}
	PCMod.Progs.Load( v )
end