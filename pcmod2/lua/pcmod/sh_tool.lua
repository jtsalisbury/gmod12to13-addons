
// ---------------------------------------------------------------------------------------------------------
// sh_tool.lua - Revision 1
// Shared
// Loads toolgun utilities
// ---------------------------------------------------------------------------------------------------------

// ************************************************** \\
// * This file might be loaded BEFORE the core pcmod files! * \\
// ************************************************** \\

if (SERVER) then AddCSLuaFile( "pcmod/sh_tool.lua" ) end

// ---------------------------------------------------------------------------------------------------------
// Define core tables
// ---------------------------------------------------------------------------------------------------------

PCTool = {}
PCTool.Version = "1.0.0"

Msg( "PCMod2: PCTool Library Loaded! (" .. PCTool.Version .. ")\n" )

// ---------------------------------------------------------------------------------------------------------
// GetCount - Gets the global amount of entities
// ---------------------------------------------------------------------------------------------------------
function PCTool.GetCount( class )
	return #ents.FindByClass( class )
end

if (SERVER) then

	// ---------------------------------------------------------------------------------------------------------
	// SetLimit - Sets a PCMod entity limit
	// ---------------------------------------------------------------------------------------------------------
	function PCTool.SetLimit( ply, com, args )
		if (!ply:IsSuperAdmin()) then
			ply:PrintMessage( HUD_PRINTTALK, "You must be a super-admin to change that!" )
			return
		end
		if (!args[1]) then return end
		if (!args[2]) then return end
		local ent = args[1]
		local val = args[2]
		local cv = "sbox_maxpcmod_" .. ent
		local old = server_settings.Int( cv, 0 )
		if (tonumber( val ) == old) then return end
		game.ConsoleCommand( cv .. " " .. val .. "\n" )
		PCMod.GMsg( "Maximum PCMod " .. ent .. " changed to '" .. val .. "'!" )
	end
	concommand.Add( "pc_setlimit", PCTool.SetLimit )
	
	// ---------------------------------------------------------------------------------------------------------
	// GetCnt - Tells the player the entity count
	// ---------------------------------------------------------------------------------------------------------
	function PCTool.GetCnt( ply, com, args )
		local class = args[1]
		if (!class) then
			ply:PrintMessage( HUD_PRINTTALK, "There are " .. tostring( PCTool.GetCount( "pcmod_*" ) ) .. " pcmod entities in total!" )
		else
			ply:PrintMessage( HUD_PRINTTALK, "There are " .. tostring( PCTool.GetCount( class ) ) .. " " .. class .. "s in total!" )
		end
	end
	concommand.Add( "pc_getcnt", PCTool.GetCnt )

	// ---------------------------------------------------------------------------------------------------------
	// SpawnEntity - Spawns a PCMod entity
	// ---------------------------------------------------------------------------------------------------------
	function PCTool.SpawnEntity( ply, model, pos, ang, entclass, harddrive, setupdata )
		PCMod.Msg( "Spawning entity: " .. model .. "," .. entclass, true )
		
		// Check the global limit
		if (PCTool.GetCount( entclass ) > 253) then return end
	
		// Check the limit
		if (!ply:CheckLimit( entclass .. "s" )) then return end
		
		// Create the entity
		local ent = ents.Create( entclass )
		if ((!ent) || (!ent:IsValid())) then return end
		
		// Position and spawn
		ent:SetPos( pos )
		ent:SetAngles( ang )
		ent:Spawn()
		ent:Activate()
		
		// Set it up
		ent:Setup( setupdata )
		ent:SetPlayer( ply )
		ent:ChangeModel( model )
		
		// Do the effect
		DoPropSpawnedEffect( ent )
		
		ply:AddCount( entclass .. "s", ent )
		ply:AddCleanup( entclass .. "s", ent )
		
		PCMod.Msg( "Returning spawned entity! (" .. ent:GetClass() .. ")", true )
		
		return ent
	end
	
end
	
