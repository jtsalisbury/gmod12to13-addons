
// ---------------------------------------------------------------------------------------------------------
// sh_beam.lua - Revision 1
// Shared
// Controls beaming data from server to client
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------

PCMod.Beam = {}
PCMod.Beam.Version = "1.0"
PCMod.Beam.StrSegs = {}
PCMod.Beam.Hooks = {}

PCMod.Beam.Range_SS = 1024 -- Range to beam ScreenSpaces to

PCMod.PortData = {}

PCMod.EntData = {}

PCMod.Msg( "Beam Library Loaded (V" .. PCMod.Beam.Version .. ")", true )

if (SERVER) then
	util.AddNetworkString("pcmod_stringhook");

	// ---------------------------------------------------------------------------------------------------------
	// SendScreenSpace - Sends a screen space to the client
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.SendScreenSpace( ply, ent )
		PCMod.Msg( "Preparing to send SS...", true )
		
		// If the entity is not on, send an empty ss
		if (!ent:Data().IsOn) then
			PCMod.Beam.BeamTable( ply, "ssdata", {} )
		end
		
		// Get the SS data
		local ss = ent:ScreenSpace()
		if (!ss) then return end
		local dat = ss.Data
		
		// Ensure the player's beam data exists
		if (!ply.BeamData) then ply.BeamData = {} end
		if (!ply.BeamData[ ent:EntIndex() ]) then ply.BeamData[ ent:EntIndex() ] = {} end
		
		// Check the player's beam data for items that no longer exist
		local btbl = ply.BeamData[ ent:EntIndex() ]
		local newdat = {}
		for k, v in pairs( dat ) do
			if (type(v) == "table") then
				// For every device name and device in the screenspace;
				// k is the device name in the sspace, v is the actual device.
				// Check to see what version the player has
				// Cycle through player beam data for the right one
				// We're screwed if an entity needs multiple screenspaces - thomasfn
				local f = false
				for devname, rev in pairs( btbl ) do
					if (k == devname) then
						f = true -- We found the device, at least the player has recieved a version of this device
						-- Check the revisions
						if (rev != v.Rev) then
							-- Revision mismatch! Assume the server's version
							newdat[ k ] = v
							ply.BeamData[ ent:EntIndex() ][ devname ] = v.Rev
							PCMod.Msg( "Server has different revision! (" .. k .. ")", true )
						end
						break
					end
				end
				if (f == false) then
					// We have not found this device, insert it right in
					PCMod.Msg( "Server has new device! (" .. k .. ")", true )
					newdat[ k ] = v
					ply.BeamData[ ent:EntIndex() ][ k ] = v.Rev
				end
			else
				// We have a variable which isn't a table. Probably a 'sneaky' variable, let's send it anyway
				newdat[ k ] = v
			end
		end
		
		// Check if the player has a ss device that we don't
		for k, v in pairs( btbl ) do
			if (!table.HasKey( dat, k )) then
				// Tell the client the device no longer exists
				newdat[ k ] = 0
				ply.BeamData[ ent:EntIndex() ][ k ] = nil
			end
		end
		
		// Send the data
		newdat.EntID = ent:EntIndex()
		PCMod.Beam.BeamTable( ply, "ssdata_update", newdat )
	end

	// ---------------------------------------------------------------------------------------------------------
	// BeamTable - Sends a table to the client
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.BeamTable( ply, tag, tbl )
		if (type(tbl) != "table") then
			PCMod.Warning( "BeamTable recieved a non-table value!" )
			return
		end
		PCMod.Beam.BeamString( ply, tag, PCMod.TableToString( tbl ) )
	end

	// ---------------------------------------------------------------------------------------------------------
	// BeamString - Sends a string to the client (larger than 255 bytes)
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.BeamString( ply, tag, str )
		/*local rs = 230 - string.len( tag )
		local chunks = PCMod.SplitString( str, rs )
		umsg.Start( "pcmod_stringstart", ply )
			umsg.String( tag )
			umsg.Short( #chunks )
			umsg.String( chunks[1] )
		umsg.End()
		local i = 0
		if (#chunks < 2) then return end
		for i = 2, #chunks do
			umsg.Start( "pcmod_stringseg", ply )
				umsg.String( tag )
				umsg.Short( i )
				umsg.String( chunks[ i ] )
			umsg.End()
		end*/
		
		net.Start("pcmod_stringhook")
			net.WriteString(str);
			net.WriteString(tag);
		net.Send(ply)
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// BeamEntSS - Beam a screen space of an entity to all players in range
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.BeamEntSS( ent, range )
		if ((!ent) || (!ent:IsValid())) then return end
		for _, v in pairs( player.GetAll() ) do
			if (!v.SSBeam) then v.SSBeam = {} end
			if (!v.SSBeam[ ent:EntIndex() ]) then
				if ((v:GetPos()-ent:GetPos()):Length()<range) then
					PCMod.Beam.SendScreenSpace( v, ent )
				end
				v.SSBeam[ ent:EntIndex() ] = true
			end
		end
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// SetEntData - Sets a networked piece of ent data
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.SetEntData( id, key, val )
		if (!PCMod.EntData[ id ]) then PCMod.EntData[ id ] = {} end
		PCMod.EntData[ id ].ID = id
		PCMod.Msg( "Setting ent data (" .. key .. " = " .. tostring( val ) .. ")", true )
		if (PCMod.EntData[ id ][ key ] == val) then return end
		PCMod.EntData[ id ][ key ] = val
		PCMod.Msg( "Beaming ent data...", true )
		PCMod.Beam.BeamTable( nil, "entdata", PCMod.EntData[ id ] )
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// ClearEntData - Clears the entity data table
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.ClearEntData( id )
		PCMod.Msg( "Resetting ent data (" .. id .. ")!", true )
		PCMod.EntData[ id ] = {}
		PCMod.EntData[ id ].ID = id
		PCMod.Beam.BeamTable( nil, "entdata", PCMod.EntData[ id ] )
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// SendFullEntData - Sends the full entdata table to the client
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.SendFullEntData( ply )
		PCMod.beam.BeamTable( ply, "fullentdata", PCMod.EntData )
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// FirstSpawn - Called when a player spawns for the first time
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.FirstSpawn( ply )
		timer.Simple( 1, function( ply )
			PCMod.Beam.SendFullEntData( ply )
		end)
	end
	hook.Add( "PlayerInitialSpawn", PCMod.Beam.FirstSpawn )
	
	// ---------------------------------------------------------------------------------------------------------
	// HD_Struct - Returns a HD structure
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.HD_Struct( ent )
		if ((!ent) || (!ent:IsValid()) || (!ent.IsPCMod)) then return {} end
		local hd = PCMod.Data[ ent:EntIndex() ].HardDrive
		if (!hd) then return {} end
		local tmp = {}
		for dir, item in pairs( hd ) do
			local dt = string.Explode( "/", dir )
			table.remove( dt, 1 )
		end
		return tmp
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// FileList - Lists all files inside a certain directory
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.FileList( ent, path )
		if ((!ent) || (!ent:IsValid()) || (!ent.IsPCMod)) then return {} end
		local hd = PCMod.Data[ ent:EntIndex() ].HardDrive
		if (!hd) then return {} end
		local tmp = {}
		path = "/" .. path
		PCMod.Msg( "Preparing to check vs '" .. path .. "'...", true )
		for dir, item in pairs( hd ) do
			if (item.ItemType == "file") then
				PCMod.Msg( "Checking file '" .. dir .. "'...", true )
				if (string.lower( string.sub( dir, 1, string.len( path ) ) ) == string.lower( path )) then
					PCMod.Msg( "Path match found!", true )
					// First bit matches, now check it doesn't go on
					local rt = string.sub( dir, string.len( path )+1, string.len( dir ) )
					if (!string.find( rt, "/" )) then
						// This looks like a file! Add it
						table.insert( tmp, rt )
						PCMod.Msg( "Full match found!", true )
					end
				end
			end
		end
		return tmp
	end
end

if (CLIENT) then

	// ---------------------------------------------------------------------------------------------------------
	// StringStart - The server has started to send us a long string
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.StringStart( um )
		local tag = um:ReadString()
		local chunks = um:ReadShort()
		local ca = um:ReadString()
		if (chunks == 1) then
			PCMod.Msg( "Small string recieved! (" .. tag .. ")", true )
			PCMod.Beam.CallHook( tag, ca )
		end
		local sdata = {}
		sdata.Tag = tag
		sdata.SegCnt = chunks
		sdata.SegsR = 1
		sdata.Segs = { ca }
		PCMod.Beam.StrSegs[ tag ] = table.Copy( sdata )
		PCMod.Msg( "String beam started! (" .. tag .. ")", true )
		
	end
	usermessage.Hook( "pcmod_stringstart", PCMod.StringStart )
	
	// ---------------------------------------------------------------------------------------------------------
	// StringSegment - The server has sent us a segment of a long string
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.StringSegment( um )
		local tag = um:ReadString()
		local cid = um:ReadShort()
		local seg = um:ReadString()
		if (!PCMod.Beam.StrSegs[ tag ]) then return end
		PCMod.Beam.StrSegs[ tag ].SegsR = PCMod.Beam.StrSegs[ tag ].SegsR + 1
		PCMod.Beam.StrSegs[ tag ].Segs[ cid ] = seg
		PCMod.Msg( "String segment recieved! (" .. tag .. ")", true )
		if (PCMod.Beam.StrSegs[ tag ].SegsR == PCMod.Beam.StrSegs[ tag ].SegCnt) then
			local str = table.concat( PCMod.Beam.StrSegs[ tag ].Segs, "" )
			PCMod.Msg( "String fully recieved! (" .. tag .. ")", true )
			PCMod.Beam.CallHook( tag, str )
		end
		
	end
	usermessage.Hook( "pcmod_stringseg", PCMod.StringSegment )
	
	net.Receive("pcmod_stringhook", function(len, client)
		local str = net.ReadString();
		local tag =	net.ReadString();
		PCMod.Beam.CallHook(tag, str);
	end)
	
	// ---------------------------------------------------------------------------------------------------------
	// CallHook - Calls the hook when a string has been fully recieved
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.CallHook( tag, str )
		local cnt = 0
		for _, v in pairs( PCMod.Beam.Hooks ) do
			if (v[1] == tag) then
				v[2]( str )
				cnt = cnt + 1
			end
		end
		if (cnt == 0) then PCMod.Warning( "Unhandled big string! (" .. tag .. ")" ) end
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// Hook - Adds a hook to call when a string has been fully recieved
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.Hook( tag, callback )
		table.insert( PCMod.Beam.Hooks, { tag, callback } )
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// NewScreenSpace - Records the full screenspace of a entity that we just recieved from server
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.NewScreenSpace( str )
		if (!str) then return end
		local ss = PCMod.StringToTable( str )
		if (!ss) then return end
		local entid = ss.EntID
		ss.EntID = nil
		if (!entid) then
			PCMod.Msg( "Invalid ScreenSpace recieved! STT must have failed.", true )
			return
		end
		PCMod.SDraw.NewScreenSpace( entid, table.Copy( ss ) )
		PCMod.Msg( "New ScreenSpace Recieved! (" .. str .. ")", true )
	end
	PCMod.Beam.Hook( "ssdata", PCMod.Beam.NewScreenSpace )
	
	// ---------------------------------------------------------------------------------------------------------
	// UpdateScreenSpace - Records the partial screenspace of a entity that we just recieved from server
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.UpdateScreenSpace( str )
		if (!str) then return end
		local ss = PCMod.StringToTable( str )
		if (!ss) then return end
		local entid = ss.EntID
		ss.EntID = nil
		if (!entid) then
			PCMod.Msg( "Invalid ScreenSpace recieved! STT must have failed.", true )
			return
		end
		PCMod.SDraw.UpdateScreenSpace( entid, table.Copy( ss ) )
		PCMod.Msg( "Partial ScreenSpace Recieved! (" .. str .. ")", true )
	end
	PCMod.Beam.Hook( "ssdata_update", PCMod.Beam.UpdateScreenSpace )
	
	// ---------------------------------------------------------------------------------------------------------
	// UpdateEntData - Records a piece of EntData
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.UpdateEntData( str )
		if (!str) then return end
		local dat = PCMod.StringToTable( str )
		if (!dat) then return end
		local entid = dat.ID
		if (!entid) then
			PCMod.Msg( "Invalid EntData recieved! STT must have failed.", true )
			return
		end
		PCMod.EntData[ entid ] = dat
	end
	PCMod.Beam.Hook( "entdata", PCMod.Beam.UpdateEntData )
	
	// ---------------------------------------------------------------------------------------------------------
	// FullUpdateEntData - Records all of EntData
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.FullUpdateEntData( str )
		if (!str) then return end
		local dat = PCMod.StringToTable( str )
		if (!dat) then
			PCMod.Msg( "Invalid FullEntData recieved! STT must have failed.", true )
			return
		end
		table.Merge( PCMod.EntData, dat )
	end
	PCMod.Beam.Hook( "fullentdata", PCMod.Beam.FullUpdateEntData )
	
	// ---------------------------------------------------------------------------------------------------------
	// GetEntData - Gets a networked piece of ent data
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Beam.GetEntData( id, key )
		if (!PCMod.EntData[ id ]) then PCMod.EntData[ id ] = {} end
		return PCMod.EntData[ id ][ key ]
	end

