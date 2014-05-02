TOOL.Category		= "PCMod - Dev"
TOOL.Name			= "#SendPacket"
TOOL.Tab			= "PCMod 2"
TOOL.Command		= nil
TOOL.ConfigName		= ""

cleanup.Register( "SendPacket" )

if (CLIENT) then

	language.Add( 'Tool_pcsendpacket_name', 'SendPacket Tool' )
	language.Add( 'Tool_pcsendpacket_desc', 'Dev tool for sending test packets' )
	language.Add( 'Tool_pcsendpacket_0', 'Left-Click: Send it! (from target ent) Right-Click: Select target ent' )

end

TOOL.ClientConVar[ "port" ] = "265"
TOOL.ClientConVar[ "body" ] = "default_test"
TOOL.ClientConVar[ "filter" ] = "network"

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
	
	// The rest of the function is server-only stuff.
	if (CLIENT) then return true end

	local cl = trace.Entity:GetClass()

	if (!string.find( cl, "pcmod_" )) then
		PCMod.Notice( "Not a PCMod Object", ply )
		return false
	end

	if (!self.targetent) then
		PCMod.Notice( "Select a target first!", ply )
		return false
	end

	// Get some variables
	local ply = self:GetOwner()
	local dest1 = ( self.targetent )
	local port = ( self:GetClientInfo( "port" ) )
	local body = ( self:GetClientInfo( "body" ) )
	local filter = ( self:GetClientInfo( "filter" ) )
	local ent = trace.Entity

	if (filter == "network") then
		dest = dest1:GetFullIP()
	else
		dest = dest1:GetFullBIP()
	end

	// Get the port	
	if (#ent:Ports()==0) then
		PCMod.Notice( "That entity has no ports!", ply )
		return false
	end
	if (!ply.SelPort) then
		PC_BeamPorts( ent, ply )
		timer.Create( "AskForPort_" .. ply:Nick(), 0.1, 1, function()
			ply:SendLua( "PCMod.Gui.AskForPort( " .. tostring( ent:EntIndex() ) .. ", filter, true );" )
		end )
		return true
	end

	// Send the packet!
	local result = trace.Entity:SendPacket( ply.SelPort, dest, port, body )

	PCMod.Notice( "Packet create responded with "..result.."!", ply )
	PCMod.Notice( "Check your console for the packets trace", ply )
	
	// This was successful!
	return true
end

function TOOL:RightClick( trace )

	// If the target is a player, stop here.
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	// The rest of the function is server-only stuff.
	if (CLIENT) then return true end

	local cl = trace.Entity:GetClass()

	if (!string.find( cl, "pcmod_" )) then
		PCMod.Notice( "Not a PCMod Object", ply )
		return false
	end

	self.targetent = trace.Entity

	return true
end

if (SERVER) then

	function MakeEnt( pl, ent, Ang, Pos )
	
		// Create the entity and stop here if it isn't valid
		local aent = ents.Create( ent )
		if (!aent:IsValid()) then return false end

		// Set it's angles and position, and spawn it
		aent:SetAngles( Ang )
		aent:SetPos( Pos )
		aent:Spawn()

		
		// Make the effect
		DoPropSpawnedEffect( aent )

		// Return the entity
		return aent
		
	end

end

function TOOL:Flush()
	local ply = self:GetOwner()
	ply.SelPort = nil
	self:ClearObjects()
end

function TOOL:Holster()
	self:Flush()
end

function TOOL:Deploy()
	self:Flush()
end


function TOOL.BuildCPanel( CPanel )

	// Header
	CPanel:AddControl( "Header", { Text = "#Tool_pcsendpacket_name", Description	= "#Tool_pcsendpacket_desc" }  )
	
	// ent select
	combobox = {}
	combobox.Label = "Outgoing Port Type"
	combobox.MenuButton = 0
	combobox.Options = {}
	combobox.Options[ "network" ] = {pcsendpacket_filter = "network"}
	combobox.Options[ "optic" ] = {pcsendpacket_filter = "optic"}
	
	CPanel:AddControl("ComboBox", combobox)

	CPanel:AddControl("TextBox", {
		Label = "Dest Port (for program):",
		MaxLength = 5,
		Command = "pcsendpacket_port"
	})

	CPanel:AddControl("TextBox", {
		Label = "Body:",
		MaxLength = 255,
		Command = "pcsendpacket_body"
	})

end