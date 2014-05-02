
// ---------------------------------------------------------------------------------------------------------
// cl_core.lua - Revision 1
// Client-Side
// Loads PCMod on the client
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define core tables
// ---------------------------------------------------------------------------------------------------------

if (!PCMod_NoInclude) then PCMod = {} end -- Main table
PCMod.Exists = true -- Internal checking
PCMod.Version = "2.0.4" -- 'Nice' version
PCMod.IntVer = "Release" -- Internal version
PCMod.IsPCMod2 = true


// ---------------------------------------------------------------------------------------------------------
// Load configuration, and common functions
// ---------------------------------------------------------------------------------------------------------

if (!PCMod_NoInclude) then

	PCMod.Cfg = {} -- Define config table

	include( "pcmod/sh_baseconfig.lua" ) -- Configuration file
	include( "pcmod/sh_common.lua" ) -- Common functions
	include( "pcmod/sh_logging.lua" ) -- Logging functions
	include( "pcmod/sh_plugins.lua" ) -- Plugins file

	PCMod.Msg( "PCMod Version " .. PCMod.Version .. " Installed" )
	PCMod.Msg( "Loading PCMod Core..." )

	include( "pcmod/sh_beam.lua" ) -- Beaming control file
	include( "pcmod/sh_resources.lua" ) -- Resources file
	include( "pcmod/sh_settings.lua" ) -- Settings file


	// ---------------------------------------------------------------------------------------------------------
	// Load main core files
	// ---------------------------------------------------------------------------------------------------------

	include( "pcmod/cl_gui.lua" ) -- Drawing control file
	include( "pcmod/cl_2d3d.lua" ) -- 2D 3D drawing file
	include( "pcmod/cl_rp.lua" ) -- RolePlay control file
	include( "pcmod/cl_camera.lua" ) -- Camera control file
	include( "pcmod/cl_keyboard.lua" ) -- Keyboard control file
	include( "pcmod/cl_sselements.lua" ) -- ScreenSpace elements control file

end


// ---------------------------------------------------------------------------------------------------------
// Remove bad hooks
// ---------------------------------------------------------------------------------------------------------

timer.Create( "PCMod_DestroyHooks", 5, 1, function()
	if (!PCMod.Cfg.BadHooks) then return end
	for k, v in pairs( PCMod.Cfg.BadHooks ) do
		hook.Remove( v[1], v[2] )
	end
end )


// ---------------------------------------------------------------------------------------------------------
// Define some helpful debug commands
// ---------------------------------------------------------------------------------------------------------

function PCMod.DumpDirectory( pl, com, args )
	local dir = args[1]
	if (!dir) then return end
	local incsub = args[2]
	if (!incsub) then incsub = 0 end
	incsub = (incsub == "1")
	PCMod.Msg( "About to dump " .. dir .. "... (" .. tostring( incsub ) .. ")" )
	local dir = PCMod.ListDir( "../" .. dir, incsub )
	file.Write( PCMod.Cfg.DataFolderRoot .. PCMod.Cfg.DumpPath .. "dir_dump.txt", table.concat( dir, "\n" ) )
end
concommand.Add( "pc_dumpdir", PCMod.DumpDirectory )

function PCMod.ListDir( dir, incsub )
	PCMod.Msg( "ListDir: " .. dir )
	local res = file.Find( dir .. "*" )
	for k, v in pairs( table.Copy( res ) ) do
		if (v) then
			if ((v == "..") || (v == ".")) then	
				table.remove( res, k )
			else
				if (!table.HasValue( string.Explode( "", v ), ".")) then
					PCMod.Msg( "Extra Dir Found! (" .. v .. ")" )
					table.remove( res, k )
					if (incsub) then table.Add( res, PCMod.ListDir( dir .. v .. "/" ) ) end
				end
			end
		end
	end
	for k, v in pairs( table.Copy( res ) ) do
		res[ k ] = dir .. v
	end
	return res
end


// ---------------------------------------------------------------------------------------------------------
// Call the post_load plugin hook
// ---------------------------------------------------------------------------------------------------------
PCMod.CallHook( "post_load" )