end

// ---------------------------------------------------------------------------------------------------------
// LockCam - Tells a client to lock the cam on an object
// ---------------------------------------------------------------------------------------------------------
function PCMod.Beam.LockCam( entid, ply )
	if (SERVER) then
		if ((!ply) || (!ply:IsValid()) || (!ply:IsPlayer())) then return end
		umsg.Start( "pcmod_lockcam", ply ); umsg.Long( entid ); umsg.End()
		return
	end
	if (CLIENT) then
		if (ply != LocalPlayer()) then return end
		
		PCMod.Gui.CamLocked = true
		PCMod.Gui.CamLockID = entid
		
		gui.EnableScreenClicker( true )
		LocalPlayer():Freeze( true )
		
		PCMod.Gui.EnableHackyClicky( true )
		PCMod.Gui.ShowLockFrame( true )
		PCMod.SDraw.DevFocus = ""
		
		PCMod.Cam.Trigger( "lock", entid )
	end
end
if (CLIENT) then
	usermessage.Hook( "pcmod_lockcam", function( um )
		PCMod.Beam.LockCam( um:ReadLong(), LocalPlayer() )
	end )
end

// ---------------------------------------------------------------------------------------------------------
// UnlockCam - Tells a client to unlock the cam
// ---------------------------------------------------------------------------------------------------------
function PCMod.Beam.UnlockCam( ply )
	if (SERVER) then
		if ((!ply) || (!ply:IsValid()) || (!ply:IsPlayer())) then return end
		umsg.Start( "pcmod_unlockcam", ply ); umsg.End()
		return
	end
	if (CLIENT) then
		if (ply != LocalPlayer()) then return end
		
		PCMod.Gui.CamLocked = false
		PCMod.Gui.CamLockID = 0
		
		gui.EnableScreenClicker( false )
		LocalPlayer():Freeze( false )
		
		PCMod.Gui.ShowLockFrame( false )
		PCMod.Beam.UnlockKeyboard( LocalPlayer() )
		PCMod.Gui.EnableHackyClicky( false )
		PCMod.SDraw.DevFocus = ""
		
		PCMod.Cam.Trigger( "unlock" )
	end
