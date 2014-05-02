
// ---------------------------------------------------------------------------------------------------------
// pcmod_keyboard
// Keyboard entity - for servers and PCs
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "Keyboard"
ENT.Class = "pcmod_keyboard"

ENT.ItemModel = "models/props_c17/computer01_keyboard.mdl"

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup( setupdata )
	if (!setupdata) then setupdata = {} end -- Ensure we have setup data
	local dt = self:Data() -- Get our data
	
	self:AddEHook( "ent", nil, "keypress" )
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "ps2" ) )
	dt.Ports = pts
	
	// Update us
	self:UpdateData( dt )
end

function ENT:DataRecieved( port, data )
	if (!data) then return end
	if (data[1] == "keyboard_req") then
		PCMod.Msg( "Keyboard Lock Request Activated!", true )
		PCMod.Beam.LockKeyboard( data[2], self:EntIndex() )
	end
end

function ENT:CallEvent( data )
	if (data.Event == "keypress") then
		PCMod.Msg( "Registered keypress! (" .. data[1] .. ")", true )
	end
end