// ---------------------------------------------------------------------------------------------------------
// RegisterSTool - Adds all the core functions and stuff to a STool
// ---------------------------------------------------------------------------------------------------------
function PCTool.RegisterSTool( TOOL )

	TOOL.Tab = "PCMod 2"
	TOOL.Command = nil
	TOOL.ConfigName = ""
	TOOL.Category = "PCMod - " .. TOOL.SpawnType
	
	if (TOOL.Type == "spawner") then
	
		TOOL.ClientConVar[ "model" ] = TOOL.ModelList[1]
		
		TOOL.EntCID = TOOL.EntClass .. "s"
		cleanup.Register( TOOL.EntCID )
		
		function TOOL:Think()
			if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo( "model" )) then
				self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
			end
			self:UpdateGhost( self.GhostEntity, self:GetOwner() )
		end
	
		function TOOL:UpdateGhost( ent, ply )

			if ( !ent || !ent:IsValid() ) then return end

			local tr 	= util.GetPlayerTrace( ply, ply:GetAimVector() )
			local trace 	= util.TraceLine( tr )
			
			if (!trace.Hit || trace.Entity:IsPlayer() || trace.Entity:GetClass() == self.EntClass ) then
				ent:SetNoDraw( true )
				return
			end
			
			local Ang = trace.HitNormal:Angle()
			Ang.pitch = Ang.pitch + 90
			ent:SetAngles( Ang )	

			local min = ent:OBBMins()
			ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
			
			ent:SetNoDraw( false )

		end	
	
		if (CLIENT) then
		
			local pf = "Tool_" .. TOOL.Class .. "_"
			language.Add( pf .. "name", TOOL.Name )
			language.Add( pf .. "desc", TOOL.Desc .. " (PCMod)" )
			for k, v in pairs( TOOL.Inst ) do
				local s = ""
				if (v[1]) then s = s .. "Primary: " .. v[1] end
				if (v[2]) then s = s .. "   Secondary: " .. v[2] end
				if (v[3]) then s = s .. "   Reload: " .. v[3] end
				language.Add( pf .. tostring( k-1 ), s )
			end
				
			language.Add( "sboxlimit_" .. TOOL.EntCID, "You've hit the " .. TOOL.EntName .. " limit!" )
			language.Add( "undone_" .. TOOL.EntClass, "Undone " .. TOOL.EntName )
			
			language.Add( "Cleanup_" .. TOOL.EntCID, TOOL.EntName )
			language.Add( "cleaned_" .. TOOL.EntClass, "Cleaned up all " .. string.lower( TOOL.EntName ) .. "s!" )
			
			// Now, this is awkward because BuildCPanel must be defined using dot notation (x.y) not using colon notation (x:y).
			// When using dot notation, using self won't work because self is only define using colon notation.
			// So, the BuildCPanel function is defined the STool itself.
			
			for _, v in pairs( TOOL.ModelList ) do
				list.Set( "mdls_" .. TOOL.Class, v, {} )
			end
			
			function TOOL:LeftClick( trace )
				if ((trace.Entity) && ((trace.Entity:IsPlayer()) || (trace.Entity:GetClass()==self.EntClass))) then return false end
				return true
			end
			
			function TOOL:RightClick( trace )
				return false
			end
			
			function TOOL:Reload( trace )
				return false
			end
		
		end
		
		CreateConVar( "sbox_max" .. TOOL.EntCID, TOOL.DefaultMax, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY } )
		
		if (SERVER) then
		
			function TOOL:LeftClick( trace )
				// Validate the target
				if ((trace.Entity) && ((trace.Entity:IsPlayer()) || (trace.Entity:GetClass()==self.EntClass))) then return false end
				
				// Get some variables
				local ply = self:GetOwner()
				local ang = trace.HitNormal:Angle()
				ang.pitch = ang.pitch + 90
				local pos = trace.HitPos
				local model = self:GetClientInfo( "model" )
				
				// Build the setupdata
				local setupdata = self:BuildSetupData()

				// Make the entity
				local ent = PCTool.SpawnEntity( ply, model, pos, ang, self.EntClass, nil, setupdata )
				
				// If the entity does not exist, end here
				if ((!ent) || (!ent:IsValid())) then return false end
				
				// With thanks to WireMod team :P
				local min = ent:OBBMins()
				ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
				
				// Add this to the undo list
				undo.Create( self.EntClass )
					undo.AddEntity( ent )
					undo.SetPlayer( ply )
				undo.Finish()
				
				// This was successful!
				return true
			end
			
			duplicator.RegisterEntityClass( TOOL.EntClass, PCTool.SpawnEntity, "Model", "Pos", "Ang", "Class", "harddrive" )
		
		end
		
	end
	
	
	return TOOL
end