end
if (CLIENT) then
	usermessage.Hook( "pcmod_unlockcam", function( um )
		PCMod.Beam.UnlockCam( LocalPlayer() )
	end )
end

// ---------------------------------------------------------------------------------------------------------
// LockKeyboard - Tells a client to lock to keyboard
// ---------------------------------------------------------------------------------------------------------
function PCMod.Beam.LockKeyboard( ply, entid )
	if (!entid) then entid = 0 end
	if (SERVER) then
		if ((!ply) || (!ply:IsValid()) || (!ply:IsPlayer())) then return end
		umsg.Start( "pcmod_lockkeyboard", ply ); umsg.Long( entid ); umsg.End()
		return
	end
	if (CLIENT) then
		PCMod.SDraw.DrawKeyboard = true
		PCMod.SDraw.KeyboardEntID = entid
		PCMod.EnableCapture( true )
		if (PCMod.Gui.KeyBoard) then
			PCMod.Gui.KeyBoard:SetVisible( true )
		else
			PCMod.Msg( "No keyboard derma panel!", true )
		end
	end
end
if (CLIENT) then
	usermessage.Hook( "pcmod_lockkeyboard", function( um )
		PCMod.Beam.LockKeyboard( nil, um:ReadLong() )
	end )
end

// ---------------------------------------------------------------------------------------------------------
// UnlockKeyboard - Tells a client to unlock the keyboard
// ---------------------------------------------------------------------------------------------------------
function PCMod.Beam.UnlockKeyboard( ply )
	if (SERVER) then
		if ((!ply) || (!ply:IsValid()) || (!ply:IsPlayer())) then return end
		umsg.Start( "pcmod_unlockkeyboard", ply ); umsg.End()
		return
	end
	if (CLIENT) then
		PCMod.SDraw.DrawKeyboard = false
		PCMod.SDraw.KeyboardEntID = 0
		PCMod.EnableCapture( false )
		if (PCMod.Gui.KeyBoard) then
			PCMod.Gui.KeyBoard:SetVisible( false )
		else
			PCMod.Msg( "No keyboard derma panel!", true )
		end
	end
