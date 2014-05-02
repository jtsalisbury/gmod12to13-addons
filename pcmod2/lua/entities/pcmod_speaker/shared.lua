// ---------------------------------------------------------------------------------------------------------
// pcmod_speaker
// Speaker entity - for any item with a minijack output
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "Speaker"
ENT.Class = "pcmod_speaker"

ENT.ItemModel = "models/props_junk/MetalBucket01a.mdl"

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup( setupdata )
	if (!setupdata) then setupdata = {} end -- Ensure we have setup data
	local dt = self:Data() -- Get our data
	
	self:AddEHook( "ent", nil, "unlinked" )
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "phono" ) )
	dt.Ports = pts
	
	// Update us
	self:UpdateData( dt )
end

function ENT:DataRecieved( port, data )
	if (!data) then return end
	if (data[1] == "snd_stop") then
		self:StopSounds()
	end
	if (data[1] == "snd_play") then
		self:PlaySound( data[2] )
	end
end

function ENT:CallEvent( data )
	if (data.Event == "unlinked") then
		self:StopSounds()
	end
end

function ENT:StopSounds()
	PCMod.Msg( "Speaker Stopping Sound!", true )
	if (PCMod.Data[ self.Entity:EntIndex() ].PSnd) then
		PCMod.Data[ self.Entity:EntIndex() ].PSnd:Stop()
	else
		PCMod.Msg( "No sound to stop!", true )
	end
	PCMod.Data[ self.Entity:EntIndex() ].PSnd = nil
	PCMod.Data[ self.Entity:EntIndex() ].PSndName = ""
end

function ENT:PlaySound( sndname )
	self:StopSounds()
	PCMod.Msg( "Speaker Playing Sound! (" .. sndname .. ")", true )
	PCMod.Data[ self.Entity:EntIndex() ].PSnd = CreateSound( self.Entity, Sound( sndname ) )
	PCMod.Data[ self.Entity:EntIndex() ].PSnd:Play()
	PCMod.Data[ self.Entity:EntIndex() ].PSndName = sndname
end