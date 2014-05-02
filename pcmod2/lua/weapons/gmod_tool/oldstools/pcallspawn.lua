/*TOOL.Category		= "PCMod - Dev"
TOOL.Name			= "#AllSpawn"
TOOL.Tab			= "PCMod 2"
TOOL.Command		= nil
TOOL.ConfigName		= ""

cleanup.Register( "AllSpawn" )

if (CLIENT) then

	language.Add( 'Tool_pcallspawn_name', 'AllSpawn Tool' )
	language.Add( 'Tool_pcallspawn_desc', 'Dev tool for spawning all PCMod entities' )
	language.Add( 'Tool_pcallspawn_0', 'Left-Click: Spawn it!' )

	language.Add( 'Undone_AllSpawn', 'AllSpawn Undone' )
	language.Add( 'Cleanup_AllSpawn', 'AllSpawn' )
	language.Add( 'Cleaned_AllSpawn', 'Cleaned up all AllSpawns' )

end

TOOL.ClientConVar[ "centity" ] = "pcmod_keyboard"


function TOOL:LeftClick( trace )

	// If the target is a player, stop here.
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	// The rest of the function is server-only stuff.
	if (CLIENT) then return true end
	
	// Get some variables
	local ply = self:GetOwner()
	local enttype = ( self:GetClientInfo( "centity" ) )
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	local Pos = trace.HitPos

	// Make the entity
	local ent = MakeEnt( ply, enttype, Ang, Pos )
	
	// If the entity does not exist, end here
	if (!ent) then return false end
	
	// With thanks to WireMod team :P
	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	
	// Add this to the undo list
	undo.Create("AllSpawn")
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish()
	
	// Add this to the cleanup list
	ply:AddCleanup( "AllSpawn", ent )
	
	// This was successful!
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

		//call pcmod setup on ent
		aent:Setup()

		
		// Make the effect
		DoPropSpawnedEffect( aent )

		// Return the entity
		return aent
		
	end

end

function TOOL:Flush()
	local ply = self:GetOwner()
	local Ent1,  Ent2  = self:GetEnt(1),	 self:GetEnt(2)
	if ((Ent1) && (Ent1:IsValid())) then Ent1:SetColor( 255, 255, 255, 255 ) end
	if ((Ent2) && (Ent1:IsValid())) then Ent2:SetColor( 255, 255, 255, 255 ) end
	ply.FirstSelPort = nil
	ply.SelPort = nil
	self:ClearObjects()
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

function TOOL:UpdateGhost( ent, player )

	if ( !ent || !ent:IsValid() ) then return end

	local tr 	= utilx.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )
	
	if (!trace.Hit || trace.Entity:IsPlayer() || string.find( trace.Entity:GetClass(), "pcmod_" )) then
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
	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo( "centity" )) then
		self:MakeGhostEntity( self:GetClientInfo( "centity" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhost( self.GhostEntity, self:GetOwner() )
end

function TOOL.BuildCPanel( CPanel )

	local files = file.FindInLua( "entities/pcmod_*" )

	// Header
	CPanel:AddControl( "Header", { Text = "#Tool_pcallspawn_name", Description	= "#Tool_pcallspawn_desc" }  )
	
	// ent select
	combobox = {}
	combobox.Label = "Entity"
	combobox.MenuButton = 0
	combobox.Options = {}
	
	for k, v in pairs( files ) do
		if (!string.find( v, "base" )) then
			combobox.Options[ v ] = {pcallspawn_centity = v}
		end
	end
	
	
	CPanel:AddControl("ComboBox", combobox)

end

--------------------------[ new stool ]----------------------*/

if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Allspawn"
TOOL.Class = "pcallspawn"
TOOL.Desc = "Dev tool to spawn any pcmod entity"
TOOL.Inst = {
	{ "Spawn entity" }
}

TOOL.Type = "spawner"
TOOL.SpawnType = "HDev"

TOOL.EntName = "Allspawn"
TOOL.EntClass = "pcallspawn"
TOOL.DefaultMax = 99999
TOOL.Model = ""

TOOL.ModelList = { "models/props_c17/computer01_keyboard.mdl" }

local dat = PCTool.RegisterSTool( TOOL )
table.Merge( TOOL, dat )

TOOL.ClientConVar[ "centity" ] = "pcmod_keyboard"

if (SERVER) then

	function TOOL:BuildSetupData()
		local tmp = {}
		return tmp
	end

	function TOOL:LeftClick( trace )

		local enttype = self:GetClientInfo( "centity" )

		// Validate the target
		if ((trace.Entity) && ((trace.Entity:IsPlayer()) || (trace.Entity:GetClass()==enttype))) then return false end
				
		// Get some variables
		local ply = self:GetOwner()
		local ang = trace.HitNormal:Angle()
		ang.pitch = ang.pitch + 90
		local pos = trace.HitPos
		local model = self:GetClientInfo( "model" )
				
		// Build the setupdata
		local setupdata = self:BuildSetupData()
		// Make the entity
		local ent = PCTool.SpawnEntity( ply, model, pos, ang, enttype, nil, setupdata )
				
		// If the entity does not exist, end here
		if (!ent) then return false end
				
		// With thanks to WireMod team :P
		local min = ent:OBBMins()
		ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
				
		// Add this to the undo list
		undo.Create( self.EntClass )
			undo.AddEntity( ent )
			undo.SetPlayer( ply )
		undo.Finish()
				
		// Add this to the cleanup list
		ply:AddCleanup( self.EntCID, ent )
				
		// This was successful!
		return true
	end

end

if (CLIENT) then

	function TOOL.BuildCPanel( panel )
		// local pf = "Tool_pcspawn_tower_"
	
		// Header
		// panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		local files = file.Find( "entities/pcmod_*", "LUA")

		// Header
		panel:AddControl( "Header", { Text = "#Tool_pcallspawn_name", Description	= "#Tool_pcallspawn_desc" }  )
	
		// ent select
		combobox = {}
		combobox.Label = "Entity"
		combobox.MenuButton = 0
		combobox.Options = {}
	
		for k, v in pairs( files ) do
			if (v != "pcmod_base") then
				combobox.Options[ v ] = {pcallspawn_centity = v,}
				local data = file.Read("entities/"..v.."/shared.lua", "LUA")
				local pos1 = string.find(data, "ENT.ItemModel")
				local pos2 = string.find(data, "\"", pos1)
				local pos3 = string.find(data, "\"", pos2+1)
				local model = string.sub(data, pos2+1, pos3-1)
				combobox.Options[ v ] = {pcallspawn_centity = v,pcallspawn_model = model}
			end
		end
	
	
		panel:AddControl("ComboBox", combobox)
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn