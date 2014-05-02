
// ---------------------------------------------------------------------------------------------------------
// sh_common.lua - Revision 1
// Shared
// Loads basic shared common functions
// ---------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------
// Require the modules we need
// ---------------------------------------------------------------------------------------------------------

//require( "datastream" )


// ---------------------------------------------------------------------------------------------------------
// Add some common files not added by sv_core
// ---------------------------------------------------------------------------------------------------------

//if (SERVER) then AddCSLuaFile( "pcmod/sh_json.lua" ) end
//include( "sh_json.lua" )

PCMod.GM = GM or GAMEMODE

PCMod.MsgDebugBuffer = {}
PCMod.MsgBuffer = {}
PCMod.WarningBuffer = {}
PCMod.ErrorBuffer = {}
PCMod.BufferI = { 1, 1, 1, 1 }

// ---------------------------------------------------------------------------------------------------------
// Msg - Prints a PCMod message to console
// ---------------------------------------------------------------------------------------------------------
function PCMod.Msg( msgtext, isdebug )
	if ((isdebug == true) && (PCMod.Cfg.DebugMode == false)) then return end
	if (isdebug == true) then
		table.insert(PCMod.MsgDebugBuffer, { PCMod.BufferI[1], msgtext })
		PCMod.BufferI[1] = PCMod.BufferI[1] + 1
	else
		table.insert(PCMod.MsgBuffer, { PCMod.BufferI[2], msgtext })
		PCMod.BufferI[2] = PCMod.BufferI[2] + 1
	end
	Msg( "PCMod2: " )
	Msg( msgtext )
	Msg( "\n" )
end

// ---------------------------------------------------------------------------------------------------------
// Warning - Prints a PCMod warning to console
// ---------------------------------------------------------------------------------------------------------
function PCMod.Warning( msgtext )
	table.insert(PCMod.WarningBuffer, { PCMod.BufferI[3], msgtext })
	PCMod.BufferI[3] = PCMod.BufferI[3] + 1
	ErrorNoHalt( "PCMod2: " .. msgtext .. "\n" )
end

// ---------------------------------------------------------------------------------------------------------
// Error - Prints a PCMod error to console
// ---------------------------------------------------------------------------------------------------------
function PCMod.Error( msgtext )
	table.insert(PCMod.ErrorBuffer, { PCMod.BufferI[4], msgtext })
	PCMod.BufferI[4] = PCMod.BufferI[4] + 1
	Error( "PCMod2: " .. msgtext .. "\n" )
end

// ---------------------------------------------------------------------------------------------------------
// Notice - Prints a sandbox notice
// ---------------------------------------------------------------------------------------------------------
function PCMod.Notice( msgtext, ply )
	if (CLIENT) then
		PCMod.Msg( msgtext )
		GAMEMODE:AddNotify( msgtext, NOTIFY_GENERIC, 5 )
	end
	if (SERVER) then
		if (ply && ply:IsValid()) then
			umsg.Start( "pcmod_notice", ply )
				umsg.String( msgtext )
			umsg.End()
		end
	end
end
if (CLIENT) then usermessage.Hook( "pcmod_notice", function( um ) PCMod.Notice( um:ReadString() ) end ) end

// ---------------------------------------------------------------------------------------------------------
// GMsg - Prints a message to all players
// ---------------------------------------------------------------------------------------------------------
function PCMod.GMsg( msgtext )
	if (CLIENT) then return end
	PrintMessage( HUD_PRINTTALK, msgtext )
end

// ---------------------------------------------------------------------------------------------------------
// TableToString - Converts a table into a string
// ---------------------------------------------------------------------------------------------------------
function PCMod.TableToString( tbl )
	if (PCMod.Cfg.UseJson) then
		 local result = util.TableToJSON( tbl )
		 return result
	end
	local str = "{"
	local allnum = table.AllNumerical( tbl )
	if (allnum) then
		local cnt
		for i=1, table.maxn( tbl ) do
			local v = tbl[ i ]
			if (v) then
				local val = ""
				if (type( v ) == "string") then val = "\"" .. v .. "\"" end
				if (type( v ) == "boolean") then val = tostring(v) end
				if (type( v ) == "number") then val = tostring(v) end
				if (type( v ) == "table") then val = PCMod.TableToString( v ) end
				str = str .. val .. ","
			end
		end
	else
		for k, v in pairs( tbl ) do
			local val = ""
			local key = ""
			if (type( v ) == "string") then val = "\"" .. PCMod.CleanString( v ) .. "\"" end
			if (type( v ) == "boolean") then val = tostring(v) end
			if (type( v ) == "number") then val = tostring(v) end
			if (type( v ) == "table") then val = PCMod.TableToString( v ) end
			if (type( k ) == "string") then key = "[\"" .. k .. "\"]" end
			if (type( k ) == "number") then key = "[" .. tostring(k) .. "]" end
			str = str .. key .. "=" .. val .. ","
		end
	end
	str = string.Replace( str, "\n", "#>" )
	local fstr = str .. "}"
	// PCMod.Msg( "Final Conversion: " .. fstr, true )
	return fstr
