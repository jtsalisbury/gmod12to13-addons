
// ---------------------------------------------------------------------------------------------------------
// sv_core.lua - Revision 1
// Server-Side
// Loads PCMod on the server
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define core tables
// ---------------------------------------------------------------------------------------------------------

PCMod = {} -- Main table
PCMod.Exists = true -- Internal checking
PCMod.Version = "2.0.4" -- 'Nice' version
PCMod.IntVer = "Release" -- Internal version
PCMod.Data = {} -- Data storage table for entities

util.AddNetworkString("pc_stream");

// ---------------------------------------------------------------------------------------------------------
// Load configuration, and common functions
// ---------------------------------------------------------------------------------------------------------

PCMod.Cfg = {} -- Define config table

include( "pcmod/sh_baseconfig.lua" ) -- Configuration file
AddCSLuaFile( "pcmod/sh_baseconfig.lua" ) -- Give base config file to client
AddCSLuaFile( "pcmod/sh_config.lua" ) -- Give config file to client

include( "pcmod/sh_common.lua" ) -- Common functions
AddCSLuaFile( "pcmod/sh_common.lua" ) -- Give common file to client

include( "pcmod/sh_logging.lua" ) -- Logging functions
AddCSLuaFile( "pcmod/sh_logging.lua" ) -- Give logging file to client

include( "pcmod/sh_plugins.lua" ) -- Plugins file
AddCSLuaFile( "pcmod/sh_plugins.lua" ) -- Give plugins file to client

include( "pcmod/sh_resources.lua" ) -- Resources file
AddCSLuaFile( "pcmod/sh_resources.lua" ) -- Give resources file to client

include( "pcmod/sh_beam.lua" ) -- Beaming file
AddCSLuaFile( "pcmod/sh_beam.lua" ) -- Give beaming file to client

include( "pcmod/sh_settings.lua" ) -- Settings file
AddCSLuaFile( "pcmod/sh_settings.lua" ) -- Give settings file to client

PCMod.Msg( "PCMod Version " .. PCMod.Version .. " Installed" )
PCMod.Msg( "Loading PCMod Core..." )


// ---------------------------------------------------------------------------------------------------------
// Include all other files we need
// ---------------------------------------------------------------------------------------------------------

include( "pcmod/sv_wiring.lua" ) -- Wiring control
include( "pcmod/sv_network.lua" ) -- Networking
include( "pcmod/sv_drivers.lua" ) -- Drivers
include( "pcmod/sv_rp.lua" ) -- RP control
include( "pcmod/sv_programs.lua" ) -- Programs
include( "pcmod/sv_data.lua" ) -- Player data


// ---------------------------------------------------------------------------------------------------------
// Give the client all the other core files it needs
// ---------------------------------------------------------------------------------------------------------

AddCSLuaFile( "pcmod/cl_core.lua" ) -- Core file
AddCSLuaFile( "pcmod/cl_gui.lua" ) -- Gui control file
AddCSLuaFile( "pcmod/cl_vgui.lua" ) -- Vgui control file
AddCSLuaFile( "pcmod/cl_2d3d.lua" ) -- 2D 3D drawing file
AddCSLuaFile( "pcmod/cl_rp.lua" ) -- RolePlay mode file
AddCSLuaFile( "pcmod/cl_keyboard.lua" ) -- Keyboard control file
AddCSLuaFile( "pcmod/cl_camera.lua" ) -- Camera control file
AddCSLuaFile( "pcmod/cl_input.lua" ) -- Input capture control file
AddCSLuaFile( "pcmod/cl_sselements.lua" ) -- SS device elements control file

// ---------------------------------------------------------------------------------------------------------
// Give the client all our devices and themes
// ---------------------------------------------------------------------------------------------------------

AddCSLuaFile( "pcmod/ssdevices/base.lua" )
for _, v in pairs( file.Find( "pcmod/ssdevices/dev_*", "LUA" ) ) do
	local fn = "pcmod/ssdevices/" .. v
	PCMod.Msg( "Adding SSDevice: " .. v, true )
	AddCSLuaFile( fn )
