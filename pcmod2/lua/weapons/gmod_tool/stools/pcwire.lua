
TOOL.Category		= "PCMod - Wiring"
TOOL.Name			= "#Wire Tool"
TOOL.Tab			= "PCMod 2"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if (!ToolOnly) then cleanup.Register( "computers" ) end

if ((CLIENT) && (!ToolOnly)) then

	language.Add( 'Tool_pcwire_name', 'Wire Tool' )
	language.Add( 'Tool_pcwire_desc', 'Wires together two ports on a device' )
	language.Add( 'Tool_pcwire_0', 'Left-Click: Select the primary device. Right-Click: Reset tool.' )
	language.Add( 'Tool_pcwire_1', 'Left-Click: Select another device to connect to. Right-Click: Reset tool. Reload: Attach to cable tie.' )

end

TOOL.ClientConVar[ "material" ] = "cable/rope"
TOOL.ClientConVar[ "width" ] = "2"

TOOL.RopeTable = {}

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
		self:GetOwner():SetEyeAngles( (ent:GetPos() - self:GetOwner():GetShootPos()):Angle() )
	end
	local wep = self:GetOwner():GetActiveWeapon()
	if (wep) then
		self:GetOwner().SelPort = portid
		wep:PrimaryAttack()
	end
end

function TOOL:LeftClick( trace )

	// If the target is a player, stop here.
	if ( trace.Entity && trace.Entity:IsPlayer() ) then
		self:Flush()
		return false
	end
	
	// If there is no physics object, stop here.
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then
		self:Flush()
		return false
	end
	
	// Clients can stop here
	local iNum = self:NumObjects()
	if ( CLIENT ) then
		if ( iNum > 0 ) then self:ClearObjects() end
		return true
	end
	
	// If there is no entity, stop here
	if ((!trace.Entity) || (!trace.Entity:IsValid()) || (!trace.Entity.IsPCMod)) then
		self:Flush()
		return false
	end
	
	// Get the player
	local ply = self:GetOwner()
	
	// Get our object data
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	local id = trace.Entity:EntIndex()
	local ent = trace.Entity
	
	// If we are looking for new connection:
	if (iNum == 0) then
		if (#ent:Ports()==0) then
			PCMod.Notice( "That entity has no ports!", ply )
			self:Flush()
			return false
		end
		if (!ply.SelPort) then
			PC_BeamPorts( ent, ply )
			timer.Create( "AskForPort_" .. ply:Nick(), 0.1, 1, function()
				// ply:SendLua( "PCMod.Gui.AskForPort( " .. tostring( ent:EntIndex() ) .. " );" )
				PC_AskForPort( ply, ent:EntIndex() )
			end )
			return true
		else
			self:SetObject( iNum + 1, ent, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
			self:AddRopeTarget( trace )
			ent:SetColor( 200, 200, 255, 150 )
			local prt = ply.SelPort
			ply.SelPort = nil
			if ((!ent:Ports()[ prt ]) || (ent:Ports()[ prt ].Connected)) then
				PCMod.Notice( "Invalid port!", ply )
				self:Flush()
				return false
			end
			ply.FirstSelPort = prt
			ply.FirstSelPortType = ent:Ports()[ prt ].Type
			self:SetStage( iNum + 1 )
			return true
		end
	end
	
	if (iNum == 1) then
		if (#ent:Ports()==0) then
			PCMod.Notice( "That entity has no ports!", ply )
			self:Flush()
			return false
		end
		if (!ply.SelPort) then
			PC_BeamPorts( ent, ply )
			timer.Create( "AskForPort_" .. ply:Nick(), 0.1, 1, function()
				// ply:SendLua( "PCMod.Gui.AskForPort( " .. tostring( ent:EntIndex() ) .. ", \"" .. ply.FirstSelPortType .. "\", false );" )
				PC_AskForPort( ply, ent:EntIndex(), ply.FirstSelPortType, false )
			end )
			return true
		else
			self:SetObject( iNum + 1, ent, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
			self:AddRopeTarget( trace )
			ent:SetColor( 200, 200, 255, 150 )
			local prt = ply.SelPort
			if ((!ent:Ports()[ prt ]) || (ent:Ports()[ prt ].Connected)) then
				PCMod.Notice( "Invalid port!", ply )
				self:Flush()
				return false
			end
			local ptype = ent:Ports()[ prt ].Type
			if (ptype != ply.FirstSelPortType) then
				PCMod.Notice( "Ports don't match!", ply )
				self:Flush()
				return false
			end
			if (self:GetEnt(1) == ent) then
				PCMod.Notice( "Cannot wire!", ply )
				self:Flush()
				return false
			end
			if ((self:GetEnt(1).Class == ent.Class) && (!ent:Ports()[ prt ].CanWireSameType)) then
				PCMod.Notice( "Cannot wire!", ply )
				self:Flush()
				return false
			end
		end
	end
	

	// Setup our variables
	local forcelimit = 0
	local addlength = 100
	local material = self:GetClientInfo( "material" )
	local width = self:GetClientNumber( "width" ) 
	local rigid	= false
	
	// Get information we're about to use
	local Ent1,  Ent2  = self:GetEnt(1),	 self:GetEnt(2)
	local Port1, Port2 = ply.FirstSelPort,      ply.SelPort
	local Bone1, Bone2 = self:GetBone(1),	 self:GetBone(2)
	local WPos1, WPos2 = self:GetPos(1),	 self:GetPos(2)
	local LPos1, LPos2 = self:GetLocalPos(1),self:GetLocalPos(2)
	local length = ( WPos1 - WPos2):Length()
	
	// Check that both entities aren't the same ent
	if (Ent1 == Ent2) then
		// Nono!
		PCMod.Notice( "You can't link an entity to itself!", ply )
		self:Flush()
		return false
	end

	// Create the rope(s)
	// local const, rope = constraint.Rope( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, length+addlength, 0, forcelimit, width, material, rigid )
	self:AddCableTieData( Ent1, Port1, Ent2, Port2 )
	local cties = self:GetRopeTableTargetList()
	local rps = self:RopeTheTable( width, material, addlength )
	
	// Link the entities
	PCMod.Msg( "Linking now!", true )
	PCMod.Wiring.LinkPorts( Ent1, Port1, Ent2, Port2, rps, cties )
	
	// Flush us
	self:Flush()
	
	// This was successful!
	return true
end

function TOOL:AddRopeTarget( trace )
	local rdata = {}
	local ent = trace.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	rdata.Entity = ent
	rdata.Bone = trace.PhysicsBone
	rdata.LPos = ent:WorldToLocal( trace.HitPos )
	table.insert( self.RopeTable, rdata )	
end

function TOOL:AddCableTieData( ent1, port1, ent2, port2 )
	for _, v in pairs( self.RopeTable ) do
		local ent = v.Entity
		if ((ent) && (ent:IsValid()) && (ent.IsCableTie)) then
			local tmp = {}
			tmp.EntA = ent1
			tmp.EntB = ent2
			tmp.PortA = port1
			tmp.PortB = port2
			table.insert( ent.LinkedPorts, tmp )
		end
	end
end

function TOOL:FlushRopeTargets()
	for _, v in pairs( self.RopeTable ) do
		local ent = v.Entity
		if ((ent) && (ent:IsValid())) then ent:SetColor( 255, 255, 255, 255 ) end
	end
end

function TOOL:GetRopeTableTargetList()
	local tmp = {}
	for _, v in pairs( self.RopeTable ) do
		local ent = v.Entity
		if ((ent) && (ent:IsValid()) && (ent.IsCableTie)) then
			table.insert( tmp, v.Entity )
		end
	end
	return tmp
end

function TOOL:RopeTheTable( width, material, addlength )
	local rs = self.RopeTable
	if (!rs) then return {} end
	if (#rs == 0) then return {} end
	if (#rs == 1) then return {} end
	local cnt
	local rps = {}
	self:FlushRopeTargets()
	for cnt=1, (#rs-1) do
		local a = rs[ cnt ]
		local b = rs[ cnt+1 ]
		if ((a) && (b)) then
			local const, rope = constraint.Rope( a.Entity, b.Entity, 0, 0, a.LPos, b.LPos, (a.Entity:GetPos() - b.Entity:GetPos()):Length()+addlength, 0, 0, width, material, false )
			table.insert( rps, { const, rope } )
		end
	end
	self.RopeTable = {}
	return rps
end

function TOOL:Reload( trace )
	// If the target is a player, stop here.
	if ( trace.Entity && trace.Entity:IsPlayer() ) then
		return false
	end
	
	// If there is no physics object, stop here.
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then
		return false
	end
	
	// Clients can stop here
	local iNum = self:NumObjects()
	if ( CLIENT ) then return true end
	
	// If there is no entity, stop here
	if ((!trace.Entity) || (!trace.Entity:IsValid()) || (!trace.Entity.IsCableTie)) then return false end
	
	// Get the player
	local ply = self:GetOwner()
	
	// Get our object data
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	local id = trace.Entity:EntIndex()
	local ent = trace.Entity
	
	// If we are looking for new connection then stop
	if (iNum == 0) then return end
	
	// Add rope data
	local rdata = {}
	rdata.Entity = ent
	rdata.Bone = trace.PhysicsBone
	rdata.LPos = ent:WorldToLocal( trace.HitPos )
	table.insert( self.RopeTable, rdata )
	ent:SetColor( 200, 200, 255, 150 )
	
	// Return yes
	return true
end

function TOOL:Flush()
	local ply = self:GetOwner()
	local Ent1,  Ent2  = self:GetEnt(1),	 self:GetEnt(2)
	if ((Ent1) && (Ent1:IsValid())) then Ent1:SetColor( 255, 255, 255, 255 ) end
	if ((Ent2) && (Ent2:IsValid())) then Ent2:SetColor( 255, 255, 255, 255 ) end
	ply.FirstSelPort = nil
	ply.SelPort = nil
	self:ClearObjects()
	self:FlushRopeTargets()
	self.RopeTable = {}
end

function TOOL:Holster()
	self:Flush()
end

function TOOL:Deploy()
	self:Flush()
end

function TOOL:RightClick( trace )
	
	self:Flush()
	return false

end

function TOOL.BuildCPanel( CPanel )

	// Header
	CPanel:AddControl( "Header", { Text = "#Tool_pcwire_name", Description	= "#Tool_pcwire_desc" }  )
	
	// Rope Width
	CPanel:AddControl( "Slider", {
		Label = "Width:",
		Type = "Float",
		Min = "0",
		Max = "5",
		Command = "pcwire_width"
	})
	
	// Material Selection
	CPanel:AddControl( "MatSelect", { 
			Height = "1", 
			Label = "Material:", 
			ItemWidth = 24, 
			ItemHeight = 64, 
			ConVar = "pcwire_material", 
			Options = list.Get( "WireMaterials" ) 
		} )

end