end

// ---------------------------------------------------------------------------------------------------------
// BTN - Converts a bool to number
// ---------------------------------------------------------------------------------------------------------
function PCMod.BTN( bool )
	if (bool) then return 1 else return 0 end
end

// ---------------------------------------------------------------------------------------------------------
// CleanString - Cleans a string, ready to be added into a RunString command
// ---------------------------------------------------------------------------------------------------------
function PCMod.CleanString( str )
	str = string.Replace( str, "\n", "#>" )
	str = string.Replace( str, "\"", "#@" )
	return str
end

// ---------------------------------------------------------------------------------------------------------
// RestoreString - Restores a cleaned string
// ---------------------------------------------------------------------------------------------------------
function PCMod.RestoreString( str )
	str = string.Replace( str, "#>", "\n" )
	str = string.Replace( str, "#@", "\"" )
	return str
end

// ---------------------------------------------------------------------------------------------------------
// StringToTable - Converts a string back into a table
// ---------------------------------------------------------------------------------------------------------
function PCMod.StringToTable( str )
	if (type( str ) != "string") then
		PCMod.Msg( "Tried to convert non-string value to table!", true )
		return {}
	end
	if (PCMod.Cfg.UseJson) then
		local result = util.JSONToTable( str )
		return result
	end
	PCMod.STTResult = {}
	str = string.Replace( str, "\\", "" )
	// PCMod.Msg( "Table Conversation: " .. str, true )
	RunString( "PCMod.STTResult = " .. str .. ";" )
	local res = PCMod.RestoreTable( PCMod.STTResult )
	PCMod.STTResult = nil
	return res
end

// ---------------------------------------------------------------------------------------------------------
// RestoreTable - Restores all strings in a table, and subtables, back to proper state
// ---------------------------------------------------------------------------------------------------------
function PCMod.RestoreTable( tbl )
	local tmp = table.Copy( tbl )
	for k, v in pairs( tbl ) do
		local t = type( v )
		if (t == "table") then
			tmp[ k ] = PCMod.RestoreTable( v )
		end
		if (t == "string") then
			tmp[ k ] = PCMod.RestoreString( v )
		end
	end
	return tmp
end

