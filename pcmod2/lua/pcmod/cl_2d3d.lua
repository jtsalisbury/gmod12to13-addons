
// ---------------------------------------------------------------------------------------------------------
// cl_2d3d.lua - Revision 1
// Client-Side
// Controls the 2D 3D Drawing operations
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------

PCMod.SDraw = {}
PCMod.SDraw.Version = "1.0"
PCMod.SDraw.Configs = {}
PCMod.SDraw.SSpaces = {}
PCMod.SDraw.Devices = {}
PCMod.SDraw.DevMap = {}
PCMod.SDraw.OldData = {}
PCMod.SDraw.DMap = {}

PCMod.SDraw.KeyboardEntID = 0
PCMod.SDraw.DrawKeyboard = false
PCMod.SDraw.KB_Shift = false
PCMod.SDraw.KB_UnShift = false
PCMod.SDraw.KB_Caps = false

PCMod.SDraw.DevFocus = ""

PCMod.SDraw.CFrame = 0

PCMod.SDraw.DevParams = {}

PCMod.Msg( "2D 3D ScreenDraw Library Loaded (V" .. PCMod.SDraw.Version .. ")", true )


// ---------------------------------------------------------------------------------------------------------
// Load all our SS devices
// ---------------------------------------------------------------------------------------------------------

function PCMod.LoadSSDevice( id )
	DEV = {}
	if (id == "base") then
		include( "pcmod/ssdevices/base.lua" )
		PCMod.SDraw.Devices[ "base" ] = table.Copy( DEV )
		PCMod.Msg( "Loaded base device!", true )
		return
	end
	local fn = "pcmod/ssdevices/" ..id
	DEV.FileName = fn
	table.Merge( DEV, PCMod.SDraw.Devices[ "base" ] )
	include( fn )
	PCMod.SDraw.Devices[ DEV.Name ] = table.Copy( DEV )
	PCMod.Msg( "Device '" .. DEV.Name .. "' loaded!", true )
end

