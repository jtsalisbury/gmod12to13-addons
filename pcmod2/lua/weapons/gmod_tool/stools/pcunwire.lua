
TOOL.Category		= "PCMod - Wiring"
TOOL.Name			= "#Unwire Tool"
TOOL.Tab			= "PCMod 2"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if (!ToolOnly) then cleanup.Register( "computers" ) end

if ((CLIENT) && (!ToolOnly)) then

	language.Add( 'Tool_pcunwire_name', 'Unwire Tool' )
	language.Add( 'Tool_pcunwire_desc', 'Unconnects two ports.' )
	language.Add( 'Tool_pcunwire_0', 'Left-Click: Select the primary device.' )

end

function TOOL:SelectPort( entid, portid )
	if (!entid) then return end -- Arg 1
	if (!portid) then return end -- Arg 2
	local ent = ents.GetByIndex( entid )
	if (!ent) then return end -- Entity
	if (!ent.IsPCMod) then return end -- Valid entity
	local prt = ent:Ports()[ portid ]
	if (!prt) then return end -- Port
	PCMod.Msg( "Firing off toolgun...", true )
	local tr = self:GetOwner():GetEyeTrace()
	if (tr.Entity != ent) then
		self:GetOwner():SetEyeAngles( (ent:GetPos() - self:GetOwner():GetPos()):Normalize():Angle() )
	end
	local wep = self:GetOwner():GetActiveWeapon()
	if (wep) then
		self:GetOwner().SelPort = portid
		wep:PrimaryAttack()
	end
end

function TOOL:LeftClick( trace )

	// If the target is a player, stop here.
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	// If there is no physics object, stop here.
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	// Clients can stop here
	local iNum = self:NumObjects()
	if ( CLIENT ) then
		if ( iNum > 0 ) then self:ClearObjects() end
		return true
	end
	
	// If there is no entity, stop here
	if ((!trace.Entity) || (!trace.Entity:IsValid()) || (!trace.Entity.IsPCMod)) then return false end
	
	// Get the player
	local ply = self:GetOwner()
	
	// Get our object data
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	local id = trace.Entity:EntIndex()
	local ent = trace.Entity
	
	// Get the port	
	if (#ent:Ports()==0) then
		PCMod.Notice( "That entity has no ports!", ply )
		return false
	end
	if (!ply.SelPort) then
		PC_BeamPorts( ent, ply )
		timer.Create( "AskForPort_" .. ply:Nick(), 0.1, 1, function()
			// ply:SendLua( "PCMod.Gui.AskForPort( " .. tostring( ent:EntIndex() ) .. ", nil, true );" )
			PC_AskForPort( ply, ent:EntIndex(), nil, true )
		end )
		return true
	end
	
	// Unlink the entities
	PCMod.Msg( "Unlinking now!", true )
	PCMod.Wiring.UnlinkPort( ent, ply.SelPort )
	
	// Flush us
	self:Flush()
	
	// This was successful!
	return true
end

function TOOL:Flush()
	self:GetOwner().SelPort = nil
end

function TOOL:Holster()
	self:Flush()
end

function TOOL:Deploy()
	self:Flush()
end

function TOOL:RightClick( trace )
	
	// No soup for you
	return false

end

function TOOL.BuildCPanel( CPanel )

	// Header
	CPanel:AddControl( "Header", { Text = "#Tool_pcunwire_name", Description	= "#Tool_pcunwire_desc" }  )
	

end