// ---------------------------------------------------------------------------------------------------------
// IsIP - Returns true if the string represents an IP address
// ---------------------------------------------------------------------------------------------------------
function string.IsIP( str )
	local c = string.Count( str, "." )
	if (c != 3) then return false end
	local es = string.Explode( ".", str )
	if (#es != 4) then return false end
	local cnt
	for cnt=1, 4 do
		local v = tonumber( es[ cnt ] )
		if ((v < 0) || (v > 255)) then return false end
	end
	return true
end

// ---------------------------------------------------------------------------------------------------------
// Count - Returns a count of total characters found in a string
// ---------------------------------------------------------------------------------------------------------
function string.Count( str, char )
	local i
	local s = string.Explode( "", str )
	local r = 0
	for i=1, #s do
		if (s[i] == char) then r = r + 1 end
	end
	return r
end

// ---------------------------------------------------------------------------------------------------------
// AllNumerical - Determines if all keys of a table are numerical or not
// ---------------------------------------------------------------------------------------------------------
function table.AllNumerical( tbl )
	for k, v in pairs( tbl ) do
		if (type(k) != "number") then return false end
	end
	return true
end

// ---------------------------------------------------------------------------------------------------------
// HasKey - Determines if a table has a key or not
// ---------------------------------------------------------------------------------------------------------
function table.HasKey( tbl, key )
	for k, v in pairs( tbl ) do
		if (k == key) then return true end
	end
	return false
end

// ---------------------------------------------------------------------------------------------------------
// MaxVal - Determines the highest numerical value in a table
// ---------------------------------------------------------------------------------------------------------
function table.MaxVal( tbl )
	if (#tbl == 0) then return 0 end
	if (#tbl == 1) then return tbl[1] end
	local vl = tbl[1]
	for _, v in pairs( tbl ) do
		if (v > vl) then vl = v end
	end
	return vl
end

// ---------------------------------------------------------------------------------------------------------
// MinVal - Determines the lowest numerical value in a table
// ---------------------------------------------------------------------------------------------------------
function table.MinVal( tbl )
	if (#tbl == 0) then return 0 end
	if (#tbl == 1) then return tbl[1] end
	local vl = tbl[1]
	for _, v in pairs( tbl ) do
		if (v < vl) then vl = v end
	end
	return vl
end

// ---------------------------------------------------------------------------------------------------------
// TotalVal - Determines the total numerical value in a table
// ---------------------------------------------------------------------------------------------------------
function table.TotalVal( tbl )
	if (#tbl == 0) then return 0 end
	if (#tbl == 1) then return tbl[1] end
	local vl = 0
	for _, v in pairs( tbl ) do
		vl = vl + v
	end
	return vl
end

// ---------------------------------------------------------------------------------------------------------
// PartialVal - Determines the total numerical value in a table up to a point
// ---------------------------------------------------------------------------------------------------------
function table.PartialVal( tbl, upto )
	local cnt = 0
	local res = 0
	if (!upto) then upto = #tbl end
	for cnt=1, upto do
		local v = tbl[ cnt ]
		if (type(v) == "number") then
			res = res + v
		else
			res = res + string.len( tostring( v ) )
		end
	end
	return res
end

// ---------------------------------------------------------------------------------------------------------
// AlphaFlash - Returns a number between two other numbers, smoothly alternating over a time period
// ---------------------------------------------------------------------------------------------------------
function math.AlphaFlash( a, b, tperiod )
	local deca = (CurTime()%tperiod)/tperiod
	local decb = deca
	if (decb>0.5) then decb = 1-decb end
	return math.Mid( a, b, math.Clamp( decb, 0, 1 ) )
end

// ---------------------------------------------------------------------------------------------------------
// Mid - Returns a number between two other numbers, with a certain ratio (rat = 0.5 will get the average)
// ---------------------------------------------------------------------------------------------------------
function math.Mid( old, target, rat )
	return old + ((target-old)*rat)
end

// ---------------------------------------------------------------------------------------------------------
// MidAngle - Returns an angle between two other angles, accounting for wrap (going backwards)
// ---------------------------------------------------------------------------------------------------------
function math.MidAngle( old, target, rat )
	return math.Mid( old:Forward(), target:Forward(), rat ):Angle()
end

// ---------------------------------------------------------------------------------------------------------
// IsOnScreen - Determines if an x,y position is onscreen
// ---------------------------------------------------------------------------------------------------------
function math.IsOnScreen( tbl )
	if ((!tbl.x) || (!tbl.y)) then return false end
	return ((tbl.x > -1) && (tbl.x < ScrW()) && (tbl.y > -1) && (tbl.y < ScrH()))
end

// ---------------------------------------------------------------------------------------------------------
// ViewModelPos - Calculates the view model's position and angles
// ---------------------------------------------------------------------------------------------------------
function PCMod.ViewModelPos( hide, origin, angles )
	if (!hide) then
		local wep = LocalPlayer():GetActiveWeapon()
		if ((!wep) || (!wep:IsValid())) then return { origin, angles } end
		if (!wep.GetViewModelPosition) then return { origin, angles } end
		return { wep:GetViewModelPosition( origin, angles ) } -- Ironsights compatability
	end
	if (PCMod.Gui.Switch_Dir == "to") then
		return { PCMod.Gui.TargetPos + ((PCMod.Gui.TargetAng*-128):Forward()), PCMod.Gui.TargetAng*-1 }
	else
		return { PCMod.Gui.OldPos + ((PCMod.Gui.OldAng*-128):Forward()), PCMod.Gui.OldAng*-1 }
	end
end

// ---------------------------------------------------------------------------------------------------------
// CanQuickType - Can quick type be used or not?
// ---------------------------------------------------------------------------------------------------------
function PCMod.CanQuickType( kb )
	local qt = PCMod.Cfg.QuickType
	if ((!qt) || (qt == 0)) then return false end
	if (qt == 1) then return PCMod.Cfg.DebugMode end
	if (qt == 2) then return PCMod.Cfg.DebugMode || kb end
	if (qt == 3) then return true end
end

// ---------------------------------------------------------------------------------------------------------
// SplitString - Splits a string into equal sized chunks, with a different sized firstchunk
// ---------------------------------------------------------------------------------------------------------
function PCMod.SplitString( str, chunksize, firstchunk )
	// Get string info
	if (!firstchunk) then firstchunk = chunksize end
	if (string.len(str) < (firstchunk+1)) then
		return { str }
	end
	local len = string.len( str )
	local chunks = math.ceil( len/chunksize )
	local tmp = {}
	local i = 0
	
	table.insert( tmp, ca )
	
	// Split it up
	for i=1, chunks do
		local chunk = string.sub( str, ((i-1)*chunksize)+1, (i*chunksize) )
		table.insert( tmp, chunk )
	end
	
	// Return it
	return tmp
end

// ---------------------------------------------------------------------------------------------------------
// CompareString - Compares a string against a COMP_ enum
// ---------------------------------------------------------------------------------------------------------
COMP_NUMBER = "1234567890-."
COMP_TEXT = "abcdefghijklmnopqrstuvwxyz"
COMP_NORMAL_CHARS = "()!£$%^&*-_=,./';[]{}#~|`+"
COMP_SPECIAL_CHARS = "\\\"\n"
COMP_ALGEBRA = "+-/*%^"
COMP_TEXT_AND_NUMBERS = COMP_TEXT .. COMP_NUMBER
COMP_TEXT_AND_CHARS = COMP_TEXT .. COMP_NORMAL_CHARS
COMP_TEXT_AND_CHARS_AND_NUMBERS = COMP_TEXT_AND_CHARS .. COMP_NUMBER
function PCMod.CompareString( str, comp )
	local cmp = string.Explode( "", comp )
	local txt = string.Explode( "", str )
	local cnt
	for cnt=1,#txt do
		if (!table.HasValue( cmp, txt[cnt] )) then return false end
	end
	return true
end