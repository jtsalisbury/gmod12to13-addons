// ---------------------------------------------------------------------------------------------------------
// pcmod_splitter
// Splitter entity - connects minijack -> phono
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "Splitter"
ENT.Class = "pcmod_splitter"

ENT.ItemModel = "models/props_lab/tpplug.mdl"

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup( setupdata )
	if (!setupdata) then setupdata = {} end -- Ensure we have setup data
	local dt = self:Data() -- Get our data
	
	self:AddEHook( "ent", nil, "unlinked" )
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "minijack" ) )
	table.insert( pts, self:CreatePort( "phono" ) )
	table.insert( pts, self:CreatePort( "phono" ) )
	table.insert( pts, self:CreatePort( "phono" ) )
	dt.Ports = pts
	
	// Update us
	self:UpdateData( dt )
end

function ENT:DataRecieved( port, data )
	if (!data) then return end
	local pt = self:Ports()[ port ]
	if (!pt) then return end
	if (pt.Type == "minijack") then
		for k, v in pairs( self:Ports() ) do
			if (v.Type == "phono") then self:PushData( k, data ) end
		end
	end
end

function ENT:CallEvent( data )
	if (data.Event == "unlinked") then
		local pt = self:Ports()[ data[1] ]
		if (pt) then
			if (pt.Type == "minijack") then
				for k, v in pairs( self:Ports() ) do
					if (v.Type == "phono") then self:PushData( k, { "snd_stop" } ) end
				end
			end
		end
	end
end