end
if (CLIENT) then
	usermessage.Hook( "pcmod_unlockkeyboard", function()
		PCMod.Beam.UnlockKeyboard()
	end )
end

if (SERVER) then
	
	// ---------------------------------------------------------------------------------------------------------
	// BeamPorts - Beams an entity's ports to the client
	// ---------------------------------------------------------------------------------------------------------
	function PC_BeamPorts( ent, ply )
		// Validate entity
		if ((!ent) || (!ent:IsValid()) || (!ent.IsPCMod)) then return end
		if ((!ply) || (!ply:IsValid()) || (!ply:IsPlayer())) then return end
		
		// Get the ports
		local ports = ent:Ports()
		
		PCMod.Msg( "Sending port data...", true )
		
		// Compile a table to send
		local tmp = {}
		tmp.EntID = ent:EntIndex()
		local cnt
		for cnt=1, #ports do
			table.insert( tmp, { ports[ cnt ].Type, ports[ cnt ].Connected } )
		end
		local str = PCMod.TableToString( tmp )
		PrintTable(tmp);
		
		// Send the table
		PCMod.Beam.BeamString( ply, "portdata", str )
	end
	
	// ---------------------------------------------------------------------------------------------------------
	// PortSelected - Pushes a selected port through to the toolgun
	// ---------------------------------------------------------------------------------------------------------
	function PC_PortSelected( pl, com, args )
		local tool = pl:GetActiveWeapon()
		
		if ((!tool) || (!tool:IsValid())) then return end
		
		if (tool:GetClass() == "gmod_tool") then
		
			local obj = tool:GetTable():GetToolObject()
			
			PCMod.Msg( "(TOOLGUN) Selecting port " .. args[2] .. " on entity " .. args[1], true )
			
			if (obj) then
				obj:SelectPort( tonumber( args[1] ), tonumber( args[2] ) )
			end
			
			return
		end
		
		if ((tool:GetClass() == "pcmod_wireswep") || (tool:GetClass() == "pcmod_unwireswep")) then
		
			local obj = tool:GetTable().ToolMode
			
			PCMod.Msg( "(SWEP) Selecting port " .. args[2] .. " on entity " .. args[1], true )
			
			if (obj) then
				obj:SelectPort( tonumber( args[1] ), tonumber( args[2] ) )
			end
			
			return
		end
		
		PCMod.Msg( "Invalid weapon! (pc_selport)", true )
	end
	concommand.Add( "pc_selport", PC_PortSelected )
	
	// ---------------------------------------------------------------------------------------------------------
	// AskForPort - Sends a port request to the client
	// ---------------------------------------------------------------------------------------------------------
	function PC_AskForPort( ply, entid, porttype, unwire )
		if (!porttype) then porttype = "" end
		if (!unwire) then unwire = false end
		umsg.Start( "pcmod_askport", ply )
			umsg.Long( entid )
			umsg.String( porttype )
			umsg.Bool( unwire )
		umsg.End()
	end
	
end


if (CLIENT) then

	// ---------------------------------------------------------------------------------------------------------
	// PortsRecieved - Reads the ports into an entity
	// ---------------------------------------------------------------------------------------------------------
	function PC_PortsRecieved( str )
		print(str);
		local tbl = PCMod.StringToTable( str )
		PCMod.Msg( str, true )
		local entid = tbl.EntID
		tbl.EntID = nil
		local tmp = {}
		PCMod.Msg( "Ports recieved! (" .. tostring( #tbl ) .. ")", true )
		local cnt
		for k, v in pairs( tbl ) do
			
			tmp[ tonumber( k ) ] = { Type=v[1], Connected=v[2] }
		end
		PCMod.PortData[ entid ] = tmp
		
	end
	PCMod.Beam.Hook( "portdata", PC_PortsRecieved )
	
	// ---------------------------------------------------------------------------------------------------------
	// PortAskedFor - Forwards the request to the Gui library
	// ---------------------------------------------------------------------------------------------------------
	function PC_PortAskedFor( um )
		local entid = um:ReadLong()
		local porttype = um:ReadString()
		local unwire = um:ReadBool()
		if ((porttype == "NA") || (porttype == "")) then porttype = nil end
		PCMod.Gui.AskForPort( entid, porttype, (!!unwire) ) -- !!unwire means convert to evaluated state
	end
	usermessage.Hook( "pcmod_askport", PC_PortAskedFor )

end