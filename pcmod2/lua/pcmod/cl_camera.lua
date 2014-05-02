
// ---------------------------------------------------------------------------------------------------------
// cl_camera.lua - Revision 1
// Client-Side
// Controls camera operations on the client
// ---------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------

PCMod.Cam = {}
PCMod.Cam.Version = "1.0"

PC_CAM_IDLE = 0
PC_CAM_MOVING = 1
PC_CAM_LOCKED = 2

PC_CAM_PLY = 1
PC_CAM_ENT = 2

PCMod.Cam.State = PC_CAM_IDLE

PCMod.Cam.A = PC_CAM_PLY
PCMod.Cam.B = PC_CAM_PLY

PCMod.Cam.EntID = 0
PCMod.Cam.LockDistance = 32

PCMod.Cam.PC_Locked = 0
PCMod.Cam.Old_Locked = 0

PCMod.Cam.ST = 0

PCMod.Msg( "Camera Library Loaded (V" .. PCMod.Cam.Version .. ")", true )


// ---------------------------------------------------------------------------------------------------------
// CalcEntView - Calculates the view based on the entity
// ---------------------------------------------------------------------------------------------------------
function PCMod.Cam.CalcEntView( ent )
	if ((!ent) || (!ent:IsValid())) then return end
	local up = 0
	local right = 0
	local forward = 0
	local sc = PCMod.SDraw.Configs[ ent:GetModel() ]
	if (sc) then
		up = sc.UpAdjust
		right = sc.RightAdjust
		forward = sc.ForwardAdjust
	end
	local ang = ent:GetAngles()
	local pos = ent:GetPos() + (ang:Forward()*(PCMod.Cam.LockDistance+forward)) + (ang:Up()*up) + (ang:Right()*right)
	return { pos, (ang:Forward()*-1):Angle() }
end

// ---------------------------------------------------------------------------------------------------------
// Retrieve - Retrieves an origin & angle
// ---------------------------------------------------------------------------------------------------------
function PCMod.Cam.Retrieve( id, origin, angles, ent )
	local st = PCMod.Cam[ id ]
	if ((st) && (st == PC_CAM_ENT)) then
		local ent = ents.GetByIndex( PCMod.Cam.EntID )
		if ((ent) && (ent:IsValid())) then
			return PCMod.Cam.CalcEntView( ent )
		end
	end
	return { origin, angles }
end

// ---------------------------------------------------------------------------------------------------------
// CheckLockState - Submits the lock state to the server
// ---------------------------------------------------------------------------------------------------------
function PCMod.Cam.CheckLockState()
	if (PCMod.Cam.PC_Locked != PCMod.Cam.Old_Locked) then
		RunConsoleCommand( "pc_locked", PCMod.Cam.PC_Locked )
	end
	PCMod.Cam.Old_Locked = PCMod.Cam.PC_Locked
end
hook.Add( "Think", "PCMod.Cam.CheckLockState", PCMod.Cam.CheckLockState )

// ---------------------------------------------------------------------------------------------------------
// Trigger - Triggers the camera moving
// ---------------------------------------------------------------------------------------------------------
function PCMod.Cam.Trigger( id, entid )
	if (id == "lock") then
		PCMod.Cam.A = PC_CAM_PLY
		PCMod.Cam.B = PC_CAM_ENT
		PCMod.Cam.ST = CurTime()
		PCMod.Cam.State = PC_CAM_MOVING
		PCMod.Cam.EntID = entid
	end
	if (id == "unlock") then
		PCMod.Cam.A = PC_CAM_ENT
		PCMod.Cam.B = PC_CAM_PLY
		PCMod.Cam.ST = CurTime()
		PCMod.Cam.State = PC_CAM_MOVING
	end
end

// ---------------------------------------------------------------------------------------------------------
// CalcView - Calculates the camera viewpoint
// ---------------------------------------------------------------------------------------------------------
function PCMod.Cam.CalcView( ply, origin, angles, fov )
	
	// Get our state, check for idle
	local state = PCMod.Cam.State
	if (state == PC_CAM_IDLE) then
		PCMod.Cam.PC_Locked = 0
		return
	end
	
	// Check for locked
	if (state == PC_CAM_LOCKED) then
		// Get the entity
		local ent = ents.GetByIndex( PCMod.Cam.EntID )
		if ((!ent) || (!ent:IsValid())) then
			// No entity, reset to idle
			PCMod.Cam.PC_Locked = 0
			PCMod.Cam.State = PC_CAM_IDLE
			return
		end
		
		// Determine our position
		local p = PCMod.Cam.CalcEntView( ent )
		
		// Setup the view
		local view = {}
		view.fov = fov
		view.vm_origin = origin
		view.vm_angles = angles
		view.origin = p[1]
		view.angles = p[2]
		
		// Return the view
		PCMod.Cam.PC_Locked = 1
		return view
	end
	
	// Check for moving
	if (state == PC_CAM_MOVING) then
		// Get the entity
		local ent = ents.GetByIndex( PCMod.Cam.EntID )
		if ((!ent) || (!ent:IsValid())) then
			// No entity, reset to idle
			PCMod.Cam.PC_Locked = 0
			PCMod.Cam.State = PC_CAM_IDLE
			return
		end
		
		// Get our time checkpoints
		local stime = PCMod.Cam.ST
		local diff = CurTime() - stime
		local smooth = PCMod.Cfg.CamLockSmoothTime
		local dec = diff/smooth
		
		// Determine if we have finished
		if ((dec == 1) || (dec > 1)) then
			// We are finished! Reset to our target
			if (PCMod.Cam.B == PC_CAM_ENT) then
				// We have finished locking, reset to ENTITY
				PCMod.Cam.State = PC_CAM_LOCKED
				PCMod.Cam.PC_Locked = 1
				return PCMod.Cam.CalcView( ply, origin, angles, fov )
			else
				// We have finished unlocking, reset to PLAYER
				PCMod.Cam.State = PC_CAM_IDLE
				PCMod.Cam.PC_Locked = 0
				return
			end
		end
		
		// Get our start and endpoints
		local st = PCMod.Cam.Retrieve( "A", origin, angles, ent )
		local ed = PCMod.Cam.Retrieve( "B", origin, angles, ent )
		
		// Calculate the mid-points
		local mid = {}
		mid[1] = math.Mid( st[1], ed[1], dec )
		mid[2] = math.MidAngle( st[2], ed[2], dec )
		
		// Setup the view
		local view = {}
		view.fov = fov
		view.vm_origin = origin
		view.vm_angles = angles
		view.origin = mid[1]
		view.angles = mid[2]
		
		// Return the view
		if (PCMod.Cam.A == PC_CAM_ENT) then
			PCMod.Cam.PC_Locked = PCMod.BTN( dec < 0.5 )
		else
			PCMod.Cam.PC_Locked = PCMod.BTN( dec > 0.5 )
		end
		return view
	end
	
	// Unknown state, reset to idle
	PCMod.Cam.State = PC_CAM_IDLE
	PCMod.Cam.PC_Locked = 0
	return
end
hook.Add( "CalcView", "PCMod.Cam.CalcView", PCMod.Cam.CalcView )