function PCMod.LoadAllDevices()
	local ssds = file.Find( "pcmod/ssdevices/dev_*", "LUA")
	if ((!ssds) || (#ssds == 0)) then
		PCMod.Warning( "No ScreenSpace devices to load!" )
	else
		DEV = {}
		PCMod.LoadSSDevice( "base" )
		for _, v in pairs( ssds ) do
			DEV = {}
			PCMod.LoadSSDevice( v )
		end
	end
	DEV = nil
end

PCMod.LoadAllDevices()

concommand.Add( "pc_ssd_reload", function( pl, com, args ) PCMod.LoadSSDevice( args[1] ); end )
concommand.Add( "pc_ssd_reloadall", function() PCMod.LoadAllDevices(); end )


// ---------------------------------------------------------------------------------------------------------
// Define all the screen configs
// ---------------------------------------------------------------------------------------------------------

// Old CRT
local sc = {}
	// For Reference:
	sc.ScreenModel = "models/props_lab/monitor01a.mdl"
	
	// For 3D 2D Drawing:
	sc.OffsetForward = 12.4
	sc.OffsetUp = 2.95
	sc.OffsetRight = -2.4
	sc.Resolution = 0.04
	sc.Rotation = Vector( 4.5, 0, 0 )
	
	// For Screen Drawing:
	sc.RX = -302
	sc.RY = -218
	sc.RW = 480
	sc.RH = 393
	
	// For Cursor Position Calculation:
	sc.x1 = -9
	sc.x2 = 9
	sc.y1 = 12.5
	sc.y2 = -4
	sc.z = 6.4
	sc.fov = 70
	
	// For Camera Lock Positioning:
	sc.UpAdjust = 0
	sc.RightAdjust = 0
	sc.ForwardAdjust = 1
	
PCMod.SDraw.Configs[ sc.ScreenModel ] = sc

// New LCD
sc = {}
	// For Reference:
	sc.ScreenModel = "models/props/cs_office/computer_monitor.mdl"
	
	// For 3D 2D Drawing:
	sc.OffsetForward = 3.25
	sc.OffsetUp = 15.85
	sc.OffsetRight = -2.2
	sc.Resolution = 0.0425
	sc.Rotation = Vector( 0, 0, 0 )
	
	// For Screen Drawing:
	sc.RX = -296
	sc.RY = -205
	sc.RW = 487
	sc.RH = 368
	
	// For Cursor Position Calculation:
	sc.x1 = -10.5
	sc.x2 = 10.5
	sc.y1 = 24.7
	sc.y2 = 8.6
	sc.z = 3.33
	sc.fov = 70
	
	// For Camera Lock Positioning:
	sc.UpAdjust = 13
	sc.RightAdjust = 0
	sc.ForwardAdjust = -6.5
	
PCMod.SDraw.Configs[ sc.ScreenModel ] = sc

// Darksunrise's model
local sc = {}

	sc.ScreenModel = "models/darksunrise/monitor01.mdl"

	// For 3D 2D Drawing:
	sc.OffsetForward = 3.25
	sc.OffsetUp = -2.24
	sc.OffsetRight = -15.8
	sc.Resolution = 0.0425
	sc.Rotation = Vector( 180, 90, 180 )

	// For Screen Drawing:
	sc.RX = -296
	sc.RY = -205
	sc.RW = 487
	sc.RH = 368

	// For Cursor Position Calculation:
	sc.x1 = 9
	sc.x2 = 24
	sc.y1 = 10
	sc.y2 = -6
	sc.z = 6
	sc.fov = 70

	// For Camera Lock Positioning:
	sc.UpAdjust = 0
	sc.RightAdjust = -17
	sc.ForwardAdjust = -8

PCMod.SDraw.Configs[ sc.ScreenModel ] = table.Copy( sc )

// New LCD
sc = {}
	// For Reference:
	sc.ScreenModel = "models/pcmod/eeepc.mdl"
	
	// For 3D 2D Drawing:
	sc.OffsetForward = -9.84
	sc.OffsetUp = 10
	sc.OffsetRight = -2.2
	sc.Resolution = 0.0425
	sc.Rotation = Vector( 11, 0, 0 )
	
	// For Screen Drawing:
	sc.RX = -317
	sc.RY = -205
	sc.RW = 530
	sc.RH = 368
	
	// For Cursor Position Calculation:
	sc.x1 = -11.5
	sc.x2 = 11.5
	sc.y1 = 18.5
	sc.y2 = 3
	sc.z = 3.33
	sc.fov = 70
	
	// For Camera Lock Positioning:
	sc.UpAdjust = 6.8
	sc.RightAdjust = 0
	sc.ForwardAdjust = -22.5
	
PCMod.SDraw.Configs[ sc.ScreenModel ] = sc

// ---------------------------------------------------------------------------------------------------------
// SetDevParam - Sets a device parameter
// ---------------------------------------------------------------------------------------------------------
function PCMod.SetDevParam( um )
	local entid = um:ReadShort()
	local device = um:ReadString()
	local index = um:ReadShort()
	local type = um:ReadString()
	local value = nil
	if (type == "bool") then
		value = um:ReadBool()
	elseif (type == "string") then
		value = um:ReadString()
	elseif (type == "int") then
		value = um:ReadShort()
	elseif (type == "float") then
		value = um:ReadFloat()
	elseif (type == "entity") then
		value = um:ReadEntity()
	end
	PCMod.SDraw.DevParams[ entid ] = {}
	PCMod.SDraw.DevParams[ entid ][ device ] = {}
	PCMod.SDraw.DevParams[ entid ][ device ][ index ] = value
end
usermessage.Hook( "pcmod_setdevparam", PCMod.SetDevParam )

// ---------------------------------------------------------------------------------------------------------
// Add some dev adjustment commands
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.SetScreenConfig( ply, com, args )
	if (!args[1]) then
		PCMod.Msg( "Invalid screen id!" )
		return
	end
	local mdl_id = tonumber( args[1] )
	local mdl = ""
	if (mdl_id == 1) then mdl = "models/props_lab/monitor01a.mdl" end
	if (mdl_id == 2) then mdl = "models/props/cs_office/computer_monitor.mdl" end
	if (mdl_id == 3) then mdl = "models/darksunrise/monitor01.mdl" end
	if (mdl_id == 4) then mdl = "models/pcmod/eeepc.mdl" end
	if (mdl == "") then
		PCMod.Msg( "Invalid screen id!" )
		return
	end
	if (!args[2]) then
		PCMod.Msg( "Invalid setting!" )
		return
	end
	local setting = tostring( args[2] )
	local set = PCMod.SDraw.Configs[ mdl ][ setting ]
	if (!set) then
		PCMod.Msg( setting .. ": Nil" )
		return
	end
	if (!args[3]) then
		PCMod.Msg( setting .. ": " .. set )
		return
	end
	local value = tonumber( args[3] )
	PCMod.SDraw.Configs[ mdl ][ setting ] = value
end
concommand.Add( "pc_ssc", PCMod.SDraw.SetScreenConfig )


// ---------------------------------------------------------------------------------------------------------
// Add a data dumping command
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.DumpScreenConfig( ply, com, args )
	if (!args[1]) then
		PCMod.Msg( "Invalid screen id!" )
		return
	end
	local mdl_id = tonumber( args[1] )
	local mdl = ""
	if (mdl_id == 1) then mdl = "models/props_lab/monitor01a.mdl" end
	if (mdl_id == 2) then mdl = "models/props/cs_office/computer_monitor.mdl" end
	if (mdl_id == 3) then mdl = "models/darksunrise/monitor01.mdl" end
	if (mdl_id == 4) then mdl = "models/pcmod/eeepc.mdl" end	
	if (mdl == "") then
		PCMod.Msg( "Invalid screen id!" )
		return
	end
	local cfg = PCMod.SDraw.Configs[ mdl ]
	local txt = PCMod.TableToString( cfg )
	local pth = PCMod.Cfg.DataFolderRoot .. PCMod.Cfg.DumpPath .. tostring( mdl_id ) .. "_config.txt"
	file.Write( pth, txt )
	PCMod.Msg( "Screen config dumped!" )
end
concommand.Add( "pc_ssc_dump", PCMod.SDraw.DumpScreenConfig )


// ---------------------------------------------------------------------------------------------------------
// GarbageCollect - Destroys all stored devices that are 2 or more frames old
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.GarbageCollect()
	PCMod.SDraw.CFrame = PCMod.SDraw.CFrame + 1
	for k, v in pairs( PCMod.SDraw.DevMap ) do
		if ((v.LastFrame < (PCMod.SDraw.CFrame-2)) && (!v.NoGarbage)) then
			PCMod.SDraw.DevMap[ k ]:Kill()
			PCMod.SDraw.DevMap[ k ] = nil
			PCMod.Msg( "Garbage collected '" .. k .. "'", true )
		end
	end
end
hook.Add( "Think", "PCMod.SDraw.GarbageCollect", PCMod.SDraw.GarbageCollect )


// ---------------------------------------------------------------------------------------------------------
// DrawScreen - Draws the screen of a PC entity
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.DrawScreen( ent, cursor )
	// Validate Entity
	if ((!ent) || (!ent:IsValid())) then return end
	
	// Check it's a screen
	if (!ent.IsScreen) then return end
	
	// Check its distance from the player
	local dist = (LocalPlayer():GetPos()-ent:GetPos()):Length()
	if (dist > PCMod.Cfg.SightRange) then return end
	
	// Retrieve it's screenspace, validate it
	local ss = PCMod.SDraw.SSpaces[ ent:EntIndex() ]
	if (!ss) then
		PCMod.Msg( "Entity (" .. tostring( ent:EntIndex() ) .. ") has no screenspace!", true )
		PCMod.SDraw.SSpaces[ ent:EntIndex() ] = {}
		return
	end
	
	// Check if we have any 'sneaky' variables
	if ((ss.SC) && (ss.SC==true)) then
		cursor = true
	end
	ss.SC = nil
	
	// Add the standard clientside devices if they dont exist
	ss["cl_bg"] = {
		Priority = 0,
		X = 0,
		Y = 0,
		W = 1,
		H = 1,
		Type = "background",
		NoGarbage = true
	}
	
	// Retrieve the screen config, validate it
	local sc = PCMod.SDraw.Configs[ ent:GetModel() ]
	if (!sc) then
		PCMod.Msg( "Entity (" .. tostring( ent:EntIndex() ) .. ") has no screen configuration!", true )
		return
	end
	
	// Get the entity angles & pos
	local ang = ent:GetAngles()
	local rot = Vector(-90,90,0) + sc.Rotation
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	local pos = ent:GetPos() + (ent:GetForward() * sc.OffsetForward) + (ent:GetUp() * sc.OffsetUp) + (ent:GetRight() * sc.OffsetRight)
	
	// Start the 3D 2D
	cam.Start3D2D( pos, ang, sc.Resolution )
		
	// Get drawing coords
	local x = sc.RX
	local y = sc.RY
	local w = sc.RW
	local h = sc.RH
	
	// Draw the screen space
	PCMod.SDraw.DrawSpace( ss, x, y, w, h, ent:EntIndex() )
	
	// If we are drawing the cursor, then...
	if (cursor) then
	
		// Get the cursor position
		local cx, cy = PCMod.SDraw.CalcCursor( ent, sc.fov )
		local ax = x+(cx*w)
		local ay = y+(cy*h)
		
		// Draw it
		surface.SetDrawColor( 255, 255, 255, 255 )
		// surface.DrawRect( ax-3, ay-3, 8, 8 )
		surface.DrawLine( ax, ay, ax+6, ay+6 )
		surface.DrawLine( ax-2, ay-2, ax+3, ay-2 )
		surface.DrawLine( ax-3, ay+3, ax+3, ay-3 )
		surface.DrawLine( ax-2, ay-2, ax-2, ay+3 )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine( ax-3, ay-3, ax+4, ay-3 )
		surface.DrawLine( ax-3, ay-3, ax-3, ay+4 )
		surface.DrawLine( ax-3, ay+4, ax+4, ay-3 )
		surface.DrawLine( ax, ay+1, ax+5, ay+6 )
		surface.DrawLine( ax+1, ay, ax+6, ay+5 )

		
		// Set back our 'sneaky' variable (lol)
		ss.SC = true
		
	end
	
	// End the 3D 2D
	cam.End3D2D()
	
	// Reupdate the screenspace
	PCMod.SDraw.SSpaces[ ent:EntIndex() ] = ss
end

// ---------------------------------------------------------------------------------------------------------
// DrawSpace - Draws the screenspace
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.DrawSpace( ss, x, y, w, h, entid )
	// Get the entity for reference
	local ent = ents.GetByIndex( entid )
	
	// Cycle through list of devices, reorder them
	local tmp = {}
	for k, v in pairs( ss ) do
		local pr = v.Priority
		v.DevID = tostring( entid ) .. ":" .. k
		if (!pr) then pr = 1 end
		if (!tmp[pr]) then tmp[pr] = {} end
		table.insert( tmp[pr], table.Copy( v ) )
	end
	
	// Cycle through the reordered devices, render them
	local i = 1
	for i=0, table.maxn( tmp ) do
		local v = tmp[i]
		if (v) then
			for _, device in pairs( v ) do
				if (PCMod.SDraw.DevMap[ device.DevID ]) then PCMod.SDraw.DevMap[ device.DevID ]:Tick() end
				local dx = x+(device.X*w)
				local dy = y+(device.Y*h)
				local dw = device.W*w
				local dh = device.H*h
				if (!device.Rev) then device.Rev = 1 end
				device.Entity = ent
				PCMod.SDraw.DrawDevice( device, dx, dy, dw, dh, entid )
			end
		end
	end
	
end

// ---------------------------------------------------------------------------------------------------------
// DrawDevice - Draws a ScreenSpace device
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.DrawDevice( device, x, y, w, h, entid )
	// Get the device details
	local basedev = PCMod.SDraw.Devices[ device.Type ]
	local dev = PCMod.SDraw.DevMap[ device.DevID ]
	
	if (!dev) then
	
		// Create a new device
		if (!basedev) then return end
		dev = {}
		setmetatable( dev, { __index = basedev } )
		if (dev.OnCreate) then dev:OnCreate() end
		PCMod.SDraw.DevMap[ device.DevID ] = dev
		
		// Feed in the data
		table.Merge( dev, device )
		
		// Initialize it
		dev:Int_Initialize( x, y, w, h)
	else		
		// Feed in the data
		local dev = PCMod.SDraw.DevMap[ device.DevID ]
		table.Merge( dev, device )
		
		// Check for update
		if (device.Rev > PCMod.SDraw.DMap[ device.DevID ]) then
			dev:Int_Update()
		end
	end
	
	// Fill in the DMap link & the entid
	PCMod.SDraw.DMap[ device.DevID ] = device.Rev
	dev.EntID = entid
	
	// Draw it
	dev:Int_Paint( x, y, w, h )
end

// ---------------------------------------------------------------------------------------------------------
// NewScreenSpace - Updates a screenspace with a full newer copy
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.UpdateScreenSpace( entid, ss )
	PCMod.SDraw.SSpaces[ entid ] = ss
end

// ---------------------------------------------------------------------------------------------------------
// UpdateScreenSpace - Updates a screenspace with a partial newer copy
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.UpdateScreenSpace( entid, ss )
	if (!PCMod.SDraw.SSpaces[ entid ]) then PCMod.SDraw.SSpaces[ entid ] = {} end
	for k, v in pairs( ss ) do
		if (v == 0) then
			// Let's hope there are no sneaky variables that equal 0... -thomasfn
			PCMod.SDraw.SSpaces[ entid ][ k ] = nil
		else
			if (type(v) == "table") then
				PCMod.SDraw.SSpaces[ entid ][ k ] = table.Copy( v )
			else
				PCMod.SDraw.SSpaces[ entid ][ k ] = v
			end
		end
	end
end

// ---------------------------------------------------------------------------------------------------------
// CalcCursor - Calculates the location of the cursor on a screen
// ---------------------------------------------------------------------------------------------------------
function PCMod.SDraw.CalcCursor( ent, fov )
	if ((!ent) || (!ent:IsValid())) then return end
	local sc = PCMod.SDraw.Configs[ ent:GetModel() ]
	if (!sc) then return end
	
	// Begin adapted nighteagle code (amazing work with vectors!!!)  
	// Nighteagle has put a lot of work into refining the use of cam3d2d and traces to create cursor screen systems.
	// (Taken from gmod_wire_graphics_tablet, in wiremod pack)
		
		// Get the entity information
		local ang = ent:GetAngles()
		local rot = Vector(-90,90,0)+sc.Rotation
		ang:RotateAroundAxis(ang:Right(), rot.x)
		ang:RotateAroundAxis(ang:Up(), rot.y)
		ang:RotateAroundAxis(ang:Forward(), rot.z)
		local pos = ent:GetPos() + (ent:GetForward() * sc.z)
		
		// Get the cursor's traceline
		local trace = {}
			trace.start = LocalPlayer():GetShootPos()
			trace.endpos = (LocalPlayer():GetAimVector() * 64) + trace.start
			trace.filter = LocalPlayer()
			if ((PCMod.Gui.CamLocked) && (PCMod.Gui.CamLockID == ent:EntIndex())) then
				if ((ent) && (ent:IsValid())) then
					// This chunk of code is mine, it does the job of 'ply:GetAimVector()' but compensates for CalcView as well - thomasfn
					local view = PCMod.Cam.CalcEntView( ent )
					trace.start = view[1]
					trace.endpos = trace.start + (gui.ScreenToVector( gui.MouseX(), gui.MouseY() ) * 64)
					// End chunk of code
				end
			end
		local tr = util.TraceLine(trace)
		
		// If the cursor's traceline hits the entity, calculate where
		if (tr.Entity == ent) then
			local pos = ent:WorldToLocal( tr.HitPos )
			local cx = math.Clamp( (sc.x1 - pos.y) / (sc.x1 - sc.x2), 0, 1 )
			local cy = math.Clamp( (sc.y1 - pos.z) / (sc.y1 - sc.y2), 0, 1 )
			return cx, cy
		else
			// No hit, return default
			return 0.5, 0.5
		end
		
	// End adapted nighteagle code
	
end