end

for _, v in pairs( file.Find( "pcmod/themes/cl_*", "LUA" ) ) do
	local fn = "pcmod/themes/" .. v
	PCMod.Msg( "Adding Theme: " .. v, true )
	AddCSLuaFile( fn )
end

for _, v in pairs( file.Find( "pcmod/sselements/*.lua", "LUA" ) ) do
	local fn = "pcmod/sselements/" .. v
	PCMod.Msg( "Adding SS Element: " .. v, true )
	AddCSLuaFile( fn )
end


// ---------------------------------------------------------------------------------------------------------
// Timed message and server tags
// ---------------------------------------------------------------------------------------------------------

if (PCMod.Cfg.TimedMessage) then
	timer.Create( "PCMOD_TimedMessage", PCMod.Cfg.TimedMessageDelay, 0, function()
		PCMod.GMsg( PCMod.Cfg.Message )
	end )
end
if (PCMod.Cfg.UsePCModTags) then
	function PCMod.SetTags()
		game.ConsoleCommand( "sv_tags " .. PCMod.Cfg.PCModTags .. "\n" )
	end
	hook.Add( "Initialize", "PCMod.SetTags", PCMod.SetTags )
end


// ---------------------------------------------------------------------------------------------------------
// Screen Space Control
// ---------------------------------------------------------------------------------------------------------

local ss = {}
	ss.Data = {}
	ss.Data.SC = false
	function ss:Setup( w, h )
		self.Width = w
		self.Height = h
		self:ClearAll()
	end
	function ss:AddDevice( devicename, devicedata )
		local rev = 1
		if (self.Data[ devicename ]) then rev = self.Data[ devicename ].Rev + 1 end
		devicedata.Rev = rev
		self.Data[ devicename ] = table.Copy( devicedata )
	end
	function ss:RemoveDevice( devicename )
		self.Data[ devicename ] = nil
	end
	function ss:GetDevice( devicename )
		return self.Data[ devicename ]
	end
	function ss:MakeDevice( dtype, x, y, w, h, data, pri )
		if (!data) then data = {} end
		data.X = x
		data.Y = y
		data.W = w
		data.H = h
		data.Type = dtype
		data.Priority = pri
		return table.Copy( data )
	end
	function ss:ClearAll()
		local oldsc = self.Data.SC
		self.Data = {}
		self.Data.SC = oldsc -- Sneaky Variable ftw
	end
	function ss:EnableCursor()
		self.Data.SC = true
	end
	function ss:DisableCursor()
		self.Data.SC = false
	end

PCMod.ScreenSpace = table.Copy( ss )
ss = nil

PCMod.NextSSID = 1

function PCMod.MakeScreenSpace()
	PCMod.Msg( "Making ScreenSpace...", true )
	local tmp = table.Copy( PCMod.ScreenSpace )
	tmp.ID = PCMod.NextSSID
	PCMod.NextSSID = tmp.ID+1
	return tmp
end


// ---------------------------------------------------------------------------------------------------------
// Load all operating systems
// ---------------------------------------------------------------------------------------------------------

PCMod.Msg( "Preparing to load all operating systems...", true )

PCMod.OSys = {}

OS = {}
include( "pcmod/osystems/base.lua" )
PCMod.OSys[ "base" ] = table.Copy( OS )
OS = nil

for _, v in pairs( file.Find( "pcmod/osystems/os_*", "LUA" ) ) do
	local fn = "pcmod/osystems/" .. v
	OS = table.Copy( PCMod.OSys[ "base" ] )
	OS.Filename = fn
	include( fn )
	//PrintTable( OS )
	PCMod.OSys[ OS.IntName ] = table.Copy( OS )
	PCMod.Msg( "Loading OS '" .. OS.ExtName .. "'...", true )
	OS = nil
end

