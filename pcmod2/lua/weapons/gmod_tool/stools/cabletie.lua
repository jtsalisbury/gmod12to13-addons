
TOOL.Category		= "PCMod - Hardware"
TOOL.Name			= "#Cable Tie"
TOOL.Tab			= "PCMod 2"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "weld" ] = 1
TOOL.ClientConVar[ "model" ] = "models/props_c17/utilityconnecter006.mdl"

cleanup.Register( "cableties" )

if (CLIENT) then
	language.Add( 'Tool_cabletie_name', 'Cable Tie Spawner' )
	language.Add( 'Tool_cabletie_desc', 'Create cable ties (PCMod)' )
	language.Add( 'Tool_cabletie_0', 'Left-Click: Spawn a cable tie.' )
	
	language.Add( 'Undone_Cabletie', 'Cable Tie Undone' )
	language.Add( 'Cleanup_Cabletie', 'Cable Tie' )
	language.Add( 'Cleaned_Cabletie', 'Cleaned up all cable ties' )
end

function TOOL:LeftClick( trace )

	// If the target is a player, stop here.
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	// The rest of the function is server-only stuff.
	if (CLIENT) then return true end
	
	// Get some variables
	local ply = self:GetOwner()
	local weld = ( self:GetClientNumber( "weld" ) == 1 )
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	local Pos = trace.HitPos

	// Make the entity
	local ent = ents.Create( "pcmod_cabletie" )
	ent:Spawn()
	ent:SetPos( Pos )
	ent:SetAngles( Ang )
	// ent:ChangeModel( 
	local const
	
	// If the entity does not exist, end here
	if ((!ent) || (!ent:IsValid())) then return false end
	
	// Only weld if we want to
	if ( weld ) and ( trace.Entity ) and (!trace.HitWorld) then
		const = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0, collision == 0, true )
	end
	
	// With thanks to WireMod team :P
	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	
	// Add this to the undo list
	undo.Create( "Cabletie" )
		undo.AddEntity( ent )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()
	
	// Add this to the cleanup list
	ply:AddCleanup( "cableties", ent )
	ply:AddCleanup( "cableties", const )
	
	// This was successful!
	return true
end

function TOOL:UpdateGhost( ent, player )

	if ( !ent || !ent:IsValid() ) then return end

	local tr 	= util.GetPlayerTrace( player, player:GetAimVector() )
	local trace 	= util.TraceLine( tr )
	
	if (!trace.Hit || trace.Entity:IsPlayer() || trace.Entity:GetClass() == "pcmod_cabletie" ) then
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

function TOOL:Think()
	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo( "model" )) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhost( self.GhostEntity, self:GetOwner() )
end

function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool_cabletie_name", Description	= "#Tool_cabletie_desc" }  )

	// BODY
	CPanel:AddControl( "CheckBox", { Label = "#Weld",
									 Command = "cabletie_weld" } )
end