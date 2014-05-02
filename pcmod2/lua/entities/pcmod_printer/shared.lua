
// ---------------------------------------------------------------------------------------------------------
// pcmod_printer
// Printer entity - it prints stuff. (No, honest)
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "pcmod_base"
ENT.PrintName = "Printer"
ENT.Class = "pcmod_printer"

ENT.ItemModel = "models/props_lab/plotter.mdl"

ENT.AlwaysOn = true

ENT.PrintTime = 5

if (SERVER) then AddCSLuaFile( "shared.lua" ) end

function ENT:Setup()
	local dt = self:Data() -- Get our data
	
	// Hook in our events
	self:AddEHook( "ent", nil, "linked" )
	self:AddEHook( "ent", nil, "unlinked" )
	
	// Create our ports
	local pts = {}
	table.insert( pts, self:CreatePort( "usb" ) )
	dt.Ports = pts
	
	// Update us
	self:SetGVar( "printing", 0 )
	self:UpdateData( dt )
end

function ENT:DataRecieved( port, data )
	local prt = self:Ports()[ port ]
	if (!prt) then return end
	if (prt.Type == "usb") then
		PCMod.Msg( "Printer recieved '" .. data[1] .. "' through USB port!", true )
		// Generic USB stuff
		if (data[1] == "getdeviceinfo") then
			local dat = { "deviceinfo", "printer", "Standard Printer" }
			self.Entity:PushData( prt, dat )
			
		end
		// Printer stuff
		if (data[1] == "print_doc") then
			if (!self:Data().Printing) then
				self:PrintDocument( data[2] )
			end
		end
		if (data[2] == "getstatus") then
			if (self:Data().Printing) then
				local dat = { "status", "Printing" }
				self.Entity:PushData( prt, dat )
			else
				local dat = { "status", "Idle" }
				self.Entity:PushData( prt, dat )
			end
		end
	end
end

function ENT:PrintDocument( text )
	if (CLIENT) then return end
	if (self:Data().Printing) then return end
	if (!text) then text = "" end
	PCMod.Msg( "Preparing to print...", true )
	local dt = self:Data()
	dt.Printing = true
	dt.PrintDoc = text
	dt.PrintEnd = CurTime() + PCMod.Cfg.PrintTime
	self:UpdateData( dt )
	self:SetGVar( "printing", 1 )
end

function ENT:CustomThink()
	local dt = self:Data()
	if (dt.Printing) then
		if (CurTime() > dt.PrintEnd) then
			PCMod.Msg( "Print complete!", true )
			dt.Printing = false
			local text = dt.PrintDoc
			dt.PrintDoc = ""
			dt.PrintEnd = 0
			self:SetGVar( "printing", 0 )
			local ent = self:SpawnDocument( text )
		end
	end
end

function ENT:SpawnDocument( text )
	local ent = ents.Create( "pcmod_document" )
	if ((!ent) || (!ent:IsValid())) then
		PCMod.Msg( "Failed to created document!", true )
		return
	end
	ent:Spawn()
	ent:SetPos( self:GetPos() + Vector( 0, 0, 32 ) )
	ent:SetAngles( self:GetAngles() )
	ent:SetDocument( text )
	ent:SetPlayer( self:GetOwner() )
	return ent
end

function ENT:DrawInfo( origin )
	local txt = { self.PrintName, "Not Printing" }
	if (self:GetGVar( "printing" ) == 1) then txt[2] = "Printing" end
	PCMod.Gui.DrawLabel( origin.x, origin.y, "ScoreboardText", txt, 10, Color( 50, 50, 50, 200 ), Color( 255, 255, 255, 255 ) )
end