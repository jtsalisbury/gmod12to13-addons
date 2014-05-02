
// ---------------------------------------------------------------------------------------------------------
// sv_data.lua - Revision 1
// Server-Side
// Controls player data on the server
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define core tables
// ---------------------------------------------------------------------------------------------------------

PCMod.PLD = {}
PCMod.PLD.Version = "1.0"

PCMod.Msg( "Player Data library loaded! (V" .. PCMod.PLD.Version .. ")", true )

PCMod.PLD.PlyPath = PCMod.Cfg.DataFolderRoot .. PCMod.Cfg.PlayerPath


// ---------------------------------------------------------------------------------------------------------
// LoadPlyData - Loads player data from file
// ---------------------------------------------------------------------------------------------------------
function PCMod.PLD.LoadPlyData( ply )
	if (ply.PCData) then
		PCMod.Msg( "Player data already present!", true )
		return
	end
	local id = string.Replace( ply:SteamID(), ":", "" )
	local fn = PCMod.PLD.PlyPath .. id .. ".txt"
	if (!file.Exists( fn, "DATA")) then
		// We have no data file!
		PCMod.Msg( "No data file for " .. ply:Nick() .. "!", true )
		ply.PCData = {}
		PCMod.PLD.SavePlyData( ply )
		return
	end
	local str = file.Read( fn )
	if ((!str) || (str == "")) then
		// File is corrupt!
		PCMod.Msg( "Data file corrupt for " .. ply:Nick() .. "!", true )
		file.Delete( fn )
		ply.PCData = {}
		PCMod.PLD.SavePlyData( ply )
		return
	end
	local tbl = PCMod.StringToTable( str )
	if (!tbl) then
		// File is corrupt!
		PCMod.Msg( "Data file corrupt for " .. ply:Nick() .. "!", true )
		file.Delete( fn )
		ply.PCData = {}
		PCMod.PLD.SavePlyData( ply )
		return
	end
	ply.PCData = tbl
	PCMod.Msg( "Data file loaded! (" .. ply:Nick() .. ")", true )
end

// ---------------------------------------------------------------------------------------------------------
// SavePlyData - Saves player data to file
// ---------------------------------------------------------------------------------------------------------
function PCMod.PLD.SavePlyData( ply )
	local id = string.Replace( ply:SteamID(), ":", "" )
	local fn = PCMod.PLD.PlyPath .. id .. ".txt"
	if (!ply.PCData) then
		PCMod.Msg( "Nothing to save! (" .. ply:Nick() .. ")", true )
		return
	end
	local str = PCMod.TableToString( ply.PCData )
	file.Write( fn, str )
	PCMod.Msg( "Data file saved! (" .. ply:Nick() .. ")", true )
end

// ---------------------------------------------------------------------------------------------------------
// GetPlyData - Gets the player data for a player
// ---------------------------------------------------------------------------------------------------------
function PCMod.PLD.GetPlyData( ply )
	if (!ply.PCData) then PCMod.PLD.LoadPlyData( ply ) end
	return ply.PCData
end

// ---------------------------------------------------------------------------------------------------------
// SetPlyData - Sets the player data for a player and saves it
// ---------------------------------------------------------------------------------------------------------
function PCMod.PLD.SetPlyData( ply, data )
	ply.PCData = data
	PCMod.PLD.SavePlyData( ply )
end