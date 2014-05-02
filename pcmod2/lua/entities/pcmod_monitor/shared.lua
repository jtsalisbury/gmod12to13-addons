
// ---------------------------------------------------------------------------------------------------------
// pcmod_monitor
// Monitor entity - for servers and PCs
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "Monitor"
ENT.Class = "pcmod_monitor"

ENT.ItemModel = "models/props_lab/monitor01a.mdl"

ENT.IsScreen = true

ENT.AlwaysOn = true

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup( setupdata )
	if (!setupdata) then setupdata = {} end -- Ensure we have setup data
	local dt = self:Data() -- Get our data
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "vga" ) )
	dt.Ports = pts
	
	// Hook our events
	self.Entity:AddEHook( "ent", nil, "unlinked" )
	self.Entity:AddEHook( "ent", nil, "use" )
	self.Entity:AddEHook( "ent", nil, "user_input" )
	
	// Update us
	self:UpdateData( dt )
end

function ENT:DataRecieved( port, data )
	local pt = self:Ports()[ port ]
	if (!pt) then return end
	if (pt.Type == "vga") then
		PCMod.Msg( "Monitor recieved message!", true )
		if (data[1] == "display") then
			local oldss = self:ScreenSpace()
			oldss.Data = data[2]
			self:UpdateScreenSpace( oldss )
			// PCMod.Msg( "Printing Monitor SS...", true )
			// PrintTable( data[2] )
		end
	end
end

function ENT:CallEvent( data )
	if (data.Event == "use") then
		local ply = data[1]
		if ((!ply) || (!ply:IsValid()) || (!ply:IsPlayer())) then return end
		PCMod.Msg( "Locking player cam...", true )
		PCMod.Beam.LockCam( self:EntIndex(), ply )
		PCMod.Msg( "Sending 'locked' event!", true )
		local res = self:PushData( self:Ports()[ 1 ], { "player_locked", ply } ) -- We are assuming our VGA port is port no 1
	end
	if (data.Event == "user_input" ) then
		local ply = data[1]
		local args = data[2]
		PCMod.Msg( "Sending 'input' event!", true )
		local res = self:PushData( self:Ports()[ 1 ], { "player_input", ply, args } )
	end
	if (data.Event == "unlinked") then
		local oldss = self:ScreenSpace()
		oldss:ClearAll()
		oldss:DisableCursor()
		self:UpdateScreenSpace( oldss )
	end
end