// ---------------------------------------------------------------------------------------------------------
// ReloadOS - Reloads an OS
// ---------------------------------------------------------------------------------------------------------
function PCMod.ReloadOS( ply, com, args )
	OS = nil

	local fn = "pcmod/osystems/" .. args[ 1 ]
	OS = table.Copy( PCMod.OSys[ "base" ] )
	OS.Filename = fn
	include( fn )
	//PrintTable( OS )
	PCMod.OSys[ OS.IntName ] = table.Copy( OS )
	PCMod.Msg( "Loading OS '" .. OS.ExtName .. "'...", true )
	OS = nil
end
concommand.Add( "pc_os_reload", PCMod.ReloadOS )


// ---------------------------------------------------------------------------------------------------------
// KeyPress - Registers a keypress from the on-screen keyboard and passes it to correct entity (_OBSOLETE_)
// ---------------------------------------------------------------------------------------------------------
function PCMod.KeyPress( ply, com, args )
	if ((!ply) || (!ply:IsValid())) then return end
	if ((!args) || (!args[1]) || (!args[2])) then return end
	local key = tostring( args[1] )
	local entid = tonumber( args[2] )
	local ent = ents.GetByIndex( entid )
	if ((!ent) || (!ent:IsValid())) then return end
	if ((!ent.IsPCMod) || (ent.Class != "pcmod_keyboard")) then return end
	if ((ent:GetPos()-ply:GetPos()):Length() > PCMod.Cfg.ReachDistance) then
		ply:PrintMessage( HUD_PRINTTALK, "You are too far away to reach the keyboard!" )
		return
	end
	ent:FireEvent( { "keypress", key } )
end
concommand.Add( "pc_keypress", PCMod.KeyPress )

// ---------------------------------------------------------------------------------------------------------
// PlayerSay - Chat commands controlled here
// ---------------------------------------------------------------------------------------------------------
function PCMod.PlayerSay( ply, text )
	local ln = string.len( text )
	if (ln > 3) then
		local lft = string.sub( string.lower( text ), 1, 3 )
		local rt = string.sub( string.lower( text ), 4, ln )
		if (lft == "!pc") then
			if (rt == "buy") then
				PCMod.RP.OpenRPMenu( ply )
				return ""
			end
			if (rt == "type") then
				PCMod.PC_QuickType( ply )
				return ""
			end
			if (rt == "settings") then
				PCMod.Settings.OpenClientWindow( ply )
				return ""
			end
		end
	end
end
hook.Add( "PlayerSay", "PCMod.PlayerSay", PCMod.PlayerSay )

// ---------------------------------------------------------------------------------------------------------
// PC_Command - Runs a specific command based on an entity
// ---------------------------------------------------------------------------------------------------------
function PCMod.PC_Command( ply, com, args )
	if (!ply.NextRun) then ply.NextRun = 0 end
	if (CurTime() > ply.NextRun) then
		ply.NextRun = CurTime() + PCMod.Cfg.PCC_FLOOD
	else
		PCMod.Msg( "PC_Command: Flood Protection! (" .. ply:Nick() .. ")" )
		return
	end
	if (!args[1]) then
		PCMod.Msg( "PC_Command failed! (No entID)", true )
		return
	end
	local entid = tonumber( args[1] )
	table.remove( args, 1 )
	local ent = ents.GetByIndex( entid )
	if ((!ent) || (!ent:IsValid())) then
		PCMod.Msg( "PC_Command failed! (No entity)", true )
		return
	end
	if ((ent:GetPos()-ply:GetPos()):Length() > PCMod.Cfg.ReachDistance) then
		PCMod.Msg( "PC_Command failed! Player is too far away.", true )
		return
	end
	if (!args[1]) then
		PCMod.Msg( "PC_Command failed! (No command)", true )
		return
	end
	local command = args[1]
	table.remove( args, 1 )
	if (!ent.IsPCMod) then
		PCMod.Msg( "PC_Command failed! (Target is not a PCMod Ent)", true )
		return
	end
	if (command == "input") then
		PCMod.Msg( "PC_Command: Forwarding data to ent...", true )
		ent:FireEvent( { "user_input", ply, args } )
		return
	end
	if (command == "power") then
		PCMod.Msg( "PC_Command: Toggling entity power...", true )
		ent:FireEvent( { "toggleon" } )
		return
	end
	PCMod.Msg( "PC_Command: Didn't recognise command! ('" .. command .. "')", true )
end
concommand.Add( "pc_command", PCMod.PC_Command )

// ---------------------------------------------------------------------------------------------------------
// PC_Stream - Passes a datastream to PC_Command
// ---------------------------------------------------------------------------------------------------------
function PCMod.PC_Stream(len, client)//pl, handler, id, rawdata, procdata )
	local procdata = net.ReadTable();
	
	if (PCMod.Cfg.DebugMode) then
		print( "-----" )
		print( "PC_Stream data recieved on server!" )
		print( pl:Nick() )
		print( handler )
		print( id )
		print( rawdata )
		PrintTable( procdata )
		print( "-----" )
	end
	PCMod.PC_Command( client, "pc_command", procdata )
end
net.Receive( "pc_stream", PCMod.PC_Stream )

// ---------------------------------------------------------------------------------------------------------
// PC_Run - Runs a command on the targetted entity
// ---------------------------------------------------------------------------------------------------------
function PCMod.PC_Run( ply, com, args )
	local tr = ply:GetEyeTrace()
	if ((tr.Entity) && (tr.Entity:IsValid())) then
		table.insert( args, 1, tostring( tr.Entity:EntIndex() ) )
		PCMod.PC_Command( ply, com, args )
	end
end
concommand.Add( "pc_run", PCMod.PC_Run )

// ---------------------------------------------------------------------------------------------------------
// Locked - Enables/disables Lock mode (Lock mode means player is frozen and has no view model)
// ---------------------------------------------------------------------------------------------------------
function PCMod.Locked( ply, com, args )
	local svm = tonumber( args[1] )
	ply:DrawViewModel( svm == 0 )
	ply:Freeze( svm == 1 )
end
concommand.Add( "pc_locked", PCMod.Locked )

// ---------------------------------------------------------------------------------------------------------
// PC_QuickType - Shows the QuickType menu on the client
// ---------------------------------------------------------------------------------------------------------
function PCMod.PC_QuickType( ply, com, args )
	if (!args) then args = {} end
	local kb = false
	if (args[1]) then
		local ent = ents.GetByIndex( tonumber( args[1] ) )
		if ((ent) && (ent:IsValid()) && (ent:GetClass() == "pcmod_keyboard")) then kb = true end
	end
	if (!PCMod.CanQuickType( kb )) then
		ply:PrintMessage( HUD_PRINTTALK, "You may not use QuickType!" )
		return
	end
	umsg.Start( "pcmod_quicktype", ply )
	umsg.End()
end
concommand.Add( "pc_quicktype", PCMod.PC_QuickType )

// ---------------------------------------------------------------------------------------------------------
// SendPopupNotice - Sends a notice popup to the player (nil player = all players!)
// ---------------------------------------------------------------------------------------------------------
function PCMod.SendPopupNotice( ply, title, text )
	umsg.Start( "pcmod_ppnot", ply )
		umsg.String( title )
		umsg.String( text )
	umsg.End()
end

// ---------------------------------------------------------------------------------------------------------
// SetDevparam - Sets device params on the client
// ---------------------------------------------------------------------------------------------------------
function PCMod.SetDevParam( entid, device, index, value )
	for _,v in pairs( player.GetAll() ) do
		umsg.Start( "pcmod_setdevparam", v )
		umsg.Short( entid )
		umsg.String( device )
		umsg.Short( index )
		umsg.String( value[ 1 ] )
		if (value[ 1 ] == "bool") then
			umsg.Bool( value [ 2 ] )
		elseif (value[ 1 ] == "string") then
			umsg.String( value [ 2 ] )
		elseif (value[ 1 ] == "int") then
			umsg.Short( value [ 2 ] )
		elseif (value[ 1 ] == "float") then
			umsg.Float( value [ 2 ] )
		elseif (value[ 1 ] == "entity") then
			umsg.Entity( value [ 2 ] )
		end
		umsg.End()
	end
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
// Call the post_load plugin hook
// ---------------------------------------------------------------------------------------------------------
PCMod.CallHook( "post_load" )